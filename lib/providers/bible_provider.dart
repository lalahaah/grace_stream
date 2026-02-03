import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/models/bible.dart';
import 'package:grace_stream/services/bible_service.dart';

final bibleServiceProvider = Provider((ref) => BibleService());

final bibleInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(bibleServiceProvider);
  await service.init();
});

final bibleChapterProvider =
    FutureProvider.family<BibleChapter?, ({String bookId, String chapter})>((
      ref,
      arg,
    ) async {
      // Ensure initialization is complete
      await ref.watch(bibleInitProvider.future);
      final service = ref.watch(bibleServiceProvider);
      return service.getChapter(arg.bookId, arg.chapter);
    });

// For simplicity in MVP, tracking current reading position
final currentPositionProvider =
    StateProvider<({String bookId, String chapter})>(
      (ref) => (bookId: "GEN", chapter: "1"),
    );
