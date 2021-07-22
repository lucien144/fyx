import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

enum ISOLATE_ARG { images, width, quality }

typedef F = Future<bool> Function(String? inputField, String message,
    List<Map<ATTACHMENT, dynamic>> attachment);

class NewMessageSettings {
  String inputFieldPlaceholder;
  bool hasInputField;
  Widget? replyWidget;
  Function? onClose;
  F onSubmit;

  NewMessageSettings(
      {this.replyWidget,
      this.onClose,
      required this.onSubmit,
      this.hasInputField = false,
      this.inputFieldPlaceholder = ''});
}

class NewMessagePage extends StatefulWidget {
  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  TextEditingController _recipientController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  List<Map<ATTACHMENT, dynamic>> _images = [];
  late NewMessageSettings _settings;
  final List<int> widths = [640, 768, 1024, 1280];
  int _widthIndex = 2;
  final List<int> qualities = [60, 70, 80, 90, 100];
  int _qualityIndex = 1;
  String _message = '';
  String _recipient = '';
  bool _loadingImage = false;
  bool _sending = false;
  FocusNode _recipientFocusNode = FocusNode();
  FocusNode _messageFocusNode = FocusNode();
  bool recipientHasFocus = true;

  Future getImage(ImageSource source) async {
    final picker = ImagePicker();
    setState(() => _loadingImage = true);
    final file = await picker.getImage(
        source: source,
        maxHeight: widths[_widthIndex].toDouble(),
        maxWidth: widths[_widthIndex].toDouble(),
        imageQuality: qualities[_qualityIndex]);
    if (file != null) {
      String ext = 'jpg';
      try {
        ext = Helpers.fileExtension(file.path) ?? '';
      } catch (error) {}

      final list = await file.readAsBytes();
      final mime = lookupMimeType(file.path);
      setState(() => _images.add({
            ATTACHMENT.bytes: list,
            ATTACHMENT.filename: '${basename(file.path)}.$ext',
            ATTACHMENT.mime: mime,
            ATTACHMENT.extension: ext,
            ATTACHMENT.mediatype:
                MediaType(mime!.split('/')[0], mime.split('/')[1]),
          }));
    }
    setState(() => _loadingImage = false);
  }

  @override
  void initState() {
    _recipientFocusNode.addListener(_focusCallback);
    _messageFocusNode.addListener(_focusCallback);
    _messageController
        .addListener(() => setState(() => _message = _messageController.text));
    _recipientController.addListener(
        () => setState(() => _recipient = _recipientController.text));
    _widthIndex = widths.indexOf(MainRepository().settings.photoWidth);
    _qualityIndex = qualities.indexOf(MainRepository().settings.photoQuality);
    AnalyticsProvider().setScreen('New Message', 'NewMessagePage');
    super.initState();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    _recipientFocusNode.removeListener(_focusCallback);
    _messageFocusNode.removeListener(_focusCallback);
    super.dispose();
  }

  // Saving where the focus is.
  // Gallery/Photo picker (or other action where we lose app focus) loses the input focus, therefore, we need to save latest state in order to restore it.
  _focusCallback() {
    if (_messageFocusNode.hasFocus) {
      recipientHasFocus = false;
      return;
    }
    if (_recipientFocusNode.hasFocus) {
      recipientHasFocus = true;
    }
  }

  _isSendDisabled() {
    if (_sending) {
      return true;
    }

    return ((_settings.hasInputField == true ? _recipient.length : 1) *
            (_message.length + _images.length)) ==
        0;
  }

