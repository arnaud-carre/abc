/*--------------------------------------------------------------------
	Amiga-Atari Bitmap Converter
	Supports bitmap, HAM, RGB, sprite sheets, Color reduction etc...
	GPU speed enhanced
	Written by Arnaud Carré aka Leonard/Oxygene (@leonard_coder)
--------------------------------------------------------------------*/
#include <algorithm>
#include <array>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <vector>

#include <vulkan/vulkan.h>

#include "color.h"
#include "vulkanManager.h"

#include "HamCompute.comp.h"
#include "MppCompute.comp.h"
#include "ShamCompute.comp.h"
#include "SinglePalCompute.comp.h"

namespace
{
constexpr uint32_t kBruteForceColorCount = 4096;
constexpr uint32_t kSingleThreadGroupSize = 64;
constexpr uint32_t kMultiThreadGroupSize = 128;

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

struct Buffer
{
	VkBuffer buffer = VK_NULL_HANDLE;
	VkDeviceMemory memory = VK_NULL_HANDLE;
	VkDeviceSize size = 0;
	void* mapped = nullptr;
	bool coherent = false;
};

static void ApplyForcedColorsSingle(Color444* outPalettes, int colorCount, const int* forceColors)
{
	if (!forceColors)
		return;

	for (int palEntry = 1; palEntry < colorCount; ++palEntry)
	{
		if (forceColors[palEntry] >= 0)
			outPalettes[palEntry].SetRGB444(forceColors[palEntry]);
	}
}

static void ApplyForcedColorsMulti(Color444* outPalettes, int h, int colorCount, const int* forceColors)
{
	if (!forceColors)
		return;

	for (int palEntry = 1; palEntry < colorCount; ++palEntry)
	{
		if (forceColors[palEntry] < 0)
			continue;

		for (int line = 0; line < h; ++line)
			outPalettes[line * colorCount + palEntry].SetRGB444(forceColors[palEntry]);
	}
}

static std::vector<uint32_t> CopySpirv(const unsigned char* bytes, unsigned int sizeInBytes)
{
	assert((sizeInBytes & 3u) == 0u);
	std::vector<uint32_t> words(sizeInBytes / sizeof(uint32_t));
	memcpy(words.data(), bytes, sizeInBytes);
	return words;
}
}

struct VulkanManager::Impl
{
	enum class Kernel
	{
		Ham,
		Sham,
		Mpp,
		SinglePal,
	};

	VkInstance instance = VK_NULL_HANDLE;
	VkPhysicalDevice physicalDevice = VK_NULL_HANDLE;
	VkPhysicalDeviceProperties physicalDeviceProperties = {};
	VkDevice device = VK_NULL_HANDLE;
	uint32_t queueFamilyIndex = 0;
	VkQueue queue = VK_NULL_HANDLE;
	VkCommandPool commandPool = VK_NULL_HANDLE;
	VkCommandBuffer commandBuffer = VK_NULL_HANDLE;
	VkFence fence = VK_NULL_HANDLE;
	VkDescriptorSetLayout descriptorSetLayout = VK_NULL_HANDLE;
	VkPipelineLayout pipelineLayout = VK_NULL_HANDLE;
	VkDescriptorPool descriptorPool = VK_NULL_HANDLE;
	VkDescriptorSet descriptorSet = VK_NULL_HANDLE;
	VkPipeline hamPipeline = VK_NULL_HANDLE;
	VkPipeline shamPipeline = VK_NULL_HANDLE;
	VkPipeline mppPipeline = VK_NULL_HANDLE;
	VkPipeline singlePalPipeline = VK_NULL_HANDLE;

	~Impl();

	bool initialize();
	bool bestSingle(Kernel kernel, const Color444* image, int w, int h, Color444* outPalettes, int bpc, const int* forceColors);
	bool bestMulti(Kernel kernel, const Color444* image, int w, int h, Color444* outPalettes, int bpc, bool hamLayout, const int* forceColors);

private:
	bool createInstance();
	bool pickPhysicalDevice();
	bool createDevice();
	bool createCommandResources();
	bool createDescriptors();
	bool createPipelines();
	bool createPipeline(const unsigned char* codeBytes, unsigned int codeSize, VkPipeline* outPipeline);

