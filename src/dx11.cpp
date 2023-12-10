/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <d3dcompiler.h>
#include <d3d11.h>
#include <time.h>
#include "color.h"
#include "dx11.h"
#include "shaders/HamCompute.h"
#include "shaders/ShamCompute.h"
#include "shaders/MppCompute.h"
#include "shaders/SinglePalCompute.h"

#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "dxgi")

struct int4 
{
	int x, y, z, w;
};

Dx11Buffer::Dx11Buffer()
{
	m_dxBuffer = NULL;
	m_uavView = NULL;
	m_texView = NULL;
	m_type = kUnknown;
}

Dx11Buffer::~Dx11Buffer()
{
	if (m_uavView)
		m_uavView->Release();
	if (m_texView)
		m_texView->Release();
	if (m_dxBuffer)
		m_dxBuffer->Release();
}

bool	Dx11Buffer::CreateInternal(Buffer_t type, ID3D11Device* pDevice, int sizeInBytes, const void* initialData)
{

	assert(m_type == kUnknown);
	assert(type != kUnknown);
	m_type = type;
	bool bRet = false;
	m_size = sizeInBytes;

	D3D11_BUFFER_DESC bufferDesc = {};
	bufferDesc.ByteWidth = sizeInBytes;
	if (kConstant == m_type)
	{
		bufferDesc.Usage = D3D11_USAGE_DYNAMIC;
		bufferDesc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
		bufferDesc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
	}
	else
	{
		bufferDesc.Usage = (kUav == m_type) ? D3D11_USAGE_DEFAULT : D3D11_USAGE_IMMUTABLE;
		bufferDesc.BindFlags = (kUav == m_type) ? D3D11_BIND_UNORDERED_ACCESS : D3D11_BIND_SHADER_RESOURCE;
		bufferDesc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS;
		bufferDesc.CPUAccessFlags = (kUav == m_type) ? D3D11_CPU_ACCESS_READ : 0;
	}
	bufferDesc.StructureByteStride = 0;

	D3D11_SUBRESOURCE_DATA initData = {};
	initData.pSysMem = initialData;

	HRESULT hr = pDevice->CreateBuffer(
		&bufferDesc,
		initialData ? &initData : NULL,
		&m_dxBuffer);

	if (S_OK == hr)
	{
		bRet = true;
		if (kSrv == m_type)
		{
			D3D11_SHADER_RESOURCE_VIEW_DESC texDesc = {};
			texDesc.Format = DXGI_FORMAT_R32_TYPELESS;
			texDesc.ViewDimension = D3D11_SRV_DIMENSION_BUFFEREX;
			texDesc.BufferEx.FirstElement = 0;
			texDesc.BufferEx.NumElements = sizeInBytes / 4;
			texDesc.BufferEx.Flags = D3D11_BUFFEREX_SRV_FLAG_RAW;

			hr = pDevice->CreateShaderResourceView(m_dxBuffer, &texDesc, &m_texView);
			bRet = (S_OK == hr);
		}
		else if (kUav == m_type)
		{
			D3D11_UNORDERED_ACCESS_VIEW_DESC uvDesc = {};
			uvDesc.Format = DXGI_FORMAT_R32_TYPELESS;
			uvDesc.ViewDimension = D3D11_UAV_DIMENSION_BUFFER;
			uvDesc.Buffer.FirstElement = 0;
			uvDesc.Buffer.NumElements = sizeInBytes / 4;
			uvDesc.Buffer.Flags = D3D11_BUFFER_UAV_FLAG_RAW;

			hr = pDevice->CreateUnorderedAccessView(m_dxBuffer, &uvDesc, &m_uavView);
			bRet = (S_OK == hr);
		}
	}

	return bRet;
}

void Dx11Buffer::Clear(ID3D11DeviceContext* context)
{
	assert(kUav == m_type);
	assert(m_uavView);
	UINT clear[4] = {};
	context->ClearUnorderedAccessViewUint(m_uavView, clear);
}

bool	Dx11Buffer::CreateConstantBuffer(ID3D11Device* pDevice, int sizeInBytes, const void* initialData)
{
	return CreateInternal(kConstant, pDevice, sizeInBytes, initialData);
}

bool	Dx11Buffer::CreateUAVBuffer(ID3D11Device* pDevice, int sizeInBytes, const void* initialData)
{
	return CreateInternal(kUav, pDevice, sizeInBytes, initialData);
}

bool	Dx11Buffer::CreateSRVBuffer(ID3D11Device* pDevice, int sizeInBytes, const void* initialData)
{
	return CreateInternal(kSrv, pDevice, sizeInBytes, initialData);
}

void	Dx11Buffer::Bind(ID3D11DeviceContext* context, int slot)
{
	assert(m_type != kUnknown);
	assert(m_dxBuffer);
	switch (m_type)
	{
	case kConstant:
		context->CSSetConstantBuffers(slot, 1, &m_dxBuffer);
		break;
	case kSrv:
		assert(m_texView);
		context->CSSetShaderResources(slot, 1, &m_texView);
		break;
	case kUav:
		assert(m_uavView);
		context->CSSetUnorderedAccessViews(slot, 1, &m_uavView, NULL);
		break;
	default:
		break;
	}
}

