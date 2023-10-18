# https://www.vinnie.work/blog/2020-11-17-cmake-eval

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER riscv32-unknown-elf-gcc)

set(CMAKE_C_FLAGS "-nostartfiles -nostdlib")

# Disable standard library
# set(CMAKE_C_STANDARD_LIBRARIES "")

# set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

