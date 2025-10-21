#include "keyboard_insets.h"
#include <stdbool.h>

static KeyboardInsetUpdateCallback inset_callback = 0;
static KeyboardStateUpdateCallback state_callback = 0;
static SafeAreaInsetUpdateCallback safe_area_callback = 0;

static float current_inset = -1.0f;
static float current_target = -1.0f;
static float max_inset = -1.0f;

static bool is_keyboard_animation_enabled = true;


// ---- Keyboard insets ------------------------------------------------------------------

// Call this function to start listening to keyboard events.
void start_listening_insets(void);

float get_keyboard_height(void) { return max_inset; }

void register_inset_callback(KeyboardInsetUpdateCallback callback) {
    inset_callback = callback;
    set_keyboard_animation(true);
    start_listening_insets();
}

void unregister_inset_callback(void) { inset_callback = 0; }

// ---- Keyboard state -------------------------------------------------------------------

void register_state_callback(KeyboardStateUpdateCallback callback) {
    state_callback = callback;
    start_listening_insets();
}

void unregister_state_callback(void) { state_callback = 0; }

bool is_keyboard_visible(void) {
    if (is_keyboard_animation_enabled) {
            return current_target > 0.0f;
    }

    return current_inset > 0.0f;
}

bool is_keyboard_animating(void) { return current_inset != current_target; }

void set_keyboard_animation(bool isEnabled) {
    is_keyboard_animation_enabled = isEnabled;
    // Implementated inside platform-specific code.
    platform_set_keyboard_animation(isEnabled);
}

/// Called by platform-specific code
///
/// Triggers callback for update insets
void platform_update_inset(float current, float target) {
    if (current == current_inset) {
        return;
    }

    current_inset = current;
    current_target = target;
    if (max_inset < target) {
        max_inset = target;
    }

    if (inset_callback && is_keyboard_animation_enabled) {
        inset_callback(current);
    }

    if (state_callback) {
        state_callback(is_keyboard_visible(), is_keyboard_animating());
    }
}

// ---- Safe area insets -----------------------------------------------------------------

void start_listening_safe_area(void);
void stop_listening_safe_area(void);

void register_safe_area_inset_callback(SafeAreaInsetUpdateCallback callback) {
    safe_area_callback = callback;
    start_listening_safe_area();
}

void unregister_safe_area_inset_callback(void) { 
    safe_area_callback = 0;
    stop_listening_safe_area();
}

/// Called by platform-specific code
///
/// Triggers callback for update safe area insets
void platform_update_safe_area(float inset) {
    if (safe_area_callback) {
        safe_area_callback(inset);
    }
}