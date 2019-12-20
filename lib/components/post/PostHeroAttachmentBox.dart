import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/theme/T.dart';

class PostHeroAttachmentBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final String image;

  PostHeroAttachmentBox({this.title, this.icon, this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        image: this.image == null ? null : DecorationImage(image: NetworkImage(this.image), fit: BoxFit.cover),
        color: T.COLOR_PRIMARY,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
          ),
          Container(
            color: Color.fromRGBO(255, 255, 255, 0.6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14),
              ),
            ),
          )
        ],
      ),
    );
  }
}
