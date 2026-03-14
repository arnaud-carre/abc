/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <string.h>

#include "color.h"
#include "metalManager.h"

namespace
{
constexpr NSUInteger kSingleThreadGroupSize = 64;
constexpr NSUInteger kMultiThreadGroupSize = 128;

static void ApplyForcedColorsSingle(Color444* outPalettes, int colorCount, const int* forceColors)
{
	if (!forceColors)
		return;

	for (int palEntry = 1; palEntry < colorCount; palEntry++)
	{
		if (forceColors[palEntry] >= 0)
			outPalettes[palEntry].SetRGB444(forceColors[palEntry]);
	}
}

static void ApplyForcedColorsMulti(Color444* outPalettes, int h, int colorCount, const int* forceColors)
{
	if (!forceColors)
		return;

	for (int palEntry = 1; palEntry < colorCount; palEntry++)
	{
		if (forceColors[palEntry] < 0)
			continue;

		for (int line = 0; line < h; line++)
			outPalettes[line * colorCount + palEntry].SetRGB444(forceColors[palEntry]);
	}
}

static const char* kMetalShaderSource = R"METAL(
#include <metal_stdlib>
using namespace metal;

constant uint kSingleThreadGroupSize = 64;
constant uint kMultiThreadGroupSize = 128;
constant uint kBruteForcePerThread = 4096 / kMultiThreadGroupSize;

struct SingleProcessInfo
{
	uint w;
	uint h;
	uint palEntry;
	uint pad;
	uint inPalette[32];
};

struct MultiProcessInfo
{
	uint w;
	uint h;
	uint palEntry;
	uint palStride;
};

int GetR(uint c) { return (c >> 8) & 15; }
int GetG(uint c) { return (c >> 4) & 15; }
int GetB(uint c) { return (c >> 0) & 15; }

uint DistanceR(int r0, int r1)
{
	int dr = (r0 - r1) * 3;
	return dr * dr;
}

uint DistanceG(int g0, int g1)
{
	int dg = (g0 - g1) * 4;
	return dg * dg;
}

uint DistanceB(int b0, int b1)
{
	int db = (b0 - b1) * 2;
	return db * db;
}

uint Distance(uint c0, uint c1)
{
	return DistanceR(GetR(c0), GetR(c1)) +
		DistanceG(GetG(c0), GetG(c1)) +
		DistanceB(GetB(c0), GetB(c1));
}

uint getBestColor(uint original, uint currentBruteforceColor, constant SingleProcessInfo& processInfo)
{
	uint err = 0xffffffffu;
	uint sort = 0;

	for (uint p = 0; p < processInfo.palEntry; p++)
	{
		uint colPal = processInfo.inPalette[p];
		uint d = Distance(original, colPal);
		d = (d << 17) | sort | colPal;
		err = min(err, d);
		sort += 1 << 12;
	}

	uint d = Distance(original, currentBruteforceColor);
	d = (d << 17) | sort | currentBruteforceColor;
	err = min(err, d);

	return err >> 17;
}

uint getBestHAMColor(uint original, uint previous, thread uint& errOut, uint currentBruteforceColor, constant SingleProcessInfo& processInfo)
{
	uint err = 0xffffffffu;
	const int oR = GetR(original);
	const int oG = GetG(original);
	const int oB = GetB(original);
	const uint distR = DistanceR(oR, GetR(previous));
	const uint distG = DistanceG(oG, GetG(previous));
	const uint distB = DistanceB(oB, GetB(previous));

	uint d = ((distG + distB) << 17) | (0 << 12) | (oR << 8) | (previous & 0x0ff);
	err = min(err, d);
	d = ((distR + distB) << 17) | (1 << 12) | (oG << 4) | (previous & 0xf0f);
	err = min(err, d);
	d = ((distR + distG) << 17) | (2 << 12) | (oB << 0) | (previous & 0xff0);
	err = min(err, d);

	uint sort = 3 << 12;
	for (uint p = 0; p < processInfo.palEntry; p++)
	{
		uint colPal = processInfo.inPalette[p];
		d = Distance(original, colPal);
		d = (d << 17) | sort | colPal;
		err = min(err, d);
		sort += 1 << 12;
	}

	d = Distance(original, currentBruteforceColor);
	d = (d << 17) | sort | currentBruteforceColor;
	err = min(err, d);

	errOut = err >> 17;
	return err & 0xfff;
}

kernel void SinglePalKernel(const device uint* inImage [[buffer(0)]],
							device atomic_uint* inOutErrors [[buffer(1)]],
							constant SingleProcessInfo& processInfo [[buffer(2)]],
							uint3 groupId [[threadgroup_position_in_grid]],
							uint threadId [[thread_index_in_threadgroup]])
{
	uint bruteColor = groupId.y * kSingleThreadGroupSize + threadId;
	uint scanline = groupId.x;

	uint err = 0;
	uint readImgAd = scanline * processInfo.w;
	for (uint x = 0; x < processInfo.w; x++)
	{
		err += getBestColor(inImage[readImgAd++], bruteColor, processInfo);
	}

	atomic_fetch_add_explicit(&inOutErrors[bruteColor], err, memory_order_relaxed);
}

kernel void HamKernel(const device uint* inImage [[buffer(0)]],
					  device atomic_uint* inOutErrors [[buffer(1)]],
					  constant SingleProcessInfo& processInfo [[buffer(2)]],
					  uint3 groupId [[threadgroup_position_in_grid]],
					  uint threadId [[thread_index_in_threadgroup]])
{
	uint bruteColor = groupId.y * kSingleThreadGroupSize + threadId;
	uint scanline = groupId.x;

	uint prevColor = processInfo.inPalette[0];
	uint err = 0;
	uint readImgAd = scanline * processInfo.w;
	for (uint x = 0; x < processInfo.w; x++)
	{
		uint pixelErr;
		prevColor = getBestHAMColor(inImage[readImgAd++], prevColor, pixelErr, bruteColor, processInfo);
		err += pixelErr;
	}

	atomic_fetch_add_explicit(&inOutErrors[bruteColor], err, memory_order_relaxed);
}

uint getBestMPPColor(uint original, uint scanline, uint currentBruteforceColor, const device uint* inOutPalettes, constant MultiProcessInfo& processInfo)
{
	uint err = 0xffffffffu;
	uint sort = 0;

	for (uint p = 0; p < processInfo.palEntry; p++)
	{
		uint colPal = inOutPalettes[(scanline << processInfo.palStride) + p];
		uint d = Distance(original, colPal);
		d = (d << 17) | sort | colPal;
		err = min(err, d);
		sort += 1 << 12;
	}

	uint d = Distance(original, currentBruteforceColor);
	d = (d << 17) | sort | currentBruteforceColor;
	err = min(err, d);

	return err >> 17;
}

uint getBestSHAMColor(uint original, uint previous, thread uint& errOut, uint scanline, uint currentBruteforceColor, const device uint* inOutPalettes, constant MultiProcessInfo& processInfo)
{
	uint err = 0xffffffffu;
	const int oR = GetR(original);
	const int oG = GetG(original);
	const int oB = GetB(original);
	const uint distR = DistanceR(oR, GetR(previous));
	const uint distG = DistanceG(oG, GetG(previous));
	const uint distB = DistanceB(oB, GetB(previous));

	uint d = ((distG + distB) << 17) | (0 << 12) | (oR << 8) | (previous & 0x0ff);
	err = min(err, d);
	d = ((distR + distB) << 17) | (1 << 12) | (oG << 4) | (previous & 0xf0f);
	err = min(err, d);
	d = ((distR + distG) << 17) | (2 << 12) | (oB << 0) | (previous & 0xff0);
	err = min(err, d);

	uint sort = 3 << 12;
	for (uint p = 0; p < processInfo.palEntry; p++)
	{
		uint colPal = inOutPalettes[scanline * 16 + p];
		d = Distance(original, colPal);
		d = (d << 17) | sort | colPal;
		err = min(err, d);
		sort += 1 << 12;
	}

	d = Distance(original, currentBruteforceColor);
	d = (d << 17) | sort | currentBruteforceColor;
	err = min(err, d);

	errOut = err >> 17;
	return err & 0xfff;
}

kernel void MppKernel(const device uint* inImage [[buffer(0)]],
					  device uint* inOutPalettes [[buffer(1)]],
					  constant MultiProcessInfo& processInfo [[buffer(2)]],
					  uint3 groupId [[threadgroup_position_in_grid]],
					  uint threadId [[thread_index_in_threadgroup]])
{
	threadgroup atomic_uint sharedBestError;
	threadgroup uint sharedBestColor[kMultiThreadGroupSize];

	uint scanline = groupId.x;
	uint colorChunk = threadId;

	if (colorChunk == 0)
		atomic_store_explicit(&sharedBestError, 0xffffffffu, memory_order_relaxed);

	threadgroup_barrier(mem_flags::mem_threadgroup);

	const uint bruteForceColorStart = colorChunk * kBruteForcePerThread;
	uint bestColor = 0;
	uint bestError = 0xffffffffu;
	for (uint bruteForceColor = bruteForceColorStart; bruteForceColor < bruteForceColorStart + kBruteForcePerThread; bruteForceColor++)
	{
		uint imgAd = scanline * processInfo.w;
		uint err = 0;
		for (uint x = 0; x < processInfo.w; x++)
		{
			err += getBestMPPColor(inImage[imgAd++], scanline, bruteForceColor, inOutPalettes, processInfo);
		}

		if (err < bestError)
		{
			bestError = err;
			bestColor = bruteForceColor;
		}
	}

	sharedBestColor[colorChunk] = bestColor;
	bestError = (bestError * kMultiThreadGroupSize) | colorChunk;
	atomic_fetch_min_explicit(&sharedBestError, bestError, memory_order_relaxed);

	threadgroup_barrier(mem_flags::mem_threadgroup);

	if (colorChunk == 0)
	{
		const uint bestIndex = atomic_load_explicit(&sharedBestError, memory_order_relaxed) & (kMultiThreadGroupSize - 1);
		inOutPalettes[(scanline << processInfo.palStride) + processInfo.palEntry] = sharedBestColor[bestIndex];
	}
}

kernel void ShamKernel(const device uint* inImage [[buffer(0)]],
					   device uint* inOutPalettes [[buffer(1)]],
					   constant MultiProcessInfo& processInfo [[buffer(2)]],
					   uint3 groupId [[threadgroup_position_in_grid]],
					   uint threadId [[thread_index_in_threadgroup]])
{
	threadgroup atomic_uint sharedBestError;
	threadgroup uint sharedBestColor[kMultiThreadGroupSize];

	uint scanline = groupId.x;
	uint colorChunk = threadId;

	if (colorChunk == 0)
		atomic_store_explicit(&sharedBestError, 0xffffffffu, memory_order_relaxed);

	threadgroup_barrier(mem_flags::mem_threadgroup);

	const uint bruteForceColorStart = colorChunk * kBruteForcePerThread;
	uint bestColor = 0;
	uint bestError = 0xffffffffu;
	for (uint bruteForceColor = bruteForceColorStart; bruteForceColor < bruteForceColorStart + kBruteForcePerThread; bruteForceColor++)
	{
		uint prevColor = inOutPalettes[scanline * 16];
		uint imgAd = scanline * processInfo.w;
		uint err = 0;
		for (uint x = 0; x < processInfo.w; x++)
		{
			uint pixelErr;
			prevColor = getBestSHAMColor(inImage[imgAd++], prevColor, pixelErr, scanline, bruteForceColor, inOutPalettes, processInfo);
			err += pixelErr;
		}

		if (err < bestError)
		{
			bestError = err;
			bestColor = bruteForceColor;
		}
	}

	sharedBestColor[colorChunk] = bestColor;
	bestError = (bestError * kMultiThreadGroupSize) | colorChunk;
	atomic_fetch_min_explicit(&sharedBestError, bestError, memory_order_relaxed);

	threadgroup_barrier(mem_flags::mem_threadgroup);

	if (colorChunk == 0)
	{
		const uint bestIndex = atomic_load_explicit(&sharedBestError, memory_order_relaxed) & (kMultiThreadGroupSize - 1);
		inOutPalettes[scanline * 16 + processInfo.palEntry] = sharedBestColor[bestIndex];
	}
}
)METAL";
}