bool	Dx11Buffer::UpdateData(ID3D11DeviceContext* context, const void* data, int sizeInBytes)
{
	assert(kConstant == m_type);
	bool bRet = false;
	if ((sizeInBytes <= m_size) && (m_dxBuffer))
	{
		D3D11_MAPPED_SUBRESOURCE mapInfo;
		HRESULT hr = context->Map(m_dxBuffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &mapInfo);
		if (S_OK == hr)
		{
			memcpy(mapInfo.pData, data, sizeInBytes);
			bRet = true;
		}
		else
		{
			printf("ERROR: Unable to write %d bytes in dxbuffer\n", sizeInBytes);
		}
		context->Unmap(m_dxBuffer, 0);
	}
	return bRet;
}

bool	Dx11Buffer::ReadData(ID3D11DeviceContext* context, void* outBuffer, int sizeInBytes)
{
	bool bRet = false;
	if ((sizeInBytes <= m_size) && (m_dxBuffer))
	{
		D3D11_MAPPED_SUBRESOURCE mapInfo;
		HRESULT hr = context->Map(m_dxBuffer, 0, D3D11_MAP_READ, 0, &mapInfo);
		if (S_OK == hr)
		{
			memcpy(outBuffer, mapInfo.pData, sizeInBytes);
			bRet = true;
		}
		else
		{
			printf("ERROR: Unable to read back results from GPU\n");
		}
		context->Unmap(m_dxBuffer, 0);
	}
	return bRet;
}



Dx11Manager::Dx11Manager()
{
	m_pd3dDevice = NULL;

	IDXGIFactory* pFactory;
	// Create a DXGIFactory object.
	if (S_OK == CreateDXGIFactory(__uuidof(IDXGIFactory), (void**)&pFactory))
	{
		IDXGIAdapter * pAdapter;
		if (pFactory->EnumAdapters(0, &pAdapter) != DXGI_ERROR_NOT_FOUND)
		{
			DXGI_ADAPTER_DESC desc;
			if (S_OK == pAdapter->GetDesc(&desc))
			{
				wprintf(L"GPU detected: %s\n", desc.Description);
			}
		}
		pFactory->Release();
	}

}



bool	Dx11Manager::CreateDevice()
{
	bool bRet = false;

	D3D_FEATURE_LEVEL fLevel;
	HRESULT hr = D3D11CreateDevice(NULL,
		D3D_DRIVER_TYPE_HARDWARE,
		NULL,
#ifdef _DEBUG
		D3D11_CREATE_DEVICE_SINGLETHREADED | D3D11_CREATE_DEVICE_DEBUG,
#else
		D3D11_CREATE_DEVICE_SINGLETHREADED,
#endif
		NULL,			// first feature level is 11.0
		0,
		D3D11_SDK_VERSION,
		&m_pd3dDevice,
		&fLevel,
		&m_pImmediateContext);

	if (S_OK == hr)
	{
		if (fLevel >= D3D_FEATURE_LEVEL_11_0)
		{
			HRESULT hr0 = m_pd3dDevice->CreateComputeShader((void*)&g_ShamKernel, sizeof(g_ShamKernel), NULL, &m_pShamKernel);
			HRESULT hr1 = m_pd3dDevice->CreateComputeShader((void*)&g_HamKernel, sizeof(g_HamKernel), NULL, &m_pHamKernel);
			HRESULT hr2 = m_pd3dDevice->CreateComputeShader((void*)&g_MppKernel, sizeof(g_MppKernel), NULL, &m_pMppKernel);
			HRESULT hr3 = m_pd3dDevice->CreateComputeShader((void*)&g_SinglePalKernel, sizeof(g_SinglePalKernel), NULL, &m_pSinglePalKernel);
			if ((S_OK == hr0) && (S_OK == hr1) && (S_OK == hr2) && (S_OK == hr3))
			{
				bRet = true;
			}
			else
			{
				printf("ERROR: Unable to create DirectX 11 Bruteforce Compute Shaders\n");
			}
		}
		else
		{
			printf("ERROR: DirectX device doesn't support 11.0 or greater\n");
		}
	}
	else
	{
		printf("ERROR: Unable to create DirectX 11 Device\n");
	}
	return bRet;
}

