.section .blah
.global start
start:
    // Load stack_start defined by the linker file to the stack pointer
    la sp, stack_start
    // Call c_start to do the rest of the initialisation
    call c_start
