import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

typedef F = Future<bool> Function(String inputField, String message, Map<String, dynamic> attachment);

class NewMessageSettings {
  String inputFieldPlaceholder;
  bool hasInputField;
  Widget replyWidget;
  Function onClose;
  F onSubmit;

  NewMessageSettings({this.replyWidget, this.onClose, this.onSubmit, this.hasInputField, this.inputFieldPlaceholder});
}

class NewMessagePage extends StatefulWidget {
  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  TextEditingController _recipientController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _images = [];
  NewMessageSettings _settings;
  String _message = '';
  String _recipient = '';
  bool _loadingImage = false;
  bool _sending = false;
  FocusNode _inputNode = FocusNode();

  void getImage(ImageSource source) {
    final picker = ImagePicker();
    setState(() => _loadingImage = true);
    picker.getImage(source: source).then((file) async {
      if (file != null) {
        var list = await file.readAsBytes();
        setState(() => _images.insert(0, {'uint8list': list, 'filename': '${basename(file.path)}.jpg'}));
      }
    }).whenComplete(() => setState(() => _loadingImage = false));
  }

  @override
  void initState() {
    _messageController.addListener(() => setState(() => _message = _messageController.text));
    _recipientController.addListener(() => setState(() => _recipient = _recipientController.text));
    AnalyticsProvider().setScreen('New Message', 'NewMessagePage');
    super.initState();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  _isSendDisabled() {
    if (_sending) {
      return true;
    }

    return ((_settings.hasInputField == true ? _recipient.length : 1) * (_message.length + _images.length)) == 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      _settings = ModalRoute.of(context).settings.arguments as NewMessageSettings;
      _recipientController.text = _settings.inputFieldPlaceholder?.toUpperCase();
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
                      CupertinoButton(padding: EdgeInsets.all(0), child: Text('Zavřít'), onPressed: () => Navigator.of(context).pop()),
                      CupertinoButton(
                        padding: EdgeInsets.all(0),
                        child: _sending ? CupertinoActivityIndicator() : Text('Odeslat'),
                        onPressed: _isSendDisabled()
                            ? null
                            : () async {
                                setState(() => _sending = true);
                                _images = _images.map((image) {
                                  var resized = img.copyResize(img.decodeImage(image['uint8list']), width: 640);
                                  return {'uint8list': image['uint8list'], 'bytes': img.encodeJpg(resized, quality: 90), 'filename': image['filename']};
                                }).toList();
                                var response =
                                    await _settings.onSubmit(_settings.hasInputField == true ? _recipientController.text : null, _messageController.text, _images.length > 0 ? _images[0] : null);
                                if (response) {
                                  if (_settings.onClose is Function) {
                                    _settings.onClose();
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
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]'))],
                        textCapitalization: TextCapitalization.characters,
                        placeholder: 'Adresát',
                        autofocus: _recipientController.text.length == 0,
                        autocorrect: MainRepository().settings.useAutocorrect,
                        focusNode: _recipientController.text.length == 0 ? _inputNode : null,
                      )),
                  SizedBox(
                    height: 8,
                  ),
                  CupertinoTextField(
                    controller: _messageController,
                    maxLines: 10,
                    autofocus: _recipientController.text.length > 0 || _settings.hasInputField != true,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: MainRepository().settings.useAutocorrect,
                    focusNode: _recipientController.text.length > 0 || _settings.hasInputField != true ? _inputNode : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: Icon(Icons.camera_alt),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            getImage(ImageSource.camera);
                            FocusScope.of(context).requestFocus(_inputNode);
                          },
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: Icon(Icons.image),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            getImage(ImageSource.gallery);
                            FocusScope.of(context).requestFocus(_inputNode);
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
                            // children: _images.map((List<int> file) => _buildPreviewWidget(file)).toList(),
                            children: _images.length > 0
                                ? [
                                    _buildPreviewWidget(_images[0]['uint8list']),
                                    CupertinoButton(
                                      padding: EdgeInsets.all(0),
                                      child: Text('Smazat'),
                                      onPressed: () => setState(() => _images.clear()),
                                    )
                                  ]
                                : [],
                          )
                      ],
                    ),
                  )
                ],
              ),
              _settings.replyWidget
            ].where((Object o) => o != null).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewWidget(List<int> bytes) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: MemoryImage(bytes),
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
            if (frame == null) {
              return CupertinoActivityIndicator();
            }
            return child;
          },
        ),
      ),
    );
  }
}
