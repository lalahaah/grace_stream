import 'package:hive_flutter/hive_flutter.dart';
import 'package:grace_stream/models/reading_goal.dart';

class ReadingGoalService {
  static const String _boxName = 'reading_goal_box';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ReadingGoalAdapter());
    }
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<ReadingGoal>(_boxName);
    }
  }

  ReadingGoal? getCurrentGoal() {
    final box = Hive.box<ReadingGoal>(_boxName);
    if (box.isEmpty) return null;
    // 가장 최근에 생성된 목표를 반환하거나 특정 로직 수행
    return box.values.last;
  }

  Future<void> saveGoal(ReadingGoal goal) async {
    final box = Hive.box<ReadingGoal>(_boxName);
    // 단순하게 하기 위해 기존 목표를 모두 지우고 새 목표를 넣거나 추가
    // 여기서는 1인 1목표 체제로 가정하여 처리
    await box.clear();
    await box.add(goal);
  }

  Future<void> markChapterAsRead(String bookId, int chapter) async {
    final box = Hive.box<ReadingGoal>(_boxName);
    if (box.isEmpty) return;

    final goal = box.values.last;
    if (goal.bookId == bookId && !goal.readChapters.contains(chapter)) {
      final newList = List<int>.from(goal.readChapters)..add(chapter);
      final updatedGoal = goal.copyWith(readChapters: newList);
      await box.putAt(box.length - 1, updatedGoal);
    }
  }

  Future<void> clearGoal() async {
    final box = Hive.box<ReadingGoal>(_boxName);
    await box.clear();
  }
}
