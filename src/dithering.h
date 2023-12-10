/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#pragma once

#include "abc2.h"
#include "ham.h"

enum Dithering_t
{
	kNone,
	kFloyd,
	kSierra,
	kBayer
};

Color555* ColorDepthQuantize555WithDitheringInt(const pngFile& src, Dithering_t dither);
Color444* ColorDepthQuantize444WithDitheringInt(const pngFile& src, Dithering_t dither, int bitPerComponent);
Color444* Split555(const Color555* src, int w, int h);
