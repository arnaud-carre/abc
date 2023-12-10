/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <windows.h>			// thread stuff
#include <thread>
#include <time.h>
#include "abc2.h"
#include "color.h"
#include "ham.h"
#include "dithering.h"
#include "dx11.h"

static LazyTables	s_lazyInit;
static const int	kMaxThreads = 64;

static BruteForceHam::ThreadState states[kMaxThreads];
static void*	hThreads[kMaxThreads];
static int		gThreadsCount;

LazyTables::LazyTables()
{

	for (int i = 0; i < 16; i++)
	{
		for (int j = 0; j < 16; j++)
		{
			int idx = (i << 4) | j;
			int d = abs(i - j);
			distR[idx] = d * 3;		// NOTE: these 3,4,2 coef instead of standard one seems to give better results!! Probably because of RGB444?
			distG[idx] = d * 4;		// I've also tried 3,5,2 and 3,6,1 but was a bit off
			distB[idx] = d * 2;
			// square
			distR[idx] *= distR[idx];
			distG[idx] *= distG[idx];
			distB[idx] *= distB[idx];

			assert(distR[idx] + distG[idx] + distB[idx] < 1 << 13);
		}
	}

	gThreadsCount = std::thread::hardware_concurrency();
	if (gThreadsCount <= 0)
		gThreadsCount = 1;
	else if (gThreadsCount > kMaxThreads)
		gThreadsCount = kMaxThreads;

}

int	LazyTables::distR[16*16];
int	LazyTables::distG[16*16];
int	LazyTables::distB[16*16];

BruteForceHam::BruteForceHam()
{
	m_original = NULL;
}

BruteForceHam::~BruteForceHam()
{
}

// This function directly return the best color ( without even needing HAM code )
// there is a 5bits "sorting" code added to be sure we get the exact same behavior than findBestPixel in case of same color distance
Color444	BruteForceHam::getBestHAMColor(const Color444 original, const Color444 previous, ColorError_t& errOut, const Color444* pal, int palSize) const
{
	u32 err = ~0;
	// warning: the HAM result depends of the order of loops here. If a color during R search have same distance as another color in G search,
	// then we don't want the lowest bit influence the compare. That's why we add 2 "sorting" bits 6 & 7
	const int oR = original.GetR();
	const int oG = original.GetG();
	const int oB = original.GetB();
	const ColorError_t distR = Color444::DistanceR(oR, previous.GetR());
	const ColorError_t distG = Color444::DistanceG(oG, previous.GetG());
	const ColorError_t distB = Color444::DistanceB(oB, previous.GetB());
	const int prevValue = previous.GetRGB444();

	// Finding best HAM code doesn't need a loop per component. Just consider best distance for each component is 0
	u32 d;
	d = ((distG + distB) << 17) | (0 << 12) | (oR<<8) | (prevValue & 0x0ff);
	err = (d < err) ? d : err;
	d = ((distR + distB) << 17) | (1 << 12) | (oG<<4) | (prevValue & 0xf0f);
	err = (d < err) ? d : err;
	d = ((distR + distG) << 17) | (2 << 12) | (oB<<0) | (prevValue & 0xff0);
	err = (d < err) ? d : err;

	// Then finally, try to find a better solution in the palette
	u32 sort = 3 << 12;		// sort codes 0,1 and 2 are already used by previous 3 HAM checks
	for (int p = 0; p < palSize; p++)
	{
		u32 d = original.Distance(pal[p]);
		d = (d << 17) | sort | pal[p].GetRGB444();					// be sure palette is always greater than RGB similar distance!
		err = (d < err) ? d : err;
		sort += 1 << 12;	// each palette entry have a increasing sort code
	}

 	errOut = err >> 17;
 	Color444 newPixel;
 	newPixel.SetRGB444(err & 0xfff);
 	return newPixel;
}


