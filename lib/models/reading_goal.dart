import 'package:hive/hive.dart';

part 'reading_goal.g.dart';

@HiveType(typeId: 4)
class ReadingGoal {
  @HiveField(0)
  final String bookId;
  @HiveField(1)
  final String bookName;
  @HiveField(2)
  final int startChapter;
  @HiveField(3)
  final int endChapter;
  @HiveField(4)
  final List<int> readChapters; // 읽은 장 번호 목록
  @HiveField(5)
  final DateTime createdAt;

  ReadingGoal({
    required this.bookId,
    required this.bookName,
    required this.startChapter,
    required this.endChapter,
    required this.readChapters,
    required this.createdAt,
  });

  double get progress {
    final total = endChapter - startChapter + 1;
    if (total <= 0) return 0.0;

    // 범위 내에 있는 읽은 장들만 필터링
    final readInRange = readChapters
        .where((c) => c >= startChapter && c <= endChapter)
        .length;
    return readInRange / total;
  }

  String get rangeText => '$bookName $startChapter-$endChapter장';

  ReadingGoal copyWith({
    String? bookId,
    String? bookName,
    int? startChapter,
    int? endChapter,
    List<int>? readChapters,
    DateTime? createdAt,
  }) {
    return ReadingGoal(
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      startChapter: startChapter ?? this.startChapter,
      endChapter: endChapter ?? this.endChapter,
      readChapters: readChapters ?? this.readChapters,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
