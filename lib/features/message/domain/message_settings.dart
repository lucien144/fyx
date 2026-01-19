import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/IApiProvider.dart';

typedef F = Future<bool> Function(String? inputField, String message, List<Map<ATTACHMENT, dynamic>> attachment);
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