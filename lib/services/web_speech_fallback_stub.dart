class WebSpeechFallback {
  bool get isSupported => false;

  Future<bool> initialize({
    required void Function(String status) onStatus,
    required void Function(String words, bool isFinal) onResult,
    required void Function(String error) onError,
  }) async {
    return false;
  }

  Future<void> start() async {}

  Future<void> stop() async {}
}
