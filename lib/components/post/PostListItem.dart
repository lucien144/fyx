import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/ListItemWithCategory.dart';
import 'package:fyx/components/post/PostAvatar.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/components/post/PostHtml.dart';
import 'package:fyx/model/Post.dart';

enum LAYOUT_TYPES { textOnly, oneImageOnly, attachmentsAndText }
typedef Widget TLayout();

class PostListItem extends ListItemWithCategory {
  final Post post;
  Map<LAYOUT_TYPES, TLayout> _layoutMap = {};

  PostListItem(this.post) {
    // The order here is important!
    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.textOnly,
        () => () {
              if (this.post.content.isNotEmpty && this.post.attachments.isEmpty) {
                return PostHtml(this.post);
              }
              return null;
            });

    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.oneImageOnly,
        () => () {
              if (!(this.post.content.isEmpty && this.post.attachments.length == 1 && this.post.images.length == 1)) {
                return null;
              }

              return CachedNetworkImage(
                alignment: Alignment.topLeft,
                imageUrl: this.post.images[0].thumb,
                placeholder: (context, url) => CupertinoActivityIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              );
            });

    _layoutMap.putIfAbsent(
        LAYOUT_TYPES.attachmentsAndText,
        () => () {
              if (!(this.post.attachments.length > 1 && this.post.content.isNotEmpty)) {
                return null;
              }
              return Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[Expanded(child: PostHtml(post)), PostHeroAttachment(post.attachmentsWithFeatured['featured'])],
                  )
                ],
              );
            });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Divider(
            thickness: 8,
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16),
            child: PostAvatar(post.avatar, post.nick),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: getContentWidget(context),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.red),
            child: Text('A: ${post.attachments.length} / '
                'I: ${post.images.length} / '
                'L: ${post.links.length} / '
                'V: ${post.videos.length} / '
                'T: ${post.content.length}'),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(post.content),
          )
        ],
      ),
    );
  }

  Widget getContentWidget(BuildContext context) {
    for (final layout in LAYOUT_TYPES.values) {
      var result = _layoutMap[layout]();
      if (result != null) {
        return result;
      }
    }

    // TODO: Doplnit text.
    return Column(children: <Widget>[
      Icon(Icons.warning),
      Text(
        'Nastal problém se zobrazením příspěvku.\n Vyplňte prosím github issues.',
        textAlign: TextAlign.center,
      )
    ]);
  }

  @override
  int get category => null;
}
