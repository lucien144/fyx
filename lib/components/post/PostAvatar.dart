import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:fyx/components/CircleAvatar.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/T.dart';

class PostAvatar extends StatelessWidget {
  final String nick;
  final String description;
  final bool isHighlighted;

  String get image => Helpers.avatarUrl(nick);

  PostAvatar(this.nick, {this.isHighlighted = false, this.description = ''});

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      CircleAvatar(image, isHighlighted: isHighlighted),
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
                style: TextStyle(color: isHighlighted ? T.COLOR_PRIMARY : material.Colors.black),
              ),
              Visibility(
                visible: isHighlighted,
                child: SizedBox(
                  width: 4,
                ),
              )
            ],
          ),
          Text(
            description,
            style: TextStyle(color: material.Colors.black38, fontSize: 10),
          )
        ],
      )
    ]);
  }
}