Color444	BruteForceHam::findBestPixelSlow(const Color444 original, const Color444 previous, ColorError_t& errOut, const Color444* pal, int palSize, HamPixelState& state) const
{
	unsigned int err = ~0;	
	// warning: the HAM result depends of the order of loops here. If a color during R search have same distance as another color in G search,
	// then we don't want the lowest bit influence the compare. That's why we add 2 "sorting" bits 6 & 7
	const int oR = original.GetR();
	const int oG = original.GetG();
	const int oB = original.GetB();
	const ColorError_t distR = Color444::DistanceR(oR, previous.GetR());
	const ColorError_t distG = Color444::DistanceG(oG, previous.GetG());
	const ColorError_t distB = Color444::DistanceB(oB, previous.GetB());

	u32 d = ((distG + distB)<<8)|((0 << 6) | (2 << 4) | oR);	// R ham code is 10;
	err = (d < err) ? d : err;
	d = ((distR + distB)<<8)|((1 << 6) | (3 << 4) | oG);	// G ham code is 11;
	err = (d < err) ? d : err;
	d = ((distR + distG)<<8)|((2 << 6) | (1 << 4) | oB);	// B ham code is 01;
	err = (d < err) ? d : err;

	// Then finally, try to find a better solution in the palette
	for (int p = 0; p < palSize; p++)
	{
		unsigned int d = original.Distance(pal[p]);
		d = (d<<8) | (3<<6) | p;					// be sure palette is always greater than RGB similar distance!
		err = (d < err) ? d : err;
	}

	errOut = err>>8;
	Color444 newPixel;

	int hamCode = err & 0x3f;
	newPixel = previous;
	// setup new pixel value
	switch ((hamCode>>4)&3)
	{
	case 0:
		newPixel = pal[hamCode & 15];
		break;
	case 1:
		newPixel.SetB4(hamCode & 15);
		break;
	case 2:
		newPixel.SetR4(hamCode & 15);
		break;
	case 3:
		newPixel.SetG4(hamCode & 15);
		break;
	}
	state.hamCode = hamCode>>4;
	state.hamIndex = hamCode & 15;
	return newPixel;
}

int	BruteForceHam::findBestPixelMPP(const Color444& original, ColorError_t& errOut, const Color444* pal, int palSize) const
{
	ColorError_t err = kColorErrorMax;
	int pixelId = 0;
	// first, search in the current palette
	for (int p = 0; p < palSize; p++)
	{
		ColorError_t d = original.Distance(pal[p]);
		if (d < err)
		{
			pixelId = p;
			err = d;
		}
	}
	errOut = err;
	return pixelId;
}

ColorError_t	BruteForceHam::LineErrorCompute(int y, const Color444* palette, int palSize) const
{
	const Color444* pr = m_original + y * m_w;

	ColorError_t err = 0;
	Color444 prevColor = palette[0];	// current color on first pixel is background color
	for (unsigned int x = 0; x < m_w; x++)
	{
		// search best fit in palette
		ColorError_t pixelErr;
		prevColor = getBestHAMColor(pr[x], prevColor, pixelErr, palette, palSize);
		err += pixelErr;
	}
	return err;
}

ColorError_t	BruteForceHam::LineErrorComputeMPP(int y, const Color444* palette, int palSize) const
{
	ColorError_t err = 0;
	const Color444* pr = m_original + y * m_w;
	for (unsigned int x = 0; x < m_w; x++)
	{
		// search best fit in palette
		ColorError_t pixelErr;
		findBestPixelMPP(pr[x], pixelErr, palette, palSize);
		err += pixelErr;
	}
	return err;
}

ColorError_t	BruteForceHam::ErrorCompute(const Color444* palette, int palSize) const
{
	ColorError_t err = 0;
	for (unsigned y = 0; y < m_h; y++)
	{
		err += LineErrorCompute(y, palette, palSize);
	}
	return err;
}

ColorError_t	BruteForceHam::ErrorComputeSinglePal(const Color444* palette, int palSize) const
{
	ColorError_t err = 0;
	for (unsigned y = 0; y < m_h; y++)
	{
		err += LineErrorComputeMPP(y, palette, palSize);
	}
	return err;
}

unsigned long threadMainHAM(void *pUser)
{
	BruteForceHam::ThreadState* state = (BruteForceHam::ThreadState*)pUser;

	ColorError_t best = kColorErrorMax;
	int bestBruteColor;
	for (int bruteColor = state->rangeStart; bruteColor < state->rangeEnd; bruteColor++)
	{
		state->pal[state->currentPalIndex].SetRGB444(bruteColor);
		ColorError_t error = state->solver->ErrorCompute(state->pal, state->palSize);
		if (error < best)
		{
			bestBruteColor = bruteColor;
			best = error;
		}
	}
	state->bestBruteColor = bestBruteColor;
	state->bestError = best;
	return 0;
}

