/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "dx11.h"
#include "abc2.h"
#include "ham.h"
#include "dithering.h"

ConvertParams::ConvertParams()
{
	memset(this, 0, sizeof(ConvertParams));

	// amiga or STE by default
	atari = false;
	ste = false;
	bitplanCount = -1;
	gpu = true;

	expRegionX = -1;
	expRegionY = -1;
	expRegionW = -1;
	expRegionH = -1;

	remapCount = 0;
	ham = false;

	for (int i = 0; i < 32; i++)
		forceColors[i] = -1;

	dithering = Dithering_t::kNone;
}

static bool	IsIndexNeedShrinking(pngFile& bitmap, int colorCount)
{
	const int w = bitmap.GetWidth();
	const int h = bitmap.GetHeight();
	const pngPixel* pal = bitmap.GetPalette();
	assert(pal);
	for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			BYTE index;
			bitmap.GetPixelIndex(x, y, index);
			if (int(index) >= colorCount)
				return true;
		}
	}
	return false;
}

static int	GetRealPaletizedColorCount(pngFile& bitmap, Color444* shrinkedPal, int maxColor, u8* remap)
{
	bool used[256] = {};
	if (remap)
	{
		for (int i = 0; i < 256; i++)
			remap[i] = i;
	}
	const int w = bitmap.GetWidth();
	const int h = bitmap.GetHeight();
	int count = 0;
	const pngPixel* pal = bitmap.GetPalette();
	if (pal)
	{
		for (int y = 0; y < h; y++)
		{
			for (int x = 0; x < w; x++)
			{
				uint8_t index;
				bitmap.GetPixelIndex( x, y, index);
				if (!used[index])
				{
					if ((shrinkedPal) && (count < maxColor))
						shrinkedPal[count] = PngPixelQuantToColor444(pal[index]);
					used[index] = true;
					if (remap)
						remap[index] = count;
					count++;
				}
			}
		}
	}
	else
	{	// count real number of different colors in a 24bits picture
		u8* usedColors = (u8*)malloc(1 << 24);	// 16MiB alloc (640KiB is enough for anybody)
		memset(usedColors, 0, 1 << 24);

		const int w = bitmap.GetWidth();
		const int h = bitmap.GetHeight();
		for (int y = 0; y < h; y++)
		{
			for (int x = 0; x < w; x++)
			{
				pngPixel color;
				bitmap.GetPixelColor(x, y, color);
				u32 index = (color.r << 16) | (color.g << 8) | (color.b);
				if (!usedColors[index])
				{
					count++;
					usedColors[index] = 1;
				}
			}
		}
		free(usedColors);
	}
	return count;
}

int ColorDepthCount(const pngFile& bitmap)
{
	bool byteRange[256] = {};
	const int w = bitmap.GetWidth();
	const int h = bitmap.GetHeight();
	const pngPixel* pal = bitmap.GetPalette();
	if (pal)
	{
		int count = 256;
		for (int i = 0; i < count; i++)
		{
			byteRange[pal[i].r] = true;
			byteRange[pal[i].g] = true;
			byteRange[pal[i].b] = true;
		}
	}
	else
	{
		for (int y = 0; y < h; y++)
		{
			for (int x = 0; x < w; x++)
			{
				pngPixel color;
				bitmap.GetPixelColor(x, y, color);
				byteRange[color.r] = true;
				byteRange[color.g] = true;
				byteRange[color.b] = true;
			}
		}
	}
	int count = 0;
	for (int i = 0; i < 256; i++)
		if (byteRange[i])
			count++;

	return count;
}

