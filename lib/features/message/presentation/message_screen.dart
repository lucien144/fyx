import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:fyx/components/bottom_sheets/context_menu/grid.dart';
import 'package:fyx/components/bottom_sheets/context_menu/item.dart';
import 'package:fyx/components/premium_feature.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/features/message/domain/entities/attachment.dart';
import 'package:fyx/features/message/domain/enums/image_quality.dart';
import 'package:fyx/features/message/domain/enums/image_quality.dart';
import 'package:fyx/features/message/presentation/viewmodel/message_viewmodel.dart';
import 'package:fyx/features/message/presentation/widgets/attachment_preview.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/premium_feature_enum.dart';
import 'package:fyx/shared/services/service_locator.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mime/mime.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' as p;

enum FileSource { media, camera, files }

class MessageScreen extends WatchingStatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _recipientController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  FocusNode _recipientFocusNode = FocusNode();
  FocusNode _messageFocusNode = FocusNode();
  bool _hasRequestedInitialFocus = false;
  bool _hasInitializedControllers = false;

  final _scaffoldKey = UniqueKey();
  final _scrollKey = UniqueKey();

  final viewModel = getIt<MessageViewModel>();

  Future getImage(FileSource source) async {
    viewModel.setLoadingImage(true);
    switch (source) {
      case FileSource.media:
        final picker = ImagePicker();
        var files = await picker.pickMultipleMedia();
        if (files.isNotEmpty) {
          files.forEach((file) => addAttachment(file));
        }
        break;
      case FileSource.camera:
        final picker = ImagePicker();
        var file = await picker.pickImage(source: ImageSource.camera);
        if (file != null) {
          addAttachment(file);
        }
        break;
      case FileSource.files:
        FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
        if (result != null) {
          result.xFiles.forEach((file) => addAttachment(file));
        } else {
          // User canceled the picker
        }
        break;
    }
    viewModel.setLoadingImage(false);
  }

  addAttachment(XFile file) async {
    String ext = 'jpg';
    try {
      ext = Helpers.fileExtension(file.path) ?? '';
    } catch (error) {}

    final list = await file.readAsBytes();
    final mime = lookupMimeType(file.path);
    viewModel.addAttachment(new Attachment(
      filename: '${p.basename(file.path)}.$ext',
      extension: ext,
      mediaType: MediaType(mime!.split('/')[0], mime.split('/')[1]),
      bytes: list,
    ));
  }

  @override
  void initState() {
    // _recipientFocusNode.addListener(_focusCallback);
    // _messageFocusNode.addListener(_focusCallback);

    // Debug listeners to track focus changes
    _recipientFocusNode.addListener(() {
      LogService.log('[MessageScreen] Recipient focus changed: ${_recipientFocusNode.hasFocus}');
    });
    _messageFocusNode.addListener(() {
      LogService.log('[MessageScreen] Message focus changed: ${_messageFocusNode.hasFocus}');
    });

    _messageController.addListener(() {
      if (viewModel.state.onCompose != null) {
        viewModel.state.onCompose!(_messageController.text);
      }
    });

    AnalyticsProvider().setScreen('New Message', 'NewMessagePage');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize controllers only once to prevent resetting text when MediaQuery changes (keyboard open/close)
    if (!_hasInitializedControllers) {
      _hasInitializedControllers = true;

      // Initialize settings from route arguments
      _recipientController.text = viewModel.state.inputFieldPlaceholder.toUpperCase();
      _messageController.text = viewModel.state.draft.isNotEmpty ? viewModel.state.draft : viewModel.state.messageFieldPlaceholder;

      // Schedule initial focus request
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestInitialFocus());

      LogService.log('[MessageScreen] Controllers initialized in didChangeDependencies');
    } else {
      LogService.log('[MessageScreen] didChangeDependencies called again, skipping controller initialization');
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    // _recipientFocusNode.removeListener(_focusCallback);
    // _messageFocusNode.removeListener(_focusCallback);
    _recipientFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  /// Not in use ATM.
  // Saving where the focus is.
  // Gallery/Photo picker (or other action where we lose app focus) loses the input focus, therefore, we need to save latest state in order to restore it.
  _focusCallback() {
    if (_messageFocusNode.hasFocus) {
      viewModel.setRecipientFocus(false);
      return;
    }
    if (_recipientFocusNode.hasFocus) {
      viewModel.setRecipientFocus(true);
    }
  }

  void _requestInitialFocus() {
    if (_hasRequestedInitialFocus) return;
    _hasRequestedInitialFocus = true;

    LogService.log('[MessageScreen] Scheduling initial focus request');

    // Delay focus request to avoid keyboard flicker

    if (!mounted) {
      LogService.log('[MessageScreen] Widget not mounted, skipping focus request');
      return;
    }

    try {
      // Determine which field should get focus based on settings
      final shouldFocusRecipient = viewModel.state.hasInputField == true && viewModel.state.inputFieldPlaceholder.isEmpty;
      final shouldFocusMessage = viewModel.state.hasInputField != true || viewModel.state.inputFieldPlaceholder.isNotEmpty;

      LogService.log('[MessageScreen] Requesting focus - recipient: $shouldFocusRecipient, message: $shouldFocusMessage, '
          'recipientNode.canRequestFocus: ${_recipientFocusNode.canRequestFocus}, '
          'messageNode.canRequestFocus: ${_messageFocusNode.canRequestFocus}');

      if (shouldFocusRecipient) {
        _recipientFocusNode.requestFocus();
        LogService.log('[MessageScreen] Focus requested for recipient field');
      } else if (shouldFocusMessage) {
        _messageFocusNode.requestFocus();
        LogService.log('[MessageScreen] Focus requested for message field');
      }
    } catch (e, stackTrace) {
      LogService.log('[MessageScreen] Error requesting focus: $e');
      LogService.captureError(e, stack: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    LogService.log('[MessageScreen] -> widget rebuild');

    final viewModel = watchIt<MessageViewModel>();
    final state = viewModel.state;
    SkinColors colors = Skin.of(context).theme.colors;

    return CupertinoPageScaffold(
      key: _scaffoldKey,
      child: SafeArea(
        child: CustomScrollView(
          key: _scrollKey,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          shrinkWrap: true,
          slivers: [
            if (state.replyWidget != null)
              SliverPadding(padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0), sliver: SliverToBoxAdapter(child: state.replyWidget!)),
            if (state.hasInputField == true) const SliverToBoxAdapter(child: const SizedBox(height: 8)),
            if (state.hasInputField == true)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                sliver: SliverToBoxAdapter(
                  child: CupertinoTextField(
                    key: ValueKey('recipient_field'),
                    decoration: colors.textFieldDecoration,
                    controller: _recipientController,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]'))],
                    textCapitalization: TextCapitalization.characters,
                    placeholder: 'Adresát',
                    autocorrect: MainRepository().settings.useAutocorrect,
                    focusNode: _recipientFocusNode,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: const SizedBox(height: 8)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        key: ValueKey('message_field'),
                        decoration: colors.textFieldDecoration,
                        controller: _messageController,
                        expands: false,
                        minLines: 2,
                        maxLines: null,
                        scribbleEnabled: true,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: MainRepository().settings.useAutocorrect,
                        focusNode: _messageFocusNode,
                        contextMenuBuilder: (_, editableTextState) {
                          final buttonsMatrix = {
                            'B': {
                              'htmlStart': '<b>',
                              'htmlEnd': '</b>',
                              'md': '**',
                            },
                            'I': {
                              'htmlStart': '<i>',
                              'htmlEnd': '</i>',
                              'md': '*',
                            },
                            'Spoiler': {
                              'htmlStart': '<span class="spoiler">',
                              'htmlEnd': '</span>',
                              'md': '§',
                            },
                            'Code': {
                              'htmlStart': '<code>',
                              'htmlEnd': '</code>',
                              'md': '```',
                            },
                          };
                          final TextEditingValue value = editableTextState.textEditingValue;
                          final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
                          buttonsMatrix.entries.forEach((element) {
                            buttonItems.add(
                              ContextMenuButtonItem(
                                label: element.key,
                                onPressed: () {
                                  String replacement = '';
                                  final selected = value.selection.textInside(value.text);

                                  if (state.useMarkdown) {
                                    replacement = '${element.value['md']}${selected}${element.value['md']}';
                                  } else {
                                    replacement = '${element.value['htmlStart']}${selected}${element.value['htmlEnd']}';
                                  }

                                  // Update the message
                                  _messageController.text = value.text.replaceRange(value.selection.start, value.selection.end, replacement);

                                  // Move the cursor
                                  final isSelected = value.selection.start != value.selection.end;
                                  int offset = value.selection.extentOffset + (replacement.length - selected.length);
                                  if (!isSelected) {
                                    offset -= state.useMarkdown ? element.value['md']!.length : element.value['htmlEnd']!.length;
                                  }
                                  _messageController.selection = TextSelection(baseOffset: offset, extentOffset: offset);
                                  ContextMenuController.removeAny();
                                },
                              ),
                            );
                          });

                          return AdaptiveTextSelectionToolbar.buttonItems(
                            anchors: editableTextState.contextMenuAnchors,
                            buttonItems: buttonItems,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _messageController,
                        _recipientController,
                      ]),
                      builder: (context, child) {
                        final isSendDisabled = viewModel.isSendDisabled(
                          _recipientController.text,
                          _messageController.text,
                        );

                        return CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: state.sending
                              ? CupertinoActivityIndicator()
                              : Icon(
                                  MdiIcons.send,
                                  color: colors.background,
                                ),
                          color: colors.primary,
                          disabledColor: colors.grey,
                          onPressed: isSendDisabled
                              ? null
                              : () async {
                                  String message = state.useMarkdown
                                      ? md.markdownToHtml(
                                          _messageController.text,
                                          inlineSyntaxes: [
                                            md.DelimiterSyntax('§+', tags: [md.DelimiterTag('span class="spoiler"', 1)], requiresDelimiterRun: true),
                                            md.AutolinkExtensionSyntax()
                                          ],
                                        ).replaceAll('</span class="spoiler">', '</span>')
                                      : _messageController.text;

                                  final response = await viewModel.submit(
                                    state.hasInputField == true ? _recipientController.text : null,
                                    message,
                                  );

                                  if (response) {
                                    if (state.onClose != null) {
                                      state.onClose!();
                                    }
                                    Navigator.of(context).pop();
                                  }
                                },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.all(0),
                                child: Icon(MdiIcons.plusCircle),
                                onPressed: () {
                                  showCupertinoModalBottomSheet(
                                    context: context,
                                    expand: false,
                                    builder: (context) {
                                      return ContextMenuGrid(
                                        children: [
                                          ContextMenuItem(
                                            label: 'Kamera',
                                            icon: MdiIcons.camera,
                                            onTap: () async {
                                              Navigator.of(context).pop();
                                              FocusScope.of(context).unfocus();
                                              await getImage(FileSource.camera);
                                              //FocusScope.of(context).requestFocus(recipientHasFocus ? _recipientFocusNode : _messageFocusNode);
                                            },
                                          ),
                                          ContextMenuItem(
                                            label: 'Galerie',
                                            icon: MdiIcons.image,
                                            onTap: () async {
                                              Navigator.of(context).pop();
                                              FocusScope.of(context).unfocus();
                                              await getImage(FileSource.media);
                                              //FocusScope.of(context).requestFocus(recipientHasFocus ? _recipientFocusNode : _messageFocusNode);
                                            },
                                          ),
                                          ContextMenuItem(
                                            label: 'Soubory',
                                            icon: MdiIcons.fileDocument,
                                            onTap: () async {
                                              Navigator.of(context).pop();
                                              FocusScope.of(context).unfocus();
                                              await getImage(FileSource.files);
                                              //FocusScope.of(context).requestFocus(recipientHasFocus ? _recipientFocusNode : _messageFocusNode);
                                            },
                                          ),
                                          FutureBuilder(
                                              future: Pasteboard.image,
                                              builder: (_, data) {
                                                if (data.hasData) {
                                                  return ContextMenuItem(
                                                    label: 'Schránka',
                                                    icon: MdiIcons.contentPaste,
                                                    onTap: () async {
                                                      Navigator.of(context).pop();
                                                      FocusScope.of(context).unfocus();
                                                      final imageBytes = await Pasteboard.image;
                                                      if (imageBytes != null) {
                                                        viewModel.addAttachment(new Attachment(
                                                          filename: 'pasteboard_image.${DateTime.now().millisecondsSinceEpoch}.jpg',
                                                          extension: 'jpg',
                                                          mediaType: MediaType('image', 'jpeg'),
                                                          bytes: imageBytes,
                                                        ));
                                                      }
                                                      //FocusScope.of(context).requestFocus(state.recipientHasFocus ? _recipientFocusNode : _messageFocusNode);
                                                    },
                                                  );
                                                }
                                                return ContextMenuItem(
                                                  icon: MdiIcons.contentPaste,
                                                  label: 'Schránka',
                                                  disabled: true,
                                                );
                                              }),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              PremiumFeature(
                                feature: PremiumFeatureEnum.markdown,
                                child: CupertinoButton(
                                  padding: EdgeInsets.all(0),
                                  child: Icon(
                                    MdiIcons.languageMarkdown,
                                    color: state.useMarkdown ? colors.primary : colors.disabled,
                                    size: 32,
                                  ),
                                  onPressed: () => viewModel.toggleMarkdown(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (state.loadingImage)
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 10 + 8.0, top: 8.0),
                sliver: SliverToBoxAdapter(
                  child: Align(child: CupertinoActivityIndicator(), alignment: Alignment.centerLeft),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: state.attachments.map((Attachment attachment) => AttachmentPreview(attachment: attachment)).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
