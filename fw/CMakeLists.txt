cmake_minimum_required(VERSION 3.24 FATAL_ERROR)

project(crush-blinky C ASM)

set(CMAKE_C_STANDARD 11)

add_executable(crush-blinky)
target_sources(crush-blinky PRIVATE start.S start.c main.c hal.c)

target_link_options(crush-blinky PRIVATE -T${CMAKE_CURRENT_SOURCE_DIR}/crush.ld)
set_target_properties(crush-blinky PROPERTIES LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/crush.ld)

string(REPLACE "-gcc" "-objcopy" objcopy_name ${CMAKE_C_COMPILER})
find_program(objcopy_program ${objcopy_name} REQUIRED)
add_custom_command(TARGET crush-blinky POST_BUILD
        COMMAND ${objcopy_program} -O binary crush-blinky crush-blinky.bin
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        )
add_custom_command(TARGET crush-blinky POST_BUILD
        COMMAND ${objcopy_program} --verilog-data-width 4 -O verilog crush-blinky crush-blinky.data
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        )
