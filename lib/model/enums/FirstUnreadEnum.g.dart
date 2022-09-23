// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FirstUnreadEnum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FirstUnreadEnumAdapter extends TypeAdapter<FirstUnreadEnum> {
  @override
  final int typeId = 10;

  @override
  FirstUnreadEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 11:
        return FirstUnreadEnum.off;
      case 12:
        return FirstUnreadEnum.button;
      case 13:
        return FirstUnreadEnum.autoscroll;
      default:
        return FirstUnreadEnum.off;
    }
  }

  @override
  void write(BinaryWriter writer, FirstUnreadEnum obj) {
    switch (obj) {
      case FirstUnreadEnum.off:
        writer.writeByte(11);
        break;
      case FirstUnreadEnum.button:
        writer.writeByte(12);
        break;
      case FirstUnreadEnum.autoscroll:
        writer.writeByte(13);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirstUnreadEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
