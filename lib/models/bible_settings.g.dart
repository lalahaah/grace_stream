// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BibleSettingsAdapter extends TypeAdapter<BibleSettings> {
  @override
  final int typeId = 3;

  @override
  BibleSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BibleSettings(
      fontSize: fields[0] as double,
      fontFamily: fields[1] as String,
      lineHeight: fields[2] as double,
      letterSpacing: fields[3] as double,
      backgroundColorValue: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BibleSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fontSize)
      ..writeByte(1)
      ..write(obj.fontFamily)
      ..writeByte(2)
      ..write(obj.lineHeight)
      ..writeByte(3)
      ..write(obj.letterSpacing)
      ..writeByte(4)
      ..write(obj.backgroundColorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
