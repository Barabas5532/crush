cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

project(crush_freertos C ASM)

set(CMAKE_C_STANDARD 11)

include(FetchContent)

FetchContent_Declare( freertos_kernel
  GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS-Kernel.git
  GIT_TAG        V11.1.0
)

add_subdirectory(freertos_config)

# no heap, only static allocation
# unset( FREERTOS_HEAP CACHE )

# Select the native compile PORT
set( FREERTOS_PORT "GCC_POSIX" CACHE STRING "" FORCE)

# Select the cross-compile PORT
if (CMAKE_CROSSCOMPILING)
    set(FREERTOS_RISCV_EXTENSION "RISCV_no_extensions" CACHE STRING "" FORCE)
    set(FREERTOS_PORT "GCC_RISC_V_GENERIC" CACHE STRING "" FORCE)
endif()

FetchContent_MakeAvailable(freertos_kernel)


add_executable(${PROJECT_NAME}
    src/main.c
    src/hal.c
    src/start.S
    src/start.c
)

target_link_options(${PROJECT_NAME} PRIVATE -T${CMAKE_CURRENT_SOURCE_DIR}/crush.ld)
set_target_properties(${PROJECT_NAME} PROPERTIES LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/crush.ld)

target_link_libraries(${PROJECT_NAME} PRIVATE freertos_kernel)

# Since we use -nostdlib, we must link to libgcc manually
target_link_libraries(${PROJECT_NAME} PRIVATE gcc)

string(REPLACE "-gcc" "-objcopy" objcopy_name ${CMAKE_C_COMPILER})
find_program(objcopy_program ${objcopy_name} REQUIRED)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${objcopy_program} -O binary ${PROJECT_NAME} ${PROJECT_NAME}.bin
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        )
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${objcopy_program} --verilog-data-width 4 -O verilog ${PROJECT_NAME} ${PROJECT_NAME}.data
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        )
