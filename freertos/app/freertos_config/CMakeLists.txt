add_library(freertos_config STATIC)

target_include_directories(freertos_config SYSTEM INTERFACE include)
target_include_directories(freertos_config PRIVATE include)

target_compile_definitions(freertos_config PUBLIC projCOVERAGE_TEST=0)

target_sources(freertos_config PRIVATE string.c)

# options for cross-compilation or something like that?
target_compile_definitions(freertos_config PUBLIC ${definitions})
target_compile_options(freertos_config PUBLIC ${options})
