import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:grace_stream/models/bible.dart';
import 'package:grace_stream/constants/bible_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BibleService {
  static const String _boxName = 'bible_box';
  static const String _isImportedKey = 'is_imported';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BibleVerseAdapter());
    }
    await Hive.openBox<BibleVerse>(_boxName);
    await _importBibleDataIfNeeded();
  }

  Future<void> _importBibleDataIfNeeded() async {
    final box = Hive.box<BibleVerse>(_boxName);
    final settingsBox = await Hive.openBox('settings');
    final bool isImported = settingsBox.get(
      _isImportedKey,
      defaultValue: false,
    );

    if (!isImported || box.isEmpty) {
      debugPrint('Starting Bible data import from korean_bible.json...');
      try {
        final String response = await rootBundle.loadString(
          'assets/bible/korean_bible.json',
        );
        final dynamic decoded = json.decode(response);

        Map<String, dynamic> data;
        if (decoded is List) {
          // Fallback if structure is wrong
          debugPrint('Warning: Bible data is a List, not a Map.');
          return;
        } else {
          data = decoded as Map<String, dynamic>;
        }

        final List<BibleVerse> allVerses = [];
        data.forEach((bookId, chapters) {
          final chaptersMap = chapters as Map<String, dynamic>;
          chaptersMap.forEach((chapterNum, verses) {
            final versesMap = verses as Map<String, dynamic>;
            versesMap.forEach((verseNum, text) {
              allVerses.add(
                BibleVerse(
                  book: bookId.toString(),
                  chapter: chapterNum.toString(),
                  verse: verseNum.toString(),
                  text: text.toString(),
                ),
              );
            });
          });
        });

        await box.clear();
        await box.addAll(allVerses);
        await settingsBox.put(_isImportedKey, true);
        debugPrint('Bible data import completed. Total verses: ${box.length}');
      } catch (e) {
        debugPrint('Error importing Bible: $e');
      }
    } else {
      debugPrint('Bible data already imported. Count: ${box.length}');
    }
  }

  Future<List<String>> getBooks() async {
    final box = Hive.box<BibleVerse>(_boxName);
    final books = box.values.map((v) => v.book).toSet().toList();
    // Maintain original order if possible, though toSet might break it.
    // Ideally, we'd use a sorted list from BibleConstants.
    return BibleConstants.bookNames.keys
        .where((key) => books.contains(key))
        .toList();
  }

  Future<List<String>> getChapters(String bookId) async {
    final box = Hive.box<BibleVerse>(_boxName);
    final chapters = box.values
        .where((v) => v.book == bookId)
        .map((v) => v.chapter)
        .toSet()
        .toList();

    // Sort chapters numerically
    chapters.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    return chapters;
  }

  Future<BibleChapter?> getChapter(String bookId, String chapterNum) async {
    final box = Hive.box<BibleVerse>(_boxName);
    if (box.isEmpty) {
      await _importBibleDataIfNeeded();
    }

    debugPrint('Searching for: Book=$bookId, Chapter=$chapterNum');

    // Normalize search query
    final searchBook = bookId.trim().toUpperCase();
    final searchChapter = chapterNum.trim();

    final verses = box.values
        .where(
          (v) =>
              v.book.trim().toUpperCase() == searchBook &&
              v.chapter.trim() == searchChapter,
        )
        .toList();

    debugPrint('Found ${verses.length} verses');

    if (verses.isEmpty) {
      // Basic check: what IDs are in the box?
      if (box.isNotEmpty) {
        final first = box.values.first;
        debugPrint('Box Sample: Book=${first.book}, Chapter=${first.chapter}');
      }
      return null;
    }

    return BibleChapter(
      bookName: BibleConstants.getBookName(bookId),
      chapter: chapterNum,
      verses: verses,
    );
  }

  Future<({String bookId, String chapter})?> getNextChapter(
    String currentBookId,
    String currentChapter,
  ) async {
    final chapters = await getChapters(currentBookId);
    final currentIndex = chapters.indexOf(currentChapter);

    if (currentIndex != -1 && currentIndex < chapters.length - 1) {
      return (bookId: currentBookId, chapter: chapters[currentIndex + 1]);
    } else {
      // Move to next book's first chapter
      final books = await getBooks();
      final currentBookIndex = books.indexOf(currentBookId);
      if (currentBookIndex != -1 && currentBookIndex < books.length - 1) {
        final nextBookId = books[currentBookIndex + 1];
        final nextBookChapters = await getChapters(nextBookId);
        if (nextBookChapters.isNotEmpty) {
          return (bookId: nextBookId, chapter: nextBookChapters.first);
        }
      }
    }
    return null;
  }

  Future<({String bookId, String chapter})?> getPreviousChapter(
    String currentBookId,
    String currentChapter,
  ) async {
    final chapters = await getChapters(currentBookId);
    final currentIndex = chapters.indexOf(currentChapter);

    if (currentIndex > 0) {
      return (bookId: currentBookId, chapter: chapters[currentIndex - 1]);
    } else {
      // Move to previous book's last chapter
      final books = await getBooks();
      final currentBookIndex = books.indexOf(currentBookId);
      if (currentBookIndex > 0) {
        final prevBookId = books[currentBookIndex - 1];
        final prevBookChapters = await getChapters(prevBookId);
        if (prevBookChapters.isNotEmpty) {
          return (bookId: prevBookId, chapter: prevBookChapters.last);
        }
      }
    }
    return null;
  }
}
