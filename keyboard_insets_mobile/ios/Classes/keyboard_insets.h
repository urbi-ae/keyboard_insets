#ifndef KEYBOARD_INSETS_IOS_H
#define KEYBOARD_INSETS_IOS_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

void start_listening_insets(void);
void stop_listening_insets(void);

void platform_update_inset(float current, float target);

void platform_set_keyboard_animation(bool isEnabled);

#ifdef __cplusplus
}
#endif

#endif