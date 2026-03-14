/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#pragma once

#include <memory>

#include "computeManager.h"

class VulkanManager final : public ComputeManager
{
public:
	VulkanManager();
	~VulkanManager() override;

	bool bestSHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes) override;
	bool bestMppPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc) override;
	bool bestHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes) override;
	bool bestSinglePaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc) override;

private:
	struct Impl;
	std::unique_ptr<Impl> m_impl;
};
