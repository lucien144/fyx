import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/theme/T.dart';

class CircleAvatar extends StatelessWidget {
  final String url;
  final bool _isHighlighted;
  final double _size;

  CircleAvatar(this.url, {bool isHighlighted = false, double size = 40.0})
      : _isHighlighted = isHighlighted,
        _size = size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: _isHighlighted ? T.COLOR_PRIMARY : Colors.black),
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: _isHighlighted ? T.COLOR_PRIMARY : Colors.white),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, url) => CupertinoActivityIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            width: _size,
            height: _size,
          ),
        ),
      ),
    );
  }
}
