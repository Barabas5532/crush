# https://www.vinnie.work/blog/2020-11-17-cmake-eval

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER riscv64-elf-gcc)

# TODO maybe we want startfiles? just nostdlib
set(CMAKE_C_FLAGS "-nostartfiles -nostdlib -march=rv32i -mabi=ilp32")
set(CMAKE_ASM_FLAGS "-march=rv32i -mabi=ilp32")

# Disable standard library
# set(CMAKE_C_STANDARD_LIBRARIES "")

# set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

