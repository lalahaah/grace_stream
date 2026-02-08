import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/models/app_settings.dart';
import 'package:grace_stream/providers/player_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
      return AppSettingsNotifier(ref);
    });

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final Ref _ref;
  Timer? _sleepTimer;

  AppSettingsNotifier(this._ref) : super(AppSettings()) {
    _init();
  }

  static const String _boxName = 'app_settings';

  Future<void> _init() async {
    final box = await Hive.openBox(_boxName);
    final qualityIndex =
        box.get('audioQuality', defaultValue: AudioQuality.medium.index) as int;

    state = AppSettings(audioQuality: AudioQuality.values[qualityIndex]);
  }

  Future<void> setAudioQuality(AudioQuality quality) async {
    state = state.copyWith(audioQuality: quality);
    final box = await Hive.openBox(_boxName);
    await box.put('audioQuality', quality.index);
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();

    final startTime = DateTime.now();
    state = state.copyWith(
      sleepTimerMinutes: minutes,
      sleepTimerStartTime: startTime,
    );

    _sleepTimer = Timer(Duration(minutes: minutes), () {
      _ref.read(playerProvider.notifier).stop();
      clearSleepTimer();
    });
  }

  void clearSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    state = state.copyWith(clearTimer: true);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }
}
