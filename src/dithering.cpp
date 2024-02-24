/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "abc2.h"
#include "dithering.h"

static const int kBits = 4;

void	ErrorDiffuseInt(ColorErrorI* buffer, int x, int y, int w, int h, const ColorErrorI& err, int coef)
{
	if (((unsigned int)x < (unsigned int)w) &&
		((unsigned int)y < (unsigned int)h))
	{
		buffer[y*w + x].r += err.r * coef;
		buffer[y*w + x].g += err.g * coef;
		buffer[y*w + x].b += err.b * coef;
	}
}

ColorErrorI	ReadErrorInt(const ColorErrorI& errorPrec, int prec)
{
	ColorErrorI rc = errorPrec;
	rc.r /= prec;
	rc.g /= prec;
	rc.b /= prec;
	return rc;
}

static int	GetDitheringPrec(Dithering_t dither)
{
	switch ( dither )
	{
		case Dithering_t::kFloyd:	return 32; break;
		case Dithering_t::kSierra:	return 32; break;
		case Dithering_t::kJarvis:	return 48; break;
		default: return 1; break;
	}
}

static void	DiffuseSierraInt(ColorErrorI* buffer, int x, int y, int w, int h, const ColorErrorI& err)
{
	ErrorDiffuseInt(buffer, x + 1, y + 0, w, h, err, 5);
	ErrorDiffuseInt(buffer, x + 2, y + 0, w, h, err, 3);
	ErrorDiffuseInt(buffer, x - 2, y + 1, w, h, err, 2);
	ErrorDiffuseInt(buffer, x - 1, y + 1, w, h, err, 4);
	ErrorDiffuseInt(buffer, x + 0, y + 1, w, h, err, 5);
	ErrorDiffuseInt(buffer, x + 1, y + 1, w, h, err, 4);
	ErrorDiffuseInt(buffer, x + 2, y + 1, w, h, err, 2);
	ErrorDiffuseInt(buffer, x - 1, y + 2, w, h, err, 2);
	ErrorDiffuseInt(buffer, x + 0, y + 2, w, h, err, 3);
	ErrorDiffuseInt(buffer, x + 1, y + 2, w, h, err, 2);
}

static void	DiffuseJarvisInt(ColorErrorI* buffer, int x, int y, int w, int h, const ColorErrorI& err)
{
	ErrorDiffuseInt(buffer, x + 1, y + 0, w, h, err, 7);
	ErrorDiffuseInt(buffer, x + 2, y + 0, w, h, err, 5);
	ErrorDiffuseInt(buffer, x - 2, y + 1, w, h, err, 3);
	ErrorDiffuseInt(buffer, x - 1, y + 1, w, h, err, 5);
	ErrorDiffuseInt(buffer, x + 0, y + 1, w, h, err, 7);
	ErrorDiffuseInt(buffer, x + 1, y + 1, w, h, err, 5);
	ErrorDiffuseInt(buffer, x + 2, y + 1, w, h, err, 3);
	ErrorDiffuseInt(buffer, x - 2, y + 2, w, h, err, 1);
	ErrorDiffuseInt(buffer, x - 1, y + 2, w, h, err, 3);
	ErrorDiffuseInt(buffer, x + 0, y + 2, w, h, err, 5);
	ErrorDiffuseInt(buffer, x + 1, y + 2, w, h, err, 3);
	ErrorDiffuseInt(buffer, x + 2, y + 2, w, h, err, 1);
}

static void	DiffuseFloydInt(ColorErrorI* buffer, int x, int y, int w, int h, const ColorErrorI& err)
{
	ErrorDiffuseInt(buffer, x + 1, y + 0, w, h, err, 7*2);
	ErrorDiffuseInt(buffer, x - 1, y + 1, w, h, err, 1*2);
	ErrorDiffuseInt(buffer, x + 0, y + 1, w, h, err, 5*2);
	ErrorDiffuseInt(buffer, x + 1, y + 1, w, h, err, 3*2);
}

