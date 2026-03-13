TARGET ?= abc2
BUILD_DIR ?= build
UNAME_S := $(shell uname -s)

CXX ?= c++
CC ?= cc
OBJCXX ?= $(CXX)

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

clean:
	rm -rf $(BUILD_DIR) $(TARGET)
