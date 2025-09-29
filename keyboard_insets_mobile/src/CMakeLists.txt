# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(keyboard_insets_core VERSION 0.0.1 LANGUAGES C)

add_library(keyboard_insets_core SHARED
  "keyboard_insets.c"
)

target_include_directories(keyboard_insets_core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(keyboard_insets_core PUBLIC DART_SHARED_LIB)

if (ANDROID)
  target_link_options(keyboard_insets_core PRIVATE "-Wl,-z,max-page-size=16384")
endif()
