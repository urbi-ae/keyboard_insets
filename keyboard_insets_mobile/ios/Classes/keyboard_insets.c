#include "../../src/keyboard_insets.c"
#include "keyboard_insets.h"

// ---- Swift functions exported with @_cdecl --------------------------------------------

void start_keyboard_observer(void);

void stop_keyboard_observer(void);

void simulate_keyboard_animation(bool isEnabled);

// ---- C functions to be called by Dart or Clang Core -----------------------------------

void start_listening_insets(void) {
    start_keyboard_observer();
}

void stop_listening_insets(void) {
    stop_keyboard_observer();
}

void platform_set_keyboard_animation(bool isEnabled){
    simulate_keyboard_animation(isEnabled);
}