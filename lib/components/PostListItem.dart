import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/ListItemWithCategory.dart';
import 'package:fyx/model/Post.dart';

class PostListItem extends ListItemWithCategory {
  final Post post;

  PostListItem(this.post);

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
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    post.avatar,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Text(post.nick)
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Html(
                    data: post.content,
                  ),
                ),
                Visibility(
                  visible: post.images.length == 1,
                  child: Image.network(
                    post.images.length > 0 ? post.images[0]['thumb'] : '',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
          ),
          Text(post.content),
          Text(post.images.length > 0 ? post.images[0]['image'] : ''),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  @override
  int get category => null;
}