unsigned long threadMainSinglePal(void *pUser)
{
	BruteForceHam::ThreadState* state = (BruteForceHam::ThreadState*)pUser;

	ColorError_t best = kColorErrorMax;
	int bestBruteColor;
	for (int bruteColor = state->rangeStart; bruteColor < state->rangeEnd; bruteColor++)
	{
		state->pal[state->currentPalIndex].SetRGB444(bruteColor);
		ColorError_t error = state->solver->ErrorComputeSinglePal(state->pal, state->palSize);
		if (error < best)
		{
			bestBruteColor = bruteColor;
			best = error;
		}
	}
	state->bestBruteColor = bestBruteColor;
	state->bestError = best;
	return 0;
}



unsigned long threadMainSHAM(void *pUser)
{
	BruteForceHam::ThreadState* state = (BruteForceHam::ThreadState*)pUser;
	for (int line = state->rangeStart; line < state->rangeEnd; line++)
	{
		Color444* palette = state->mpp_palettes + line * 16;
		for (int palEntry = 1; palEntry < 16; palEntry++)		// no use to search color 0 ( fixed to black )
		{
			ColorError_t best = kColorErrorMax;
			int bestBruteColor;
			for (int bruteColor = 0; bruteColor < 4096; bruteColor++)
			{
				palette[palEntry].SetRGB444(bruteColor);
				ColorError_t error = state->solver->LineErrorCompute(line, palette, palEntry + 1);
				if (error < best)
				{
					bestBruteColor = bruteColor;
					best = error;
				}
			}
			palette[palEntry].SetRGB444(bestBruteColor);
		}
	}
	return 0;
}


unsigned long threadMainMpp(void *pUser)
{
	BruteForceHam::ThreadState* state = (BruteForceHam::ThreadState*)pUser;

	for (int line = state->rangeStart; line < state->rangeEnd; line++)
	{
		Color444* pal = state->mpp_palettes + (line << state->mpp_strideShift);
		ColorError_t best = kColorErrorMax;
		int bestBruteColor;
		for (int bruteColor = 0; bruteColor < 4096; bruteColor++)
		{
			pal[state->currentPalIndex].SetRGB444(bruteColor);
			ColorError_t error = state->solver->LineErrorComputeMPP(line, pal, state->palSize);
			if (error < best)
			{
				bestBruteColor = bruteColor;
				best = error;
			}
		}
		// store best color
		pal[state->currentPalIndex].SetRGB444(bestBruteColor);
	}
	return 0;
}

void	BruteForceHam::SplitRanges(ThreadState* ts, int threadCount, int maxRange)
{
	int rangeStart = 0;
	for (int i = 0; i < threadCount; i++)
	{
		ts[i].rangeStart = rangeStart;
		if (i < threadCount - 1)
			ts[i].rangeEnd = rangeStart + maxRange / threadCount;
		else
			ts[i].rangeEnd = maxRange;

		rangeStart = ts[i].rangeEnd;
	}
}

void	BruteForceHam::BestHAMPaletteSearch(Color444* bitmap, int w, int h, Color444* palette, const ConvertParams& params)
{
	m_w = w;
	m_h = h;

	bool verbose = params.hamDebug;
	m_original = bitmap;

	clock_t t0 = clock();

	if (params.gpu)
	{
		Dx11Manager dx11;
		printf("  Brute force single palette search for HAM mode, GPU mode...\n");
		bool gpuResult = dx11.bestHAMPaletteCompute(bitmap, w, h, palette);
	}
	else
	{


		// classic HAM, one 16 colors palette for complete image
		printf("  Brute force palette search for HAM mode, CPU, %d threads running...\n", gThreadsCount);

		for (int pi = 0; pi < 16; pi++)
		{
			int bestBruteColor = 0;
			int palSize = pi + 1;
			printf("Compute pal entry %d/%d...\n", pi + 1, 16);

			if (pi > 0)	// do not search for background color ( supposed to be BLACK )
			{
				// create and start all threads
				SplitRanges(states, gThreadsCount, 4096);
				for (int i = 0; i < gThreadsCount; i++)
				{
					memcpy(states[i].pal, palette, 16 * sizeof(Color444));
					states[i].palSize = palSize;
					states[i].solver = this;
					states[i].currentPalIndex = pi;
					hThreads[i] = (void*)CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)threadMainHAM, states + i, 0, NULL);
				}

				// wait for all threads to finish
				WaitForMultipleObjects(gThreadsCount, hThreads, TRUE, INFINITE);

				// now get the best result
				ColorError_t best = kColorErrorMax;
				for (int r = 0; r < gThreadsCount; r++)
				{
					if (states[r].bestError < best)
					{
						bestBruteColor = states[r].bestBruteColor;
						best = states[r].bestError;
					}
					CloseHandle(hThreads[r]);
				}
				// set the best color in the palette
				palette[pi].SetRGB444(bestBruteColor);
			}

			if (verbose)
			{
				char sTmp[_MAX_PATH];
				sprintf_s(sTmp, "abc2_ham_c%02d.png", pi);
				printf("HAM Debug: saving intermediate HAM result \"%s\"\n", sTmp);
				HamDebugSave(palette, 16, sTmp);
			}
		}
	}

	t0 = clock() - t0;
	int ms = (t0 * 1000) / CLOCKS_PER_SEC;
	int sec = ms/1000;
	printf("HAM CPU Searching time: %dm%02ds%03dms\n", sec / 60, sec % 60, ms%1000);

}