	uint32_t findMemoryType(uint32_t typeBits, VkMemoryPropertyFlags requiredFlags, VkMemoryPropertyFlags preferredFlags, VkMemoryPropertyFlags* outFlags) const;
	bool createBuffer(VkDeviceSize size, VkBufferUsageFlags usage, Buffer* outBuffer);
	void destroyBuffer(Buffer* buffer);
	bool flushBuffer(const Buffer& buffer);
	bool invalidateBuffer(const Buffer& buffer);
	bool writeBuffer(const Buffer& buffer, const void* data, size_t size);
	bool readBuffer(const Buffer& buffer, void* outData, size_t size);

	bool updateDescriptorSet(const Buffer& buffer0, const Buffer& buffer1, const Buffer& buffer2);
	bool beginCommands();
	bool submitAndWait();
	VkPipeline pipeline(Kernel kernel) const;
	void destroy();
};

VulkanManager::Impl::~Impl()
{
	destroy();
}

void VulkanManager::Impl::destroy()
{
	if (device != VK_NULL_HANDLE)
		vkDeviceWaitIdle(device);

	if (hamPipeline != VK_NULL_HANDLE)
		vkDestroyPipeline(device, hamPipeline, nullptr);
	if (shamPipeline != VK_NULL_HANDLE)
		vkDestroyPipeline(device, shamPipeline, nullptr);
	if (mppPipeline != VK_NULL_HANDLE)
		vkDestroyPipeline(device, mppPipeline, nullptr);
	if (singlePalPipeline != VK_NULL_HANDLE)
		vkDestroyPipeline(device, singlePalPipeline, nullptr);
	if (descriptorPool != VK_NULL_HANDLE)
		vkDestroyDescriptorPool(device, descriptorPool, nullptr);
	if (pipelineLayout != VK_NULL_HANDLE)
		vkDestroyPipelineLayout(device, pipelineLayout, nullptr);
	if (descriptorSetLayout != VK_NULL_HANDLE)
		vkDestroyDescriptorSetLayout(device, descriptorSetLayout, nullptr);
	if (fence != VK_NULL_HANDLE)
		vkDestroyFence(device, fence, nullptr);
	if (commandPool != VK_NULL_HANDLE)
		vkDestroyCommandPool(device, commandPool, nullptr);
	if (device != VK_NULL_HANDLE)
		vkDestroyDevice(device, nullptr);
	if (instance != VK_NULL_HANDLE)
		vkDestroyInstance(instance, nullptr);

	instance = VK_NULL_HANDLE;
	physicalDevice = VK_NULL_HANDLE;
	device = VK_NULL_HANDLE;
	queue = VK_NULL_HANDLE;
	commandPool = VK_NULL_HANDLE;
	commandBuffer = VK_NULL_HANDLE;
	fence = VK_NULL_HANDLE;
	descriptorSetLayout = VK_NULL_HANDLE;
	pipelineLayout = VK_NULL_HANDLE;
	descriptorPool = VK_NULL_HANDLE;
	descriptorSet = VK_NULL_HANDLE;
	hamPipeline = VK_NULL_HANDLE;
	shamPipeline = VK_NULL_HANDLE;
	mppPipeline = VK_NULL_HANDLE;
	singlePalPipeline = VK_NULL_HANDLE;
}

bool VulkanManager::Impl::createInstance()
{
	VkApplicationInfo appInfo = {};
	appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
	appInfo.pApplicationName = "abc2";
	appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
	appInfo.pEngineName = "abc2";
	appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
	appInfo.apiVersion = VK_API_VERSION_1_0;

	VkInstanceCreateInfo createInfo = {};
	createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
	createInfo.pApplicationInfo = &appInfo;

	const VkResult result = vkCreateInstance(&createInfo, nullptr, &instance);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkCreateInstance() failed (%d)\n", int(result));
		return false;
	}
	return true;
}

