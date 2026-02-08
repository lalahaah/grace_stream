import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/models/bible_settings.dart';
import 'package:hive_flutter/hive_flutter.dart';

final bibleSettingsProvider =
    StateNotifierProvider<BibleSettingsNotifier, BibleSettings>((ref) {
      return BibleSettingsNotifier();
    });

class BibleSettingsNotifier extends StateNotifier<BibleSettings> {
  BibleSettingsNotifier() : super(BibleSettings()) {
    _init();
  }

  static const String _boxName = 'bible_settings';

  Future<void> _init() async {
    final box = await Hive.openBox(_boxName);
    final fontSize = box.get('fontSize', defaultValue: 18.0) as double;
    final fontFamily =
        box.get('fontFamily', defaultValue: 'Nanum Myeongjo') as String;
    final lineHeight = box.get('lineHeight', defaultValue: 1.6) as double;
    final letterSpacing = box.get('letterSpacing', defaultValue: 0.0) as double;

    final backgroundColorValue =
        box.get('backgroundColorValue', defaultValue: 0xFFF7F8FA) as int;

    state = BibleSettings(
      fontSize: fontSize,
      fontFamily: fontFamily,
      lineHeight: lineHeight,
      letterSpacing: letterSpacing,
      backgroundColorValue: backgroundColorValue,
    );
  }

  Future<void> setBackgroundColor(int colorValue) async {
    state = state.copyWith(backgroundColorValue: colorValue);
    final box = await Hive.openBox(_boxName);
    await box.put('backgroundColorValue', colorValue);
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    final box = await Hive.openBox(_boxName);
    await box.put('fontSize', size);
  }

  Future<void> setFontFamily(String family) async {
    state = state.copyWith(fontFamily: family);
    final box = await Hive.openBox(_boxName);
    await box.put('fontFamily', family);
  }

  Future<void> setLineHeight(double height) async {
    state = state.copyWith(lineHeight: height);
    final box = await Hive.openBox(_boxName);
    await box.put('lineHeight', height);
  }

  Future<void> setLetterSpacing(double spacing) async {
    state = state.copyWith(letterSpacing: spacing);
    final box = await Hive.openBox(_boxName);
    await box.put('letterSpacing', spacing);
  }
}