void	BruteForceHam::BestSHAMPaletteSearch(Color444* bitmap, int w, int h, Color444* palette, const ConvertParams& params)
{
	m_w = w;
	m_h = h;

	bool verbose = params.hamDebug;
	m_original = bitmap;

	int threadsCount = std::thread::hardware_concurrency();
	if (threadsCount <= 0)
		threadsCount = 1;
	else if (threadsCount > kMaxThreads)
		threadsCount = kMaxThreads;

	ThreadState states[kMaxThreads];
	void*	hThreads[kMaxThreads];

	clock_t t0 = clock();

	{
		// extended SHAM mode ( one palette per line )

		if (params.gpu)
		{
			Dx11Manager dx11;
			printf("  Brute force palette search for S-HAM mode, GPU mode...\n");
			bool gpuResult = dx11.bestSHAMPaletteCompute(bitmap, w, h, palette);
		}
		else
		{
			printf("  Brute force palette search for SHAM mode, CPU mode, %d threads running...\n", threadsCount);
			SplitRanges(states, threadsCount, m_h);			// in SHAM we split thread work per lines!
			for (int i = 0; i < threadsCount; i++)
			{
				states[i].mpp_palettes = palette;
				states[i].solver = this;
				hThreads[i] = (void*)CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)threadMainSHAM, states + i, 0, NULL);
			}

			// wait for all threads to finish
			WaitForMultipleObjects(threadsCount, hThreads, TRUE, INFINITE);
		}
	}

	t0 = clock() - t0;
	int ms = (t0 * 1000) / CLOCKS_PER_SEC;
	int sec = ms / 1000;
	printf("S-HAM %s Searching time: %dm%02ds%03dms\n", params.gpu?"GPU":"CPU", sec / 60, sec % 60, ms % 1000);

}


