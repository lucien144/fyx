import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/features/message/domain/entities/attachment.dart';

typedef F = Future<bool> Function(String? inputField, String message, List<Attachment> attachment);
typedef C = void Function(String message);

class MessageSettings {
  String inputFieldPlaceholder;
  String messageFieldPlaceholder;
  String draft;
  bool hasInputField;
  bool useMarkdown;
  Widget? replyWidget;
  Function? onClose;
  Function? onDraftRemove;
  C? onCompose;
  F onSubmit;

  MessageSettings({
    this.replyWidget,
    this.onClose,
    this.onCompose,
    this.onDraftRemove,
    this.useMarkdown = false,
    required this.onSubmit,
    this.hasInputField = false,
    this.inputFieldPlaceholder = '',
    this.messageFieldPlaceholder = '',
    this.draft = '',
  });
}