bool VulkanManager::Impl::pickPhysicalDevice()
{
	uint32_t deviceCount = 0;
	VkResult result = vkEnumeratePhysicalDevices(instance, &deviceCount, nullptr);
	if ((result != VK_SUCCESS) || (deviceCount == 0))
	{
		printf("ERROR: No Vulkan physical device with compute support found\n");
		return false;
	}

	std::vector<VkPhysicalDevice> devices(deviceCount);
	result = vkEnumeratePhysicalDevices(instance, &deviceCount, devices.data());
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkEnumeratePhysicalDevices() failed (%d)\n", int(result));
		return false;
	}

	for (VkPhysicalDevice candidate : devices)
	{
		uint32_t queueCount = 0;
		vkGetPhysicalDeviceQueueFamilyProperties(candidate, &queueCount, nullptr);
		std::vector<VkQueueFamilyProperties> queueFamilies(queueCount);
		vkGetPhysicalDeviceQueueFamilyProperties(candidate, &queueCount, queueFamilies.data());

		for (uint32_t i = 0; i < queueCount; ++i)
		{
			if ((queueFamilies[i].queueFlags & VK_QUEUE_COMPUTE_BIT) != 0)
			{
				physicalDevice = candidate;
				queueFamilyIndex = i;
				vkGetPhysicalDeviceProperties(physicalDevice, &physicalDeviceProperties);
				printf("GPU detected: %s\n", physicalDeviceProperties.deviceName);
				return true;
			}
		}
	}

	printf("ERROR: Unable to find a Vulkan queue family with compute support\n");
	return false;
}

bool VulkanManager::Impl::createDevice()
{
	const float queuePriority = 1.0f;
	VkDeviceQueueCreateInfo queueInfo = {};
	queueInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
	queueInfo.queueFamilyIndex = queueFamilyIndex;
	queueInfo.queueCount = 1;
	queueInfo.pQueuePriorities = &queuePriority;

	VkDeviceCreateInfo createInfo = {};
	createInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
	createInfo.queueCreateInfoCount = 1;
	createInfo.pQueueCreateInfos = &queueInfo;

	const VkResult result = vkCreateDevice(physicalDevice, &createInfo, nullptr, &device);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkCreateDevice() failed (%d)\n", int(result));
		return false;
	}

	vkGetDeviceQueue(device, queueFamilyIndex, 0, &queue);
	return queue != VK_NULL_HANDLE;
}

bool VulkanManager::Impl::createCommandResources()
{
	VkCommandPoolCreateInfo poolInfo = {};
	poolInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
	poolInfo.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
	poolInfo.queueFamilyIndex = queueFamilyIndex;
	VkResult result = vkCreateCommandPool(device, &poolInfo, nullptr, &commandPool);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkCreateCommandPool() failed (%d)\n", int(result));
		return false;
	}

	VkCommandBufferAllocateInfo allocInfo = {};
	allocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
	allocInfo.commandPool = commandPool;
	allocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
	allocInfo.commandBufferCount = 1;
	result = vkAllocateCommandBuffers(device, &allocInfo, &commandBuffer);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkAllocateCommandBuffers() failed (%d)\n", int(result));
		return false;
	}

	VkFenceCreateInfo fenceInfo = {};
	fenceInfo.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
	result = vkCreateFence(device, &fenceInfo, nullptr, &fence);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkCreateFence() failed (%d)\n", int(result));
		return false;
	}

	return true;
}

