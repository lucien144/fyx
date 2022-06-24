import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class Avatar extends StatelessWidget {
  final String url;
  final bool isHighlighted;
  final double size;

  Avatar(this.url, {this.size = 32.0, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    final SkinColors colors = Skin.of(context).theme.colors;
    final width = size;
    final height = width * (50 / 40);

    return SizedBox(
      width: width,
      height: height,
      child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: isHighlighted ? colors.highlight : Colors.transparent),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => CupertinoActivityIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: width,
              height: height,
            ),
          )),
    );
  }
}