bool	ConvertParams::Validate(pngFile& bitmap)
{
	bool ret = true;

	if (NULL == srcFilename)
	{
		printf("ERROR: You should specify a source PNG filename\n");
		ret = false;
	}

	int hamCount = 0;
	if (ham) hamCount++;
	if ( sham ) hamCount++;
	if ( sham5b ) hamCount++;
	if (hamCount >= 2)
	{
		printf("ERROR: You should specify one HAM mode only (-ham,-sham or -sham5g)\n");
		ret = false;
	}

	if (multiPalette && AnyHam())
	{
		printf("ERROR: You can't use -mpp with any HAM mode\n");
		ret = false;
	}

	if (multiPalette && (bitplanCount <= 0))
	{
		printf("ERROR: you should provide bitplan count (-bpc) when using -mpp\n");
		ret = false;
	}

	if (bitplanCount <= 0)
	{
		if ((!AnyHam()) && (!rgb))
		{
			printf("ERROR: you should specify either -bpc or -rgb or any HAM mode\n");
			ret = false;
		}
	}
	// test forcecolor
	bool forceColor = false;
	for (int i = 0; i < 32; i++)
	{
		if (forceColors[i] != -1)
		{
			forceColor = true;
			if (unsigned(forceColors[i]) >= 4096)
			{
				printf("ERROR: -forcecolor index #%d should specify a RGB444 color in hex ( max is fff )\n", i);
				ret = false;
			}
			else
			{
				printf("Note: forcing color index #%d to be RGB color %03x\n", i, forceColors[i]);
			}
		}
	}

	if (forceColor)
	{
		if ((!allowQuantize) && (!AnyHam()))
		{
			printf("ERROR: -forcecolor should always be used with -quantize or any HAM mode\n");
			ret = false;
		}
	}

	if (bitplanCount > 0)
	{
		if (chunky && (bitplanCount > 4))
		{
			printf("ERROR: -chunky mode only support 4 bitplans max\n");
			ret = false;
		}

		if ((rgb) || (AnyHam()))
		{
			printf("ERROR: -bpc classic export mode should not be used with -rgb or HAM mode!\n");
			ret = false;
		}

		if (atari)
		{
			if (bitplanCount > 4)
			{
				printf("ERROR: Atari bitplan count max is 4 (-bpc)\n");
				ret = false;
			}
		}
		else
		{
			if (bitplanCount > 5)
			{
				printf("ERROR: Amiga bitplan count max is 5 (-bpc)\n");
				ret = false;
			}
		}
	}
	else
	{
		if (chunky)
		{
			printf("ERROR: You should use -bpc when using -chunky\n");
			ret = false;
		}
	}

	imgW = bitmap.GetWidth();
	imgH = bitmap.GetHeight();

	if ((multiPalette) || AnyHam())
	{
		if ((expRegionX >= 0) || (expRegionY >= 0) || (expRegionW >= 0) || (expRegionH >= 0))
		{
			printf("ERROR: Export region is not supported in multi-palette or HAM mode\n");
			ret = false;
		}
	}

	if (expRegionX < 0) expRegionX = 0;
	if (expRegionY < 0) expRegionY = 0;
	if (expRegionW < 0) expRegionW = imgW;
	if (expRegionH < 0) expRegionH = imgH;

	if ((expRegionX + expRegionW > imgW) ||
		(expRegionY + expRegionH > imgH) ||
		(expRegionX < 0) ||
		(expRegionY < 0))
	{
		printf("ERROR: Export region out of bound (%d,%d,%d,%d)\n", expRegionX, expRegionY, expRegionW, expRegionH);
		ret = false;
	}

	if (remapCount > 0 )
	{
		for (int r = 0; r < remapCount; r++)
		{
			if ((unsigned(remapList[r].x) >= unsigned(imgW)) ||
				(unsigned(remapList[r].y) >= unsigned(imgH)))
			{
				printf("ERROR: Remap info #%d [%d,%d] is outside of the image\n", r, remapList[r].x, remapList[r].y);
				ret = false;
			}
		}
	}

	if (0 == sprW)
		sprW = expRegionW;

	if (0 == sprH)
		sprH = expRegionH;

	const int maxSprite = (expRegionW / sprW) * (expRegionH / sprH);
	if (0 == sprCount)
		sprCount = maxSprite;
	else
	{
		if (sprCount > maxSprite)
		{
			printf("ERROR: Source image is too small for %d sprites\n", sprCount);
			ret = false;
		}
	}

	if ((!atari) && (sprW & 7))
	{
		printf("ERROR: Amiga image width should be multiple of 8 pixels\n");
		ret = false;
	}
	if ((atari) && (sprW & 15))
	{
		printf("ERROR: Atari Image width should be multiple of 16 pixels\n");
		ret = false;
	}

	const bool hasPal = (bitmap.GetPalette() != NULL);
	srcRealColorCount = GetRealPaletizedColorCount(bitmap, NULL, 0, NULL);
	colorDepthCount = ColorDepthCount(bitmap);

	if (bitplanCount>0)
	{
		if ((srcRealColorCount > (1 << bitplanCount)) && (!multiPalette) && (!allowQuantize))
		{
			printf("ERROR: Source file contains %d colors. Does not fit into %d bitplans\n", srcRealColorCount, bitplanCount);
			printf("       You may want to try -quantize option\n");
			ret = false;
		}
	}

	if (dstIffFilename)
	{
		if ((bitplanCount < 0) && (!AnyHam()))
		{
			printf("ERROR: -iff export only support bitplan images, HAM of SHAM\n");
			ret = false;
		}
		if (sham5b || multiPalette)
		{
			printf("ERROR: -iff export does not support multi-palette or SHAM5b\n");
			ret = false;
		}
		if (atari)
		{
			printf("ERROR: -iff export does not support -atari\n");
			ret = false;
		}
	}

	if ((dstPalFilename) && (rgb))
	{
		printf("ERROR: You should not specify a palette file when using rgb mode\n");
		return false;
	}

	if ((dstBinFilename) && (0 == bitplanCount))
	{
		printf("ERROR: You should not specify a bitplan output file for 0 bitplan\n");
		return false;
	}

	return ret;
}

//void	ColorCountAndRemap(FIBITMAP* bitmap, )