void	BruteForceHam::BestMultiPaletteSearch(Color444* bitmap, int w, int h, AmigAtariBitmap& out, Color444* palettes, const ConvertParams& params)
{
	m_w = w;
	m_h = h;

	assert(params.bitplanCount > 0);
	const int colorCount = 1 << params.bitplanCount;

	m_original = bitmap;
	clock_t t0 = clock();

	if (params.gpu)
	{
		Dx11Manager dx11;
		printf("  Running GPU Compute shader MPP (Multi-Palette) Brute-Force search...\n");
		bool gpuResult = dx11.bestMppPaletteCompute(bitmap, w, h, palettes, params.bitplanCount);
	}
	else
	{
		printf("  Brute force Multi Palette palette search, CPU mode, %d threads running...\n", gThreadsCount);


		for (int pi = 0; pi < colorCount; pi++)
		{
			int bestBruteColor = 0;
			int palSize = pi + 1;
			printf("Compute pal entry %d/%d...\n", pi + 1, colorCount);

			if (pi > 0)	// do not search for background color ( supposed to be BLACK )
			{
				// create and start all threads
				SplitRanges(states, gThreadsCount, m_h);
				for (int i = 0; i < gThreadsCount; i++)
				{
					states[i].mpp_palettes = palettes;
					states[i].mpp_strideShift = params.bitplanCount;
					states[i].palSize = palSize;
					states[i].solver = this;
					states[i].currentPalIndex = pi;
					hThreads[i] = (void*)CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)threadMainMpp, states + i, 0, NULL);
				}

				// wait for all threads to finish
				WaitForMultipleObjects(gThreadsCount, hThreads, TRUE, INFINITE);

				for (int r = 0; r < gThreadsCount; r++)
					CloseHandle(hThreads[r]);
			}
		}
	}

	out.m_bpc = params.bitplanCount;		// 
	out.m_w = m_w;
	out.m_h = m_h;
	out.m_ham = false;
	out.m_multiPalette = true;
	out.m_palettes = (Color444*)malloc(m_h*colorCount * sizeof(Color444));			// 16 colors
	out.m_pixels = (u8*)malloc(out.m_w*out.m_h);

	// store palette
	memcpy(out.m_palettes, palettes, m_h*colorCount * sizeof(Color444));

	const Color444* pr = m_original;
	for (int y = 0; y < int(m_h); y++)
	{
		ColorError_t err;
		u8* pixels = out.m_pixels + y * m_w;
		for (unsigned int x = 0; x < m_w; x++)
		{
			*pixels++ = findBestPixelMPP(*pr++, err, palettes+colorCount*y, colorCount);
		}
	}

	t0 = clock() - t0;
	int ms = (t0 * 1000) / CLOCKS_PER_SEC;
	int sec = ms / 1000;
	printf("Single palette brute force CPU Searching time: %dm%02ds%03dms\n", sec / 60, sec % 60, ms % 1000);
}

void	BruteForceHam::BestPaletteSearch(Color444* bitmap, int w, int h, AmigAtariBitmap& out, Color444* palette, const ConvertParams& params)
{
	m_w = w;
	m_h = h;

	m_original = bitmap;

	clock_t t0 = clock();
	const int colorCount = 1 << params.bitplanCount;

	if (params.gpu)
	{
		Dx11Manager dx11;
		printf("  Brute force %d colors palette search, GPU compute shader...\n", colorCount);
		bool gpuResult = dx11.bestSinglePaletteCompute(bitmap, w, h, palette, params.bitplanCount);
	}
	else
	{
		// classic HAM, one 16 colors palette for complete image
		printf("  Brute force %d colors palette search, CPU, %d threads running...\n", colorCount, gThreadsCount);
		for (int pi = 0; pi < colorCount; pi++)
		{
			int bestBruteColor = 0;
			int palSize = pi + 1;
			printf("Compute pal entry %d/%d...\n", pi + 1, colorCount);

			if (pi > 0)	// do not search for background color ( supposed to be BLACK )
			{
				if (params.forceColors[pi] < 0)
				{
					// create and start all threads
					SplitRanges(states, gThreadsCount, 4096);
					for (int i = 0; i < gThreadsCount; i++)
					{
						memcpy(states[i].pal, palette, colorCount * sizeof(Color444));
						states[i].palSize = palSize;
						states[i].solver = this;
						states[i].currentPalIndex = pi;
						hThreads[i] = (void*)CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)threadMainSinglePal, states + i, 0, NULL);
					}

					// wait for all threads to finish
					WaitForMultipleObjects(gThreadsCount, hThreads, TRUE, INFINITE);

					// now get the best result
					ColorError_t best = kColorErrorMax;
					for (int r = 0; r < gThreadsCount; r++)
					{
						if (states[r].bestError < best)
						{
							bestBruteColor = states[r].bestBruteColor;
							best = states[r].bestError;
						}
						CloseHandle(hThreads[r]);
					}
				}
				else
				{
					bestBruteColor = params.forceColors[pi];
				}
				// set the best color in the palette
				palette[pi].SetRGB444(bestBruteColor);

			}
		}
	}
	t0 = clock() - t0;
	int ms = (t0 * 1000) / CLOCKS_PER_SEC;
	int sec = ms / 1000;
	printf("Single palette brute force Searching time: %dm%02ds%03dms\n", sec / 60, sec % 60, ms % 1000);

	out.m_bpc = params.bitplanCount;		// 
	out.m_w = m_w;
	out.m_h = m_h;
	out.m_ham = false;
	out.m_multiPalette = false;
	out.m_palettes = (Color444*)malloc(colorCount * sizeof(Color444));			// 16 colors
	out.m_pixels = (u8*)malloc(out.m_w*out.m_h);

	// store palette
	memcpy(out.m_palettes, palette, colorCount * sizeof(Color444));

	const Color444* pr = m_original;
	for (int y = 0; y < int(m_h); y++)
	{
		ColorError_t err;
		u8* pixels = out.m_pixels + y * m_w;
		for (unsigned int x = 0; x < m_w; x++)
		{
			*pixels++ = findBestPixelMPP(*pr++, err, palette, colorCount);
		}
	}

}


