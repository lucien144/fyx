import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker_modern/image_picker_modern.dart';

class NewMessagePage extends StatefulWidget {
  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  List<File> _images = [];

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);

    if (image != null) {
      setState(() => _images.add(image));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  CupertinoButton(
                    padding: EdgeInsets.all(0),
                    child: Text('Zavřít'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.all(0),
                    child: Text('Odeslat'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              CupertinoTextField(
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
                      children: _images.map((File file) => _buildPreviewWidget(file)).toList(),
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

  Widget _buildPreviewWidget(File file) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          file,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
