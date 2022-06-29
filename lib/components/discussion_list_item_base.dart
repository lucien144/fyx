import 'package:flutter/material.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class DiscussionListItemBase extends StatelessWidget {
  final int discussionId;
  final Widget child;

  const DiscussionListItemBase({Key? key, required this.discussionId, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: DiscussionPageArguments(this.discussionId)),
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.grey.withOpacity(.12)))),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: child,
      ),
    );
  }
}
