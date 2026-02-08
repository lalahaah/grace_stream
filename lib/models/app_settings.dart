enum AudioQuality { low, medium, high }

class AppSettings {
  final AudioQuality audioQuality;
  final int? sleepTimerMinutes;
  final DateTime? sleepTimerStartTime;

  AppSettings({
    this.audioQuality = AudioQuality.medium,
    this.sleepTimerMinutes,
    this.sleepTimerStartTime,
  });

  AppSettings copyWith({
    AudioQuality? audioQuality,
    int? sleepTimerMinutes,
    DateTime? sleepTimerStartTime,
    bool clearTimer = false,
  }) {
    return AppSettings(
      audioQuality: audioQuality ?? this.audioQuality,
      sleepTimerMinutes: clearTimer
          ? null
          : (sleepTimerMinutes ?? this.sleepTimerMinutes),
      sleepTimerStartTime: clearTimer
          ? null
          : (sleepTimerStartTime ?? this.sleepTimerStartTime),
    );
  }
}
