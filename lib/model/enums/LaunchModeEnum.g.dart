// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LaunchModeEnum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LaunchModeEnumAdapter extends TypeAdapter<LaunchModeEnum> {
  @override
  final int typeId = 15;

  @override
  LaunchModeEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LaunchModeEnum.platformDefault;
      case 1:
        return LaunchModeEnum.inAppWebView;
      case 2:
        return LaunchModeEnum.externalApplication;
      case 3:
        return LaunchModeEnum.externalNonBrowserApplication;
      default:
        return LaunchModeEnum.platformDefault;
    }
  }

  @override
  void write(BinaryWriter writer, LaunchModeEnum obj) {
    switch (obj) {
      case LaunchModeEnum.platformDefault:
        writer.writeByte(0);
        break;
      case LaunchModeEnum.inAppWebView:
        writer.writeByte(1);
        break;
      case LaunchModeEnum.externalApplication:
        writer.writeByte(2);
        break;
      case LaunchModeEnum.externalNonBrowserApplication:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LaunchModeEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