// Split a 555 image into a twice height image, containing two 444 images
Color444*	Split555(const Color555* src, int w, int h)
{
	Color444* dst444 = (Color444*)malloc(w*(h * 2) * sizeof(Color444));
	Color444* outA = dst444;
	Color444* outB = outA + w*h;

	for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			int rA = src->r >> 1;
			int gA = src->g >> 1;
			int bA = src->b >> 1;
			int colL = (rA << 8) | (gA << 4) | bA;
			int rB = rA + (src->r & 1);
			int gB = gA + (src->g & 1);
			int bB = bA + (src->b & 1);
			if (rB > 15) rB = 15;
			if (gB > 15) gB = 15;
			if (bB > 15) bB = 15;
			int colH = (rB << 8) | (gB << 4) | bB;
			if ((x^y) & 1)
			{
				int tmp = colL;
				colL = colH;
				colH = tmp;
			}
			outA->SetRGB444(colL);
			outB->SetRGB444(colH);
			src++;
			outA++;
			outB++;
		}
	}
	return dst444;
}

static const   int sBayerTable[16][16] = {   //  16x16 Bayer Dithering Matrix.  Color levels: 256
	{     0, 191,  48, 239,  12, 203,  60, 251,   3, 194,  51, 242,  15, 206,  63, 254  },
	{   127,  64, 175, 112, 139,  76, 187, 124, 130,  67, 178, 115, 142,  79, 190, 127  },
	{    32, 223,  16, 207,  44, 235,  28, 219,  35, 226,  19, 210,  47, 238,  31, 222  },
	{   159,  96, 143,  80, 171, 108, 155,  92, 162,  99, 146,  83, 174, 111, 158,  95  },
	{     8, 199,  56, 247,   4, 195,  52, 243,  11, 202,  59, 250,   7, 198,  55, 246  },
	{   135,  72, 183, 120, 131,  68, 179, 116, 138,  75, 186, 123, 134,  71, 182, 119  },
	{    40, 231,  24, 215,  36, 227,  20, 211,  43, 234,  27, 218,  39, 230,  23, 214  },
	{   167, 104, 151,  88, 163, 100, 147,  84, 170, 107, 154,  91, 166, 103, 150,  87  },
	{     2, 193,  50, 241,  14, 205,  62, 253,   1, 192,  49, 240,  13, 204,  61, 252  },
	{   129,  66, 177, 114, 141,  78, 189, 126, 128,  65, 176, 113, 140,  77, 188, 125  },
	{    34, 225,  18, 209,  46, 237,  30, 221,  33, 224,  17, 208,  45, 236,  29, 220  },
	{   161,  98, 145,  82, 173, 110, 157,  94, 160,  97, 144,  81, 172, 109, 156,  93  },
	{    10, 201,  58, 249,   6, 197,  54, 245,   9, 200,  57, 248,   5, 196,  53, 244  },
	{   137,  74, 185, 122, 133,  70, 181, 118, 136,  73, 184, 121, 132,  69, 180, 117  },
	{    42, 233,  26, 217,  38, 229,  22, 213,  41, 232,  25, 216,  37, 228,  21, 212  },
	{   169, 106, 153,  90, 165, 102, 149,  86, 168, 105, 152,  89, 164, 101, 148,  85  }
};

pngPixel	BayerDither(const pngPixel& ic, int x, int y, int bpp)
{
	const int shift = 8 - bpp;
	const int lshift = shift - 4;
	const int vMax = (1 << bpp) - 1;
	const int bayer = sBayerTable[x & 15][y & 15];
	int incR = (ic.r > bayer) ? 0 : 1;
	int incG = (ic.g > bayer) ? 0 : 1;
	int incB = (ic.b > bayer) ? 0 : 1;

	int r = (ic.r >> shift) + incR;
	int g = (ic.g >> shift) + incG;
	int b = (ic.b >> shift) + incB;
	if (r > vMax) r = vMax;
	if (g > vMax) g = vMax;
	if (b > vMax) b = vMax;
	r <<= lshift;
	g <<= lshift;
	b <<= lshift;

	pngPixel rc;
	rc.r = r;
	rc.g = g;
	rc.b = b;
	return rc;
}

