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
 * The entry point into the C application.
 *
 * It is called from assembly startup code in start.S, which is in turn placed
 * at the initial PC using the linker script.
 */
void c_start(void)
{
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
