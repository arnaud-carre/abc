/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#pragma once

#include <string.h>
#include "pngFile.h"
#include "dithering.h"

typedef	unsigned char	u8;
typedef	unsigned short	u16;
typedef	unsigned int	u32;

static const int kMaxRemap = 16;

struct ConvertParams 
{
	ConvertParams();

	bool		Validate(pngFile& bitmap);

	int			bitplanCount;
	bool		multiPalette;
	bool		allowQuantize;
	bool		ham;
	bool		sham;
	bool		sham5b;
	bool		AnyHam() const { return ham | sham | sham5b; }
	bool		gpu;
	int			imgW;
	int			imgH;
	int			forceColors[32];

	int			bitsPerComponent;
	bool		atari;
	bool		ste;				// ste palette color format

	int			expRegionX;
	int			expRegionY;
	int			expRegionW;
	int			expRegionH;
	bool		chunky;
	bool		uninterleaved;

	int			sprW;
	int			sprH;
	int			sprCount;

	bool		rgb;

	bool		hamDebug;
	Dithering_t	dithering;

	int			remapCount;
	struct RemapInfo
	{
		int	x, y;
		int oldId;
		int newId;
	};
	RemapInfo	remapList[kMaxRemap];

	void	AddRemap(int x, int y, int newId)
	{
		if (remapCount < kMaxRemap)
		{
			RemapInfo& rm = remapList[remapCount++];
			rm.x = x;
			rm.y = y;
			rm.newId = newId;
			rm.oldId = -1;
		}
	}

	void	AddSwap(int oldId, int newId)
	{
		if (remapCount < kMaxRemap)
		{
			RemapInfo& rm = remapList[remapCount++];
			rm.newId = newId;
			rm.oldId = oldId;
		}
	}

	const char*	srcFilename;
	const char* dstBinFilename;
	const char* dstPalFilename;
	const char* dstPreviewFilename;
	const char* dstIffFilename;

	int			srcRealColorCount;
	int			colorDepthCount;
};

struct bitField
{
	bitField(int size)
	{
		assert(size <= 32);
		m_size = size;
		Clear();
	}

	void	Clear()
	{
		m_mask = 0;
	}

	void	Set(int pos)
	{
		assert(unsigned(pos) < m_size);
		m_mask |= (1<<pos);
	}

	bool	IsSet(int pos) const
	{
		assert(unsigned(pos) < m_size);
		return ((m_mask&(1<<pos)) != 0);
	}

	int		NextFree() const
	{
		for (int i = 0; i < int(m_size); i++)
			if (!(m_mask&(1<<i)))
				return i;
		return -1;
	}

	uint32_t	m_mask;
	unsigned int m_size;
};



struct Color444;

struct AmigAtariBitmap
{
	AmigAtariBitmap()
	{
		memset(this, 0, sizeof(AmigAtariBitmap));
	}
	~AmigAtariBitmap()
	{
		free(m_pixels);
		free(m_palettes);
	}

	int			GetPixelId(int x, int y) const;
	bool		ColorIndexRemap(int oldId, int newId);
	bool		SaveBitplans(const ConvertParams& params, const char* sFilename);
	bool		SaveIff(const ConvertParams& params, const char* sFilename);
	bool		SavePalettes(const ConvertParams& params, const char* sFilename);
	bool		SavePcPreview(const ConvertParams& params, const char* sFilename);

	int			m_w;
	int			m_h;
	int			m_bpc;
	bool		m_multiPalette;					// multi palette
	bool		m_ham;
	u8*			m_pixels;
	Color444*	m_palettes;
};

struct Color444;
struct Color555;

int ColorDepthCount(const pngFile& bitmap);
bool	MultiPaletteOptimize(const u8* pixels, int w, int h, int bitplanCount, bool hamLayout);