void	Help()
{
	printf("Usage:\n"
			"\tabc2 <src png file> [-options]\n"
			"\n"
			"Export modes:\n"
			"\t-bpc <n> : output classic n bitplans bitmap\n"
			"\t-rgb : output 16bits rgb binary\n"
			"\t-ham : convert to Amiga HAM6 format (brute force best result)\n"
			"\t-sham : convert to Amiga Sliced-HAM6 format (brute force best result)\n"
			"\t-sham5b : convert to best quality Amiga SHAM5b (31 shades) (brute force best result)\n"
			"Output files options:\n"
			"\t-b <file> : bitmap binary output file\n"
			"\t-p <file> : palette binary output file\n"
			"\t-preview <file> : PC preview PNG output image\n"
			"\t-iff <file> : output Amiga compatible IFF file\n"
			"Options:\n"
			"\t-mpp : use one palette per line ( more colors )\n"
			"\t-quantize : if src has more color than supported by # of bitplan(s), reduce colors\n"
			"\t-floyd : use Floyd dithering during RGB888 to 444 or 555 quantization (HAM modes)\n"
			"\t-jarvis : use Jarvis-Judice-Ninke dithering during RGB888 to 444 or 555 quantization\n"
			"\t-sierra : use Sierra dithering during RGB888 to 444 or 555 quantization (HAM modes)\n"
			"\t-bayer : use ordered Bayer dithering during RGB888 to 444 or 555 quantization (HAM modes)\n"
			"\t-uninterleaved: save each complete amiga bitplan (not interleaved per line)\n"
			"\t-cpu : force CPU usage for HAM or -quantize option instead of GPU\n"
			"\t-forcecolor <id> <RGB> : force color index <id> to a RGB 444 value (like ff0 for yellow)\n"
			"\t-remap <x> <y> <i>: consider pixel (x,y) as color index <i>\n"
			"\t-swap <id0> <id1>: swap color index id0 with color index id1\n"
			"\t-chunky : store bitmap file in chunky mode (4bits per pixel)\n"
			"\t-amiga : use Amiga bitplan format output (default)\n"
			"\t-atari : use Atari bitplan format output\n"
			"\t-ste : use Atari STE palette format (Atari default)\n"
			"\t-stf : use Atari STF palette format (3bits per component)\n"
			"\t-sprw <w> : input image contains w pixels width tiles\n"
			"\t-sprh <h> : input image contains h pixels high tiles\n"
			"\t-sprc <n> : input image contains n tiles\n"
			"\t-erx <x> : export region start at x\n"
			"\t-ery <y> : export region start at y\n"
			"\t-erw <w> : export region is w pixels width\n"
			"\t-erh <h> : export region is h pixels high\n");
}

