import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/providers/reading_goal_provider.dart';
import 'package:grace_stream/constants/bible_constants.dart';
import 'package:grace_stream/theme/app_theme.dart';

class ReadingGoalDialog extends ConsumerStatefulWidget {
  const ReadingGoalDialog({super.key});

  @override
  ConsumerState<ReadingGoalDialog> createState() => _ReadingGoalDialogState();
}

class _ReadingGoalDialogState extends ConsumerState<ReadingGoalDialog> {
  String _selectedBookId = 'GEN';
  final TextEditingController _startController = TextEditingController(
    text: '1',
  );
  final TextEditingController _endController = TextEditingController(
    text: '10',
  );

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 통독 목표 설정',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '성경 선택',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBookId,
                  isExpanded: true,
                  items: BibleConstants.bookNames.keys.map((id) {
                    return DropdownMenuItem(
                      value: id,
                      child: Text(BibleConstants.getBookName(id)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedBookId = val!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '시작 장',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _startController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '종료 장',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _endController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final start = int.tryParse(_startController.text) ?? 1;
                  final end = int.tryParse(_endController.text) ?? 1;

                  await ref
                      .read(readingGoalProvider.notifier)
                      .setGoal(
                        bookId: _selectedBookId,
                        bookName: BibleConstants.getBookName(_selectedBookId),
                        start: start,
                        end: end,
                      );

                  if (!mounted) return;
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  navigator.pop();

                  messenger.showSnackBar(
                    const SnackBar(content: Text('통독 목표가 설정되었습니다.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '목표 저장하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
