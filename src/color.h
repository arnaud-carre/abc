/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#pragma once

#include <stdint.h>

struct pngPixel
{
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
};

typedef unsigned int	ColorError_t;
static const ColorError_t kColorErrorMax = ~0;

class LazyTables
{
public:
	LazyTables();

	static int	distR[16 * 16];
	static int	distG[16 * 16];
	static int	distB[16 * 16];
};


struct Color444
{
	int		GetR() const { return (value >> 8) & 15; }
	int		GetG() const { return (value >> 4) & 15; }
	int		GetB() const { return (value >> 0) & 15; }
	int		GetRGB444() const { return value; }
	bool	Equal(const Color444 rv) const { return rv.value == value; }
	pngPixel	ToPngPixel() const
	{
		pngPixel color;
		color.r = GetR() * 17;		// note: 17 == 255/15
		color.g = GetG() * 17;
		color.b = GetB() * 17;
		color.a = 255;
		return color;
	}
	void	SetR4(int v)
	{
		assert(unsigned(v) < 16);
		value = (value & 0x00ff) | (v << 8);
	}
	void	SetG4(int v)
	{
		assert(unsigned(v) < 16);
		value = (value & 0x0f0f) | (v << 4);
	}
	void	SetB4(int v)
	{
		assert(unsigned(v) < 16);
		value = (value & 0x0ff0) | (v << 0);
	}

	void	SetRGB444(int v444)
	{
		assert(unsigned(v444) < 4096);
		value = v444;
	}

	static ColorError_t	DistanceR(int v0, int v1)
	{
		const int idx = (v0 << 4) | v1;
		return LazyTables::distR[idx];
	}
	static ColorError_t	DistanceG(int v0, int v1)
	{
		const int idx = (v0 << 4) | v1;
		return LazyTables::distG[idx];
	}
	static ColorError_t	DistanceB(int v0, int v1)
	{
		const int idx = (v0 << 4) | v1;
		return LazyTables::distB[idx];
	}

	ColorError_t	Distance(const Color444 rv) const
	{
		const ColorError_t distR = DistanceR(GetR(), rv.GetR());
		const ColorError_t distG = DistanceG(GetG(), rv.GetG());
		const ColorError_t distB = DistanceB(GetB(), rv.GetB());
		return distR + distG + distB;
	}
private:
//	unsigned short	value;
	unsigned int	value;
};

struct Color555
{
	int r, g, b;
	pngPixel	ToPngPixel() const
	{
		pngPixel color;
		color.r = (r * 255) / 31;
		color.g = (g * 255) / 31;
		color.b = (b * 255) / 31;
		color.a = 255;
		return color;
	}
};


struct ColorErrorI
{
	static ColorErrorI 	FromPngPixel(pngPixel& ic)
	{
		ColorErrorI a;
		a.r = int(ic.r);
		a.g = int(ic.g);
		a.b = int(ic.b);
		return a;
	}

	static Color444 	QuantizeN(const ColorErrorI& a, int bitPerComponent)
	{
		int r = (a.r < 0) ? 0 : (a.r > 255) ? 255 : a.r;
		int g = (a.g < 0) ? 0 : (a.g > 255) ? 255 : a.g;
		int b = (a.b < 0) ? 0 : (a.b > 255) ? 255 : a.b;
		const unsigned int shift = 8-bitPerComponent;
		const unsigned int lshift = shift-4;
		r >>= shift;
		g >>= shift;
		b >>= shift;
		r <<= lshift;
		g <<= lshift;
		b <<= lshift;
		Color444 rc;
		rc.SetRGB444((r << 8) | (g << 4) | b);
		return rc;
	}

	static Color555 	Quantize5(const ColorErrorI& a)
	{
		int r = (a.r < 0) ? 0 : (a.r > 255) ? 255 : a.r;
		int g = (a.g < 0) ? 0 : (a.g > 255) ? 255 : a.g;
		int b = (a.b < 0) ? 0 : (a.b > 255) ? 255 : a.b;
		const unsigned int shift = 8-5;
		r >>= shift;
		g >>= shift;
		b >>= shift;
		Color555 rc;
		rc.r = r;
		rc.g = g;
		rc.b = b;
		return rc;
	}

	void	Add(const ColorErrorI& c)
	{
		r += c.r;
		g += c.g;
		b += c.b;
	}
	void	Sub(const ColorErrorI& c)
	{
		r -= c.r;
		g -= c.g;
		b -= c.b;
	}

	static ColorErrorI FromColor444(const Color444& ic)
	{
		ColorErrorI rc;
		rc.r = ic.GetR() << 4;
		rc.g = ic.GetG() << 4;
		rc.b = ic.GetB() << 4;
		return rc;
	}

	static ColorErrorI FromColor555(const Color555& ic)
	{
		ColorErrorI rc;
		const int shift = 8 - 5;
		rc.r = ic.r << shift;
		rc.g = ic.g << shift;
		rc.b = ic.b << shift;
		return rc;
	}

	int r, g, b;
};

Color444 PngPixelQuantToColor444(const pngPixel& c);
