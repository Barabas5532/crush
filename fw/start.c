/**
 * \file Start-up code for hardware and C runtime initialisation.
 */

/**
 * \defgroup linker Symbols exported by the linker script
 * @{
 */

/** The start of the data region in flash to be copied to RAM */
int data_flash_start[0];
/** The end of the data region in flash to be copied to RAM */
int data_flash_end[0];
/** The start of the data region in RAM */
int data_ram_start[0];
/** The end of the data region in RAM */
int data_ram_end[0];

/** The start of the region in RAM to be zero initialised */
int bss_start[0];
/** The end of the region in RAM to be zero initialised */
int bss_end[0];


/**
 * @}
 */

int main();

/**
 * The entry point into the application.
 *
 * The linker script is configured to place this function at the initial PC.
 * This will be the very first thing executed after boot.
 */
__attribute__ ((section (".start"))) void start(void) {
    for(int i = 0; data_flash_start + i < data_flash_end; i++)
    {
        data_ram_start[i] = data_flash_start[i];
    }

    for(int *i = bss_start; i < bss_end; i++)
    {
        i[0] = 0;
    }

    main();

    // Main should never return
    while(1);
}
