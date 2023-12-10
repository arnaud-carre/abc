/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#include <stdlib.h>
#include <assert.h>
#include "abc2.h"
#include "color.h"
#include "dithering.h"

Color444 PngPixelQuantToColor444(const pngPixel& c)
{
	int r = c.r>>4;
	int g = c.g>>4;
	int b = c.b>>4;
	Color444 cr;
	cr.SetRGB444((r << 8) | (g << 4) | b);
	return cr;
}
