import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/theme/T.dart';

class PostAvatar extends StatelessWidget {
  final String image;
  final String nick;
  final String description;
  final bool isHighlighted;

  PostAvatar(this.image, this.nick, {this.isHighlighted = false, this.description = ''});

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Container(
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: isHighlighted ? T.COLOR_PRIMARY : Colors.black),
        child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: isHighlighted ? T.COLOR_PRIMARY : Colors.white),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              width: 40,
              height: 40,
            ),
          ),
        ),
      ),
      SizedBox(
        width: 4,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            nick,
            style: TextStyle(color: isHighlighted ? T.COLOR_PRIMARY : Colors.black),
          ),
          Text(
            description,
            style: TextStyle(color: Colors.black38, fontSize: 10),
          )
        ],
      )
    ]);
  }
}
