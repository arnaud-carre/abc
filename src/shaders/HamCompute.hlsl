/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/

#define	MY_THREAD_GROUP_SIZE		64


RWByteAddressBuffer inOutErrors : register(u0);
ByteAddressBuffer inImage : register(t0);

cbuffer processInfo : register(b0)
{
	uint	m_w;
	uint	m_h;
	uint	m_palEntry;
	uint	m_pad;
	uint4	inPalette[32];
};

int	GetR(uint c)
{
	return (c >> 8) & 15;
}
int	GetG(uint c)
{
	return (c >> 4) & 15;
}
int	GetB(uint c)
{
	return (c >> 0) & 15;
}

uint	DistanceR(int r0, int r1)
{
	int dr = (r0-r1)*3;
	return dr * dr;
}
uint	DistanceG(int g0, int g1)
{
	int dg = (g0 - g1) * 4;
	return dg * dg;
}
uint	DistanceB(int b0, int b1)
{
	int db = (b0 - b1) * 2;
	return db * db;
}

uint	Distance(uint c0, uint c1)
{
	return DistanceR(GetR(c0), GetR(c1)) +
		DistanceG(GetG(c0), GetG(c1)) +
		DistanceB(GetB(c0), GetB(c1));
}

uint	getBestHAMColor(in uint original, in uint previous, out uint errOut, in int scanline, in uint currentBruteforceColor)
{
	uint err = 0xffffffff;
	// warning: the HAM result depends of the order of loops here. If a color during R search have same distance as another color in G search,
	// then we don't want the lowest bit influence the compare. That's why we add 2 "sorting" bits 6 & 7
	const int oR = GetR(original);
	const int oG = GetG(original);
	const int oB = GetB(original);
	const uint distR = DistanceR(oR, GetR(previous));
	const uint distG = DistanceG(oG, GetG(previous));
	const uint distB = DistanceB(oB, GetB(previous));
	uint d;
	d = ((distG + distB) << 17) | (0 << 12) | (oR << 8) | (previous & 0x0ff);
	err = (d < err) ? d : err;
	d = ((distR + distB) << 17) | (1 << 12) | (oG << 4) | (previous & 0xf0f);
	err = (d < err) ? d : err;
	d = ((distR + distG) << 17) | (2 << 12) | (oB << 0) | (previous & 0xff0);
	err = (d < err) ? d : err;

	// Then finally, try to find a better solution in the palette
	uint sort = 3 << 12;		// sort codes 0,1 and 2 are already used by previous 3 HAM checks
	[loop]
	for (uint p = 0; p < m_palEntry; p++)
	{
		uint colPal = inPalette[p].x;
		d = Distance(original,colPal);
		d = (d << 17) | sort | colPal;					// be sure palette is always greater than RGB similar distance!
		err = (d < err) ? d : err;
		sort += 1 << 12;	// each palette entry have a increasing sort code
	}
	// last iteration with current bruteforcecolor
	d = Distance(original, currentBruteforceColor);
	d = (d << 17) | sort | currentBruteforceColor;					// be sure palette is always greater than RGB similar distance!
	err = (d < err) ? d : err;

	errOut = err >> 17;
	return err&0xfff;
}

uint	LineErrorCompute(in int scanline, in uint bruteForceColor)
{

	uint prevColor = inPalette[0].x;	// current color on first pixel is background color
	uint err = 0;
	uint readImgAd = scanline * m_w * 4;
	[loop]
	for (uint x = 0; x < m_w; x++)
	{
		// search best fit in palette
		uint pixelErr;
		prevColor = getBestHAMColor(inImage.Load(readImgAd), prevColor, pixelErr, scanline, bruteForceColor);
		err += pixelErr;
		readImgAd += 4;
	}

	return err;
}

[numthreads(MY_THREAD_GROUP_SIZE, 1, 1)]
void HamKernel( uint3 DTid : SV_GroupID, uint3 TGid : SV_GroupThreadID)
{
	uint bruteColor = DTid.y*MY_THREAD_GROUP_SIZE+TGid.x;
	uint scanline = DTid.x;

	uint err = LineErrorCompute(scanline, bruteColor);

	inOutErrors.InterlockedAdd(bruteColor * 4, err);
}
