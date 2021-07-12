import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/theme/T.dart';

class PostHeroAttachmentBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final String image;
  final Function onTap;
  Size size;
  bool showStrip;

  PostHeroAttachmentBox({this.title, this.icon, this.image, this.onTap, this.showStrip = true, this.size = const Size(100, 100)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTap,
      child: Container(
        width: this.size.width,
        height: this.size.height,
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
            if (this.showStrip) Container(
              color: Color.fromRGBO(255, 255, 255, 0.6),
              width: double.infinity,
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
      ),
    );
  }
}
