import 'package:flutter/material.dart';
import 'package:fyx/components/discussion_list_item_base.dart';

class DiscussionSearchListItem extends StatelessWidget {
  final int discussionId;
  final Widget child;
  const DiscussionSearchListItem({Key? key, required this.discussionId, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DiscussionListItemBase(discussionId: discussionId, child: child);
  }
}
