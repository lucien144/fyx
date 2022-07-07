import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:fyx/components/avatar.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class PostAvatar extends StatelessWidget {
  final String nick;
  final bool isHighlighted;
  String? description;
  Widget? descriptionWidget;

  String get image => Helpers.avatarUrl(nick);

  PostAvatar(this.nick, {this.isHighlighted = false, this.description, this.descriptionWidget});

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Row(children: <Widget>[
      Avatar(image),
      SizedBox(
        width: 4,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          material.Row(
            children: <material.Widget>[
              Text(
                nick,
                style: TextStyle(color: isHighlighted ? colors.primary : colors.text, fontSize: Skin.of(context).defaultFontSize),
              ),
              Visibility(
                visible: isHighlighted,
                child: SizedBox(
                  width: 4,
                ),
              )
            ],
          ),
          if (this.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                this.description!,
                style: TextStyle(color: colors.text.withOpacity(0.38), fontSize: 10),
              ),
            )
          else if (this.descriptionWidget != null)
            Padding(padding: const EdgeInsets.only(top: 4.0), child: this.descriptionWidget!)
        ],
      )
    ]);
  }
}
