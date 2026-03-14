/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#pragma once

#include "computeManager.h"

typedef unsigned int u32;
struct Color444;

#ifdef _WIN32

#include <d3d11.h>

class Dx11Buffer
{
public:
	Dx11Buffer();
	~Dx11Buffer();

	bool	CreateConstantBuffer(ID3D11Device* pDevice, int sizeInBytes, const void* initialData);
	bool	CreateUAVBuffer(ID3D11Device* pDevice, int sizeInBytes, const void* initialData);
	bool	CreateSRVBuffer(ID3D11Device* pDevice, int sizeInBytes, const void* initialData);
	void	Clear(ID3D11DeviceContext* context);
	void	Bind(ID3D11DeviceContext* context, int slot);

	bool	UpdateData(ID3D11DeviceContext* context, const void* data, int sizeInBytes);
	bool	ReadData(ID3D11DeviceContext* context, void* outBuffer, int sizeInBytes);

private:
	enum Buffer_t
	{
		kUnknown,
		kConstant,
		kUav,
		kSrv
	};
	bool	CreateInternal(Buffer_t type, ID3D11Device* pDevice, int sizeInBytes, const void* initialData);
	Buffer_t					m_type;
	int							m_size;
	ID3D11Buffer*				m_dxBuffer;
	ID3D11UnorderedAccessView*	m_uavView;
	ID3D11ShaderResourceView*	m_texView;
};

class Dx11Manager : public ComputeManager
{
public:
	Dx11Manager();
	~Dx11Manager() override = default;

	bool	bestSHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, const int* forceColors) override;
	bool	bestMppPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc, const int* forceColors) override;
	bool	bestHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, const int* forceColors) override;
	bool	bestSinglePaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc, const int* forceColors) override;

private:
	bool bestMultiPaletteSearch(const Color444* image, int w, int h, Color444* outPalettes, int bpc, bool ham, const int* forceColors);
	bool bestSinglePaletteSearch(const Color444* image, int w, int h, Color444* outPalettes, int bpc, bool ham, const int* forceColors);

	bool			CreateDevice();

	ID3D11Device*               m_pd3dDevice;
	ID3D11DeviceContext*        m_pImmediateContext;
	IDXGISwapChain*             m_pSwapChain;
	ID3D11ComputeShader*		m_pHamKernel;
	ID3D11ComputeShader*		m_pShamKernel;
	ID3D11ComputeShader*		m_pMppKernel;
	ID3D11ComputeShader*		m_pSinglePalKernel;
};
#endif
