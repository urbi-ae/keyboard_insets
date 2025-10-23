#include "../../src/keyboard_insets.c"
#include "keyboard_insets.h"

// ---- Swift functions exported with @_cdecl --------------------------------------------

void start_keyboard_observer(void);

void stop_keyboard_observer(void);

void simulate_keyboard_animation(bool isEnabled);

void start_safe_area_observer(void);

void stop_safe_area_observer(void);

// ---- C functions to be called by Dart or Clang Core -----------------------------------

void start_listening_insets(void) {
    start_keyboard_observer();
}

void stop_listening_insets(void) {
    stop_keyboard_observer();
}

void start_listening_safe_area(void){
    start_safe_area_observer();
}

void stop_listening_safe_area(void) {
    stop_safe_area_observer();
}

void platform_set_keyboard_animation(bool isEnabled){
    simulate_keyboard_animation(isEnabled);
}