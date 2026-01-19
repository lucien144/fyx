import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/IApiProvider.dart';

typedef OnSubmitCallback = Future<bool> Function(
  String? inputField,
  String message,
  List<Map<ATTACHMENT, dynamic>> attachment,
);
typedef OnComposeCallback = void Function(String message);

/// State for new message screen
@immutable
class MessageState {
  // Settings
  final String inputFieldPlaceholder;
  final String messageFieldPlaceholder;
  final String draft;
  final bool hasInputField;
  final Widget? replyWidget;
  final Function? onClose;
  final Function? onDraftRemove;
  final OnComposeCallback? onCompose;
  final OnSubmitCallback onSubmit;

  // UI State
  final List<Map<ATTACHMENT, dynamic>> images;
  final bool loadingImage;
  final bool sending;
  final bool useMarkdown;
  final bool recipientHasFocus;

  const MessageState({
    this.inputFieldPlaceholder = '',
    this.messageFieldPlaceholder = '',
    this.draft = '',
    this.hasInputField = false,
    this.replyWidget,
    this.onClose,
    this.onDraftRemove,
    this.onCompose,
    required this.onSubmit,
    this.images = const [],
    this.loadingImage = false,
    this.sending = false,
    this.useMarkdown = false,
    this.recipientHasFocus = true,
  });

  /// Create initial state from settings
  factory MessageState.fromSettings({
    required String inputFieldPlaceholder,
    required String messageFieldPlaceholder,
    required String draft,
    required bool hasInputField,
    Widget? replyWidget,
    Function? onClose,
    Function? onDraftRemove,
    OnComposeCallback? onCompose,
    required OnSubmitCallback onSubmit,
    required bool useMarkdown,
  }) {
    return MessageState(
      inputFieldPlaceholder: inputFieldPlaceholder,
      messageFieldPlaceholder: messageFieldPlaceholder,
      draft: draft,
      hasInputField: hasInputField,
      replyWidget: replyWidget,
      onClose: onClose,
      onDraftRemove: onDraftRemove,
      onCompose: onCompose,
      onSubmit: onSubmit,
      useMarkdown: useMarkdown,
    );
  }

  /// Create a copy with updated values
  MessageState copyWith({
    String? inputFieldPlaceholder,
    String? messageFieldPlaceholder,
    String? draft,
    bool? hasInputField,
    Widget? replyWidget,
    Function? onClose,
    Function? onDraftRemove,
    OnComposeCallback? onCompose,
    OnSubmitCallback? onSubmit,
    List<Map<ATTACHMENT, dynamic>>? images,
    bool? loadingImage,
    bool? sending,
    bool? useMarkdown,
    bool? recipientHasFocus,
  }) {
    return MessageState(
      inputFieldPlaceholder: inputFieldPlaceholder ?? this.inputFieldPlaceholder,
      messageFieldPlaceholder: messageFieldPlaceholder ?? this.messageFieldPlaceholder,
      draft: draft ?? this.draft,
      hasInputField: hasInputField ?? this.hasInputField,
      replyWidget: replyWidget ?? this.replyWidget,
      onClose: onClose ?? this.onClose,
      onDraftRemove: onDraftRemove ?? this.onDraftRemove,
      onCompose: onCompose ?? this.onCompose,
      onSubmit: onSubmit ?? this.onSubmit,
      images: images ?? this.images,
      loadingImage: loadingImage ?? this.loadingImage,
      sending: sending ?? this.sending,
      useMarkdown: useMarkdown ?? this.useMarkdown,
      recipientHasFocus: recipientHasFocus ?? this.recipientHasFocus,
    );
  }
}
