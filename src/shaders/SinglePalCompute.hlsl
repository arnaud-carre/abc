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

uint	getBestColor(in uint original, in int scanline, in uint currentBruteforceColor)
{
	uint err = 0xffffffff;

	// try to find a better solution in the palette
	uint sort = 0 << 12;
	uint d;

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

	return (err >> 17);
}

uint	LineErrorCompute(in int scanline, in uint bruteForceColor)
{

	uint err = 0;
	uint readImgAd = scanline * m_w * 4;
	[loop]
	for (uint x = 0; x < m_w; x++)
	{
		// search best fit in palette
		err += getBestColor(inImage.Load(readImgAd), scanline, bruteForceColor);
		readImgAd += 4;
	}
	return err;
}

[numthreads(MY_THREAD_GROUP_SIZE, 1, 1)]
void SinglePalKernel( uint3 DTid : SV_GroupID, uint3 TGid : SV_GroupThreadID)
{
	uint bruteColor = DTid.y*MY_THREAD_GROUP_SIZE+TGid.x;
	uint scanline = DTid.x;

	uint err = LineErrorCompute(scanline, bruteColor);

	inOutErrors.InterlockedAdd(bruteColor * 4, err);
}
