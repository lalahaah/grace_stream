import 'package:hive/hive.dart';

part 'bible.g.dart';

@HiveType(typeId: 0)
class BibleVerse {
  @HiveField(0)
  final String book;
  @HiveField(1)
  final String chapter;
  @HiveField(2)
  final String verse;
  @HiveField(3)
  final String text;

  BibleVerse({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  // For backward compatibility and specialized use
  factory BibleVerse.fromMap(
    String book,
    String chapter,
    String verse,
    String text,
  ) {
    return BibleVerse(book: book, chapter: chapter, verse: verse, text: text);
  }

  Map<String, dynamic> toJson() {
    return {'book': book, 'chapter': chapter, 'verse': verse, 'text': text};
  }
}

class BibleChapter {
  final String bookName;
  final String chapter;
  final List<BibleVerse> verses;

  BibleChapter({
    required this.bookName,
    required this.chapter,
    required this.verses,
  });
}
