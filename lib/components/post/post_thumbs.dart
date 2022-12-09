import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/avatar.dart';
import 'package:fyx/model/post/PostThumbItem.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostThumbs extends StatelessWidget {
  final List<PostThumbItem> items;
  final isNegative;

  PostThumbs(this.items, {this.isNegative = false});

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    var avatars = items
        .map((item) => Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 0),
              child: Column(
                children: [
                  Avatar(
                    Helpers.avatarUrl(item.username),
                    size: 62,
                    isHighlighted: item.isHighlighted,
                  ),
                  Text(item.username, style: TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                ],
              ),
            ))
        .toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isNegative ? Icons.thumb_down : Icons.thumb_up,
              size: 32,
              color: isNegative ? colors.danger : colors.success,
            ),
            SizedBox(width: 4),
            Text(
              items.length.toString(),
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        SizedBox(height: 8),
        GridView.count(
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 2 / 3,
            crossAxisCount: 6,
            shrinkWrap: true,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            children: avatars),
      ],
    );
  }
}
