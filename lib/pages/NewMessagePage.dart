import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Discussion.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker_modern/image_picker_modern.dart';
import 'package:path/path.dart';

class NewMessagePage extends StatefulWidget {
  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  TextEditingController _controller = TextEditingController();
  List<List<int>> _thumbs = [];
  List<Map<String, dynamic>> _images = [];
  Discussion _discussion;
  String _text = '';
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
    _controller.addListener(() => setState(() => _text = _controller.text));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_discussion == null) {
      _discussion = ModalRoute.of(context).settings.arguments;
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CupertinoButton(padding: EdgeInsets.all(0), child: Text('Zavřít'), onPressed: () => Navigator.of(context).pop()),
                  CupertinoButton(
                    padding: EdgeInsets.all(0),
                    child: _sending ? CupertinoActivityIndicator() : Text('Odeslat'),
                    onPressed: (_text.length + _images.length) == 0 || _sending
                        ? null
                        : () async {
                            setState(() => _sending = true);
                            await ApiController().postDiscussionMessage(_discussion.idKlub, _controller.text, attachment: _images.length > 0 ? _images[0] : null);
                            setState(() => _sending = false);
                            Navigator.of(context).pop();
                          },
                  )
                ],
              ),
              CupertinoTextField(
                controller: _controller,
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
