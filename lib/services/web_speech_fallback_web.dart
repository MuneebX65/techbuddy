import 'dart:js_util' as js_util;

class WebSpeechFallback {
  dynamic _recognition;
  dynamic get _global => js_util.globalThis;

  bool get isSupported {
    return js_util.hasProperty(_global, 'SpeechRecognition') ||
        js_util.hasProperty(_global, 'webkitSpeechRecognition');
  }

  Future<bool> initialize({
    required void Function(String status) onStatus,
    required void Function(String words, bool isFinal) onResult,
    required void Function(String error) onError,
  }) async {
    if (!isSupported) {
      return false;
    }

    try {
      final dynamic speechRecognition;
      if (js_util.hasProperty(_global, 'SpeechRecognition')) {
        speechRecognition = js_util.getProperty(_global, 'SpeechRecognition');
      } else if (js_util.hasProperty(_global, 'webkitSpeechRecognition')) {
        speechRecognition = js_util.getProperty(
          _global,
          'webkitSpeechRecognition',
        );
      } else {
        return false;
      }

      _recognition = js_util.callConstructor(speechRecognition, []);
      js_util.setProperty(_recognition, 'continuous', false);
      js_util.setProperty(_recognition, 'interimResults', true);
      js_util.setProperty(_recognition, 'lang', 'en-US');

      js_util.setProperty(
        _recognition,
        'onstart',
        js_util.allowInterop((_) {
          onStatus('listening');
        }),
      );

      js_util.setProperty(
        _recognition,
        'onend',
        js_util.allowInterop((_) {
          onStatus('done');
        }),
      );

      js_util.setProperty(
        _recognition,
        'onerror',
        js_util.allowInterop((event) {
          final error = (js_util.getProperty(event, 'error') ?? 'unknown')
              .toString();
          onError(error);
        }),
      );

      js_util.setProperty(
        _recognition,
        'onresult',
        js_util.allowInterop((event) {
          final results = js_util.getProperty(event, 'results');
          final resultIndex =
              js_util.getProperty(event, 'resultIndex') as int? ?? 0;
          final result = js_util.getProperty(results, resultIndex);
          final isFinal = js_util.getProperty(result, 'isFinal') == true;
          final alternatives = js_util.getProperty(result, 0);
          final transcript =
              (js_util.getProperty(alternatives, 'transcript') ?? '')
                  .toString()
                  .trim();

          if (transcript.isNotEmpty) {
            onResult(transcript, isFinal);
          }
        }),
      );

      return true;
    } catch (_) {
      _recognition = null;
      return false;
    }
  }

  Future<void> start() async {
    if (_recognition == null) {
      return;
    }

    try {
      js_util.callMethod<void>(_recognition, 'start', []);
    } catch (_) {
      // Ignore duplicate start calls from browser internals.
    }
  }

  Future<void> stop() async {
    if (_recognition == null) {
      return;
    }

    try {
      js_util.callMethod<void>(_recognition, 'stop', []);
    } catch (_) {
      // Ignore stop errors when already stopped.
    }
  }
}
