TARGET ?= abc2
BUILD_DIR ?= build

CXX ?= c++
CC ?= cc

CPP_SRCS := \
	src/abc2.cpp \
	src/color.cpp \
	src/computeManager.cpp \
	src/dithering.cpp \
	src/ham.cpp \
	src/pngFile.cpp \
	src/tileset.cpp

C_SRCS := \
	src/extern/libspng/spng.c \
	src/extern/miniz/miniz.c

OBJS := \
	$(patsubst src/%.cpp,$(BUILD_DIR)/%.o,$(CPP_SRCS)) \
	$(patsubst src/%.c,$(BUILD_DIR)/%.o,$(C_SRCS))

CPPFLAGS += -Isrc
CXXFLAGS += -std=c++17 -O2 -Wall -Wextra -Wpedantic -pthread
CFLAGS += -std=c11 -O2 -Wall -Wextra -Wpedantic
LDFLAGS += -pthread

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(OBJS) $(LDFLAGS) -o $@

$(BUILD_DIR)/%.o: src/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: src/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR) $(TARGET)
