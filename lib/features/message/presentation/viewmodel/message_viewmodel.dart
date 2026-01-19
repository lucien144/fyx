import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/features/message/domain/message_settings.dart';
import 'package:fyx/features/message/presentation/viewmodel/message_state.dart';

/// ViewModel for new message screen managing message composition state
class MessageViewModel extends ChangeNotifier {
  MessageState _state = MessageState(
    onSubmit: (_, __, ___) async => false,
  );

  MessageState get state => _state;

  /// Initialize message state from settings
  void initializeFromSettings(MessageSettings obj) {
    _state = MessageState.fromSettings(
      inputFieldPlaceholder: obj.inputFieldPlaceholder,
      messageFieldPlaceholder: obj.messageFieldPlaceholder,
      draft: obj.draft,
      hasInputField: obj.hasInputField,
      replyWidget: obj.replyWidget,
      onClose: obj.onClose,
      onDraftRemove: obj.onDraftRemove,
      onCompose: obj.onCompose,
      onSubmit: obj.onSubmit,
      useMarkdown: obj.useMarkdown,
    );
    notifyListeners();
  }

  /// Add image to the list
  void addImage(Map<ATTACHMENT, dynamic> image) {
    final updatedImages = List<Map<ATTACHMENT, dynamic>>.from(_state.images)..add(image);
    _state = _state.copyWith(images: updatedImages);
    notifyListeners();
  }

  /// Remove image from the list by bytes
  void removeImage(List<int> bytes) {
    final updatedImages = List<Map<ATTACHMENT, dynamic>>.from(_state.images)
      ..removeWhere((image) => image[ATTACHMENT.bytes] == bytes);
    _state = _state.copyWith(images: updatedImages);
    notifyListeners();
  }

  /// Set loading image state
  void setLoadingImage(bool loading) {
    _state = _state.copyWith(loadingImage: loading);
    notifyListeners();
  }

  /// Set sending state
  void setSending(bool sending) {
    _state = _state.copyWith(sending: sending);
    notifyListeners();
  }

  /// Toggle markdown mode
  void toggleMarkdown() {
    _state = _state.copyWith(useMarkdown: !_state.useMarkdown);
    notifyListeners();
  }

  /// Set markdown mode
  void setMarkdown(bool enabled) {
    _state = _state.copyWith(useMarkdown: enabled);
    notifyListeners();
  }

  /// Set recipient focus state
  void setRecipientFocus(bool hasFocus) {
    _state = _state.copyWith(recipientHasFocus: hasFocus);
    notifyListeners();
  }

  /// Submit the message
  Future<bool> submit(String? recipient, String message) async {
    try {
      setSending(true);
      final result = await _state.onSubmit(
        recipient,
        message,
        _state.images.isNotEmpty ? _state.images : [],
      );
      return result;
    } finally {
      setSending(false);
    }
  }

  /// Check if send button should be disabled
  bool isSendDisabled(String recipientText, String messageText) {
    if (_state.sending) {
      return true;
    }

    final recipientLength = _state.hasInputField ? recipientText.length : 1;
    final contentLength = messageText.length + _state.images.length;

    return (recipientLength * contentLength) == 0;
  }

  /// Clear all data (useful for cleanup)
  void clear() {
    _state = MessageState(
      onSubmit: (_, __, ___) async => false,
    );
    notifyListeners();
  }
}
