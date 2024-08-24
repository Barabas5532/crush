# https://www.vinnie.work/blog/2020-11-17-cmake-eval

set(CMAKE_SYSTEM_NAME Generic)

find_program(COMPILER_PATH
    NAMES
    # ubuntu and debian
    riscv32-unknown-elf-gcc
    riscv64-unknown-elf-gcc
    # arch linux
    riscv64-elf-gcc
    REQUIRED)
get_filename_component(COMPILER_NAME ${COMPILER_PATH} NAME)
set(CMAKE_C_COMPILER ${COMPILER_NAME})

set(CMAKE_C_FLAGS "-nostartfiles -nostdlib -march=rv32i_zicsr -mabi=ilp32")
set(CMAKE_ASM_FLAGS "-march=rv32i_zicsr -mabi=ilp32")
