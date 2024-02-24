/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#pragma once
#include <stdint.h>

struct AmigAtariBitmap;
class	TileSet
{
public:
	TileSet();
	~TileSet();

	bool Create(const AmigAtariBitmap& img, int tileSizeX, int tileSizeY);
	void saveTileset(const char* fname, int bitplanCount);
	void saveTilemap(const char* fname);

private:

	void grow(int newSize);
	int tileSearch(const uint8_t* tile);

	int m_mapW;
	int m_mapH;
	int m_tileSizeX;
	int m_tileSizeY;
	int m_tileSetCount;
	int m_tileSetReserve;
	int m_tileByteSize;
	uint8_t* m_tileSet;
	int* m_map;
};