bool Dx11Manager::bestMultiPaletteSearch(const Color444* image, int w, int h, Color444* outPalettes, int bpc, bool ham)
{
	bool bRet = false;

	if (CreateDevice())
	{
		assert(4 == sizeof(Color444));		// if fail, some change should be done in the compute shader code! :)
		assert(bpc <= 5);
		const int colorCount = 1 << bpc;
		int palSize = h * colorCount * sizeof(Color444);

		Dx11Buffer palBuffer;
		if (palBuffer.CreateUAVBuffer(m_pd3dDevice, palSize, outPalettes))
		{
			const int imageSize = w * h * sizeof(Color444);
			Dx11Buffer imageBuffer;
			if (imageBuffer.CreateSRVBuffer(m_pd3dDevice, imageSize, image))
			{
				Dx11Buffer constantBuffer;
				if (constantBuffer.CreateConstantBuffer(m_pd3dDevice, 16, NULL))
				{
					// Each palette entry will brute-force search among 4096 colors
					for (int palEntry = 1; palEntry < colorCount; palEntry++)
					{
						int processInfo[4] = { w, h, palEntry, bpc };

						m_pImmediateContext->CSSetShader(ham? m_pShamKernel: m_pMppKernel, NULL, 0);

						if (constantBuffer.UpdateData(m_pImmediateContext, processInfo, sizeof(processInfo)))
						{
							palBuffer.Bind(m_pImmediateContext, 0);
							imageBuffer.Bind(m_pImmediateContext, 0);
							constantBuffer.Bind(m_pImmediateContext, 0);

							// GPU start command (run compute shader kernel)
							m_pImmediateContext->Dispatch(h, 1, 1);
						}
					}

					if (palBuffer.ReadData(m_pImmediateContext, outPalettes, palSize))
					{
						bRet = true;
					}
					else
					{
						printf("ERROR: Unable to read back GPU data\n");
					}
				}
				else
				{
					printf("ERROR: Unable to create 16bytes constant buffer\n");
				}
			}
		}
	}

	if (m_pd3dDevice)
	{
		m_pd3dDevice->Release();
		m_pd3dDevice = NULL;
	}
	return bRet;
}

bool	Dx11Manager::bestSinglePaletteSearch(const Color444* image, int w, int h, Color444* outPalettes, int bpc, bool ham)
{

	bool bRet = false;

	if (CreateDevice())
	{
		assert(4 == sizeof(Color444));		// if fail, some change should be done in the compute shader code! :)
		assert(bpc <= 5);
		const int colorCount = 1 << bpc;
		int palSize = colorCount * sizeof(Color444);

		const int imageSize = w * h * sizeof(Color444);
		Dx11Buffer imageBuffer;
		if (imageBuffer.CreateSRVBuffer(m_pd3dDevice, imageSize, image))
		{
			int4 processInfo[1 + 32];
			Dx11Buffer constantBuffer;
			if (constantBuffer.CreateConstantBuffer(m_pd3dDevice, sizeof(processInfo), NULL))
			{
				Dx11Buffer outErrorBuffer;
				outErrorBuffer.CreateUAVBuffer(m_pd3dDevice, 4096 * 4, NULL);
				// Each palette entry will brute-force search among 4096 colors
				for (int palEntry = 1; palEntry < colorCount; palEntry++)
				{
					processInfo[0].x = w;
					processInfo[0].y = h;
					processInfo[0].z = palEntry;
					processInfo[0].w = 0;
					for (int c = 0; c < colorCount; c++)
						processInfo[1+c].x = outPalettes[c].GetRGB444();

					m_pImmediateContext->CSSetShader(ham?m_pHamKernel:m_pSinglePalKernel, NULL, 0);

					if (constantBuffer.UpdateData(m_pImmediateContext, processInfo, sizeof(processInfo)))
					{
						outErrorBuffer.Bind(m_pImmediateContext, 0);
						imageBuffer.Bind(m_pImmediateContext, 0);
						constantBuffer.Bind(m_pImmediateContext, 0);
						outErrorBuffer.Clear(m_pImmediateContext);

						// GPU start command (run compute shader kernel)
						m_pImmediateContext->Dispatch(h, 4096/64, 1);		// all 4096 colors
					}

					// For single palette mode, CPU have to retreive the minimal error among the 4096 results,
					// and set it as color in the current palette entry
					u32 errors[4096];	// 16KiB on stack is perfectly fine for today standard :)
					if (outErrorBuffer.ReadData(m_pImmediateContext, errors, sizeof(errors)))
					{
						u32 bestError = ~0;
						int bestColor;
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
					else
					{
						printf("ERROR: GPU can't read back error data in HAM kernel\n");
					}
				}
			}
			else
			{
				printf("ERROR: Unable to create 16bytes constant buffer\n");
			}
		}
	}

	if (m_pd3dDevice)
	{
		m_pd3dDevice->Release();
		m_pd3dDevice = NULL;
	}
	return bRet;
}


bool	Dx11Manager::bestHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes)
{
	return bestSinglePaletteSearch(image, w, h, outPalettes, 4, true);
}

bool Dx11Manager::bestSinglePaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc)
{
	assert(bpc <= 5);
	return bestSinglePaletteSearch(image, w, h, outPalettes, bpc, false);
}

bool	Dx11Manager::bestSHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes)
{
	return bestMultiPaletteSearch(image, w, h, outPalettes, 4, true);
}

bool Dx11Manager::bestMppPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc)
{
	assert(bpc <= 5);
	return bestMultiPaletteSearch(image, w, h, outPalettes, bpc, false);
}