bool VulkanManager::Impl::createDescriptors()
{
	std::array<VkDescriptorSetLayoutBinding, 3> bindings = {};
	for (uint32_t i = 0; i < bindings.size(); ++i)
	{
		bindings[i].binding = i;
		bindings[i].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
		bindings[i].descriptorCount = 1;
		bindings[i].stageFlags = VK_SHADER_STAGE_COMPUTE_BIT;
	}

	VkDescriptorSetLayoutCreateInfo layoutInfo = {};
	layoutInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
	layoutInfo.bindingCount = uint32_t(bindings.size());
	layoutInfo.pBindings = bindings.data();

	VkResult result = vkCreateDescriptorSetLayout(device, &layoutInfo, nullptr, &descriptorSetLayout);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkCreateDescriptorSetLayout() failed (%d)\n", int(result));
		return false;
	}

	VkPipelineLayoutCreateInfo pipelineLayoutInfo = {};
	pipelineLayoutInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
	pipelineLayoutInfo.setLayoutCount = 1;
	pipelineLayoutInfo.pSetLayouts = &descriptorSetLayout;
	result = vkCreatePipelineLayout(device, &pipelineLayoutInfo, nullptr, &pipelineLayout);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkCreatePipelineLayout() failed (%d)\n", int(result));
		return false;
	}

	VkDescriptorPoolSize poolSize = {};
	poolSize.type = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
	poolSize.descriptorCount = 3;

	VkDescriptorPoolCreateInfo poolInfo = {};
	poolInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO;
	poolInfo.poolSizeCount = 1;
	poolInfo.pPoolSizes = &poolSize;
	poolInfo.maxSets = 1;
	result = vkCreateDescriptorPool(device, &poolInfo, nullptr, &descriptorPool);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkCreateDescriptorPool() failed (%d)\n", int(result));
		return false;
	}

	VkDescriptorSetAllocateInfo allocInfo = {};
	allocInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
	allocInfo.descriptorPool = descriptorPool;
	allocInfo.descriptorSetCount = 1;
	allocInfo.pSetLayouts = &descriptorSetLayout;
	result = vkAllocateDescriptorSets(device, &allocInfo, &descriptorSet);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkAllocateDescriptorSets() failed (%d)\n", int(result));
		return false;
	}

	return true;
}

bool VulkanManager::Impl::createPipeline(const unsigned char* codeBytes, unsigned int codeSize, VkPipeline* outPipeline)
{
	const std::vector<uint32_t> spirv = CopySpirv(codeBytes, codeSize);

	VkShaderModuleCreateInfo moduleInfo = {};
	moduleInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
	moduleInfo.codeSize = spirv.size() * sizeof(uint32_t);
	moduleInfo.pCode = spirv.data();

	VkShaderModule shaderModule = VK_NULL_HANDLE;
	VkResult result = vkCreateShaderModule(device, &moduleInfo, nullptr, &shaderModule);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkCreateShaderModule() failed (%d)\n", int(result));
		return false;
	}

	VkPipelineShaderStageCreateInfo stageInfo = {};
	stageInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
	stageInfo.stage = VK_SHADER_STAGE_COMPUTE_BIT;
	stageInfo.module = shaderModule;
	stageInfo.pName = "main";

	VkComputePipelineCreateInfo pipelineInfo = {};
	pipelineInfo.sType = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO;
	pipelineInfo.stage = stageInfo;
	pipelineInfo.layout = pipelineLayout;

	result = vkCreateComputePipelines(device, VK_NULL_HANDLE, 1, &pipelineInfo, nullptr, outPipeline);
	vkDestroyShaderModule(device, shaderModule, nullptr);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkCreateComputePipelines() failed (%d)\n", int(result));
		return false;
	}

	return true;
}

bool VulkanManager::Impl::createPipelines()
{
	return createPipeline(g_vulkanHamKernel, g_vulkanHamKernel_len, &hamPipeline)
		&& createPipeline(g_vulkanShamKernel, g_vulkanShamKernel_len, &shamPipeline)
		&& createPipeline(g_vulkanMppKernel, g_vulkanMppKernel_len, &mppPipeline)
		&& createPipeline(g_vulkanSinglePalKernel, g_vulkanSinglePalKernel_len, &singlePalPipeline);
}

