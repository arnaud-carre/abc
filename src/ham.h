/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#pragma once

#include "color.h"

struct ConvertParams;
struct AmigAtariBitmap;

class BruteForceHam
{
public:

	BruteForceHam();
	~BruteForceHam();

	void	BestHAMPaletteSearch(Color444* bitmap, int w, int h, Color444* palette, const ConvertParams& params);
	void	BestSHAMPaletteSearch(Color444* bitmap, int w, int h, Color444* palette, const ConvertParams& params);
	void	BestMultiPaletteSearch(Color444* bitmap, int w, int h, AmigAtariBitmap& out, Color444* palette, const ConvertParams& params);
	void	BestPaletteSearch(Color444* bitmap, int w, int h, AmigAtariBitmap& out, Color444* palette, const ConvertParams& params);
	void	HamDebugSave(const Color444* palette, int colorCount, const char* pngFilename);
	void	HamStore(AmigAtariBitmap& out, const Color444* palette, bool multiPalette);

	ColorError_t	ErrorCompute(const Color444* palette, int palSize) const;
	ColorError_t	ErrorComputeSinglePal(const Color444* palette, int palSize) const;
	ColorError_t	LineErrorCompute(int y, const Color444* palette, int palSize) const;
	ColorError_t	LineErrorComputeMPP(int y, const Color444* palette, int palSize) const;

	struct ThreadState
	{
		const BruteForceHam* solver;
		Color444 pal[32];
		Color444* mpp_palettes;
		int mpp_strideShift;
		int palSize;
		int currentPalIndex;
		int rangeStart;
		int rangeEnd;
		ColorError_t bestError;
		int bestBruteColor;
		const ConvertParams* params = nullptr;
	};

private:
	struct HamPixelState
	{
		int			hamCode;
		int			hamIndex;
	};

//	float	pixelErrorCompute(const Color444& original, const Color444& previous, HamPixelState& state, bool firstPixel, Color444& newPixel);
	Color444	findBestPixelSlow(const Color444 original, const Color444 previous, ColorError_t& errOut, const Color444* pal, int palSize, HamPixelState& state) const;
	Color444	getBestHAMColor(const Color444 original, const Color444 previous, ColorError_t& errOut, const Color444* pal, int palSize) const;
	int			findBestPixelMPP(const Color444& original, ColorError_t& errOut, const Color444* pal, int palSize) const;

	static void		SplitRanges(ThreadState* ts, int threadCount, int maxRange);

	unsigned int m_w;
	unsigned int m_h;

	Color444*	m_original;
};

void	SaveRGBPcPreview(const Color444* img, int w, int h, const char* sFilename);
void	SaveSHAM5bPcPreview(const Color444* imgA, int w, int h, const char* sFilename);

