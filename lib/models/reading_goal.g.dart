// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingGoalAdapter extends TypeAdapter<ReadingGoal> {
  @override
  final int typeId = 4;

  @override
  ReadingGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingGoal(
      bookId: fields[0] as String,
      bookName: fields[1] as String,
      startChapter: fields[2] as int,
      endChapter: fields[3] as int,
      readChapters: (fields[4] as List).cast<int>(),
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingGoal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.bookId)
      ..writeByte(1)
      ..write(obj.bookName)
      ..writeByte(2)
      ..write(obj.startChapter)
      ..writeByte(3)
      ..write(obj.endChapter)
      ..writeByte(4)
      ..write(obj.readChapters)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
