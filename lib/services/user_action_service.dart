import 'package:grace_stream/models/user_action.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userActionServiceProvider = Provider((ref) => BibleUserActionService());

class BibleUserActionService {
  static const String _highlightBoxName = 'highlight_box';
  static const String _bookmarkBoxName = 'bookmark_box';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_highlightBoxName)) {
      await Hive.openBox<Highlight>(_highlightBoxName);
    }
    if (!Hive.isBoxOpen(_bookmarkBoxName)) {
      await Hive.openBox<Bookmark>(_bookmarkBoxName);
    }
  }

  Box<T> _getBox<T>(String name) {
    if (!Hive.isBoxOpen(name)) {
      // In synchronous methods, we can't await, so we return a placeholder or throw.
      // But since we wait in main, this is just a safety.
      return Hive.box<T>(name);
    }
    return Hive.box<T>(name);
  }

  // Highlights
  List<Highlight> getHighlights(String bookId, String chapter) {
    if (!Hive.isBoxOpen(_highlightBoxName)) return [];
    final box = _getBox<Highlight>(_highlightBoxName);
    return box.values
        .where((h) => h.bookId == bookId && h.chapter == chapter)
        .toList();
  }

  Future<void> toggleHighlight(Highlight highlight) async {
    final box = await Hive.openBox<Highlight>(_highlightBoxName);

    final existingIndex = box.values.toList().indexWhere(
      (h) =>
          h.bookId == highlight.bookId &&
          h.chapter == highlight.chapter &&
          h.verse == highlight.verse,
    );

    if (existingIndex != -1) {
      final existing = box.getAt(existingIndex);
      if (existing?.colorValue == highlight.colorValue) {
        await box.deleteAt(existingIndex);
      } else {
        await box.putAt(existingIndex, highlight);
      }
    } else {
      await box.add(highlight);
    }
  }

  // Bookmarks
  bool isBookmarked(String bookId, String chapter, String verse) {
    if (!Hive.isBoxOpen(_bookmarkBoxName)) return false;
    final box = _getBox<Bookmark>(_bookmarkBoxName);
    return box.values.any(
      (b) => b.bookId == bookId && b.chapter == chapter && b.verse == verse,
    );
  }

  Future<void> toggleBookmark(Bookmark bookmark) async {
    final box = await Hive.openBox<Bookmark>(_bookmarkBoxName);
    final existingIndex = box.values.toList().indexWhere(
      (b) =>
          b.bookId == bookmark.bookId &&
          b.chapter == bookmark.chapter &&
          b.verse == bookmark.verse,
    );

    if (existingIndex != -1) {
      await box.deleteAt(existingIndex);
    } else {
      await box.add(bookmark);
    }
  }

  List<Bookmark> getAllBookmarks() {
    if (!Hive.isBoxOpen(_bookmarkBoxName)) return [];
    final box = _getBox<Bookmark>(_bookmarkBoxName);
    return box.values.toList();
  }
}

// Providers for UI observation
final highlightsProvider =
    StateProvider.family<List<Highlight>, ({String bookId, String chapter})>((
      ref,
      pos,
    ) {
      final service = ref.watch(userActionServiceProvider);
      return service.getHighlights(pos.bookId, pos.chapter);
    });

final bookmarksProvider = StateProvider<List<Bookmark>>((ref) {
  final service = ref.watch(userActionServiceProvider);
  return service.getAllBookmarks();
});
