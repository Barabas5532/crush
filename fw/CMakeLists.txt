cmake_minimum_required(VERSION 3.24 FATAL_ERROR)

project(crush-blinky)

set(CMAKE_C_STANDARD 11)

add_executable(crush-blinky)
target_sources(crush-blinky PRIVATE start.c main.c hal.c)

target_link_options(crush-blinky PRIVATE -T${CMAKE_CURRENT_SOURCE_DIR}/crush.ld)
set_target_properties(crush-blinky PROPERTIES LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/crush.ld)

