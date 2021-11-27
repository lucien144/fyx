import 'package:flutter/material.dart';
import 'package:fyx/theme/T.dart';

class Spoiler extends StatefulWidget {
  final String text;

  Spoiler(this.text, {Key? key}) : super(key: key);

  @override
  _SpoilerState createState() => _SpoilerState();
}

class _SpoilerState extends State<Spoiler> {
  late final String _text;
  bool _toggle = false;

  @override
  void initState() {
    super.initState();
    _text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _toggle = !_toggle),
      child: RichText(
        text: TextSpan(children: <TextSpan>[
          TextSpan(text: 'Spoiler ⮕ ', style: DefaultTextStyle.of(context).style),
          TextSpan(
            text: '$_text',
            style: DefaultTextStyle.of(context).style.apply(backgroundColor: _toggle ? Colors.transparent : T.COLOR_BLACK),
          ),
        ]),
      ),
    );
  }
}
