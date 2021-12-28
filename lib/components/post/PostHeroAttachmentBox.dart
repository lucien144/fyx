import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:fyx/theme/skin/Skin.dart';

class PostHeroAttachmentBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? image;
  final VoidCallback? onTap;
  Size size;
  bool showStrip;

  PostHeroAttachmentBox({required this.title, required this.icon, this.image, this.onTap, this.showStrip = true, this.size = const Size(100, 100)});

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return GestureDetector(
      onTap: this.onTap,
      child: Container(
        width: this.size.width,
        height: this.size.height,
        decoration: BoxDecoration(
          image: this.image == null ? null : DecorationImage(image: NetworkImage(this.image!), fit: BoxFit.cover),
          color: colors.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Icon(
                icon,
                color: colors.lightColor.withOpacity(.85),
                size: 40,
              ),
            ),
            if (this.showStrip) Container(
              decoration: BoxDecoration(
                  color: colors.lightColor.withOpacity(.6),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                ),
                width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: colors.darkColor),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
