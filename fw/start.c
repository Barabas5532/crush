/**
 * \file Start-up code for hardware and C runtime initialisation.
 */

/**
 * \defgroup linker Symbols exported by the linker script
 * @{
 */

/** The start of the region in RAM to be zero initialised */
int bss_start[0];
/** The end of the region in RAM to be zero initialised */
int bss_end[0];

/**
 * @}
 */

int main(void);

/**
 * The entry point into the application.
 *
 * The linker script is configured to place this function at the initial PC.
 * This will be the very first thing executed after boot.
 */
__attribute__((section(".start"))) void start(void)
{
    // TODO set up stack section and stack pointer:
    // https://vivonomicon.com/2020/02/11/bare-metal-risc-v-development-with-the-gd32vf103cb/

    for(int *i = bss_start; i < bss_end; i++)
    {
        *i = 0;
    }

    main();

    // Main should never return
    while(1)
        ;
}