struct MetalManager::Impl
{
	struct SingleProcessInfo
	{
		uint32_t w;
		uint32_t h;
		uint32_t palEntry;
		uint32_t pad;
		uint32_t inPalette[32];
	};

	struct MultiProcessInfo
	{
		uint32_t w;
		uint32_t h;
		uint32_t palEntry;
		uint32_t palStride;
	};

	id<MTLDevice> device = nil;
	id<MTLLibrary> library = nil;
	id<MTLCommandQueue> queue = nil;
	id<MTLComputePipelineState> hamPipeline = nil;
	id<MTLComputePipelineState> shamPipeline = nil;
	id<MTLComputePipelineState> mppPipeline = nil;
	id<MTLComputePipelineState> singlePalPipeline = nil;

	enum class Kernel
	{
		Ham,
		Sham,
		Mpp,
		SinglePal,
	};

	bool initialize();
	bool buildPipeline(NSString* functionName, id<MTLComputePipelineState> __strong *pipeline);
	id<MTLComputePipelineState> pipeline(Kernel kernel) const;
	id<MTLBuffer> makeBuffer(NSUInteger size, const void* data);
	bool runSingle(Kernel kernel, const Color444* image, int w, int h, Color444* outPalettes, int bpc, const int* forceColors);
	bool runMulti(Kernel kernel, const Color444* image, int w, int h, Color444* outPalettes, int bpc, bool hamLayout, const int* forceColors);
};

