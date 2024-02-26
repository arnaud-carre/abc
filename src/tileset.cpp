/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <stdint.h>
#include "abc2.h"
#include "tileset.h"

TileSet::TileSet()
{
	m_mapW = 0;
	m_mapH = 0;
	m_tileSetCount = 0;
	m_tileSetReserve = 0;
	m_tileByteSize = 0;
	m_tileSet = nullptr;
	m_map = nullptr;
}

TileSet::~TileSet()
{
	free(m_tileSet);
	free(m_map);
}

void TileSet::grow(int newSize)
{
	assert(newSize >= m_tileSetCount);
	m_tileSetReserve = newSize;
	m_tileSet = (uint8_t*)realloc(m_tileSet, newSize * m_tileByteSize);
}

int TileSet::tileSearch(const uint8_t* tile)
{
	for (int t=0;t<m_tileSetCount;t++)
	{
		if (0 == memcmp(m_tileSet + t*m_tileByteSize, tile, m_tileByteSize))
			return t;
	}
	return -1;
}

bool TileSet::Create(const AmigAtariBitmap& img, int tileSizeX, int tileSizeY)
{

	bool ret = true;

	assert(0 == (img.m_w % tileSizeX));
	assert(0 == (img.m_h % tileSizeY));

	m_mapW = img.m_w / tileSizeX;
	m_mapH = img.m_h / tileSizeY;
	m_tileSizeX = tileSizeX;
	m_tileSizeY = tileSizeY;
	m_map = (int*)malloc(m_mapW * m_mapH*sizeof(int));
	m_tileByteSize = tileSizeX * tileSizeY;
	m_tileSetCount = 0;
	grow(1024);

	uint8_t* tmpTile = (uint8_t*)malloc(m_tileByteSize);

	for (int y=0;y<m_mapH;y++)
	{
		for (int x=0;x<m_mapW;x++)
		{
			// fetch the tile
			uint8_t* pw = tmpTile;
			for (int yy=0;yy<tileSizeY;yy++)
			{
				for (int xx=0;xx<tileSizeX;xx++)
				{
					*pw++ = uint8_t(img.GetPixelId(x*tileSizeX + xx, y*tileSizeY + yy));
				}
			}

			int tileId = tileSearch(tmpTile);
			if ( tileId < 0 )
			{
				if (m_tileSetCount >= m_tileSetReserve)
					grow(m_tileSetReserve + 1024);

				tileId = m_tileSetCount;
				memcpy(m_tileSet+tileId*m_tileByteSize, tmpTile, m_tileByteSize);
				m_tileSetCount++;
			}
			m_map[y * m_mapW + x] = tileId;
		}
	}
	free(tmpTile);

	printf("Tilemap stats:\n");
	printf("  Input image %d*%d, tilesize %d*%d\n", img.m_w, img.m_h, tileSizeX, tileSizeY);
	printf("  Input block count.: %d (%dKiB of map)\n", m_mapW * m_mapH, (m_mapW * m_mapH*2+1023)>>10);
	const int planTileSize = (tileSizeX / 8)*img.m_bpc * tileSizeY;
	printf("  Output block count: %d (%d%%) %dKiB\n", m_tileSetCount, (m_tileSetCount*100)/(m_mapW * m_mapH), (planTileSize*m_tileSetCount+1023)>>10);

	if ( m_tileSetCount >= 65536)
	{
		printf("ERROR: abc doesn't support more than 65536 tiles\n");
		ret = false;
	}

	return ret;
}

void TileSet::saveTilemap(const char* fname)
{
	FILE* hf;
	if (0 == fopen_s(&hf, fname, "wb"))
	{
		for (int i=0;i<m_mapW*m_mapH;i++)
		{
			uint16_t id = uint16_t(m_map[i]);
			fputc(id >> 8, hf);
			fputc(id &255, hf);
		}
		fclose(hf);
	}
}

void TileSet::saveTileset(const char* fname, int bitplanCount)
{
	FILE* hf;
	if (0 == fopen_s(&hf, fname, "wb"))
	{
		const uint8_t* pixels = m_tileSet;
		for (int t=0;t<m_tileSetCount;t++)
		{
			for (int y=0;y<m_tileSizeY;y++)
			{
				for (int b=0;b<bitplanCount;b++)
				{
					outputBitplanLine(b, pixels, m_tileSizeX, hf);
				}
				pixels += m_tileSizeX;
			}
		}
		fclose(hf);
	}
}
