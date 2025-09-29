cmake_minimum_required(VERSION 3.10)

project(keyboard_insets_mobile LANGUAGES C)

add_library(keyboard_insets_mobile SHARED
    keyboard_insets_jni.c
    ../../../../src/keyboard_insets.h
    ../../../../src/keyboard_insets.c
)

target_compile_definitions(keyboard_insets_mobile PUBLIC DART_SHARED_LIB)

target_link_options(keyboard_insets_mobile PRIVATE "-Wl,-z,max-page-size=16384")