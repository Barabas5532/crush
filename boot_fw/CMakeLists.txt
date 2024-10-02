cmake_minimum_required(VERSION 3.24 FATAL_ERROR)

project(crush-boot C ASM)

add_executable(crush-boot)
target_sources(crush-boot PRIVATE boot.S)

target_link_options(crush-boot PRIVATE -T${CMAKE_CURRENT_SOURCE_DIR}/crush-boot.ld)
set_target_properties(crush-boot PROPERTIES LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/crush-boot.ld)

string(REPLACE "-gcc" "-objcopy" objcopy_name ${CMAKE_C_COMPILER})
find_program(objcopy_program ${objcopy_name} REQUIRED)
add_custom_command(TARGET crush-boot POST_BUILD
        COMMAND ${objcopy_program} --verilog-data-width 4 -O verilog crush-boot crush-boot.data
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        )
