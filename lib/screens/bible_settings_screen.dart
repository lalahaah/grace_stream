import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_stream/models/bible_settings.dart';
import 'package:grace_stream/providers/bible_settings_provider.dart';
import 'package:grace_stream/theme/app_theme.dart';

class BibleSettingsScreen extends ConsumerWidget {
  const BibleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(bibleSettingsProvider);
    final notifier = ref.read(bibleSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '성경 폰트 및 스타일',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Section
            _buildSectionTitle('미리보기'),
            _buildPreview(settings),

            // Font Family Section
            _buildSectionTitle('배경색'),
            _buildBackgroundColorSelector(settings, notifier),

            const SizedBox(height: 16),

            // Font Family Section
            _buildSectionTitle('글꼴'),
            _buildFontFamilySelector(settings, notifier),

            const SizedBox(height: 24),

            // Font Size Section
            _buildSectionTitle('글자 크기'),
            _buildSlider(
              value: settings.fontSize,
              min: 12.0,
              max: 32.0,
              divisions: 20,
              label: settings.fontSize.toInt().toString(),
              onChanged: (val) => notifier.setFontSize(val),
            ),

            const SizedBox(height: 24),

            // Line Height Section
            _buildSectionTitle('줄 간격'),
            _buildSlider(
              value: settings.lineHeight,
              min: 1.0,
              max: 2.5,
              divisions: 15,
              label: settings.lineHeight.toStringAsFixed(1),
              onChanged: (val) => notifier.setLineHeight(val),
            ),

            const SizedBox(height: 24),

            // Letter Spacing Section
            _buildSectionTitle('글자 간격'),
            _buildSlider(
              value: settings.letterSpacing,
              min: -1.0,
              max: 2.0,
              divisions: 15,
              label: settings.letterSpacing.toStringAsFixed(1),
              onChanged: (val) => notifier.setLetterSpacing(val),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                '확인',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPreview(BibleSettings settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(settings.backgroundColorValue),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '창세기 1:1',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Noto Sans KR',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '태초에 하나님이 천지를 창조하시니라. 땅이 혼돈하고 공허하며 흑암이 깊음 위에 있고 하나님의 영은 수면 위에 운행하시니라.',
            style: _getBibleStyle(settings),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundColorSelector(
    BibleSettings settings,
    BibleSettingsNotifier notifier,
  ) {
    final colors = [
      {'name': '화이트', 'color': 0xFFFFFFFF},
      {'name': '라이트', 'color': 0xFFF7F8FA},
      {'name': '크림', 'color': 0xFFFEFCE8},
      {'name': '세피아', 'color': 0xFFF4ECD8},
      {'name': '다크', 'color': 0xFF1E293B},
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final colorItem = colors[index];
          final colorValue = colorItem['color'] as int;
          final isSelected = settings.backgroundColorValue == colorValue;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => notifier.setBackgroundColor(colorValue),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(colorValue),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected ? AppTheme.indigoShadow : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: colorValue == 0xFF1E293B
                            ? Colors.white
                            : AppColors.primary,
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFontFamilySelector(
    BibleSettings settings,
    BibleSettingsNotifier notifier,
  ) {
    final fonts = [
      {'name': '나눔명조', 'family': 'Nanum Myeongjo'},
      {'name': '나눔고딕', 'family': 'Nanum Gothic'},
      {'name': '노토산스', 'family': 'Noto Sans KR'},
      {'name': '고운바탕', 'family': 'Gowun Batang'},
      {'name': '고운돋움', 'family': 'Gowun Dodum'},
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: fonts.length,
        itemBuilder: (context, index) {
          final font = fonts[index];
          final isSelected = settings.fontFamily == font['family'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ChoiceChip(
              label: Text(
                font['name']!,
                style: TextStyle(
                  fontFamily: font['family'],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textMain,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  notifier.setFontFamily(font['family']!);
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey[200]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required Function(double) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withValues(alpha: 0.1),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _getBibleStyle(BibleSettings settings) {
    final backgroundColor = Color(settings.backgroundColorValue);
    final isDark = backgroundColor.computeLuminance() < 0.35; // 기준값 조정
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