bool VulkanManager::Impl::initialize()
{
	if (device != VK_NULL_HANDLE)
		return true;

	return createInstance()
		&& pickPhysicalDevice()
		&& createDevice()
		&& createCommandResources()
		&& createDescriptors()
		&& createPipelines();
}

uint32_t VulkanManager::Impl::findMemoryType(uint32_t typeBits, VkMemoryPropertyFlags requiredFlags, VkMemoryPropertyFlags preferredFlags, VkMemoryPropertyFlags* outFlags) const
{
	VkPhysicalDeviceMemoryProperties memoryProperties = {};
	vkGetPhysicalDeviceMemoryProperties(physicalDevice, &memoryProperties);

	uint32_t fallbackIndex = UINT32_MAX;
	VkMemoryPropertyFlags fallbackFlags = 0;
	for (uint32_t i = 0; i < memoryProperties.memoryTypeCount; ++i)
	{
		if ((typeBits & (1u << i)) == 0u)
			continue;

		const VkMemoryPropertyFlags flags = memoryProperties.memoryTypes[i].propertyFlags;
		if ((flags & requiredFlags) != requiredFlags)
			continue;

		if ((flags & preferredFlags) == preferredFlags)
		{
			if (outFlags)
				*outFlags = flags;
			return i;
		}

		if (fallbackIndex == UINT32_MAX)
		{
			fallbackIndex = i;
			fallbackFlags = flags;
		}
	}

	if ((fallbackIndex != UINT32_MAX) && outFlags)
		*outFlags = fallbackFlags;
	return fallbackIndex;
}

bool VulkanManager::Impl::createBuffer(VkDeviceSize size, VkBufferUsageFlags usage, Buffer* outBuffer)
{
	VkBufferCreateInfo bufferInfo = {};
	bufferInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
	bufferInfo.size = size;
	bufferInfo.usage = usage;
	bufferInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE;

	VkResult result = vkCreateBuffer(device, &bufferInfo, nullptr, &outBuffer->buffer);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkCreateBuffer() failed (%d)\n", int(result));
		return false;
	}

	VkMemoryRequirements requirements = {};
	vkGetBufferMemoryRequirements(device, outBuffer->buffer, &requirements);

	VkMemoryPropertyFlags actualFlags = 0;
	const uint32_t memoryTypeIndex = findMemoryType(
		requirements.memoryTypeBits,
		VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT,
		VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
		&actualFlags);
	if (memoryTypeIndex == UINT32_MAX)
	{
		printf("ERROR: Unable to find host-visible Vulkan memory\n");
		return false;
	}

	VkMemoryAllocateInfo allocInfo = {};
	allocInfo.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
	allocInfo.allocationSize = requirements.size;
	allocInfo.memoryTypeIndex = memoryTypeIndex;
	result = vkAllocateMemory(device, &allocInfo, nullptr, &outBuffer->memory);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkAllocateMemory() failed (%d)\n", int(result));
		return false;
	}

	result = vkBindBufferMemory(device, outBuffer->buffer, outBuffer->memory, 0);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkBindBufferMemory() failed (%d)\n", int(result));
		return false;
	}

	result = vkMapMemory(device, outBuffer->memory, 0, size, 0, &outBuffer->mapped);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkMapMemory() failed (%d)\n", int(result));
		return false;
	}

	outBuffer->size = size;
	outBuffer->coherent = (actualFlags & VK_MEMORY_PROPERTY_HOST_COHERENT_BIT) != 0;
	return true;
}

void VulkanManager::Impl::destroyBuffer(Buffer* buffer)
{
	if (buffer->mapped != nullptr)
		vkUnmapMemory(device, buffer->memory);
	if (buffer->memory != VK_NULL_HANDLE)
		vkFreeMemory(device, buffer->memory, nullptr);
	if (buffer->buffer != VK_NULL_HANDLE)
		vkDestroyBuffer(device, buffer->buffer, nullptr);

	buffer->buffer = VK_NULL_HANDLE;
	buffer->memory = VK_NULL_HANDLE;
	buffer->size = 0;
	buffer->mapped = nullptr;
	buffer->coherent = false;
}

