import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NewMessagePage extends StatefulWidget {
  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                  child: Text('Zavřít'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: Text('Odeslat'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: CupertinoTextField(
                maxLines: 10,
                autofocus: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}
