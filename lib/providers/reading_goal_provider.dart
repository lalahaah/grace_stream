import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/models/reading_goal.dart';
import 'package:grace_stream/services/reading_goal_service.dart';

final readingGoalServiceProvider = Provider((ref) => ReadingGoalService());

final readingGoalProvider =
    StateNotifierProvider<ReadingGoalNotifier, ReadingGoal?>((ref) {
      final service = ref.watch(readingGoalServiceProvider);
      return ReadingGoalNotifier(service);
    });

class ReadingGoalNotifier extends StateNotifier<ReadingGoal?> {
  final ReadingGoalService _service;

  ReadingGoalNotifier(this._service) : super(null) {
    _loadGoal();
  }

  void _loadGoal() {
    state = _service.getCurrentGoal();
  }

  Future<void> setGoal({
    required String bookId,
    required String bookName,
    required int start,
    required int end,
  }) async {
    final newGoal = ReadingGoal(
      bookId: bookId,
      bookName: bookName,
      startChapter: start,
      endChapter: end,
      readChapters: [],
      createdAt: DateTime.now(),
    );
    await _service.saveGoal(newGoal);
    state = newGoal;
  }

  Future<void> markAsRead(String bookId, int chapter) async {
    await _service.markChapterAsRead(bookId, chapter);
    _loadGoal();
  }

  Future<void> clear() async {
    await _service.clearGoal();
    state = null;
  }
}