bool VulkanManager::Impl::flushBuffer(const Buffer& buffer)
{
	if (buffer.coherent)
		return true;

	VkMappedMemoryRange range = {};
	range.sType = VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE;
	range.memory = buffer.memory;
	range.offset = 0;
	range.size = VK_WHOLE_SIZE;
	const VkResult result = vkFlushMappedMemoryRanges(device, 1, &range);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkFlushMappedMemoryRanges() failed (%d)\n", int(result));
		return false;
	}
	return true;
}

bool VulkanManager::Impl::invalidateBuffer(const Buffer& buffer)
{
	if (buffer.coherent)
		return true;

	VkMappedMemoryRange range = {};
	range.sType = VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE;
	range.memory = buffer.memory;
	range.offset = 0;
	range.size = VK_WHOLE_SIZE;
	const VkResult result = vkInvalidateMappedMemoryRanges(device, 1, &range);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkInvalidateMappedMemoryRanges() failed (%d)\n", int(result));
		return false;
	}
	return true;
}

bool VulkanManager::Impl::writeBuffer(const Buffer& buffer, const void* data, size_t size)
{
	if ((buffer.mapped == nullptr) || (size > size_t(buffer.size)))
		return false;
	memcpy(buffer.mapped, data, size);
	return flushBuffer(buffer);
}

bool VulkanManager::Impl::readBuffer(const Buffer& buffer, void* outData, size_t size)
{
	if ((buffer.mapped == nullptr) || (size > size_t(buffer.size)))
		return false;
	if (!invalidateBuffer(buffer))
		return false;
	memcpy(outData, buffer.mapped, size);
	return true;
}

bool VulkanManager::Impl::updateDescriptorSet(const Buffer& buffer0, const Buffer& buffer1, const Buffer& buffer2)
{
	const std::array<VkDescriptorBufferInfo, 3> bufferInfos = {{
		{ buffer0.buffer, 0, buffer0.size },
		{ buffer1.buffer, 0, buffer1.size },
		{ buffer2.buffer, 0, buffer2.size },
	}};

	std::array<VkWriteDescriptorSet, 3> writes = {};
	for (uint32_t i = 0; i < writes.size(); ++i)
	{
		writes[i].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
		writes[i].dstSet = descriptorSet;
		writes[i].dstBinding = i;
		writes[i].descriptorCount = 1;
		writes[i].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
		writes[i].pBufferInfo = &bufferInfos[i];
	}

	vkUpdateDescriptorSets(device, uint32_t(writes.size()), writes.data(), 0, nullptr);
	return true;
}

bool VulkanManager::Impl::beginCommands()
{
	vkResetFences(device, 1, &fence);
	vkResetCommandBuffer(commandBuffer, 0);

	VkCommandBufferBeginInfo beginInfo = {};
	beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
	beginInfo.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
	const VkResult result = vkBeginCommandBuffer(commandBuffer, &beginInfo);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkBeginCommandBuffer() failed (%d)\n", int(result));
		return false;
	}
	return true;
}

bool VulkanManager::Impl::submitAndWait()
{
	VkResult result = vkEndCommandBuffer(commandBuffer);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkEndCommandBuffer() failed (%d)\n", int(result));
		return false;
	}

	VkSubmitInfo submitInfo = {};
	submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;
	submitInfo.commandBufferCount = 1;
	submitInfo.pCommandBuffers = &commandBuffer;
	result = vkQueueSubmit(queue, 1, &submitInfo, fence);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkQueueSubmit() failed (%d)\n", int(result));
		return false;
	}

	result = vkWaitForFences(device, 1, &fence, VK_TRUE, UINT64_MAX);
	if (result != VK_SUCCESS)
	{
		printf("ERROR: vkWaitForFences() failed (%d)\n", int(result));
		return false;
	}

	return true;
}

VkPipeline VulkanManager::Impl::pipeline(Kernel kernel) const
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
	return VK_NULL_HANDLE;
}

