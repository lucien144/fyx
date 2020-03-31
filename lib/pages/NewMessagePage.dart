import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker_modern/image_picker_modern.dart';
import 'package:path/path.dart';

typedef F<T> = Future<T> Function(String inputField, String message, Map<String, dynamic> attachment);

class NewMessageSettings<T> {
  bool hasInputField;
  Widget replyWidget;
  Function onClose;
  F<T> onSubmit;

  NewMessageSettings({this.replyWidget, this.onClose, this.onSubmit, this.hasInputField});
}

class NewMessagePage extends StatefulWidget {
  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  TextEditingController _recipientController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  List<List<int>> _thumbs = [];
  List<Map<String, dynamic>> _images = [];
  NewMessageSettings _settings;
  String _message = '';
  String _recipient = '';
  bool _sending = false;

  Future getImage(ImageSource source) async {
    var file = await ImagePicker.pickImage(source: source);
    var image = img.decodeImage(file.readAsBytesSync());
    var big = img.copyResize(image, width: 1024);
    var thumb = img.copyResize(image, width: 50);
    var bigJpg = img.encodeJpg(big, quality: 75);
    var thumbJpg = img.encodeJpg(thumb, quality: 40);

    if (image != null) {
      setState(() {
        _images.insert(0, {'bytes': bigJpg, 'filename': '${basename(file.path)}.jpg'});
        _thumbs.insert(0, thumbJpg);
      });
    }
  }

  @override
  void initState() {
    _messageController.addListener(() => setState(() => _message = _messageController.text));
    _recipientController.addListener(() => setState(() => _recipient = _recipientController.text));
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
      _settings = ModalRoute.of(context).settings.arguments;
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
                                var response = await _settings.onSubmit(
                                    _settings.hasInputField == true ? _recipientController.text : null, _messageController.text, _images.length > 0 ? _images[0] : null);
                                setState(() => _sending = false);
                                if (_settings.onClose is Function) {
                                  _settings.onClose();
                                }
                                Navigator.of(context).pop();
                              },
                      )
                    ],
                  ),
                  Visibility(
                      visible: _settings.hasInputField == true,
                      child: CupertinoTextField(
                        controller: _recipientController,
                        inputFormatters: [WhitelistingTextInputFormatter(RegExp('[a-zA-Z0-9_]'))],
                        textCapitalization: TextCapitalization.characters,
                        placeholder: 'Adresát',
                      )),
                  SizedBox(
                    height: 8,
                  ),
                  CupertinoTextField(
                    controller: _messageController,
                    maxLines: 10,
                    autofocus: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: Icon(Icons.camera_alt),
                          onPressed: () => getImage(ImageSource.camera),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: Icon(Icons.image),
                          onPressed: () => getImage(ImageSource.gallery),
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
                        Row(
                          // children: _thumbs.map((List<int> file) => _buildPreviewWidget(file)).toList(),
                          children: _thumbs.length > 0
                              ? [
                                  _buildPreviewWidget(_thumbs[0]),
                                  CupertinoButton(
                                    padding: EdgeInsets.all(0),
                                    child: Text('Smazat'),
                                    onPressed: () {
                                      setState(() {
                                        _thumbs.clear();
                                        _images.clear();
                                      });
                                    },
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

  Widget _buildPreviewWidget(List<int> file) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          file,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
