import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/providers/bible_provider.dart';
import 'package:grace_stream/providers/bible_settings_provider.dart';
import 'package:grace_stream/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_stream/constants/bible_constants.dart';
import 'package:grace_stream/services/user_action_service.dart';
import 'package:grace_stream/services/ai_service.dart';
import 'package:grace_stream/models/user_action.dart';
import 'package:grace_stream/models/bible.dart';
import 'package:grace_stream/widgets/common_app_bar.dart';

class BibleViewerScreen extends ConsumerWidget {
  const BibleViewerScreen({super.key});

  void _showVerseMenu(
    BuildContext context,
    WidgetRef ref,
    BibleVerse verse,
    String bookName,
  ) {
    final actionService = ref.read(userActionServiceProvider);
    final isBookmarked = actionService.isBookmarked(
      verse.book,
      verse.chapter,
      verse.verse,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$bookName ${verse.chapter}:${verse.verse}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionIcon(Icons.auto_awesome, 'AI 설명', () {
                  Navigator.pop(context);
                  _showAIResponse(context, ref, verse, bookName);
                }),
                _actionIcon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  '북마크',
                  () {
                    actionService.toggleBookmark(
                      Bookmark(
                        bookId: verse.book,
                        chapter: verse.chapter,
                        verse: verse.verse,
                        createdAt: DateTime.now(),
                      ),
                    );
                    ref.invalidate(bookmarksProvider);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              '하이라이트',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _colorIcon(context, ref, verse, Colors.yellow[200]!),
                _colorIcon(context, ref, verse, Colors.green[200]!),
                _colorIcon(context, ref, verse, Colors.blue[200]!),
                _colorIcon(context, ref, verse, Colors.pink[200]!),
                _colorIcon(
                  context,
                  ref,
                  verse,
                  Colors.transparent,
                  icon: Icons.format_color_reset,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAIResponse(
    BuildContext context,
    WidgetRef ref,
    BibleVerse verse,
    String bookName,
  ) async {
    final aiService = ref.read(aiServiceProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    'AI 말씀 설명',
                    style: TextStyle(
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '$bookName ${verse.chapter}:${verse.verse}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '"${verse.text}"',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              const Divider(height: 32),
              FutureBuilder<String>(
                future: aiService.explainVerse(
                  bookName,
                  verse.chapter,
                  verse.verse,
                  verse.text,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return Text(
                    snapshot.data ?? '설명을 가져오지 못했습니다.',
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAIWordExplain(
    BuildContext context,
    WidgetRef ref,
    String word,
    String contextVerse,
  ) async {
    final aiService = ref.read(aiServiceProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.help_outline, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'AI 단어 해설',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '선택한 단어:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                word,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Divider(height: 32),
              FutureBuilder<String>(
                future: aiService.explainWord(word, contextVerse),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return Text(
                    snapshot.data ?? '해설을 가져오지 못했습니다.',
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            final selectedChapterId = ref
                .watch(currentPositionProvider)
                .chapter;

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
                                      setModalState(() {}); // Refresh grid
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
                                          ch == selectedChapterId;
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
    final bookName = BibleConstants.getBookName(currentPos.bookId);
    final settings = ref.watch(bibleSettingsProvider);

    return Scaffold(
      backgroundColor: Color(settings.backgroundColorValue),
      appBar: CommonAppBar.standard(
        context,
        centerWidget: InkWell(
          onTap: () => _showSelectionDialog(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$bookName ${currentPos.chapter}장',
                  style: const TextStyle(
                    fontSize: 14, // 홈 화면 스타일과 맞추기 위해 약간 축소
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ref
              .watch(bibleChapterProvider(currentPos))
              .when(
                data: (chapter) {
                  if (chapter == null) {
                    return const Center(
                      child: Text(
                        '해당 장을 찾을 수 없습니다.',
                        style: TextStyle(color: AppColors.textMain),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: chapter.verses.length + 1,
                    itemBuilder: (context, index) {
                      if (index == chapter.verses.length) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 24.0,
                            bottom: 100.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  ref
                                      .read(bibleServiceProvider)
                                      .getPreviousChapter(
                                        currentPos.bookId,
                                        currentPos.chapter,
                                      )
                                      .then((prev) {
                                        if (prev != null) {
                                          ref
                                                  .read(
                                                    currentPositionProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              prev;
                                        }
                                      });
                                },
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('이전 장'),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  ref
                                      .read(bibleServiceProvider)
                                      .getNextChapter(
                                        currentPos.bookId,
                                        currentPos.chapter,
                                      )
                                      .then((next) {
                                        if (next != null) {
                                          ref
                                                  .read(
                                                    currentPositionProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              next;
                                        }
                                      });
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('다음 장'),
                              ),
                            ],
                          ),
                        );
                      }

                      final verse = chapter.verses[index];
                      final highlights = ref.watch(
                        highlightsProvider((
                          bookId: currentPos.bookId,
                          chapter: currentPos.chapter,
                        )),
                      );
                      final bookmarks = ref.watch(bookmarksProvider);

                      final highlight = highlights
                          .where((h) => h.verse == verse.verse)
                          .firstOrNull;
                      final isBookmarked = bookmarks.any(
                        (b) =>
                            b.bookId == verse.book &&
                            b.chapter == verse.chapter &&
                            b.verse == verse.verse,
                      );

                      return InkWell(
                        onTap: () =>
                            _showVerseMenu(context, ref, verse, bookName),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: highlight != null
                                ? Color(highlight.colorValue)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 32,
                                child: Column(
                                  children: [
                                    Text(
                                      verse.verse.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (isBookmarked)
                                      const Icon(
                                        Icons.bookmark,
                                        size: 12,
                                        color: Colors.indigo,
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SelectableText(
                                  verse.text,
                                  style: _getBibleStyle(settings),
                                  contextMenuBuilder: (context, editableTextState) {
                                    return AdaptiveTextSelectionToolbar.buttonItems(
                                      anchors:
                                          editableTextState.contextMenuAnchors,
                                      buttonItems: [
                                        ...editableTextState
                                            .contextMenuButtonItems,
                                        ContextMenuButtonItem(
                                          label: 'AI에게 물어보기',
                                          onPressed: () {
                                            final selectedText =
                                                editableTextState
                                                    .textEditingValue
                                                    .selection
                                                    .textInside(
                                                      editableTextState
                                                          .textEditingValue
                                                          .text,
                                                    );
                                            editableTextState.hideToolbar();
                                            _showAIWordExplain(
                                              context,
                                              ref,
                                              selectedText,
                                              verse.text,
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text(
                    '에러가 발생했습니다: $err',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
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
            child: Icon(icon, color: Colors.indigo, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _colorIcon(
    BuildContext context,
    WidgetRef ref,
    BibleVerse verse,
    Color color, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: () {
        ref
            .read(userActionServiceProvider)
            .toggleHighlight(
              Highlight(
                bookId: verse.book,
                chapter: verse.chapter,
                verse: verse.verse,
                colorValue: color.toARGB32(),
              ),
            );
        ref.invalidate(
          highlightsProvider((bookId: verse.book, chapter: verse.chapter)),
        );
        Navigator.pop(context);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color == Colors.transparent ? Colors.grey[100] : color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: icon != null ? Icon(icon, size: 18, color: Colors.grey) : null,
      ),
    );
  }

  TextStyle _getBibleStyle(settings) {
    final backgroundColor = Color(settings.backgroundColorValue);
    final isDark = backgroundColor.computeLuminance() < 0.35;
    final textColor = isDark ? Colors.white : AppColors.textMain;

    switch (settings.fontFamily) {
      case 'Nanum Myeongjo':
        return GoogleFonts.nanumMyeongjo(
          fontSize: settings.fontSize,
          height: settings.lineHeight,
          letterSpacing: settings.letterSpacing,
          color: textColor,
        );
      case 'Nanum Gothic':
        return GoogleFonts.nanumGothic(
          fontSize: settings.fontSize,
          height: settings.lineHeight,
          letterSpacing: settings.letterSpacing,
          color: textColor,
        );
      case 'Noto Sans KR':
        return GoogleFonts.notoSansKr(
          fontSize: settings.fontSize,
          height: settings.lineHeight,
          letterSpacing: settings.letterSpacing,
          color: textColor,
        );
      case 'Gowun Batang':
        return GoogleFonts.gowunBatang(
          fontSize: settings.fontSize,
          height: settings.lineHeight,
          letterSpacing: settings.letterSpacing,
          color: textColor,
        );
      case 'Gowun Dodum':
        return GoogleFonts.gowunDodum(
          fontSize: settings.fontSize,
          height: settings.lineHeight,
          letterSpacing: settings.letterSpacing,
          color: textColor,
        );
      default:
        return TextStyle(
          fontSize: settings.fontSize,
          height: settings.lineHeight,
          letterSpacing: settings.letterSpacing,
          color: textColor,
        );
    }
  }
}
