/*
 * Copyright 2016 Silicon Laboratories, Inc.
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* MEMORY is specified by device-specific linker files that have to be included
 * using -T<path_to_ld_file> *before* this file.
 *
 * __vector_size is defined on the build line by toolchain.cmake
 */

/* Linker script to place sections and symbol values.
 * It references following symbols, which must be defined in code:
 *   Reset_Handler : Entry of reset handler
 *
 * It defines following symbols, which code can use without definition:
 * __uvisor_bss_start
 * __uvisor_bss_main_start
 * __uvisor_bss_main_end
 * __uvisor_bss_boxes_start
 * __uvisor_bss_boxes_end
 * __uvisor_bss_boxes_end
 * __uvisor_bss_end
 * __uvisor_main_start
 * __uvisor_main_end
 * __exidx_start
 * __exidx_end
 * __etext
 * __StackLimit
 * __StackTop
 * __stack
 * __data_start__
 * __start_vector_table__
 * __end_vector_table__
 * __preinit_array_start
 * __preinit_array_end
 * __init_array_start
 * __init_array_end
 * __fini_array_start
 * __fini_array_end
 * __data_end__
 * __uvisor_secure_start
 * __uvisor_cfgtbl_start
 * __uvisor_cfgtbl_end
 * __uvisor_cfgtbl_ptr_start
 * __uvisor_cfgtbl_ptr_end
 * __uvisor_secure_end
 * __bss_start__
 * __bss_end__
 * __end__
 * end
 * __HeapLimit
 * __heap_size
 * __mbed_sbrk_start
 * __mbed_krbs_start
 * __heap_end
 * __uvisor_flash_start
 * __uvisor_flash_end
 * __uvisor_sram_start
 * __uvisor_sram_end
 */
ENTRY(Reset_Handler)

SECTIONS
{
  /* Ensure that uvisor bss is at the beginning of RAM */
  .uvisor.bss (NOLOAD):
  {
    . = ALIGN(32);
    __uvisor_bss_start = .;

    /* Protected uvisor main bss */
    . = ALIGN(32);
    __uvisor_bss_main_start = .;
    KEEP(*(.keep.uvisor.bss.main))
    . = ALIGN(32);
    __uvisor_bss_main_end = .;

    /* Protected uvisor secure boxes bss */
    . = ALIGN(32);
    __uvisor_bss_boxes_start = .;
    KEEP(*(.keep.uvisor.bss.boxes))
    . = ALIGN(32);

    /* Place DMA descriptors inside uvisor.bss.boxes region.
     * Not used if uvisor is present (DMA is placed in secure box instead)
     */
    *("dma")

    __uvisor_bss_boxes_end = .;

    /* Ensure log2(size) alignment of the uvisor region, to ensure that
     * the region can be effectively protected by the MPU.
     */
    . = ALIGN(1 << LOG2CEIL(__uvisor_bss_boxes_end - __uvisor_bss_start));
    __uvisor_bss_end = .;
  } > RAM
  
  .text :
  {
    KEEP(*(.isr_vector))
    
    /* uVisor code and data */
    . = ALIGN(1 << LOG2CEIL(__vector_size));
    __uvisor_main_start = .;
    *(.uvisor.main)
    __uvisor_main_end = .;
    *(.text*)

    KEEP(*(.init))
    KEEP(*(.fini))

    /* .ctors */
    *crtbegin.o(.ctors)
    *crtbegin?.o(.ctors)
    *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
    *(SORT(.ctors.*))
    *(.ctors)

    /* .dtors */
    *crtbegin.o(.dtors)
    *crtbegin?.o(.dtors)
    *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
    *(SORT(.dtors.*))
    *(.dtors)

    *(.rodata*)

    KEEP(*(.eh_frame*))
  } > FLASH

  .ARM.extab :
  {
    *(.ARM.extab* .gnu.linkonce.armextab.*)
  } > FLASH

  __exidx_start = .;
  .ARM.exidx :
  {
    *(.ARM.exidx* .gnu.linkonce.armexidx.*)
  } > FLASH
  __exidx_end = .;

  /* .stack section doesn't contains any symbols. It is only
   * used for linker to reserve space for the main stack section
   * WARNING: .stack should come immediately after the last secure memory
   * section.  This provides stack overflow detection. */
  .stack (NOLOAD):
  {
    __StackLimit = .;
    *(.stack*);
    . = ALIGN(4);
  } > RAM

  __StackTop = ADDR(.stack) + SIZEOF(.stack);
  __StackLimit = ADDR(.stack);
  PROVIDE(__stack = __StackTop);

  .data . :
  {
    PROVIDE( __etext = LOADADDR(.data) );

    __data_start__ = .;
    PROVIDE( __start_vector_table__ = .);
  	. += __vector_size;
    . = ALIGN(8);
  	PROVIDE( __end_vector_table__ = .);
    *(vtable)
    *(.data*)

    . = ALIGN(4);
    /* preinit data */
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP(*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);

    . = ALIGN(4);
    /* init data */
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP(*(SORT(.init_array.*)))
    KEEP(*(.init_array))
    PROVIDE_HIDDEN (__init_array_end = .);

    . = ALIGN(4);
    /* finit data */
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP(*(SORT(.fini_array.*)))
    KEEP(*(.fini_array))
    PROVIDE_HIDDEN (__fini_array_end = .);

    . = ALIGN(4);
    /* All data end */
    . = ALIGN(32);
    __data_end__ = .;

  } > RAM AT>FLASH

  /* uvisor configuration data */
  .uvisor.secure :
  {
    . = ALIGN(32);
    __uvisor_secure_start = .;

    /* uvisor secure boxes configuration tables */
    . = ALIGN(32);
    __uvisor_cfgtbl_start = .;
    KEEP(*(.keep.uvisor.cfgtbl))
    . = ALIGN(32);
    __uvisor_cfgtbl_end = .;

    /* pointers to uvisor secure boxes configuration tables */
    /* note: no further alignment here, we need to have the exact list of pointers */
    __uvisor_cfgtbl_ptr_start = .;
    KEEP(*(.keep.uvisor.cfgtbl_ptr_first))
    KEEP(*(.keep.uvisor.cfgtbl_ptr))
    __uvisor_cfgtbl_ptr_end = .;

    . = ALIGN(32);
    __uvisor_secure_end = .;
  } >FLASH
  
  .bss (NOLOAD):
  {
    __bss_start__ = .;
    *(.bss*)
    *(COMMON)
    __bss_end__ = .;
  } > RAM

  .heap (NOLOAD):
  {
    __end__ = .;
    end = __end__;
    *(.heap*);
    . += (ORIGIN(RAM) + LENGTH(RAM) - .);
    __HeapLimit = .;
  } > RAM

  PROVIDE(__heap_size = SIZEOF(.heap));
  PROVIDE(__mbed_sbrk_start = ADDR(.heap));
  PROVIDE(__mbed_krbs_start = ADDR(.heap) + SIZEOF(.heap));
    
  /* heap limit is all the available memory, */
  __heap_end = ORIGIN(RAM) + LENGTH(RAM);

  /* Provide physical memory boundaries for uVisor. */
  __uvisor_flash_start = ORIGIN(FLASH);
  __uvisor_flash_end = ORIGIN(FLASH) + LENGTH(FLASH);
  __uvisor_sram_start = ORIGIN(RAM);
  __uvisor_sram_end = ORIGIN(RAM) + LENGTH(RAM);

  /* Check if data + heap + stack exceeds RAM limit */
  ASSERT(__end__ <= __heap_end, "region RAM overflowed")
}
