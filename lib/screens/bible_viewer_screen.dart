import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/providers/bible_provider.dart';
import 'package:grace_stream/theme/app_theme.dart';
import 'package:grace_stream/constants/bible_constants.dart';

class BibleViewerScreen extends ConsumerWidget {
  const BibleViewerScreen({super.key});

  void _showSelectionDialog(BuildContext context, WidgetRef ref) async {
    final service = ref.read(bibleServiceProvider);
    final books = await service.getBooks();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            final selectedBookId = ref.watch(currentPositionProvider).bookId;
            final selectedChapter = ref.watch(currentPositionProvider).chapter;

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollController) => GestureDetector(
                onTap:
                    () {}, // Prevent clicking inside the sheet from closing it
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        '성경 선택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            // Book List (Left)
                            Expanded(
                              flex: 5,
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: books.length,
                                itemBuilder: (context, index) {
                                  final bookId = books[index];
                                  final isSelected = bookId == selectedBookId;
                                  return ListTile(
                                    dense: true,
                                    selected: isSelected,
                                    selectedTileColor: Colors.indigo.withValues(
                                      alpha: 0.05,
                                    ),
                                    title: Text(
                                      BibleConstants.getBookName(bookId),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.indigo
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                    onTap: () {
                                      ref
                                          .read(
                                            currentPositionProvider.notifier,
                                          )
                                          .state = (
                                        bookId: bookId,
                                        chapter: "1",
                                      );
                                      setModalState(
                                        () {},
                                      ); // Refresh chapter grid
                                    },
                                  );
                                },
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            // Chapter Grid (Right)
                            Expanded(
                              flex: 7,
                              child: FutureBuilder<List<String>>(
                                future: service.getChapters(selectedBookId),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return GridView.builder(
                                    padding: const EdgeInsets.all(12),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                        ),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      final ch = snapshot.data![index];
                                      final isChSelected =
                                          ch == selectedChapter;
                                      return InkWell(
                                        onTap: () {
                                          ref
                                              .read(
                                                currentPositionProvider
                                                    .notifier,
                                              )
                                              .state = (
                                            bookId: selectedBookId,
                                            chapter: ch,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isChSelected
                                                ? Colors.indigo
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            ch,
                                            style: TextStyle(
                                              color: isChSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: isChSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPos = ref.watch(currentPositionProvider);
    final bibleChapter = ref.watch(bibleChapterProvider(currentPos));
    final bookName = BibleConstants.getBookName(currentPos.bookId);
    final service = ref.read(bibleServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _showSelectionDialog(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$bookName ${currentPos.chapter}장',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: bibleChapter.when(
        data: (chapter) {
          if (chapter == null) {
            return const Center(child: Text('성경 데이터를 불러올 수 없습니다.'));
          }
          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  120,
                ), // Bottom padding for nav buttons & bottom nav
                itemCount: chapter.verses.length + 1,
                itemBuilder: (context, index) {
                  if (index == chapter.verses.length) {
                    // Navigation Buttons at the end
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _navButton(
                            context,
                            icon: Icons.navigate_before,
                            label: '이전 장',
                            onTap: () async {
                              final prev = await service.getPreviousChapter(
                                currentPos.bookId,
                                currentPos.chapter,
                              );
                              if (prev != null) {
                                ref
                                        .read(currentPositionProvider.notifier)
                                        .state =
                                    prev;
                              }
                            },
                          ),
                          _navButton(
                            context,
                            icon: Icons.navigate_next,
                            label: '다음 장',
                            onTap: () async {
                              final next = await service.getNextChapter(
                                currentPos.bookId,
                                currentPos.chapter,
                              );
                              if (next != null) {
                                ref
                                        .read(currentPositionProvider.notifier)
                                        .state =
                                    next;
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  final verse = chapter.verses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            verse.verse.toString(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            verse.text,
                            style: AppTheme.bibleTextStyle,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류 발생: $err')),
      ),
    );
  }

  Widget _navButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.indigo),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.indigo),
          ),
        ],
      ),
    );
  }
}
