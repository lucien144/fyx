// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ThemeEnum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeEnumAdapter extends TypeAdapter<ThemeEnum> {
  @override
  final int typeId = 5;

  @override
  ThemeEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 5:
        return ThemeEnum.light;
      case 6:
        return ThemeEnum.dark;
      case 7:
        return ThemeEnum.system;
      default:
        return ThemeEnum.light;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeEnum obj) {
    switch (obj) {
      case ThemeEnum.light:
        writer.writeByte(5);
        break;
      case ThemeEnum.dark:
        writer.writeByte(6);
        break;
      case ThemeEnum.system:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
