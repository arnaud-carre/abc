/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#include <assert.h>
#include <string.h>
#include "pngFile.h"
#include "extern/libspng/spng.h"

pngFile::pngFile()
{
	m_palette = NULL;
	m_image = NULL;
	m_w = 0;
	m_h = 0;
	m_colorCount = 0;
}

pngFile::~pngFile()
{
	Release();
}

void	pngFile::Release()
{
	free(m_image);
	free(m_palette);
	m_image = NULL;
	m_palette = NULL;
	m_w = 0;
	m_h = 0;
	m_colorCount = 0;
}

bool	pngFile::GetPixelIndex(uint32_t x, uint32_t y, uint8_t& index) const
{
	assert(IsValid());
	if ((x >= m_w) || (y >= m_h))
		return false;

	if (NULL == m_palette)
		return false;

	index = m_image[y*m_w + x];
	return true;
}

bool pngFile::GetPixelColor(uint32_t x, uint32_t y, pngPixel& color) const
{
	assert(IsValid());
	if ((x >= m_w) || (y >= m_h))
		return false;

	if (m_palette)
	{
		uint8_t index;
		GetPixelIndex(x, y, index);
		color = m_palette[index];
	}
	else
	{
		const pngPixel* pr = (const pngPixel*)m_image;
		color = pr[y*m_w + x];
	}
	return true;
}

bool	pngFile::ConvertTo24bits()
{
	assert(IsValid());
	if (NULL == m_palette)
		return true;

	pngPixel* newBuffer = (pngPixel*)malloc(m_w * m_h * sizeof(pngPixel));
	uint32_t count = m_w * m_h;
	const uint8_t* pr = m_image;
	pngPixel* wp = newBuffer;
	for (uint32_t i = 0; i < count; i++)
	{
		*wp++ = m_palette[*pr++];
	}
	free(m_image);
	free(m_palette);
	m_palette = NULL;
	m_image = (uint8_t*)newBuffer;
	return true;
}

bool	pngFile::Load(const char* filename)
{

	bool bret = false;

	FILE* png = fopen(filename, "rb");
	if (png == NULL)
		return false;

	Release();

	spng_ctx *ctx = spng_ctx_new(0);

	if (ctx)
	{

		/* Ignore and don't calculate chunk CRC's */
		spng_set_crc_action(ctx, SPNG_CRC_USE, SPNG_CRC_USE);

		/* Set memory usage limits for storing standard and unknown chunks,
		   this is important when reading untrusted files! */
		size_t limit = 1024 * 1024 * 64;
		spng_set_chunk_limits(ctx, limit, limit);

		/* Set source PNG */
		spng_set_png_file(ctx, png); /* or _buffer(), _stream() */

		struct spng_ihdr ihdr;
		int ret = spng_get_ihdr(ctx, &ihdr);

		if (0 == ret)
		{

			m_w = ihdr.width;
			m_h = ihdr.height;

			if (((SPNG_COLOR_TYPE_TRUECOLOR == ihdr.color_type) ||
				(SPNG_COLOR_TYPE_TRUECOLOR_ALPHA == ihdr.color_type) ||
				(SPNG_COLOR_TYPE_INDEXED == ihdr.color_type)) &&
				( 8 == ihdr.bit_depth))
			{
				//ihdr.bit_depth

				struct spng_plte plte = {};
				ret = spng_get_plte(ctx, &plte);

				if (ret && ret != SPNG_ECHUNKAVAIL)
				{
					printf("spng_get_plte() error: %s\n", spng_strerror(ret));
				}
				else
				{
					if (0 == ret)
					{
						m_palette = (pngPixel*)malloc(256 * sizeof(pngPixel));
						assert(sizeof(pngPixel) == sizeof(spng_plte_entry));
						memset(m_palette, 0, 256 * sizeof(pngPixel));
						assert(plte.n_entries <= 256);
						memcpy(m_palette, plte.entries, plte.n_entries * sizeof(pngPixel));
						m_colorCount = plte.n_entries;
					}

					int fmt = SPNG_FMT_RGBA8;	// by default, convert to RGBA8 at loading time

					if ( m_palette )
						fmt = SPNG_FMT_PNG;		// if color palette then keep original indexed format

					size_t image_size;
					ret = spng_decoded_image_size(ctx, fmt, &image_size);
					assert(0 == ret);

					m_image = (uint8_t*)malloc(image_size);

					/* Decode the image in one go */
					ret = spng_decode_image(ctx, (void*)m_image, image_size, fmt, 0);

					if (0 == ret)
					{
						bret = true;
					}
				}
			}
			else
			{
				printf("ERROR: Only supports indexed or 24bits PNG\n");
			}
		}
		else
		{
			printf("ERROR: unable to decode PNG header\n");
		}
		spng_ctx_free(ctx);
	}

	if (!bret)
		Release();

	return bret;
}

bool	pngRGBASave(const char* filename, const pngPixel* image, int w, int h)
{

	bool bret = false;
	/* Creating an encoder context requires a flag */
	spng_ctx* ctx = spng_ctx_new(SPNG_CTX_ENCODER);

	/* Encode to internal buffer managed by the library */
	spng_set_option(ctx, SPNG_ENCODE_TO_BUFFER, 1);

	/* Set image properties, this determines the destination image format */
	struct spng_ihdr ihdr = {}; /* zero-initialize to set valid defaults */
	ihdr.width = w;
	ihdr.height = h;
	ihdr.color_type = SPNG_COLOR_TYPE_TRUECOLOR_ALPHA;
	ihdr.bit_depth = 8;
	/* Valid color type, bit depth combinations: https://www.w3.org/TR/2003/REC-PNG-20031110/#table111 */

	spng_set_ihdr(ctx, &ihdr);

	int fmt = SPNG_FMT_PNG;

	/* SPNG_ENCODE_FINALIZE will finalize the PNG with the end-of-file marker */
	int ret = spng_encode_image(ctx, (const void*)image, w*h*4, fmt, SPNG_ENCODE_FINALIZE);

	if (0 == ret)
	{

		size_t png_size;
		void *png_buf = NULL;

		/* Get the internal buffer of the finished PNG */
		png_buf = spng_get_png_buffer(ctx, &png_size, &ret);

		if (png_buf && (png_size > 0))
		{

			FILE* h = fopen(filename, "wb");
			if (h)
			{
				fwrite(png_buf, 1, png_size, h);
				fclose(h);
				bret = true;
			}
			else
			{
				printf("ERROR: unable to write \"%s\"\n", filename);
			}

			/* User owns the buffer after a successful call */
			free(png_buf);
		}
		else
		{
			printf("ERROR: spng_get_png_buffer failed\n");
		}

	}
	else
	{
		printf("ERROR: spng_encode_image failed (%s)\n", spng_strerror(ret));
	}

	spng_ctx_free(ctx);

	return bret;
}