bool VulkanManager::Impl::bestSingle(Kernel kernel, const Color444* image, int w, int h, Color444* outPalettes, int bpc, const int* forceColors)
{
	if (!initialize())
		return false;

	assert(4 == sizeof(Color444));
	assert(bpc <= 5);
	const int colorCount = 1 << bpc;
	ApplyForcedColorsSingle(outPalettes, colorCount, forceColors);

	Buffer imageBuffer;
	Buffer errorBuffer;
	Buffer processBuffer;
	const size_t imageSize = size_t(w) * size_t(h) * sizeof(Color444);
	bool ok = createBuffer(imageSize, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT, &imageBuffer)
		&& createBuffer(kBruteForceColorCount * sizeof(uint32_t), VK_BUFFER_USAGE_STORAGE_BUFFER_BIT, &errorBuffer)
		&& createBuffer(sizeof(SingleProcessInfo), VK_BUFFER_USAGE_STORAGE_BUFFER_BIT, &processBuffer);
	if (!ok)
	{
		destroyBuffer(&processBuffer);
		destroyBuffer(&errorBuffer);
		destroyBuffer(&imageBuffer);
		return false;
	}

	if (!writeBuffer(imageBuffer, image, imageSize))
		ok = false;
	if (ok && !updateDescriptorSet(imageBuffer, errorBuffer, processBuffer))
		ok = false;

	std::array<uint32_t, kBruteForceColorCount> errors = {};

	for (int palEntry = 1; ok && (palEntry < colorCount); ++palEntry)
	{
		if (forceColors && (forceColors[palEntry] >= 0))
			continue;

		memset(errorBuffer.mapped, 0, errors.size() * sizeof(uint32_t));
		ok = flushBuffer(errorBuffer);

		SingleProcessInfo info = {};
		info.w = uint32_t(w);
		info.h = uint32_t(h);
		info.palEntry = uint32_t(palEntry);
		for (int c = 0; c < colorCount; ++c)
			info.inPalette[c] = uint32_t(outPalettes[c].GetRGB444());
		if (ok && !writeBuffer(processBuffer, &info, sizeof(info)))
			ok = false;

		if (ok && !beginCommands())
			ok = false;

		if (ok)
		{
			vkCmdBindPipeline(commandBuffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline(kernel));
			vkCmdBindDescriptorSets(commandBuffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipelineLayout, 0, 1, &descriptorSet, 0, nullptr);
			vkCmdDispatch(commandBuffer, uint32_t(h), kBruteForceColorCount / kSingleThreadGroupSize, 1);

			VkBufferMemoryBarrier barrier = {};
			barrier.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
			barrier.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
			barrier.dstAccessMask = VK_ACCESS_HOST_READ_BIT;
			barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
			barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
			barrier.buffer = errorBuffer.buffer;
			barrier.offset = 0;
			barrier.size = errorBuffer.size;
			vkCmdPipelineBarrier(
				commandBuffer,
				VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
				VK_PIPELINE_STAGE_HOST_BIT,
				0,
				0, nullptr,
				1, &barrier,
				0, nullptr);
		}

		if (ok && !submitAndWait())
			ok = false;
		if (ok && !readBuffer(errorBuffer, errors.data(), errors.size() * sizeof(uint32_t)))
			ok = false;

		if (ok)
		{
			uint32_t bestError = ~0u;
			int bestColor = 0;
			for (int i = 0; i < int(errors.size()); ++i)
			{
				if (errors[size_t(i)] < bestError)
				{
					bestError = errors[size_t(i)];
					bestColor = i;
				}
			}
			outPalettes[palEntry].SetRGB444(bestColor);
		}
	}

	destroyBuffer(&processBuffer);
	destroyBuffer(&errorBuffer);
	destroyBuffer(&imageBuffer);
	return ok;
}