bool MetalManager::Impl::buildPipeline(NSString* functionName, id<MTLComputePipelineState> __strong *pipeline)
{
	id<MTLFunction> function = [library newFunctionWithName:functionName];
	if (!function)
	{
		printf("ERROR: Unable to find Metal function %s\n", [functionName UTF8String]);
		return false;
	}

	NSError* error = nil;
	*pipeline = [device newComputePipelineStateWithFunction:function error:&error];
	if (!*pipeline)
	{
		printf("ERROR: Unable to create Metal compute pipeline %s: %s\n", [functionName UTF8String], [[error localizedDescription] UTF8String]);
		return false;
	}

	return true;
}

bool MetalManager::Impl::initialize()
{
	if (device)
		return true;

	device = MTLCreateSystemDefaultDevice();
	if (!device)
	{
		printf("ERROR: MTLCreateSystemDefaultDevice() returned nil\n");
		NSArray<id<MTLDevice>>* devices = MTLCopyAllDevices();
		printf("  MTLCopyAllDevices() found %lu device(s)\n", (unsigned long)[devices count]);
		printf("  This usually means the current process cannot access a Metal device in this runtime environment.\n");
		printf("  If this is unexpected, try running abc2 directly from Terminal.app instead of a sandboxed tool.\n");
		return false;
	}

	printf("GPU detected: %s\n", [[device name] UTF8String]);

	queue = [device newCommandQueue];
	if (!queue)
	{
		printf("ERROR: Unable to create Metal command queue\n");
		return false;
	}

	NSError* error = nil;
	NSString* shaderSource = [NSString stringWithUTF8String:kMetalShaderSource];
	library = [device newLibraryWithSource:shaderSource options:nil error:&error];
	if (!library)
	{
		printf("ERROR: Unable to compile Metal shaders: %s\n", [[error localizedDescription] UTF8String]);
		return false;
	}

	return buildPipeline(@"HamKernel", &hamPipeline)
		&& buildPipeline(@"ShamKernel", &shamPipeline)
		&& buildPipeline(@"MppKernel", &mppPipeline)
		&& buildPipeline(@"SinglePalKernel", &singlePalPipeline);
}

