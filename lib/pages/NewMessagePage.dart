import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/T.dart';
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
  final List<int> widths = [640, 768, 1024, 1280];
  int _widthIndex = 0;
  final List<int> qualities = [60, 70, 80, 90, 100];
  int _qualityIndex = 3;
  String _message = '';
  String _recipient = '';
  bool _loadingImage = false;
  bool _sending = false;
  FocusNode _inputNode = FocusNode();

  Future getImage(ImageSource source) async {
    final picker = ImagePicker();
    setState(() => _loadingImage = true);
    var file = await picker.getImage(source: source);
    if (file != null) {
      var list = await file.readAsBytes();
      setState(() => _images.insert(0, {'uint8list': list, 'filename': '${basename(file.path)}.jpg'}));
    }
    setState(() => _loadingImage = false);
  }

  @override
  void initState() {
    _messageController.addListener(() => setState(() => _message = _messageController.text));
    _recipientController.addListener(() => setState(() => _recipient = _recipientController.text));
    _widthIndex = widths.indexOf(MainRepository().settings.photoWidth);
    _qualityIndex = qualities.indexOf(MainRepository().settings.photoQuality);
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
                                if (_images.length > 0) {
                                  // Workaround for frozen activity indicator when resizing & uploading images
                                  await Future.delayed(Duration(milliseconds: 200));
                                }
                                _images = _images.map((image) {
                                  var resized = img.copyResize(img.decodeImage(image['uint8list']), width: widths[_widthIndex]);
                                  return {'uint8list': image['uint8list'], 'bytes': img.encodeJpg(resized, quality: qualities[_qualityIndex]), 'filename': image['filename']};
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
                            FocusScope.of(context).requestFocus(_inputNode);
                          },
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: Icon(Icons.image),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            await getImage(ImageSource.gallery);
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
                          ),
                        Expanded(child: Container()),
                        CupertinoButton(
                            padding: EdgeInsets.all(0),
                            child: Text('${widths[_widthIndex]}px / ${qualities[_qualityIndex]}%', style: TextStyle(fontSize: 13)),
                            onPressed: () => showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 250.0,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 16.0),
                                          child: Row(
                                            children: [
                                              Expanded(child: Text('Šířka', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                              Expanded(child: Text('Kvalita', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Obrázek větší než 0.5M se zobrazí jako odkaz (příloha).', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black45)),
                                        ),
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                child: CupertinoPicker(
                                                    scrollController: new FixedExtentScrollController(
                                                      initialItem: _widthIndex,
                                                    ),
                                                    itemExtent: 32.0,
                                                    backgroundColor: Colors.white,
                                                    onSelectedItemChanged: (int index) {
                                                      setState(() {
                                                        _widthIndex = index;
                                                        MainRepository().settings.photoWidth = widths[_widthIndex];
                                                      });
                                                    },
                                                    children: widths
                                                        .map((width) => Center(
                                                              child: new Text('${width}px'),
                                                            ))
                                                        .toList()),
                                              ),
                                              Expanded(
                                                child: CupertinoPicker(
                                                    scrollController: new FixedExtentScrollController(
                                                      initialItem: _qualityIndex,
                                                    ),
                                                    itemExtent: 32.0,
                                                    backgroundColor: Colors.white,
                                                    onSelectedItemChanged: (int index) {
                                                      setState(() {
                                                        _qualityIndex = index;
                                                        MainRepository().settings.photoQuality = qualities[_qualityIndex];
                                                      });
                                                    },
                                                    children: qualities
                                                        .map((quality) => Center(
                                                              child: new Text('$quality%'),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.black45,
                      ),
                      SizedBox(width: 4),
                      Text('Kvůli omezením Nyxu lze nahrát pouze 1 obrázek.', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black45)),
                    ],
                  ),
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
