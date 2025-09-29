#include <jni.h>
#include <stdbool.h>
#include <string.h>

static JavaVM* g_jvm = NULL;
static jclass g_pluginClass = NULL;          // GlobalRef to com.example.keyboard_insets.KeyboardInsetsPlugin
static jmethodID g_midStart = NULL;          // startKeyboardObserver()V
static jmethodID g_midStop  = NULL;          // stopKeyboardObserver()V
static jmethodID g_setAnim  = NULL;          // setKeyboardAnimation()V

void platform_update_inset(float inset, float target);

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
    if (!local) return; // class not found -> ignore, but you should log

    g_pluginClass = (jclass)(*env)->NewGlobalRef(env, local);
    (*env)->DeleteLocalRef(env, local);

    // Cache method IDs
    g_midStart = (*env)->GetStaticMethodID(env, g_pluginClass, "startKeyboardObserver", "()V");
    g_midStop  = (*env)->GetStaticMethodID(env, g_pluginClass, "stopKeyboardObserver",  "()V");
    g_setAnim  = (*env)->GetStaticMethodID(env, g_pluginClass, "setKeyboardAnimation",  "(Z)V");
}


JNIEXPORT void JNICALL
Java_com_example_keyboard_1insets_KeyboardInsetsImplKt_platform_1update_1inset(JNIEnv* env, jclass clazz, jfloat inset, jfloat target) {
    platform_update_inset(inset, target);
}

// ---- FFI-exposed functions ----

#ifdef __cplusplus
extern "C" {
#endif

// Exposed to Dart FFI
__attribute__((visibility("default")))
__attribute__((used))
void start_listening_insets(void) {
    if (!g_jvm || !g_pluginClass || !g_midStart) return;
    JNIEnv* env = get_env();
    if (!env) return;
    (*env)->CallStaticVoidMethod(env, g_pluginClass, g_midStart);
}

__attribute__((visibility("default")))
__attribute__((used))
void stop_listening_insets(void) {
    if (!g_jvm || !g_pluginClass || !g_midStop) return;
    JNIEnv* env = get_env();
    if (!env) return;
    (*env)->CallStaticVoidMethod(env, g_pluginClass, g_midStop);
}

__attribute__((visibility("default")))
__attribute__((used))
void platform_set_keyboard_animation(bool isEnabled){
 if (!g_jvm || !g_pluginClass || !g_setAnim) return;
    JNIEnv* env = get_env();
    if (!env) return;

    jboolean jniBooleanValue = isEnabled ? JNI_TRUE : JNI_FALSE;
    (*env)->CallStaticVoidMethod(env, g_pluginClass, g_setAnim, jniBooleanValue);
}

#ifdef __cplusplus
}
#endif

