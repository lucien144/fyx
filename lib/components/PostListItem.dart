import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/PlatformThemeData.dart';
import 'package:fyx/components/ListItemWithCategory.dart';
import 'package:fyx/model/Post.dart';
import 'package:html/dom.dart' as dom;

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
                      useRichText: false,
                      customRender: (dom.Node node, List<Widget> children) {
                        if (node is dom.Element) {
                          switch (node.localName) {
                            case 'a':
                              print(node);
                              print(node.attributes.containsKey('data-link-topic'));
                              print(node.attributes['data-link-topic']);
                              print(node.attributes['data-link-wu']);
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(node.innerHtml),
                                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
                              );
                          }
                        }
                        return null;
                      }),
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
