import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/providers/bible_provider.dart';
import 'package:grace_stream/providers/player_provider.dart';
import 'package:grace_stream/services/ai_service.dart';
import 'package:grace_stream/services/youtube_service.dart';

final worshipAIRecommendationProvider = FutureProvider<String>((ref) async {
  final currentPos = ref.watch(currentPositionProvider);
  final bibleChapter = await ref.watch(bibleChapterProvider(currentPos).future);
  final aiService = ref.watch(aiServiceProvider);

  if (bibleChapter == null) return "오늘의 성경 읽기를 시작해보세요!";

  final content = bibleChapter.verses.map((v) => v.text).join(" ");

  return aiService.getWorshipRecommendation(
    bibleChapter.bookName,
    bibleChapter.chapter,
    content,
  );
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final worshipSearchResultsProvider = FutureProvider<List<Song>>((ref) async {
  final selectedCat = ref.watch(selectedCategoryProvider);
  final youtubeService = ref.watch(youtubeServiceProvider);

  // Default query for initial screen
  final query = selectedCat ?? "인기 CCM";

  // Real YouTube search
  final results = await youtubeService.searchWorship(
    query == "오늘의 추천 찬양" || query == "추천 찬양" ? "인기 찬양 베스트" : "$query 찬양",
  );

  if (results.isEmpty) {
    debugPrint('DEBUG: Search results empty. Returning backup songs.');
    if (selectedCat != null) {
      final filtered = _backupSongs
          .where((song) => song.tags.contains(selectedCat))
          .toList();
      return filtered.isNotEmpty ? filtered : _backupSongs;
    }
    return _backupSongs;
  }

  return results;
});

final filteredWorshipsProvider = Provider<List<Song>>((ref) {
  final searchResults = ref.watch(worshipSearchResultsProvider);

  return searchResults.when(
    data: (songs) => songs,
    loading: () => _backupSongs, // Show backup while loading
    error: (err, stack) => _backupSongs,
  );
});

// 실제 은혜로운 곡들로 구성된 백업 리스트 (검색 실패 시 대비)
// 실제 은혜로운 곡들로 구성된 백업 리스트 (공식 채널의 검증된 영상들)
final _backupSongs = [
  Song(
    id: 2001,
    title: "주가 주되심을 (Official)",
    artist: "마커스워십",
    cover: "https://i.ytimg.com/vi/1TSgDWi323g/hqdefault.jpg",
    videoId: "1TSgDWi323g",
    tags: ["평안", "감사", "묵상"],
  ),
  Song(
    id: 2002,
    title: "입례 (入禮)",
    artist: "WELOVE",
    cover: "https://i.ytimg.com/vi/6Xdy8I6aGpg/hqdefault.jpg",
    videoId: "6Xdy8I6aGpg",
    tags: ["감사", "위로", "용기"],
  ),
  Song(
    id: 2003,
    title: "나 주님이 더욱 필요해",
    artist: "어노인팅",
    cover: "https://i.ytimg.com/vi/ED4rBtUc0RQ/hqdefault.jpg",
    videoId: "ED4rBtUc0RQ",
    tags: ["용기", "기쁨", "소망"],
  ),
  Song(
    id: 2004,
    title: "하나님 지으신 이 세상",
    artist: "Tranquil Vibes",
    cover: "https://i.ytimg.com/vi/EMKOtN-tkr4/hqdefault.jpg",
    videoId: "EMKOtN-tkr4",
    tags: ["묵상", "평안", "인도"],
  ),
];
