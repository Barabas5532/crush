/**
 * \file Start-up code for hardware and C runtime initialisation.
 */

/**
 * \defgroup linker Symbols exported by the linker script
 * @{
 */

/** The start of the region in RAM to be zero initialised */
extern int bss_start[0];
/** The end of the region in RAM to be zero initialised */
extern int bss_end[0];

/** The start of the region in flash containing the program data */
extern int __flash_data_start[0];
/** The end of the region in flash containing the program data */
extern int __flash_data_end[0];

/** The start of the region in RAM where program data is copied */
extern int __data_start[0];
/** The end of the region in RAM where program data is copied*/
extern int __data_end[0];

/**
 * @}
 */

int main(void);

/**
 * The entry point into the C application.
 *
 * It is called from assembly startup code in start.S, which is in turn placed
 * at the initial PC using the linker script.
 */
void c_start(void)
{
    {
        int *src = __flash_data_start;
        int *dst = __data_start;

        while(dst < __data_end) {
            *dst = *src;

            dst++;
            src++;
        }
    }

    for(int *i = bss_start; i < bss_end; i++)
    {
        *i = 0;
    }

    main();

    // The assembly start code does not expect us to return, really main should
    // not return either
    for(;;)
        ;
}
