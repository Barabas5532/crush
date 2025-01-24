#pragma once

#include <stddef.h>

/* The FreeRTOS GCC RISC-V port depends on some functions from string.h. We
 * don't use a stdlib, so must manually implement the functions that are used.
 */

void* memcpy( void *restrict dest, const void *restrict src, size_t count );
void *memset( void *dest, int ch, size_t count );
