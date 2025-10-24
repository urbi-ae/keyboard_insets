import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

typedef SafeAreaCallback = void Function(double bottomInset);

class SafeAreaMonitorWeb {
  static bool initialized = false;
  static bool listening = false;

  static Future<void> startSafeAreaObserver(SafeAreaCallback callback) async {
    if (!initialized) {
      await _injectJs(); // ✅ Wait until JS is fully available
      initialized = true;
    }

    final safeAreaMonitor = js.context['SafeAreaMonitor'];
    if (safeAreaMonitor == null) {
      throw Exception('SafeAreaMonitor JS object not found');
    }

    js.context.callMethod('SafeAreaMonitor.startSafeAreaObserver', [
      js.allowInterop((num bottomInset) {
        callback(bottomInset.toDouble());
      }),
    ]);

    listening = true;
  }

  static void stopSafeAreaObserver() {
    if (!initialized || !listening) return;

    js.context.callMethod('SafeAreaMonitor.stopSafeAreaObserver');
    listening = false;
  }

  static Future<void> _injectJs() async {
    if (js.context['SafeAreaMonitor'] != null) return;

    const scriptContent = '''
      window.SafeAreaMonitor = {
        _callback: null,
        _resizeListener: null,
        _scrollListener: null,

        startSafeAreaObserver: function(callback) {
          this._callback = callback;
          this._notifySafeAreaChange();

          this._resizeListener = () => this._notifySafeAreaChange();
          this._scrollListener = () => this._notifySafeAreaChange();

          if (window.visualViewport) {
            window.visualViewport.addEventListener('resize', this._resizeListener);
            window.visualViewport.addEventListener('scroll', this._scrollListener);
          } else {
            window.addEventListener('resize', this._resizeListener);
          }
        },

        stopSafeAreaObserver: function() {
          if (window.visualViewport) {
            if (this._resizeListener)
              window.visualViewport.removeEventListener('resize', this._resizeListener);
            if (this._scrollListener)
              window.visualViewport.removeEventListener('scroll', this._scrollListener);
          } else {
            if (this._resizeListener)
              window.removeEventListener('resize', this._resizeListener);
          }

          this._callback = null;
          this._resizeListener = null;
          this._scrollListener = null;
        },

        _notifySafeAreaChange: function() {
          if (!this._callback) return;

          let bottomInset = 0;

          // Try to estimate bottom inset using visual viewport
          if (window.visualViewport) {
            bottomInset = window.innerHeight - window.visualViewport.height - window.visualViewport.offsetTop;
          }

          // Use env(safe-area-inset-bottom) as fallback for iOS devices
          const div = document.createElement('div');
          div.style.position = 'absolute';
          div.style.height = '0';
          div.style.paddingBottom = 'env(safe-area-inset-bottom)';
          document.body.appendChild(div);
          const style = getComputedStyle(div);
          const envInset = parseInt(style.paddingBottom) || 0;
          document.body.removeChild(div);

          bottomInset = Math.max(bottomInset, envInset);
          this._callback(bottomInset);
        }
      };
    ''';

    final script = html.ScriptElement()
      ..type = 'text/javascript'
      ..text = scriptContent;

    final completer = Completer<void>();
    script.onLoad.listen((_) => completer.complete());
    script.onError.listen((_) =>
        completer.completeError('Failed to load SafeAreaMonitor script'));
    html.document.head!.append(script);

    await completer.future;
  }
}
