set(CMAKE_SYSTEM_NAME               Generic)
set(CMAKE_SYSTEM_PROCESSOR          arm)

set(CMAKE_C_COMPILER_ID GNU)
set(CMAKE_CXX_COMPILER_ID GNU)

# Some default GCC settings
set(TOOLCHAIN_PREFIX                arm-none-eabi-)

# Try to resolve full paths first so IDE-side CMake diagnostics work even when PATH is incomplete.
set(_ARM_GCC_HINTS
	"C:/ST/STM32CubeIDE_1.18.1/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.14.3.rel1.win32_1.0.100.202602081740/tools/bin"
)

find_program(ARM_GCC_EXE NAMES ${TOOLCHAIN_PREFIX}gcc HINTS ${_ARM_GCC_HINTS})
find_program(ARM_GXX_EXE NAMES ${TOOLCHAIN_PREFIX}g++ HINTS ${_ARM_GCC_HINTS})
find_program(ARM_OBJCOPY_EXE NAMES ${TOOLCHAIN_PREFIX}objcopy HINTS ${_ARM_GCC_HINTS})
find_program(ARM_SIZE_EXE NAMES ${TOOLCHAIN_PREFIX}size HINTS ${_ARM_GCC_HINTS})

if(ARM_GCC_EXE)
	set(CMAKE_C_COMPILER            ${ARM_GCC_EXE})
else()
	set(CMAKE_C_COMPILER            ${TOOLCHAIN_PREFIX}gcc)
endif()

set(CMAKE_ASM_COMPILER              ${CMAKE_C_COMPILER})

if(ARM_GXX_EXE)
	set(CMAKE_CXX_COMPILER          ${ARM_GXX_EXE})
	set(CMAKE_LINKER                ${ARM_GXX_EXE})
else()
	set(CMAKE_CXX_COMPILER          ${TOOLCHAIN_PREFIX}g++)
	set(CMAKE_LINKER                ${TOOLCHAIN_PREFIX}g++)
endif()

if(ARM_OBJCOPY_EXE)
	set(CMAKE_OBJCOPY               ${ARM_OBJCOPY_EXE})
else()
	set(CMAKE_OBJCOPY               ${TOOLCHAIN_PREFIX}objcopy)
endif()

if(ARM_SIZE_EXE)
	set(CMAKE_SIZE                  ${ARM_SIZE_EXE})
else()
	set(CMAKE_SIZE                  ${TOOLCHAIN_PREFIX}size)
endif()

set(CMAKE_EXECUTABLE_SUFFIX_ASM     ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_C       ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_CXX     ".elf")

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# MCU specific flags
set(TARGET_FLAGS "-mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard ")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${TARGET_FLAGS}")
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS} -x assembler-with-cpp -MMD -MP")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -fdata-sections -ffunction-sections -fstack-usage")

# The cyclomatic-complexity parameter must be defined for the Cyclomatic complexity feature in STM32CubeIDE to work.
# However, most GCC toolchains do not support this option, which causes a compilation error; for this reason, the feature is disabled by default.
# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fcyclomatic-complexity")

set(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_C_FLAGS_RELEASE "-Os -g0")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -g0")

set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fno-rtti -fno-exceptions -fno-threadsafe-statics")

set(CMAKE_EXE_LINKER_FLAGS "${TARGET_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T \"${CMAKE_SOURCE_DIR}/STM32G431XX_FLASH.ld\"")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --specs=nano.specs")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Map=${CMAKE_PROJECT_NAME}.map -Wl,--gc-sections")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--print-memory-usage")
set(TOOLCHAIN_LINK_LIBRARIES "m")
