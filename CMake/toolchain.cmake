# Copyright 2016 Silicon Laboratories, Inc.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if(TARGET_EFM32_TOOLCHAIN_INCLUDED)
    return()
endif()
set(TARGET_EFM32_TOOLCHAIN_INCLUDED 1)

# Set part number define. Used by em_device.h to provide correct device headers.
if(DEFINED YOTTA_CFG_HARDWARE_DEVICE)
   add_definitions("-D${YOTTA_CFG_HARDWARE_DEVICE}")
else()
   message(FATAL_ERROR
"   *****************************************************************************
   * ERROR (target-efm32): No part number was given in yotta config. Cannot    *
   *                       select the correct part header. Aborting.           *
   *                       Please define config.hardware.device to your part   *
   *                       number, e.g. \"EFM32GG990F1024\".                     *
   *****************************************************************************")
endif()

# Set CPU and architecture
if(TARGET_LIKE_CORTEX_M3)
	set(_CPU_COMPILATION_OPTIONS "-mcpu=cortex-m3 -mthumb -D__thumb2__")
	set(_CPU_LINKER_OPTIONS "-mcpu=cortex-m3 -mthumb")
elseif(TARGET_LIKE_CORTEX_M4)
	set(_CPU_COMPILATION_OPTIONS "-mcpu=cortex-m4 -mthumb -D__thumb2__")
	set(_CPU_LINKER_OPTIONS "-mcpu=cortex-m4 -mthumb")
elseif(TARGET_LIKE_CORTEX_M0PLUS)
	set(_CPU_COMPILATION_OPTIONS "-mcpu=cortex-m0plus -mthumb -D__thumb2__")
	set(_CPU_LINKER_OPTIONS "-mcpu=cortex-m0plus -mthumb")
else()
	message(FATAL_ERROR
"   *****************************************************************************
   * ERROR (target-efm32): No Cortex-M core type given. Please add the core    *
   *                       type to the 'similarTo' list in the yotta target    *
   *                       config. Should be one of \"cortex-m0plus\",           *
   *                       \"cortex-m3\" or \"cortex-m4\".                         *
   *****************************************************************************")
endif()

# Set FLASH size
if((DEFINED YOTTA_CFG_HARDWARE_FLASH_SIZE) AND (EXISTS "${CMAKE_CURRENT_LIST_DIR}/../ld/memory/flash_${YOTTA_CFG_HARDWARE_FLASH_SIZE}k.ld"))
	set(_LINKER_CFG_FILE_FLASH "${CMAKE_CURRENT_LIST_DIR}/../ld/memory/flash_${YOTTA_CFG_HARDWARE_FLASH_SIZE}k.ld")
else()
	message(FATAL_ERROR
"   *****************************************************************************
   * ERROR (target-efm32): Invalid flash size or flash size not given in yotta *
   *                       config. Please define config.hardware.flash-size to *
   *                       an integer describing the flash size of the device  *
   *                       you are building for in kilobytes.                  *
   *****************************************************************************")
endif()

# Set RAM size
if((DEFINED YOTTA_CFG_HARDWARE_RAM_SIZE) AND (EXISTS "${CMAKE_CURRENT_LIST_DIR}/../ld/memory/ram_${YOTTA_CFG_HARDWARE_RAM_SIZE}k.ld"))
	set(_LINKER_CFG_FILE_RAM "${CMAKE_CURRENT_LIST_DIR}/../ld/memory/ram_${YOTTA_CFG_HARDWARE_RAM_SIZE}k.ld")
else()
	message(FATAL_ERROR
"   *****************************************************************************
   * ERROR (target-efm32): Invalid ram size or ram size not given in yotta     *
   *                       config. Please define config.hardware.ram-size to   *
   *                       an integer describing the ram size of the device    *
   *                       you are building for in kilobytes.                  *
   *****************************************************************************")
endif()

# Set stack size
if(DEFINED YOTTA_CFG_STACK_SIZE)
	add_definitions("-D__STACK_SIZE=${YOTTA_CFG_STACK_SIZE}")
else()
	message(
"   *****************************************************************************
   * WARNING (target-efm32): No stack size set in yotta target config.         *
   *                         Defaulting to a 1 kB stack.                       *
   *                         Set config.stack-size to the preferred stack size *
   *                         for your target (must be an integer - dec or hex).*
   *****************************************************************************")
endif()

# Set NVIC size
math(EXPR _NVIC_VECTOR_SIZE "4 * (${YOTTA_CFG_CMSIS_NVIC_USER_IRQ_OFFSET} + ${YOTTA_CFG_CMSIS_NVIC_USER_IRQ_NUMBER})")
set(_LINKER_CFG_PARAMS "${_LINKER_CFG_PARAMS},--defsym=__vector_size=${_NVIC_VECTOR_SIZE}")

# Set compiler flags
set(CMAKE_C_FLAGS_INIT             "${CMAKE_C_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_ASM_FLAGS_INIT           "${CMAKE_ASM_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_CXX_FLAGS_INIT           "${CMAKE_CXX_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${CMAKE_MODULE_LINKER_FLAGS_INIT} ${_CPU_LINKER_OPTIONS}")

# Set linker flags
set(CMAKE_EXE_LINKER_FLAGS_INIT    "${CMAKE_EXE_LINKER_FLAGS_INIT} ${_CPU_LINKER_OPTIONS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT    "${CMAKE_EXE_LINKER_FLAGS_INIT} -Wl${_LINKER_CFG_PARAMS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT    "${CMAKE_EXE_LINKER_FLAGS_INIT} -T\"${_LINKER_CFG_FILE_FLASH}\"")
set(CMAKE_EXE_LINKER_FLAGS_INIT    "${CMAKE_EXE_LINKER_FLAGS_INIT} -T\"${_LINKER_CFG_FILE_RAM}\"")
set(CMAKE_EXE_LINKER_FLAGS_INIT    "${CMAKE_EXE_LINKER_FLAGS_INIT} -T\"${CMAKE_CURRENT_LIST_DIR}/../ld/efm32.ld\"")
