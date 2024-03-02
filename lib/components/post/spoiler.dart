import 'package:flutter/material.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class Spoiler extends StatefulWidget {
  final Widget parsedChild;

  Spoiler(this.parsedChild, {Key? key}) : super(key: key);

  @override
  _SpoilerState createState() => _SpoilerState();
}

class _SpoilerState extends State<Spoiler> {
  late final Widget _parsedChild;
  bool _toggle = false;

  @override
  void initState() {
    super.initState();
    _parsedChild = widget.parsedChild;
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return GestureDetector(
      onTap: () => setState(() => _toggle = !_toggle),
      child: Stack(
        fit: StackFit.loose,
        children: [
          ConstrainedBox(child: _parsedChild, constraints: BoxConstraints(minWidth: double.infinity)),
          Positioned.fill(
              child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    '* SPOILER! *',
                    style: TextStyle(color: _toggle ? Colors.transparent : colors.light),
                  ),
                  color: _toggle ? Colors.transparent : colors.text)),
        ],
      ),
    );
  }
}
