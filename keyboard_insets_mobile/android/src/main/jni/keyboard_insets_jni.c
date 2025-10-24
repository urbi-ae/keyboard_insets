#include <jni.h>
#include <stdbool.h>
#include <string.h>

static JavaVM* g_jvm = NULL;
static jclass g_keyboardClass = NULL;                   // GlobalRef to com.example.keyboard_insets.KeyboardInsets
static jclass g_safeAreaClass = NULL;                   // GlobalRef to com.example.keyboard_insets.SafeAreaMonitor
static jmethodID g_midStartKeyboardObserver = NULL;     // startKeyboardObserver()V
static jmethodID g_midStopKeyboardObserver  = NULL;     // stopKeyboardObserver()V
static jmethodID g_midSetAnimateKeyboard  = NULL;       // setKeyboardAnimation()V
static jmethodID g_midStartSafeAreaObserver = NULL;     // startSafeAreaObserver()V
static jmethodID g_midStopSafeAreaObserver  = NULL;     // stopSafeAreaObserver()V

void platform_update_inset(float inset, float target);
void platform_update_safe_area(float inset);

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void* reserved) {
    g_jvm = vm;
    return JNI_VERSION_1_6;
}

// Helper: get JNIEnv for this thread (attach if needed)
static JNIEnv* get_env(void) {
    if (!g_jvm) return NULL;
    JNIEnv* env = NULL;
    jint rc = (*g_jvm)->GetEnv(g_jvm, (void**)&env, JNI_VERSION_1_6);
    if (rc == JNI_OK) return env;
    if (rc == JNI_EDETACHED) {
        if ((*g_jvm)->AttachCurrentThread(g_jvm, &env, NULL) != 0) return NULL;
        return env;
    }
    return NULL;
}

// Called from Kotlin once (KeyboardInsetsMobilePlugin.nativeInit)
JNIEXPORT void JNICALL Java_com_example_keyboard_1insets_KeyboardInsetsMobilePlugin_nativeInit(JNIEnv* env, jclass clazz) {
    // Cache JavaVM
    (*env)->GetJavaVM(env, &g_jvm);

    // Find and GlobalRef the class we’ll call into
    jclass local = (*env)->FindClass(env, "com/example/keyboard_insets/KeyboardInsets");
    if (!local) return;

    g_keyboardClass = (jclass)(*env)->NewGlobalRef(env, local);
    (*env)->DeleteLocalRef(env, local);

    // Find and GlobalRef the class we’ll call into
    local = (*env)->FindClass(env, "com/example/keyboard_insets/SafeAreaMonitor");
    if (!local) return;

    g_safeAreaClass = (jclass)(*env)->NewGlobalRef(env, local);
    (*env)->DeleteLocalRef(env, local);

    // Cache method IDs
    g_midStartKeyboardObserver = (*env)->GetStaticMethodID(env, g_keyboardClass, "startKeyboardObserver", "()V");
    g_midStopKeyboardObserver  = (*env)->GetStaticMethodID(env, g_keyboardClass, "stopKeyboardObserver",  "()V");
    g_midSetAnimateKeyboard  = (*env)->GetStaticMethodID(env, g_keyboardClass, "setKeyboardAnimation",  "(Z)V");
    g_midStartSafeAreaObserver  = (*env)->GetStaticMethodID(env, g_safeAreaClass, "startSafeAreaObserver",  "()V");
    g_midStopSafeAreaObserver = (*env)->GetStaticMethodID(env, g_safeAreaClass, "stopSafeAreaObserver",  "()V");
}


JNIEXPORT void JNICALL
Java_com_example_keyboard_1insets_KeyboardInsetsImplKt_platform_1update_1inset(JNIEnv* env, jclass clazz, jfloat inset, jfloat target) {
    platform_update_inset(inset, target);
}

JNIEXPORT void JNICALL
Java_com_example_keyboard_1insets_SafeAreaMonitorKt_platform_1update_1safe_1area(JNIEnv* env, jclass clazz, jfloat inset) {
    platform_update_safe_area(inset);
}

// ---- FFI-exposed functions ----

#ifdef __cplusplus
extern "C" {
#endif

// Exposed to Dart FFI
__attribute__((visibility("default")))
__attribute__((used))
void start_listening_insets(void) {
    if (!g_jvm || !g_keyboardClass || !g_midStartKeyboardObserver) return;
    JNIEnv* env = get_env();
    if (!env) return;
    (*env)->CallStaticVoidMethod(env, g_keyboardClass, g_midStartKeyboardObserver);
}

__attribute__((visibility("default")))
__attribute__((used))
void stop_listening_insets(void) {
    if (!g_jvm || !g_keyboardClass || !g_midStopKeyboardObserver) return;
    JNIEnv* env = get_env();
    if (!env) return;
    (*env)->CallStaticVoidMethod(env, g_keyboardClass, g_midStopKeyboardObserver);
}

__attribute__((visibility("default")))
__attribute__((used))
void platform_set_keyboard_animation(bool isEnabled){
 if (!g_jvm || !g_keyboardClass || !g_midSetAnimateKeyboard) return;
    JNIEnv* env = get_env();
    if (!env) return;

    jboolean jniBooleanValue = isEnabled ? JNI_TRUE : JNI_FALSE;
    (*env)->CallStaticVoidMethod(env, g_keyboardClass, g_midSetAnimateKeyboard, jniBooleanValue);
}

__attribute__((visibility("default")))
__attribute__((used))
void start_listening_safe_area(void) {
    if (!g_jvm || !g_safeAreaClass || !g_midStartSafeAreaObserver) return;
    JNIEnv* env = get_env();
    if (!env) return;
    (*env)->CallStaticVoidMethod(env, g_safeAreaClass, g_midStartSafeAreaObserver);
}

__attribute__((visibility("default")))
__attribute__((used))
void stop_listening_safe_area(void) {
    if (!g_jvm || !g_safeAreaClass || !g_midStopSafeAreaObserver) return;
    JNIEnv* env = get_env();
    if (!env) return;
    (*env)->CallStaticVoidMethod(env, g_safeAreaClass, g_midStopSafeAreaObserver);
}

#ifdef __cplusplus
}
#endif

