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

  // Default query for initial screen or when nothing is selected
  final query = selectedCat ?? "인기 찬양 CCM";

  // Real YouTube search
  final results = await youtubeService.searchWorship(
    query == "오늘의 추천 찬양" || query == "추천 찬양"
        ? "은혜로운 인기 찬양 베스트 CCM"
        : "$query 찬양 CCM",
  );

  if (results.isEmpty) {
    // If results are empty (API key missing or no results),
    // filter mock songs if a category is selected, or return all mock songs
    if (selectedCat != null) {
      final filtered = _allMockSongs
          .where((song) => song.tags.contains(selectedCat))
          .toList();
      return filtered.isNotEmpty ? filtered : _allMockSongs;
    }
    return _allMockSongs;
  }

  return results;
});

final filteredWorshipsProvider = Provider<List<Song>>((ref) {
  final searchResults = ref.watch(worshipSearchResultsProvider);

  return searchResults.when(
    data: (songs) => songs,
    loading: () => _allMockSongs, // Show mock while loading
    error: (err, stack) => _allMockSongs,
  );
});

final _allMockSongs = [
  Song(
    id: 1,
    title: "은혜 아래 (Under Grace)",
    artist: "웨이메이커",
    cover:
        "https://images.unsplash.com/photo-1519307212971-dd9561667ffb?w=400&q=80",
    videoId: "mC6f9ID2Y-c",
    tags: ["평안", "용기"],
  ),
  Song(
    id: 2,
    title: "길을 만드시는 주",
    artist: "레위지파",
    cover:
        "https://images.unsplash.com/photo-1499209974431-9dac3adaf471?w=400&q=80",
    videoId: "dQw4w9WgXcQ",
    tags: ["뜨거운 찬양", "용기"],
  ),
  Song(
    id: 3,
    title: "임재 (Presence)",
    artist: "마커스워십",
    cover:
        "https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=400&q=80",
    videoId: "dQw4w9WgXcQ",
    tags: ["평안", "묵상"],
  ),
  Song(
    id: 4,
    title: "내 모습 이대로",
    artist: "어노인팅",
    cover:
        "https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=400&q=80",
    videoId: "dQw4w9WgXcQ",
    tags: ["묵상", "평안"],
  ),
];
