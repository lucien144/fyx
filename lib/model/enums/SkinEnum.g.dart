// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SkinEnum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkinEnumAdapter extends TypeAdapter<SkinEnum> {
  @override
  final int typeId = 20;

  @override
  SkinEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SkinEnum.fyx;
      case 1:
        return SkinEnum.forest;
      case 2:
        return SkinEnum.greymatter;
      case 3:
        return SkinEnum.dark;
      default:
        return SkinEnum.fyx;
    }
  }

  @override
  void write(BinaryWriter writer, SkinEnum obj) {
    switch (obj) {
      case SkinEnum.fyx:
        writer.writeByte(0);
        break;
      case SkinEnum.forest:
        writer.writeByte(1);
        break;
      case SkinEnum.greymatter:
        writer.writeByte(2);
        break;
      case SkinEnum.dark:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkinEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
