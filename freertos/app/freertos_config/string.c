#include <string.h>

/* When using -nostdlib with GCC, it may still generate calls to memcmp,
 * memset, memcpy and memmove. These usually come from the standard C library,
 * but we don't have one. Define the functions here so that the app can still
 * link.
 *
 * memcpy and memset are also used by FreeRTOS implementation.
 */

void* memcpy( void *restrict a_dest, const void *restrict a_src, size_t count ) {
    char *dest = a_dest;
    const char *src = a_src;

    for(int i = 0; i < count; i++) {
        dest[i] = src[i];
    }
}

void *memset( void *a_dest, int ch, size_t count ) {
    char *dest = a_dest;

    for(int i = 0; i < count; i++) {
        dest[i] = ch;
    }
}

int memcmp( const void* a_lhs, const void* a_rhs, size_t count ) {
    const unsigned char *lhs = a_lhs;
    const unsigned char *rhs = a_rhs;
    
    for(int i = 0; i < count; i++) {
        const unsigned char l = lhs[i];
        const unsigned char r = rhs[i];

        if(l != r)
        {
            return (int)l - (int)r;
        }
    }

    return 0;
}

void *memmove(void *a_dest, const void *a_src, size_t count) {
    unsigned char *dest = a_dest;
    const unsigned char *src = a_src;

    if (dest == src || count == 0) {
        // nothing to copy
    } else if (dest < src) {
        for (size_t i = 0; i < count; i++) {
            dest[i] = src[i];
        }
    } else {
        for (size_t i = count; i > 0; i--) {
            dest[i - 1] = src[i - 1];
        }
    }

    return a_dest;
}