Color444* ColorDepthQuantize444WithDitheringInt(const pngFile& src, Dithering_t dither, int bitPerComponent)
{
	const int imgW = src.GetWidth();
	const int imgH = src.GetHeight();

	const int prec = GetDitheringPrec(dither);
	ColorErrorI* errorBuffer = (ColorErrorI*)malloc(imgW*imgH * sizeof(ColorErrorI));
	memset(errorBuffer, 0, imgW*imgH * sizeof(ColorErrorI));
	Color444* quantImage = (Color444*)malloc(imgW*imgH * sizeof(Color444));
	Color444* w = quantImage;
	for (int y = 0; y < imgH; y++)
	{
		for (int x = 0; x < imgW; x++)
		{
			pngPixel color;
			src.GetPixelColor(x, y, color);

			Color444 quantPixel;
			if (kNone == dither)
			{
				ColorErrorI originalPixel = ColorErrorI::FromPngPixel(color);
				quantPixel = ColorErrorI::QuantizeN(originalPixel, bitPerComponent);
			}
			else if (kBayer == dither)
			{
				pngPixel ditherPixel = BayerDither(color, x, y, bitPerComponent);
				quantPixel.SetR4(ditherPixel.r);
				quantPixel.SetG4(ditherPixel.g);
				quantPixel.SetB4(ditherPixel.b);
			}
			else
			{
				ColorErrorI correctedPixel = ColorErrorI::FromPngPixel(color);
				correctedPixel.Add(ReadErrorInt(errorBuffer[y*imgW + x], prec));

				quantPixel = ColorErrorI::QuantizeN(correctedPixel, bitPerComponent);
				ColorErrorI quantPixelI = ColorErrorI::FromColor444(quantPixel);

//				ColorErrorI errorPixel = correctedPixel;
				ColorErrorI errorPixel = ColorErrorI::FromPngPixel(color);
				errorPixel.Sub(quantPixelI);

				if ( kFloyd == dither )
					DiffuseFloydInt(errorBuffer, x, y, imgW, imgH, errorPixel);
				else if (kJarvis == dither)
					DiffuseJarvisInt(errorBuffer, x, y, imgW, imgH, errorPixel);
				else
					DiffuseSierraInt(errorBuffer, x, y, imgW, imgH, errorPixel);
			}

			*w++ = quantPixel;
		}
	}
	free(errorBuffer);
	return quantImage;
}


Color555* ColorDepthQuantize555WithDitheringInt(const pngFile& src, Dithering_t dither)
{
	const int imgW = src.GetWidth();
	const int imgH = src.GetHeight();

	const int prec = GetDitheringPrec(dither);
	ColorErrorI* errorBuffer = (ColorErrorI*)malloc(imgW*imgH * sizeof(ColorErrorI));
	memset(errorBuffer, 0, imgW*imgH * sizeof(ColorErrorI));
	Color555* quantImage = (Color555*)malloc(imgW*imgH * sizeof(Color555));
	Color555* w = quantImage;
	for (int y = 0; y < imgH; y++)
	{
		for (int x = 0; x < imgW; x++)
		{
			pngPixel color;
			src.GetPixelColor(x, y, color);

			Color555 quantPixel;
			if (kNone == dither)
			{
				ColorErrorI originalPixel = ColorErrorI::FromPngPixel(color);
				quantPixel = ColorErrorI::Quantize5(originalPixel);
			}
			else if (kBayer == dither)
			{
				pngPixel ditherPixel = BayerDither(color, x, y, 5);
				quantPixel.r = ditherPixel.r;
				quantPixel.g = ditherPixel.g;
				quantPixel.b = ditherPixel.b;
			}
			else
			{
				ColorErrorI correctedPixel = ColorErrorI::FromPngPixel(color);
				correctedPixel.Add(ReadErrorInt(errorBuffer[y*imgW + x], prec));

				quantPixel = ColorErrorI::Quantize5(correctedPixel);
				ColorErrorI quantPixelI = ColorErrorI::FromColor555(quantPixel);

//				ColorErrorI errorPixel = correctedPixel;
				ColorErrorI errorPixel = ColorErrorI::FromPngPixel(color);
				errorPixel.Sub(quantPixelI);

				if (kFloyd == dither)
					DiffuseFloydInt(errorBuffer, x, y, imgW, imgH, errorPixel);
				else if (kJarvis == dither)
					DiffuseJarvisInt(errorBuffer, x, y, imgW, imgH, errorPixel);
				else
					DiffuseSierraInt(errorBuffer, x, y, imgW, imgH, errorPixel);
			}

			*w++ = quantPixel;
		}
	}
	free(errorBuffer);
	return quantImage;
}



