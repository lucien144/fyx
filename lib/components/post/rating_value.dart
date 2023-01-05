import 'package:flutter/material.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class RatingValue extends StatelessWidget {
  final int? rating;
  final double fontSize;

  const RatingValue(this.rating, {this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    Color color = colors.text.withOpacity(0.2);
    if (rating != null) {
      if (rating! > 0) {
        color = colors.success.withOpacity(Helpers.ratingRange(rating!));
      } else if (rating! < 0) {
        color = colors.danger.withOpacity(Helpers.ratingRange(rating!.abs()));
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2)),
      child: Text(rating == null ? ' 0 ' : Post.formatRating(rating!), style: TextStyle(fontSize: fontSize)),
    );
  }
}
