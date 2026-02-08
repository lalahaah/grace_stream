import 'package:hive/hive.dart';

part 'bible_settings.g.dart';

@HiveType(typeId: 3)
class BibleSettings {
  @HiveField(0)
  final double fontSize;

  @HiveField(1)
  final String fontFamily;

  @HiveField(2)
  final double lineHeight;

  @HiveField(3)
  final double letterSpacing;

  @HiveField(4)
  final int backgroundColorValue;

  BibleSettings({
    this.fontSize = 18.0,
    this.fontFamily = 'Nanum Myeongjo',
    this.lineHeight = 1.6,
    this.letterSpacing = 0.0,
    this.backgroundColorValue = 0xFFF7F8FA, // AppColors.backgroundLight
  });

  BibleSettings copyWith({
    double? fontSize,
    String? fontFamily,
    double? lineHeight,
    double? letterSpacing,
    int? backgroundColorValue,
  }) {
    return BibleSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
    );
  }
}