  // Isolate -> encoding to JPG
  static FutureOr<List<Map<ATTACHMENT, dynamic>>> handleImages(
      List<Map<ATTACHMENT, dynamic>> images) {
    return images.map<Map<ATTACHMENT, dynamic>>((image) {
      var decode = img.decodeImage(image[ATTACHMENT.bytes]);
      var baked = decode == null
          ? image[ATTACHMENT.bytes]
          : img.bakeOrientation(decode);
      return {
        ATTACHMENT.bytes: img.encodeJpg(baked),
        ATTACHMENT.filename: image[ATTACHMENT.filename],
        ATTACHMENT.mime: 'image/jpeg',
        ATTACHMENT.mediatype: MediaType('image', 'jpg'),
        ATTACHMENT.extension: 'jpg',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      _settings =
          ModalRoute.of(context)!.settings.arguments as NewMessageSettings;
      _recipientController.text = _settings.inputFieldPlaceholder.toUpperCase();
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: Text('Zavřít'),
                          onPressed: () => Navigator.of(context).pop()),
                      CupertinoButton(
                        padding: EdgeInsets.all(0),
                        child: _sending
                            ? CupertinoActivityIndicator()
                            : Text('Odeslat'),
                        onPressed: _isSendDisabled()
                            ? null
                            : () async {
                                setState(() => _sending = true);
                                if (_images.length > 0) {
                                  _images =
                                      await compute(handleImages, _images);
                                }
                                var response = await _settings.onSubmit(
                                    _settings.hasInputField == true
                                        ? _recipientController.text
                                        : null,
                                    _messageController.text,
                                    _images.length > 0 ? _images : []);
                                if (response) {
                                  if (_settings.onClose != null) {
                                    _settings.onClose!();
                                  }
                                  Navigator.of(context).pop();
                                }
                                setState(() => _sending = false);
                              },
                      )
                    ],
                  ),
                  Visibility(
                      visible: _settings.hasInputField == true,
                      child: CupertinoTextField(
                        controller: _recipientController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp('[a-zA-Z0-9_]'))
                        ],
                        textCapitalization: TextCapitalization.characters,
                        placeholder: 'Adresát',
                        autofocus: _settings.hasInputField == true &&
                            _settings.inputFieldPlaceholder == null,
                        autocorrect: MainRepository().settings.useAutocorrect,
                        focusNode: _recipientFocusNode,
                      )),
                  SizedBox(
                    height: 8,
                  ),
                  CupertinoTextField(
                    controller: _messageController,
                    maxLines: 10,
                    autofocus: _settings.hasInputField != true ||
                        _settings.inputFieldPlaceholder != null,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: MainRepository().settings.useAutocorrect,
                    focusNode: _messageFocusNode,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: Icon(Icons.camera_alt),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            await getImage(ImageSource.camera);
                            FocusScope.of(context).requestFocus(
                                recipientHasFocus
                                    ? _recipientFocusNode
                                    : _messageFocusNode);
                          },
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: Icon(Icons.image),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            await getImage(ImageSource.gallery);
                            FocusScope.of(context).requestFocus(
                                recipientHasFocus
                                    ? _recipientFocusNode
                                    : _messageFocusNode);
                          },
                        ),
                        Visibility(
                          visible: _images.length > 0,
                          child: Container(
                            width: 16,
                            height: 1,
                            color: Colors.black38,
                          ),
                        ),
                        SizedBox(width: 12),
                        if (_loadingImage)
                          CupertinoActivityIndicator()
                        else
                          Row(
                            children: _images
                                .map((Map<ATTACHMENT, dynamic> image) =>
                                    _buildPreviewWidget(
                                        image[ATTACHMENT.bytes]))
                                .toList(),
                          ),
                        Expanded(child: Container()),
                        CupertinoButton(
                            padding: EdgeInsets.all(0),
                            child: Text(
                                '${widths[_widthIndex]}px / ${qualities[_qualityIndex]}%',
                                style: TextStyle(fontSize: 13)),
                            onPressed: () => showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 250.0,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text('Šířka',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              Expanded(
                                                  child: Text('Kvalita',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              'Obrázek větší než 0.5M se zobrazí jako odkaz (příloha).',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black45)),
                                        ),
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                child: CupertinoPicker(
                                                    scrollController:
                                                        new FixedExtentScrollController(
                                                      initialItem: _widthIndex,
                                                    ),
                                                    itemExtent: 32.0,
                                                    backgroundColor:
                                                        Colors.white,
                                                    onSelectedItemChanged:
                                                        (int index) {
                                                      setState(() {
                                                        _widthIndex = index;
                                                        MainRepository()
                                                                .settings
                                                                .photoWidth =
                                                            widths[_widthIndex];
                                                      });
                                                    },
                                                    children: widths
                                                        .map((width) => Center(
                                                              child: new Text(
                                                                  '${width}px'),
                                                            ))
                                                        .toList()),
                                              ),
                                              Expanded(
                                                child: CupertinoPicker(
                                                    scrollController:
                                                        new FixedExtentScrollController(
                                                      initialItem:
                                                          _qualityIndex,
                                                    ),
                                                    itemExtent: 32.0,
                                                    backgroundColor:
                                                        Colors.white,
                                                    onSelectedItemChanged:
                                                        (int index) {
                                                      setState(() {
                                                        _qualityIndex = index;
                                                        MainRepository()
                                                                .settings
                                                                .photoQuality =
                                                            qualities[
                                                                _qualityIndex];
                                                      });
                                                    },
                                                    children: qualities
                                                        .map(
                                                            (quality) => Center(
                                                                  child: new Text(
                                                                      '$quality%'),
                                                                ))
                                                        .toList()),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }))
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (_settings.replyWidget != null) _settings.replyWidget!
            ].where((Object o) => o != null).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewWidget(List<int> bytes) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() =>
            _images.removeWhere((image) => image[ATTACHMENT.bytes] == bytes)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image(
            image: MemoryImage(Uint8List.fromList(bytes)),
            width: 35,
            height: 35,
            fit: BoxFit.cover,
            frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
              if (frame == null) {
                return CupertinoActivityIndicator();
              }
              return child;
            },
          ),
        ),
      ),
    );
  }
}
