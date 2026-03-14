TARGET ?= abc2
BUILD_DIR ?= build
UNAME_S := $(shell uname -s)
GENERATED_DIR := $(BUILD_DIR)/generated

CXX ?= c++
CC ?= cc
OBJCXX ?= $(CXX)
GLSLANGVALIDATOR ?= $(shell command -v glslangValidator 2>/dev/null)
XXD ?= $(shell command -v xxd 2>/dev/null)
VULKAN_CFLAGS := $(shell pkg-config --cflags vulkan 2>/dev/null)
VULKAN_LIBS := $(shell pkg-config --libs vulkan 2>/dev/null)
ENABLE_VULKAN := 0

CPP_SRCS := \
	src/abc2.cpp \
	src/color.cpp \
	src/computeManager.cpp \
	src/dithering.cpp \
	src/ham.cpp \
	src/pngFile.cpp \
	src/tileset.cpp

MM_SRCS :=

ifeq ($(UNAME_S),Darwin)
MM_SRCS += src/metalManager.mm
endif

ifeq ($(UNAME_S),Linux)
ifneq ($(GLSLANGVALIDATOR),)
ifneq ($(XXD),)
ifneq ($(VULKAN_LIBS),)
ENABLE_VULKAN := 1
CPP_SRCS += src/vulkanManager.cpp
CPPFLAGS += $(VULKAN_CFLAGS) -DABC_HAVE_VULKAN=1 -I$(GENERATED_DIR)
LDFLAGS += $(VULKAN_LIBS)
VULKAN_SHADER_HEADERS := \
	$(GENERATED_DIR)/HamCompute.comp.h \
	$(GENERATED_DIR)/MppCompute.comp.h \
	$(GENERATED_DIR)/ShamCompute.comp.h \
	$(GENERATED_DIR)/SinglePalCompute.comp.h
endif
endif
endif
endif

C_SRCS := \
	src/extern/libspng/spng.c \
	src/extern/miniz/miniz.c

OBJS := \
	$(patsubst src/%.cpp,$(BUILD_DIR)/%.o,$(CPP_SRCS)) \
	$(patsubst src/%.mm,$(BUILD_DIR)/%.o,$(MM_SRCS)) \
	$(patsubst src/%.c,$(BUILD_DIR)/%.o,$(C_SRCS))

CPPFLAGS += -Isrc
CXXFLAGS += -std=c++17 -O2 -Wall -Wextra -Wpedantic -pthread
OBJCXXFLAGS += -std=c++17 -O2 -Wall -Wextra -Wpedantic -pthread
CFLAGS += -std=c11 -O2 -Wall -Wextra -Wpedantic
LDFLAGS += -pthread

ifeq ($(UNAME_S),Darwin)
OBJCXXFLAGS += -fobjc-arc
LDFLAGS += -framework Foundation -framework Metal
endif

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(OBJS) $(LDFLAGS) -o $@

$(BUILD_DIR)/%.o: src/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: src/%.mm
	@mkdir -p $(dir $@)
	$(OBJCXX) $(CPPFLAGS) $(OBJCXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: src/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

ifeq ($(ENABLE_VULKAN),1)
$(BUILD_DIR)/vulkanManager.o: $(VULKAN_SHADER_HEADERS)

$(GENERATED_DIR)/%.comp.spv: src/shaders/vulkan/%.comp
	@mkdir -p $(dir $@)
	$(GLSLANGVALIDATOR) -V -S comp -o $@ $<

$(GENERATED_DIR)/HamCompute.comp.h: $(GENERATED_DIR)/HamCompute.comp.spv
	@mkdir -p $(dir $@)
	$(XXD) -i -n g_vulkanHamKernel $< > $@

$(GENERATED_DIR)/MppCompute.comp.h: $(GENERATED_DIR)/MppCompute.comp.spv
	@mkdir -p $(dir $@)
	$(XXD) -i -n g_vulkanMppKernel $< > $@

$(GENERATED_DIR)/ShamCompute.comp.h: $(GENERATED_DIR)/ShamCompute.comp.spv
	@mkdir -p $(dir $@)
	$(XXD) -i -n g_vulkanShamKernel $< > $@

$(GENERATED_DIR)/SinglePalCompute.comp.h: $(GENERATED_DIR)/SinglePalCompute.comp.spv
	@mkdir -p $(dir $@)
	$(XXD) -i -n g_vulkanSinglePalKernel $< > $@
endif

clean:
	rm -rf $(BUILD_DIR) $(TARGET)
