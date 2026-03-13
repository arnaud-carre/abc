/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#include "computeManager.h"

#ifdef _WIN32
#include "dx11.h"
#elif defined(__APPLE__)
#include "metalManager.h"
#endif

std::unique_ptr<ComputeManager> CreateComputeManager()
{
#ifdef _WIN32
	return std::make_unique<Dx11Manager>();
#elif defined(__APPLE__)
	return std::make_unique<MetalManager>();
#else
	return nullptr;
#endif
}