bool VulkanManager::Impl::bestMulti(Kernel kernel, const Color444* image, int w, int h, Color444* outPalettes, int bpc, bool hamLayout, const int* forceColors)
{
	if (!initialize())
		return false;

	assert(4 == sizeof(Color444));
	assert(bpc <= 5);

	const int colorCount = 1 << bpc;
	ApplyForcedColorsMulti(outPalettes, h, colorCount, forceColors);
	const size_t imageSize = size_t(w) * size_t(h) * sizeof(Color444);
	const size_t paletteSize = size_t(h) * size_t(colorCount) * sizeof(Color444);

	Buffer imageBuffer;
	Buffer paletteBuffer;
	Buffer processBuffer;
	bool ok = createBuffer(imageSize, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT, &imageBuffer)
		&& createBuffer(paletteSize, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT, &paletteBuffer)
		&& createBuffer(sizeof(MultiProcessInfo), VK_BUFFER_USAGE_STORAGE_BUFFER_BIT, &processBuffer);
	if (!ok)
	{
		destroyBuffer(&processBuffer);
		destroyBuffer(&paletteBuffer);
		destroyBuffer(&imageBuffer);
		return false;
	}

	if (!writeBuffer(imageBuffer, image, imageSize))
		ok = false;
	if (ok && !writeBuffer(paletteBuffer, outPalettes, paletteSize))
		ok = false;
	if (ok && !updateDescriptorSet(imageBuffer, paletteBuffer, processBuffer))
		ok = false;

	for (int palEntry = 1; ok && (palEntry < colorCount); ++palEntry)
	{
		if (forceColors && (forceColors[palEntry] >= 0))
			continue;

		MultiProcessInfo info = {};
		info.w = uint32_t(w);
		info.h = uint32_t(h);
		info.palEntry = uint32_t(palEntry);
		info.palStride = hamLayout ? 4u : uint32_t(bpc);
		if (!writeBuffer(processBuffer, &info, sizeof(info)))
			ok = false;

		if (ok && !beginCommands())
			ok = false;

		if (ok)
		{
			vkCmdBindPipeline(commandBuffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline(kernel));
			vkCmdBindDescriptorSets(commandBuffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipelineLayout, 0, 1, &descriptorSet, 0, nullptr);
			vkCmdDispatch(commandBuffer, uint32_t(h), 1, 1);

			VkBufferMemoryBarrier barrier = {};
			barrier.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
			barrier.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
			barrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT;
			barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
			barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
			barrier.buffer = paletteBuffer.buffer;
			barrier.offset = 0;
			barrier.size = paletteBuffer.size;
			vkCmdPipelineBarrier(
				commandBuffer,
				VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
				VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
				0,
				0, nullptr,
				1, &barrier,
				0, nullptr);
		}

		if (ok && !submitAndWait())
			ok = false;
	}

	if (ok && !readBuffer(paletteBuffer, outPalettes, paletteSize))
		ok = false;

	destroyBuffer(&processBuffer);
	destroyBuffer(&paletteBuffer);
	destroyBuffer(&imageBuffer);
	return ok;
}

VulkanManager::VulkanManager()
	: m_impl(std::make_unique<Impl>())
{
}

VulkanManager::~VulkanManager() = default;

bool VulkanManager::bestSHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, const int* forceColors)
{
	return m_impl->bestMulti(Impl::Kernel::Sham, image, w, h, outPalettes, 4, true, forceColors);
}

bool VulkanManager::bestMppPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc, const int* forceColors)
{
	return m_impl->bestMulti(Impl::Kernel::Mpp, image, w, h, outPalettes, bpc, false, forceColors);
}

bool VulkanManager::bestHAMPaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, const int* forceColors)
{
	return m_impl->bestSingle(Impl::Kernel::Ham, image, w, h, outPalettes, 4, forceColors);
}

bool VulkanManager::bestSinglePaletteCompute(const Color444* image, int w, int h, Color444* outPalettes, int bpc, const int* forceColors)
{
	return m_impl->bestSingle(Impl::Kernel::SinglePal, image, w, h, outPalettes, bpc, forceColors);
}