id<MTLBuffer> MetalManager::Impl::makeBuffer(NSUInteger size, const void* data)
{
	id<MTLBuffer> buffer = nil;
	if (data)
		buffer = [device newBufferWithBytes:data length:size options:MTLResourceStorageModeShared];
	else
		buffer = [device newBufferWithLength:size options:MTLResourceStorageModeShared];
	return buffer;
}

id<MTLComputePipelineState> MetalManager::Impl::pipeline(Kernel kernel) const
{
	switch (kernel)
	{
	case Kernel::Ham:
		return hamPipeline;
	case Kernel::Sham:
		return shamPipeline;
	case Kernel::Mpp:
		return mppPipeline;
	case Kernel::SinglePal:
		return singlePalPipeline;
	}
	return nil;
}

bool MetalManager::Impl::runSingle(Kernel kernel, const Color444* image, int w, int h, Color444* outPalettes, int bpc, const int* forceColors)
{
	if (!initialize())
		return false;

	id<MTLComputePipelineState> selectedPipeline = pipeline(kernel);
	if (!selectedPipeline)
	{
		printf("ERROR: Metal compute pipeline is not initialized\n");
		return false;
	}

	assert(4 == sizeof(Color444));
	const int colorCount = 1 << bpc;
	ApplyForcedColorsSingle(outPalettes, colorCount, forceColors);
	const NSUInteger imageSize = NSUInteger(w) * NSUInteger(h) * sizeof(Color444);
	id<MTLBuffer> imageBuffer = makeBuffer(imageSize, image);
	id<MTLBuffer> errorBuffer = makeBuffer(4096 * sizeof(uint32_t), nullptr);
	id<MTLBuffer> constantBuffer = makeBuffer(sizeof(SingleProcessInfo), nullptr);
	if (!imageBuffer || !errorBuffer || !constantBuffer)
	{
		printf("ERROR: Unable to allocate Metal buffers\n");
		return false;
	}

	for (int palEntry = 1; palEntry < colorCount; palEntry++)
	{
		if (forceColors && (forceColors[palEntry] >= 0))
			continue;

		memset([errorBuffer contents], 0, 4096 * sizeof(uint32_t));

		SingleProcessInfo info = {};
		info.w = uint32_t(w);
		info.h = uint32_t(h);
		info.palEntry = uint32_t(palEntry);
		for (int c = 0; c < colorCount; c++)
			info.inPalette[c] = uint32_t(outPalettes[c].GetRGB444());
		memcpy([constantBuffer contents], &info, sizeof(info));

		id<MTLCommandBuffer> commandBuffer = [queue commandBuffer];
		id<MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];
		[encoder setComputePipelineState:selectedPipeline];
		[encoder setBuffer:imageBuffer offset:0 atIndex:0];
		[encoder setBuffer:errorBuffer offset:0 atIndex:1];
		[encoder setBuffer:constantBuffer offset:0 atIndex:2];
		[encoder dispatchThreadgroups:MTLSizeMake(NSUInteger(h), 4096 / kSingleThreadGroupSize, 1)
				  threadsPerThreadgroup:MTLSizeMake(kSingleThreadGroupSize, 1, 1)];
		[encoder endEncoding];
		[commandBuffer commit];
		[commandBuffer waitUntilCompleted];

		if ([commandBuffer status] != MTLCommandBufferStatusCompleted)
		{
			printf("ERROR: Metal compute command failed in single palette mode\n");
			return false;
		}

		const uint32_t* errors = (const uint32_t*)[errorBuffer contents];
		uint32_t bestError = ~0u;
		int bestColor = 0;
		for (int i = 0; i < 4096; i++)
		{
			if (errors[i] < bestError)
			{
				bestError = errors[i];
				bestColor = i;
			}
		}
		outPalettes[palEntry].SetRGB444(bestColor);
	}

	return true;
}