bool	ParseArgs(int argc, char* argv[], ConvertParams& params)
{

	int nameCount = 0;
	int argId = 1;

	while (argId < argc)
	{
		if ('-' == argv[argId][0])
		{
			if ((0 == strcmp("-bpc", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.bitplanCount = atoi(argv[argId]);
			}
			else if ((0 == strcmp("-sprw", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.sprW = atoi(argv[argId]);
			}
			else if ((0 == strcmp("-sprh", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.sprH = atoi(argv[argId]);
			}
			else if ((0 == strcmp("-sprc", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.sprCount = atoi(argv[argId]);
			}
			else if ((0 == strcmp("-erx", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.expRegionX = atoi(argv[argId]);
			}
			else if ((0 == strcmp("-ery", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.expRegionY = atoi(argv[argId]);
			}
			else if ((0 == strcmp("-erw", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.expRegionW = atoi(argv[argId]);
			}
			else if ((0 == strcmp("-erh", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.expRegionH = atoi(argv[argId]);
			}
			else if ((0 == strcmp("-b", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.dstBinFilename = argv[argId];
			}
			else if ((0 == strcmp("-iff", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.dstIffFilename = argv[argId];
			}
			else if ((0 == strcmp("-p", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.dstPalFilename = argv[argId];
			}
			else if ((0 == strcmp("-preview", argv[argId]) && (argId + 1 < argc)))
			{
				argId++;
				params.dstPreviewFilename = argv[argId];
			}
			else if ((0 == strcmp("-forcecolor", argv[argId]) && (argId + 2 < argc)))
			{
				argId++;
				int index = atoi(argv[argId]);
				argId++;
				if (unsigned(index) < 32)
				{
					sscanf_s(argv[argId], "%x", &params.forceColors[index]);
				}
				else
				{
					printf("ERROR: -forcecolor color index should be 0 to 31\n");
				}
			}
			else if ((0 == strcmp("-remap", argv[argId]) && (argId + 3 < argc)))
			{
				argId++;
				int x = atoi(argv[argId]);
				argId++;
				int y = atoi(argv[argId]);
				argId++;
				int id = atoi(argv[argId]);
				params.AddRemap(x, y, id);
			}
			else if ((0 == strcmp("-swap", argv[argId]) && (argId + 2 < argc)))
			{
				argId++;
				int oldId = atoi(argv[argId]);
				argId++;
				int newId = atoi(argv[argId]);
				params.AddSwap(oldId, newId);
			}
			else if (0 == strcmp("-mpp", argv[argId]))
			{
				params.multiPalette = true;
			}
			else if (0 == strcmp("-chunky", argv[argId]))
			{
				params.chunky = true;
			}
			else if (0 == strcmp("-uninterleaved", argv[argId]))
			{
				params.uninterleaved = true;
			}
			else if (0 == strcmp("-quantize", argv[argId]))
			{
				params.allowQuantize = true;
			}
			else if (0 == strcmp("-ham", argv[argId]))
			{
				params.ham = true;
			}
			else if (0 == strcmp("-sham", argv[argId]))
			{
				params.sham = true;
			}
			else if (0 == strcmp("-sham5b", argv[argId]))
			{
				params.sham5b = true;
			}
			else if (0 == strcmp("-cpu", argv[argId]))
			{
				params.gpu = false;
			}
			else if (0 == strcmp("-hamdebug", argv[argId]))
			{
				params.hamDebug = true;
			}
			else if (0 == strcmp("-floyd", argv[argId]))
			{
				params.dithering = Dithering_t::kFloyd;
			}
			else if (0 == strcmp("-jarvis", argv[argId]))
			{
				params.dithering = Dithering_t::kJarvis;
			}
			else if (0 == strcmp("-bayer", argv[argId]))
			{
				params.dithering = Dithering_t::kBayer;
			}
			else if (0 == strcmp("-sierra", argv[argId]))
			{
				params.dithering = Dithering_t::kSierra;
			}
			else if (0 == strcmp("-rgb", argv[argId]))
			{
				params.rgb = true;
			}
			else if (0 == strcmp("-stf", argv[argId]))
			{
				params.ste = false;
			}
			else if (0 == strcmp("-ste", argv[argId]))
			{
				params.ste = true;
			}
			else if (0 == strcmp("-amiga", argv[argId]))
			{
				params.atari = false;
			}
			else if (0 == strcmp("-atari", argv[argId]))
			{
				params.atari = true;
			}
			else
			{
				printf("Unknown option \"%s\"\n", argv[argId]);
				return false;
			}
		}
		else
		{
			nameCount++;
			if (1 == nameCount)
				params.srcFilename = argv[argId];
			else
			{
				printf("Too much files specified (\"%s\")\n", argv[argId]);
				return false;
			}
		}
		argId++;
	}

	return (1==nameCount);
}

static	int	ExactPaletteColorSearch(const Color444 color, const Color444* pal, int palSize)
{
	for (int i = 0; i < palSize; i++)
	{
		if ( color.Equal(pal[i]) )
			return i;
	}
	return -1;
}

static	u16	AmigaAtariColorExport(const ConvertParams& params, Color444 c)
{
	int r = c.GetR();
	int g = c.GetG();
	int b = c.GetB();
	if (params.ste)
	{	// STE color weird shuffling
		r = (r >> 1) | ((r & 1) << 3);
		g = (g >> 1) | ((g & 1) << 3);
		b = (b >> 1) | ((b & 1) << 3);
	}
	else if (params.atari)
	{
		// STF
		r >>= 1;
		g >>= 1;
		b >>= 1;
	}
	const u16 val = (r << 8) | (g << 4) | b;
	return val;
}

bool	SaveRGBFile(const ConvertParams& params, const Color444* bitmap, int w, int h, const char* sFilename)
{
	bool ret = false;
	FILE* hf;
	if (0 == fopen_s(&hf, sFilename, "wb"))
	{
		printf("Saving RGB file (%d*%d)\n", w, h);
		for (int y = 0; y < h; y++)
		{
			for (int x = 0; x < w; x++)
			{
				u16 val = AmigaAtariColorExport(params, *bitmap++);
				fputc(val >> 8, hf);
				fputc(val & 255, hf);
			}
		}
		fclose(hf);
		ret = true;
	}
	return ret;
}

bool	Convert24bToIndexed(const ConvertParams& params, pngFile& bitmap, AmigAtariBitmap& out)
{
	assert(!params.multiPalette);
	assert(!params.AnyHam());
	assert(NULL == bitmap.GetPalette());

	const int imgw = bitmap.GetWidth();
	const int imgh = bitmap.GetHeight();

	const int w = params.expRegionW;
	const int h = params.expRegionH;

	out.m_bpc = params.bitplanCount;
	out.m_w = w;
	out.m_h = h;
	out.m_multiPalette = false;
	const int colorsCount = 1 << out.m_bpc;
	out.m_palettes = (Color444*)malloc(colorsCount * sizeof(Color444));
	memset(out.m_palettes, 0, colorsCount * sizeof(Color444));

	out.m_pixels = (u8*)malloc(w*h * sizeof(u8));

	u8* pWrite = out.m_pixels;
	int16_t* usedColors = (int16_t*)malloc((1 << 24) * sizeof(int16_t));	// 33MiB alloc (640KiB is enough for anybody)
	memset(usedColors, 0xff, (1 << 24)*sizeof(int16_t));

	int palIndex = 0;
	for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			pngPixel color;
			bitmap.GetPixelColor(x, y, color);
			u32 index = (color.r << 16) | (color.g << 8) | (color.b);
			if (usedColors[index]<0)
			{
				assert(palIndex < colorsCount);
				if (palIndex < colorsCount)
				{
					out.m_palettes[palIndex] = PngPixelQuantToColor444(color);
					usedColors[index] = palIndex;
					palIndex++;
				}
			}
			*pWrite++ = u8(usedColors[index]);
		}
	}
	free(usedColors);
	return true;
}



bool	ConvertToStandardIndexed(const ConvertParams& params, pngFile& bitmap, AmigAtariBitmap& out)
{
	assert(!params.multiPalette);
	assert(!params.AnyHam());

	const int imgw = bitmap.GetWidth();
	const int imgh = bitmap.GetHeight();

	const int w = params.expRegionW;
	const int h = params.expRegionH;

	out.m_bpc = params.bitplanCount;
	out.m_w = w;
	out.m_h = h;
	out.m_multiPalette = false;
	const int colorsCount = 1 << out.m_bpc;
	out.m_palettes = (Color444*)malloc(colorsCount * sizeof(Color444));
	memset(out.m_palettes, 0, colorsCount * sizeof(Color444));

	const pngPixel* pal = bitmap.GetPalette();
	assert(pal);
	for (int c = 0; c < colorsCount; c++)
		out.m_palettes[c] = PngPixelQuantToColor444(pal[c]);

	u8 remapTable[256];
	for (int i = 0; i < 256; i++)
		remapTable[i] = i;

	int realCount = colorsCount;
	if (IsIndexNeedShrinking(bitmap, colorsCount))
	{
		printf("Pixels indices are spread, shrink to %d bitplans\n", params.bitplanCount);
		realCount = GetRealPaletizedColorCount(bitmap, out.m_palettes, colorsCount, remapTable);
	}
	assert(realCount <= colorsCount);

	out.m_pixels = (u8*)malloc(w*h*sizeof(u8));

	u8* pWrite = out.m_pixels;
	for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			BYTE index;
			bitmap.GetPixelIndex(x + params.expRegionX, y + params.expRegionY, index);
			// Remap into shrinked palette
			const u8 remapId = remapTable[index];
			assert(remapId < unsigned(colorsCount));
			*pWrite++ = remapId;
		}
	}

	return true;
}

static void outputBitplanLine(int bitplan, const u8* pixels, int w, FILE* hf)
{
	for (int x = 0; x < w; x += 8)
	{
		u8 val = 0;
		u8 mask = (1 << 7);
		while (mask)
		{
			if ((*pixels++) & (1 << bitplan))
				val |= mask;
			mask >>= 1;
		}
		fputc(val, hf);
	}
}

static void outputBitplanAtariLine(int bitplanCount, const u8* pixels, int w, FILE* hf)
{
	assert(0 == (w & 15));
	for (int x = 0; x < w; x += 16)
	{
		for (int p = 0; p < bitplanCount; p++)
		{
			outputBitplanLine(p, pixels, 16, hf);
		}
		pixels += 16;
	}
}

bool	AmigAtariBitmap::SaveBitplans(const ConvertParams& params, const char* sFilename)
{
	assert(m_pixels);

	printf("Saving %s %s binary file \"%s\"...\n", params.atari ? "Atari" : "Amiga", 
		params.chunky?"chunky":"bitplan",
		sFilename);
	bool ret = false;
	FILE* hf;
	if (0 == fopen_s(&hf, sFilename, "wb"))
	{
		printf("  (export region [%d,%d,%d,%d])\n", params.expRegionX, params.expRegionY, params.expRegionW, params.expRegionH);
		printf("  %d bitplans, %d block(s) of %d*%d each...\n", m_bpc, params.sprCount, params.sprW, params.sprH);

		int sprCount = 0;
		for (int yb = 0; yb < m_h / params.sprH; yb++)
		{
			for (int xb = 0; xb < m_w / params.sprW; xb++)
			{
				if (sprCount < params.sprCount)
				{
					if (params.chunky)
					{
						for (int y = 0; y < params.sprH; y++)
						{
							const u8* pixels = m_pixels + (yb * params.sprH + y)*m_w + xb * params.sprW;
							for (int x = 0; x < params.sprW; x += 2)
							{
								u8 val = (pixels[0] << 4) | (pixels[1]);
								fputc(val, hf);
								pixels += 2;
							}
						}
					}
					else if (params.uninterleaved)
					{
						for (int p = 0; p < m_bpc; p++)
						{
							for (int y = 0; y < params.sprH; y++)
							{
								const u8* pixels = m_pixels + (yb * params.sprH + y)*m_w + xb * params.sprW;
								outputBitplanLine(p, pixels, params.sprW, hf);
							}
						}
					}
					else if (params.atari)
					{
						for (int y = 0; y < params.sprH; y++)
						{
							const u8* pixels = m_pixels + (yb * params.sprH + y)*m_w + xb * params.sprW;
							outputBitplanAtariLine(m_bpc, pixels, params.sprW, hf);
						}
					}
					else
					{
						for (int y = 0; y < params.sprH; y++)
						{
							for (int p = 0; p < m_bpc; p++)
							{
								const u8* pixels = m_pixels + (yb * params.sprH + y)*m_w + xb * params.sprW;
								outputBitplanLine(p, pixels, params.sprW, hf);
							}
						}
					}
				}
				sprCount++;
			}
		}
		fclose(hf);
		ret = true;
	}
	else
	{
		printf("ERROR: Unable to write \"%s\"\n", sFilename);
	}

	return ret;
}

static void w8(FILE* h, uint8_t v)
{
	fputc(v, h);
}

static void w16(FILE* h, uint16_t v)
{
	fputc(uint8_t(v >> 8), h);
	fputc(uint8_t(v>>0), h);
}

static void w32(FILE* h, uint32_t v)
{
	w16(h, uint16_t(v >> 16));
	w16(h, uint16_t(v >> 0));
}

bool	AmigAtariBitmap::SaveIff(const ConvertParams& params, const char* sFilename)
{
	assert(m_pixels);
	assert(!params.chunky);
	assert(!params.uninterleaved);
	assert(!params.atari);

	printf("Saving IFF bitmap file \"%s\"...\n", sFilename);
	bool ret = false;
	FILE* hf;
	if (0 == fopen_s(&hf, sFilename, "wb"))
	{
		fwrite("FORM", 1, 4, hf);
		w32(hf, 0);		// dummy size
		fwrite("ILBMBMHD", 1, 8, hf);
		w32(hf, 0x14);	// BMHD size
		w16(hf, m_w);
		w16(hf, m_h);
		w16(hf, 0);
		w16(hf, 0);
		w8(hf, m_bpc);
		w8(hf, 0);	// masking
		w8(hf, 0);  // no compression
		w8(hf, 0);  // padding
		w16(hf, 0);	// transparent color
		w8(hf, 4);  // x aspect
		w8(hf, 3);  // y aspect
		w16(hf, 0);
		w16(hf, 0);
		if (m_ham)
		{
			fwrite("CAMG", 1, 4, hf);
			w32(hf, 4);
			w32(hf, 0x800);	// Amiga HAM mode bit
		}
		fwrite("CMAP", 1, 4, hf);
		const int colorCount = m_ham ? 16 : 1 << m_bpc;
		w32(hf, colorCount*3);
		for (int i = 0; i < colorCount; i++)
		{
			// we don't use toPngPixel, it seems amiga HAM IFF files use RRGGBB instead
			w8(hf, (m_palettes[i].GetR()<<4)|(m_palettes[i].GetR()<<0));
			w8(hf, (m_palettes[i].GetG()<<4)|(m_palettes[i].GetG()<<0));
			w8(hf, (m_palettes[i].GetB()<<4)|(m_palettes[i].GetB()<<0));
		}

		if (m_multiPalette)
		{
			assert(m_ham);
			fwrite("SHAM", 1, 4, hf);
			const int chunkSize = 2 + m_h*16*2 + ((m_h & 1)?32:0);
			w32(hf, chunkSize);
			w16(hf, 0);	// SHAM version
			for (int i = 0; i < m_h*16; i++)
				w16(hf, m_palettes[i].GetRaw12bitsColor());
			if (m_h & 1)
			{
				for (int i = 0; i < 16; i++)
					w16(hf, 0);
			}
		}

		fwrite("BODY", 1, 4, hf);
		const int linePitch = m_w / 8;
		w32(hf, m_h*linePitch*m_bpc);

		for (int y = 0; y < m_h; y++)
		{
			for (int p = 0; p < m_bpc; p++)
			{
				const u8* pixels = m_pixels + y*m_w;
				outputBitplanLine(p, pixels, m_w, hf);
			}
		}

		const int formSize = ftell(hf)-8;
		fseek(hf, 4, SEEK_SET);
		w32(hf, formSize);
		fseek(hf, 0, SEEK_END);
		fclose(hf);
		ret = true;
	}
	else
	{
		printf("ERROR: Unable to write \"%s\"\n", sFilename);
	}

	return ret;
}

bool	AmigAtariBitmap::SavePalettes(const ConvertParams& params, const char* sFilename)
{
	assert(m_palettes);
	assert(sFilename);

	printf("Saving %s palette binary file \"%s\"...\n", params.atari ? "Atari" : "Amiga", sFilename);

	bool ret = false;
	FILE* hf;
	if (0 == fopen_s(&hf, sFilename, "wb"))
	{
		const int colorCount = m_ham?16:(1 << m_bpc);
		const int palCount = m_multiPalette ? m_h : 1;
		printf("  %d palette(s) of %d colors each...\n", palCount, colorCount);
		const Color444* pal = m_palettes;
		for (int p = 0; p < palCount; p++)
		{
			for (int c = 0; c < colorCount; c++)
			{
				u16 val = AmigaAtariColorExport(params, *pal++);
				fputc(val >> 8, hf);
				fputc(val&255, hf);
			}
		}

		fclose(hf);
		ret = true;
	}
	else
	{
		printf("ERROR: Unable to write \"%s\"\n", sFilename);
	}

	return ret;
}

bool	AmigAtariBitmap::ColorIndexRemap(int oldId, int newId)
{
	if (oldId != newId)
	{
		const int colorCount = (1 << m_bpc);
		for (int y = 0; y < m_h; y++)
		{
			Color444* pal = m_palettes;
			if (m_multiPalette)
				pal += y * colorCount;

			if ((0 == y) || (m_multiPalette))
			{
				Color444 cswap = pal[oldId];
				pal[oldId] = pal[newId];
				pal[newId] = cswap;
			}

			u8* pixels = m_pixels + y * m_w;
			for (int x = 0; x < m_w; x++)
			{
				if (oldId == pixels[x])
					pixels[x] = newId;
				else if (newId == pixels[x])
					pixels[x] = oldId;
			}
		}
	}
	return true;
}

static bool	IsHamColorIndex(int hamCode)
{
	return (0 == ((hamCode >> 4) & 3));
}

// remap pal and pixel indices to minimize the number of color register write per line
bool	MultiPaletteOptimize(u8* bitmap, int w, int h, Color444* palettes, int bitplanCount, bool hamLayout)
{

	assert(bitplanCount <= 5);

	const int colorCount = hamLayout ? 16 : (1 << bitplanCount);
	printf("Multi-Palette color optimization (%d entries per line)...\n", colorCount);

	bitField srcSlotUsed(colorCount);
	bitField dstSlotUsed(colorCount);
	bitField pixelIndicesUsed(colorCount);

	Color444 currentPal[32];
	for (int i = 0; i < colorCount; i++)
		currentPal[i] = palettes[i];

	int colorSet = colorCount;					// by default do the first 16 colors
	for (int y = 1; y < h; y++)				// on purpose start at line 1 ( line 0 is the reference )
	{
		Color444* pal = palettes + y * colorCount;

		srcSlotUsed.Clear();
		dstSlotUsed.Clear();
		pixelIndicesUsed.Clear();

		u8* pixels = bitmap + y * w;

		if (hamLayout)
		{
			for (int x = 0; x < w; x++)
			{
				if (IsHamColorIndex(pixels[x]))
					pixelIndicesUsed.Set(pixels[x]&15);
			}
		}
		else
		{
			for (int x = 0; x < w; x++)
				pixelIndicesUsed.Set(pixels[x]);
		}

		int pixelRemapTable[32];
		memset(pixelRemapTable, 0xff, sizeof(pixelRemapTable));

		Color444 palCopy[32];
		memcpy(palCopy, pal, colorCount * sizeof(Color444));

		// first, set all colors that already exist in current pal
		for (int i = 0; i < colorCount; i++)
		{
			if (pixelIndicesUsed.IsSet(i))
			{
				int entryInCurrentPal = ExactPaletteColorSearch(palCopy[i], currentPal, colorCount);
				if (entryInCurrentPal >= 0)
				{
					srcSlotUsed.Set(i);
					dstSlotUsed.Set(entryInCurrentPal);
					pal[entryInCurrentPal] = currentPal[entryInCurrentPal];
					pixelRemapTable[i] = entryInCurrentPal;
				}
			}
		}

		// even if entry 0 hasn't be locked, protect it (background color shouldn't change! )
		dstSlotUsed.Set(0);

		// now look all new colors & search a free entry
		for (int i = 0; i < colorCount; i++)
		{
			if (pixelIndicesUsed.IsSet(i))
			{
				if (!srcSlotUsed.IsSet(i))
				{
					assert(ExactPaletteColorSearch(palCopy[i], currentPal, colorCount) < 0);
					// find a free entry
					int freeEntry = dstSlotUsed.NextFree();
					assert(freeEntry >= 0);
					dstSlotUsed.Set(freeEntry);
					pal[freeEntry] = palCopy[i];
					pixelRemapTable[i] = freeEntry;
				}
			}
		}

		// remap pixels
		if (hamLayout)
		{
			for (int x = 0; x < w; x++)
			{
				if (IsHamColorIndex(pixels[x]))
				{
					assert(pixelRemapTable[pixels[x]] >= 0);
					pixels[x] = pixelRemapTable[pixels[x]];
				}
			}
		}
		else
		{
			for (int x = 0; x < w; x++)
			{
				assert(pixelRemapTable[pixels[x]] >= 0);
				pixels[x] = pixelRemapTable[pixels[x]];
			}
		}

		// do some stats
		for (int c = 0; c < colorCount; c++)
		{
			if (!pal[c].Equal(currentPal[c]))
				colorSet++;
		}

		memcpy(currentPal, pal, colorCount * sizeof(Color444));
	}

	printf("Average: %.02f colors write per line\n", float(colorSet) / float(h));

	return true;
}

bool	AmigAtariBitmap::SavePcPreview(const ConvertParams& params, const char* sFilename)
{

	pngPixel* tmpImage = (pngPixel*)malloc(m_w*m_h * sizeof(pngPixel));
	pngPixel* pw = tmpImage;

	const u8* pixels = m_pixels;
	if (!m_ham)
	{
		const int colorCount = 1 << m_bpc;
		const int palCount = m_multiPalette ? m_h : 1;
		for (int y = 0; y < m_h; y++)
		{
			Color444* pal = m_palettes;
			if (m_multiPalette)
				pal += y * colorCount;
			for (int x = 0; x < m_w; x++)
			{
				pngPixel color = pal[*pixels++].ToPngPixel();
				*pw++ = color;
			}
		}
	}
	else
	{
		// Amiga HAM6
		for (int y = 0; y < m_h; y++)
		{
			const Color444* pal = m_palettes;
			if (m_multiPalette)
				pal += y * 16;

			Color444 color = pal[0];			// current color at start of the line is background color
			for (int x = 0; x < m_w; x++)
			{
				const int hamCode = *pixels++;
				switch ((hamCode >> 4)&3)
				{
				case 0:
					color = pal[hamCode & 15];
					break;
				case 1:			// B
					color.SetB4(hamCode & 15);
					break;
				case 2:			// R
					color.SetR4(hamCode & 15);
					break;
				case 3:			// G
					color.SetG4(hamCode & 15);
					break;
				}
				pngPixel rgbColor = color.ToPngPixel();
				*pw++ = rgbColor;
			}
		}
	}

	bool ret = pngRGBASave(sFilename, tmpImage, m_w, m_h);

	free(tmpImage);

	return ret;
}

int	AmigAtariBitmap::GetPixelId(int x, int y) const
{
	assert((unsigned(x) < unsigned(m_w)) &&
		(unsigned(y) < unsigned(m_h)));
	assert(m_pixels);
	return m_pixels[y*m_w + x];
}

int main(int argc, char*argv[])
{
	printf("AmigAtari Bitmap Converter v2.01 by Leonard/Oxygene\n"
	       "(GPU Enhanced version)\n\n");

	ConvertParams params;

	if (!ParseArgs(argc, argv, params))
	{
		Help();
		return 1;
	}

	int err = 1;
	printf("Input image file: \"%s\"\n", params.srcFilename);

	pngFile bitmap;
	if (bitmap.Load(params.srcFilename))
	{
		if (params.Validate(bitmap))
		{
			printf("%dx%d pixels, %d different colors (color depth use %d values)\n", params.imgW, params.imgH, params.srcRealColorCount, params.colorDepthCount);

			int w = bitmap.GetWidth();
			int h = bitmap.GetHeight();

			Color444* src444 = nullptr;

			// First of all, quantize colors to 444 if needed
			if ((params.rgb) || (params.AnyHam()) || (params.multiPalette) || (params.allowQuantize))
			{
				// convert to 24bits first if palette
				if (bitmap.GetPalette())
					bitmap.ConvertTo24bits();

				const char* sDitherName[kDitheringMax] = { "No", "Floyd", "Sierra", "Bayer", "Jarvis" };
				if (params.sham5b)
				{
					printf("RGB888 quantization to RGB555 (%s dithering)...\n", sDitherName[int(params.dithering)]);
					Color555* src555 = ColorDepthQuantize555WithDitheringInt(bitmap, params.dithering);
					src444 = Split555(src555, w, h);
					h *= 2;			// Note: SHAM5b is two SHAM pictures, so double height
					params.sprH *= 2;
					free(src555);
					printf("SHAM5b mode: Processing twice more pixels (%dx%d)\n", w, h);
				}
				else
				{
					const int bitPerComponent = (params.atari && (!params.ste)) ? 3 : 4;
					printf("RGB888 quantization to RGB%d%d%d (%s dithering)...\n", bitPerComponent, bitPerComponent,bitPerComponent,sDitherName[int(params.dithering)]);
					src444 = ColorDepthQuantize444WithDitheringInt(bitmap, params.dithering, bitPerComponent);
				}
			}

			AmigAtariBitmap out;
			if (!params.rgb)
			{
				int colorPerPal = params.AnyHam() ? 16 : (1 << params.bitplanCount);
				int palEntries = params.ham ? colorPerPal : colorPerPal * h;
				Color444* pal = (Color444*)malloc(palEntries * sizeof(Color444));

				// by default all colors set to black
				memset(pal, 0, palEntries * sizeof(Color444));

				// set background color RGB
				for (int i = 0; i < palEntries / colorPerPal; i++)
				{
					for (int z = 0; z < colorPerPal; z++)
					{
						if (params.forceColors[z] >= 0)
						{
							pal[i * colorPerPal+z].SetRGB444(params.forceColors[z]);
						}
					}
				}

				if (params.AnyHam() || params.multiPalette)
				{

					if (params.AnyHam())
					{
						// now HAM could also have multi-palette mode!
						assert(src444);
						assert(16 == colorPerPal);
						BruteForceHam bf;

						// Once palettes are initialized, call the brute force HAM search
						if (params.ham)
							bf.BestHAMPaletteSearch(src444, w, h, pal, params);
						else
							bf.BestSHAMPaletteSearch(src444, w, h, pal, params);

						bf.HamStore(out, pal, (params.sham || params.sham5b));
					}
					else if (params.multiPalette)
					{
						assert(src444);
						assert(params.bitplanCount > 0);
						BruteForceHam bf;
						bf.BestMultiPaletteSearch(src444, w, h, out, pal, params);
					}

					// mpp, SHAM & SHAM5b could benefit of copper color set optimization
					if (params.sham5b)
					{
						// should be optimized in two blocks
						MultiPaletteOptimize(out.m_pixels, w, h/2, out.m_palettes, 4, true);
						MultiPaletteOptimize(out.m_pixels+w*(h/2), w, h/2, out.m_palettes+16*(h/2), 4, true);
					}
					else if ( params.multiPalette)
					{
						MultiPaletteOptimize(out.m_pixels, w, h, out.m_palettes, out.m_bpc, false);
					}
					else if (params.sham)
					{
						MultiPaletteOptimize(out.m_pixels, w, h, out.m_palettes, 4, true);
					}
				}
				else if ( params.bitplanCount > 0 )
				{
					if (params.allowQuantize)
					{
						assert(src444);
						BruteForceHam bf;
						bf.BestPaletteSearch(src444, w, h, out, pal, params);
					}
					else
					{
						if (bitmap.GetPalette())
							ConvertToStandardIndexed(params, bitmap, out);
						else
							Convert24bToIndexed(params, bitmap, out);

					}

					// Remap to keep dedicated color0 index
					if (params.remapCount)
					{
						for (int i = 0; i < params.remapCount; i++)
						{
							const ConvertParams::RemapInfo& rm = params.remapList[i];
							int oldId = rm.oldId;
							if (oldId < 0)
							{
								oldId = out.GetPixelId(rm.x, rm.y);
								printf("Remap #%d: swapping color index %d (at %d,%d) to index %d...\n", i, oldId, rm.x, rm.y, rm.newId);
							}
							else
								printf("Swaping color index %d with index %d\n", oldId, rm.newId);

							out.ColorIndexRemap(oldId, rm.newId);
						}
					}
				}

			}

			if ( params.rgb)
			{
				assert(src444);
				if (params.dstBinFilename)
					SaveRGBFile(params, src444, w, h, params.dstBinFilename);
			}
			else
			{
				if (params.dstBinFilename)
					out.SaveBitplans(params, params.dstBinFilename);
				if (params.dstIffFilename)
					out.SaveIff(params, params.dstIffFilename);
			}

			if (params.dstPalFilename)
				out.SavePalettes(params, params.dstPalFilename);
			if (params.dstPreviewFilename)
			{
				printf("Saving PC preview : \"%s\"\n", params.dstPreviewFilename);
				if (params.sham5b)
					SaveSHAM5bPcPreview(src444, w, h, params.dstPreviewFilename);
				else if (params.rgb)
				{
					assert(src444);
					SaveRGBPcPreview(src444, w, h, params.dstPreviewFilename);
				}
				else
					out.SavePcPreview(params, params.dstPreviewFilename);
			}



			err = 0;
			free(src444);
		}
	}
	else
	{
		printf("Unable to read file \"%s\"\n", params.srcFilename);
	}
	return err;
}
