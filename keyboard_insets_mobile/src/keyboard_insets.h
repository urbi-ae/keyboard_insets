#pragma once
#include <stdbool.h>

// Get keyboard height in logical pixels.
float get_keyboard_height(void);

// Check if the keyboard is currently visible.
bool is_keyboard_visible(void);

// Check if the keyboard is currently animating (showing or hiding).
bool is_keyboard_animating(void);

// A callback for keyboard inset changes.
typedef void (*KeyboardInsetUpdateCallback)(float inset);
// A callback for keyboard visibility and animation state changes.
typedef void (*KeyboardStateUpdateCallback)(bool isVisible, bool isAnimating);

// Register callback for keyboard inset changes.
void register_inset_callback(KeyboardInsetUpdateCallback callback);
// Register callback for keyboard state changes.
void register_state_callback(KeyboardStateUpdateCallback callback);

// Unregister callback for keyboard inset changes.
void unregister_inset_callback(void);
// Unregister callback for keyboard state changes.
void unregister_state_callback(void);

// Enable or disable keyboard animation handling.
void set_keyboard_animation(bool isEnabled);


// ---- Native functions which are design to be implemented in platform-specific code ----

// Call this function to start listening to keyboard events.
void start_listening_insets(void);

// Call this function to stop listening to keyboard events.
void stop_listening_insets(void);

// Do not call this function directly, it is called by platform-specific code.
void platform_set_keyboard_animation(bool isEnabled);