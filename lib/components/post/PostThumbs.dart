import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/Avatar.dart';
import 'package:fyx/model/post/PostThumbItem.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class PostThumbs extends StatelessWidget {
  final List<PostThumbItem> items;
  final isNegative;

  PostThumbs(this.items, {this.isNegative = false});

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    var avatars = items
        .map((item) => Tooltip(
              message: item.username,
              waitDuration: Duration(milliseconds: 0),
              child: Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 0),
                child: Avatar(
                  Helpers.avatarUrl(item.username),
                  size: 22,
                  isHighlighted: item.isHighlighted,
                ),
              ),
            ))
        .toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0, right: 5),
          child: Icon(
            isNegative ? Icons.thumb_down : Icons.thumb_up,
            size: 18,
            color: isNegative ? colors.danger : colors.success,
          ),
        ),
        Text(
          items.length.toString(),
          style: TextStyle(fontSize: 14),
        ),
        Expanded(
          child: Wrap(children: avatars),
        )
      ],
    );
  }
}