void	BruteForceHam::HamStore(AmigAtariBitmap& out, const Color444* palette, bool multiPalette)
{
	out.m_bpc = 6;		// ham6 has 6 bitplans
	out.m_w = m_w;
	out.m_h = m_h;
	out.m_ham = true;
	out.m_multiPalette = multiPalette;
	int palEntries = multiPalette ? 16 * m_h : 16;

	out.m_palettes = (Color444*)malloc(palEntries * sizeof(Color444));			// 16 colors
	out.m_pixels = (u8*)malloc(out.m_w*out.m_h);

	// store palette
	memcpy(out.m_palettes, palette, palEntries * sizeof(Color444));

	const Color444* pr = m_original;
	for (int y = 0;y<int(m_h);y++)
	{
		const Color444* pal = palette;
		if (multiPalette)
			pal += y * 16;
		Color444 previous = pal[0];
		ColorError_t err;
		HamPixelState state;
		u8* hamPixels = out.m_pixels+y*m_w;
		for (unsigned int x = 0; x < m_w; x++)
		{
			Color444 result = findBestPixelSlow(*pr++, previous, err, pal, 16, state);
			*hamPixels++ = (state.hamCode << 4) | state.hamIndex;
			previous = result;
		}
	}
}

void	SaveRGBPcPreview(const Color444* img, int w, int h, const char* sFilename)
{
	pngPixel* tmpImage = (pngPixel*)malloc(w*h*sizeof(pngPixel));
	pngPixel* pw = tmpImage;
	for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			pngPixel color = img->ToPngPixel();
			*pw++ = color;
			img++;
		}
	}
	pngRGBASave(sFilename, tmpImage, w, h);
	free(tmpImage);
}

static pngPixel ColorMix(const pngPixel& ca, const pngPixel& cb)
{
	int r = (int(ca.r) + int(cb.r)) >> 1;
	int g = (int(ca.g) + int(cb.g)) >> 1;
	int b = (int(ca.b) + int(cb.b)) >> 1;
	pngPixel res;
	res.r = u8(r);
	res.g = u8(g);
	res.b = u8(b);
	res.a = 255;
	return res;
}

void	SaveSHAM5bPcPreview(const Color444* imgA, int w, int h, const char* sFilename)
{

	assert(0 == (h & 1));		// h should be multiple of 2
	pngPixel* tmpImage = (pngPixel*)malloc(w*(h/2) * sizeof(pngPixel));
	pngPixel* pw = tmpImage;

	const Color444* imgB = imgA + w * (h / 2);
	for (int y = 0; y < h/2; y++)
	{
		for (int x = 0; x < w; x++)
		{
			pngPixel colA = imgA->ToPngPixel();
			pngPixel colB = imgB->ToPngPixel();
			pngPixel cmix = ColorMix(colA, colB);
			*pw++ = cmix;
			imgA++;
			imgB++;
		}
	}
	pngRGBASave(sFilename, tmpImage, w, h/2);
	free(tmpImage);
}

void	BruteForceHam::HamDebugSave(const Color444* palette, int colorCount, const char* pngFilename)
{
	pngPixel* tmpImage = (pngPixel*)malloc(m_w*m_h * sizeof(pngPixel));
	pngPixel* pw = tmpImage;

	assert(colorCount >= 0);
	assert(colorCount <= 16);
	assert(m_original);

	const Color444* pr = m_original;
	HamPixelState state;
	for (unsigned int y = 0; y < m_h; y++)
	{
		Color444 previous = palette[0];
		ColorError_t err;
		for (unsigned int x = 0; x < m_w; x++)
		{
			Color444 result = findBestPixelSlow(*pr++, previous, err, palette, colorCount, state);
			pngPixel color = result.ToPngPixel();
			*pw++ = color;
			previous = result;
		}
	}
	pngRGBASave(pngFilename, tmpImage, m_w, m_h);
	free(tmpImage);
}
