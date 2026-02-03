import 'package:hive/hive.dart';

part 'user_action.g.dart';

@HiveType(typeId: 1)
class Highlight {
  @HiveField(0)
  final String bookId;
  @HiveField(1)
  final String chapter;
  @HiveField(2)
  final String verse;
  @HiveField(3)
  final int colorValue; // ARGB hex value

  Highlight({
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.colorValue,
  });
}

@HiveType(typeId: 2)
class Bookmark {
  @HiveField(0)
  final String bookId;
  @HiveField(1)
  final String chapter;
  @HiveField(2)
  final String verse;
  @HiveField(3)
  final DateTime createdAt;

  Bookmark({
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.createdAt,
  });
}
