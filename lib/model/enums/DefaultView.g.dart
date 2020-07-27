// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DefaultView.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DefaultViewAdapter extends TypeAdapter<DefaultView> {
  @override
  final int typeId = 0;

  @override
  DefaultView read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DefaultView.history;
      case 1:
        return DefaultView.historyUnread;
      case 2:
        return DefaultView.bookmarks;
      case 3:
        return DefaultView.bookmarksUnread;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, DefaultView obj) {
    switch (obj) {
      case DefaultView.history:
        writer.writeByte(0);
        break;
      case DefaultView.historyUnread:
        writer.writeByte(1);
        break;
      case DefaultView.bookmarks:
        writer.writeByte(2);
        break;
      case DefaultView.bookmarksUnread:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefaultViewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