bool MetalManager::Impl::runMulti(Kernel kernel, const Color444* image, int w, int h, Color444* outPalettes, int bpc, bool hamLayout, const int* forceColors)
{
	if (!initialize())
		return false;

	id<MTLComputePipelineState> selectedPipeline = pipeline(kernel);
	if (!selectedPipeline)
	{
		printf("ERROR: Metal compute pipeline is not initialized\n");
		return false;
	}

	assert(4 == sizeof(Color444));
	const int colorCount = 1 << bpc;
	ApplyForcedColorsMulti(outPalettes, h, colorCount, forceColors);
	const NSUInteger imageSize = NSUInteger(w) * NSUInteger(h) * sizeof(Color444);
	const NSUInteger paletteSize = NSUInteger(h) * NSUInteger(colorCount) * sizeof(Color444);

	id<MTLBuffer> imageBuffer = makeBuffer(imageSize, image);
	id<MTLBuffer> paletteBuffer = makeBuffer(paletteSize, outPalettes);
	id<MTLBuffer> constantBuffer = makeBuffer(sizeof(MultiProcessInfo), nullptr);
	if (!imageBuffer || !paletteBuffer || !constantBuffer)
	{
		printf("ERROR: Unable to allocate Metal buffers\n");
		return false;
	}

	id<MTLCommandBuffer> commandBuffer = [queue commandBuffer];
	if (!commandBuffer)
	{
		printf("ERROR: Unable to create Metal command buffer for multi palette mode\n");
		return false;
	}

	for (int palEntry = 1; palEntry < colorCount; palEntry++)
	{
		if (forceColors && (forceColors[palEntry] >= 0))
			continue;

		MultiProcessInfo info = {};
		info.w = uint32_t(w);
		info.h = uint32_t(h);
		info.palEntry = uint32_t(palEntry);
		info.palStride = hamLayout ? 4u : uint32_t(bpc);
		memcpy([constantBuffer contents], &info, sizeof(info));

		id<MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];
		[encoder setComputePipelineState:selectedPipeline];
		[encoder setBuffer:imageBuffer offset:0 atIndex:0];
		[encoder setBuffer:paletteBuffer offset:0 atIndex:1];
			[encoder setBuffer:constantBuffer offset:0 atIndex:2];
			[encoder dispatchThreadgroups:MTLSizeMake(NSUInteger(h), 1, 1)
					  threadsPerThreadgroup:MTLSizeMake(kMultiThreadGroupSize, 1, 1)];
			[encoder endEncoding];
		}

	[commandBuffer commit];
	[commandBuffer waitUntilCompleted];

	if ([commandBuffer status] != MTLCommandBufferStatusCompleted)
	{
		printf("ERROR: Metal compute command failed in multi palette mode\n");
		return false;
	}

	memcpy(outPalettes, [paletteBuffer contents], paletteSize);
	return true;
}

MetalManager::MetalManager()
	: m_impl(std::make_unique<Impl>())
{
}

MetalManager::~MetalManager() = default;

bool MetalManager::bestSHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, const int* forceColors)
{
	return m_impl->runMulti(Impl::Kernel::Sham, image, w, h, outPalettes, 4, true, forceColors);
}

bool MetalManager::bestMppPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc, const int* forceColors)
{
	return m_impl->runMulti(Impl::Kernel::Mpp, image, w, h, outPalettes, bpc, false, forceColors);
}

bool MetalManager::bestHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, const int* forceColors)
{
	return m_impl->runSingle(Impl::Kernel::Ham, image, w, h, outPalettes, 4, forceColors);
}

bool MetalManager::bestSinglePaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc, const int* forceColors)
{
	return m_impl->runSingle(Impl::Kernel::SinglePal, image, w, h, outPalettes, bpc, forceColors);
}
