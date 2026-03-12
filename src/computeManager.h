/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#pragma once

#include <memory>

struct Color444;

class ComputeManager
{
public:
	virtual ~ComputeManager() = default;

	virtual bool bestSHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes) = 0;
	virtual bool bestMppPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc) = 0;
	virtual bool bestHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes) = 0;
	virtual bool bestSinglePaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc) = 0;
};

std::unique_ptr<ComputeManager> CreateComputeManager();
