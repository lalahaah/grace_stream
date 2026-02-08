import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/services/ai_service.dart';
import 'package:intl/intl.dart';

class TodayVerseData {
  final String verse;
  final String ref;
  final String ai;
  final String ccm;
  final String date;
  final String emotion;

  TodayVerseData({
    required this.verse,
    required this.ref,
    required this.ai,
    required this.ccm,
    required this.date,
    required this.emotion,
  });

  factory TodayVerseData.empty() => TodayVerseData(
    verse: '',
    ref: '',
    ai: '',
    ccm: '',
    date: '',
    emotion: '',
  );

  bool get isEmpty => verse.isEmpty;
}

class TodayVerseState {
  final bool isLoading;
  final TodayVerseData data;
  final String? error;

  TodayVerseState({required this.isLoading, required this.data, this.error});

  factory TodayVerseState.initial() =>
      TodayVerseState(isLoading: false, data: TodayVerseData.empty());

  TodayVerseState copyWith({
    bool? isLoading,
    TodayVerseData? data,
    String? error,
  }) {
    return TodayVerseState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

final todayVerseProvider =
    StateNotifierProvider<TodayVerseNotifier, TodayVerseState>((ref) {
      final aiService = ref.watch(aiServiceProvider);
      return TodayVerseNotifier(aiService);
    });

class TodayVerseNotifier extends StateNotifier<TodayVerseState> {
  final AIService _aiService;

  // 간단한 캐싱 (메모리 내)
  final Map<String, TodayVerseData> _cache = {};

  TodayVerseNotifier(this._aiService) : super(TodayVerseState.initial());

  Future<void> fetchVerse(String emotion) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final cacheKey = '${today}_$emotion';

    // 캐시 확인
    if (_cache.containsKey(cacheKey)) {
      state = state.copyWith(data: _cache[cacheKey], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final aiResult = await _aiService.getEmotionVerse(emotion);

      final newData = TodayVerseData(
        verse: aiResult['verse'] ?? '',
        ref: aiResult['ref'] ?? '',
        ai: aiResult['ai'] ?? '',
        ccm: aiResult['ccm'] ?? '',
        date: today,
        emotion: emotion,
      );

      _cache[cacheKey] = newData;
      state = state.copyWith(data: newData, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '오류 발생: $e');
    }
  }
}
