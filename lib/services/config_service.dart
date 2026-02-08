import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  Map<String, dynamic> _config = {};

  Future<void> init() async {
    try {
      final jsonString = await rootBundle.loadString('secrets.json');
      _config = jsonDecode(jsonString);
      debugPrint('ConfigService: Successfully loaded secrets.json');
    } catch (e) {
      debugPrint(
        'ConfigService: Could not load secrets.json, falling back to environment variables. Error: $e',
      );
    }
  }

  String get(String key, {String defaultValue = ''}) {
    // 1. secrets.json에서 먼저 찾음
    if (_config.containsKey(key)) {
      return _config[key]?.toString() ?? defaultValue;
    }
    // 2. 없으면 환경 변수(--dart-define)에서 찾음
    return String.fromEnvironment(key, defaultValue: defaultValue);
  }

  String get geminiApiKey => get('GEMINI_API_KEY');
  String get youtubeApiKey => get('YOUTUBE_API_KEY');
}

final configService = ConfigService();
