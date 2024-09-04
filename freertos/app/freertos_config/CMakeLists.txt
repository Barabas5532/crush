add_library(freertos_config STATIC)

target_include_directories(freertos_config SYSTEM INTERFACE include)
target_include_directories(freertos_config PRIVATE include)

target_compile_definitions(freertos_config PUBLIC projCOVERAGE_TEST=0)

target_sources(freertos_config PRIVATE string.c)

# When compiling our memset implementation, this optimisation inserts a
# recursive call.
#
# Disable it for this module only. We want other places to call this memset, so
# that we can optimise the implementation once here and get the speed benefits
# everywhere else.
#
# https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html#index-ftree-loop-distribute-patterns
#
# https://stackoverflow.com/a/33818680/15158846
target_compile_options(freertos_config PRIVATE "-fno-tree-loop-distribute-patterns")
