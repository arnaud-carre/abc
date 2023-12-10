/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#pragma once
#include <stdint.h>
#include "color.h"

class pngFile 
{
public:

	pngFile();
	~pngFile();




	bool	Load(const char* filename);

	bool IsValid() const { return m_image != NULL; }

	uint32_t	GetWidth() const { return m_w; }
	uint32_t	GetHeight() const { return m_h; }
	pngPixel*	GetPalette() { return m_palette; }
	const pngPixel*	GetPalette() const { return m_palette; }
	bool		GetPixelColor(uint32_t x, uint32_t y, pngPixel& color) const;
	bool		GetPixelIndex(uint32_t x, uint32_t y, uint8_t& index) const;

	bool		ConvertTo24bits();

	void	Release();

private:
	uint32_t m_w;
	uint32_t m_h;
	int m_colorCount;
	pngPixel*	m_palette;
	uint8_t* m_image;
};

extern bool	pngRGBASave(const char* filename, const pngPixel* image, int w, int h);
