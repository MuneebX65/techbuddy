import 'dart:convert';

import 'package:flutter/services.dart';

class AppEnv {
  AppEnv._();

  static final Map<String, String> _values = <String, String>{};

  static Future<void> load() async {
    const files = ['assets/env/app.env', '.env'];

    for (final file in files) {
      try {
        final raw = await rootBundle.loadString(file);
        final parsed = _parse(raw);
        if (parsed.isNotEmpty) {
          _values
            ..clear()
            ..addAll(parsed);
          return;
        }
      } catch (_) {
        // Try the next source.
      }
    }

    _values.clear();
  }

  static String get(String key) => _values[key]?.trim() ?? '';

  static Map<String, String> _parse(String raw) {
    final result = <String, String>{};
    final lines = const LineSplitter().convert(raw);

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final separator = trimmed.indexOf('=');
      if (separator <= 0) {
        continue;
      }

      final key = trimmed.substring(0, separator).trim();
      final value = trimmed.substring(separator + 1).trim();
      if (key.isNotEmpty) {
        result[key] = value;
      }
    }

    return result;
  }
}
