import 'package:flutter/material.dart';
import 'package:fyx/components/post/PostHeroAttachment.dart';
import 'package:fyx/model/enums/AdEnums.dart';
import 'package:fyx/model/post/Image.dart' as i;
import 'package:fyx/model/post/content/Advertisement.dart';
import 'package:fyx/theme/T.dart';

class Advertisement extends StatelessWidget {
  final ContentAdvertisement content;
  final String title; // Ad title can be overwritten. Helpful in discussion page where content.fullName is null.

  const Advertisement(this.content, {this.title});

  @override
  Widget build(BuildContext context) {
    String heading = this.title ?? (content.fullName ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (heading.isNotEmpty) Flexible(child: Text(heading, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20, fontWeight: FontWeight.bold))),
            if (content.price > 0) Container(
              padding: const EdgeInsets.all(6),
                child: Text('${content.price.toString()} ${content.currency}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: T.COLOR_PRIMARY)),
                decoration: BoxDecoration(color: Color(0xffa9ccd3), borderRadius: BorderRadius.circular(6))
            ),
          ],
        ),
        SizedBox(
          height: 6,
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              child: Text(
                content.type == AdTypeEnum.offer ? 'Nabízím' : 'Hledám',
                style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12, color: Colors.white),
              ),
              decoration: BoxDecoration(color: content.type == AdTypeEnum.offer ? T.COLOR_SECONDARY : Color(0xff00B99D), borderRadius: BorderRadius.circular(6)),
            ),
            if (content.location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                      ),
                      Text(
                        content.location,
                        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  //decoration: BoxDecoration(color: T.COLOR_LIGHT, borderRadius: BorderRadius.circular(6), border: Border.all(color: T.COLOR_PRIMARY)),
                ),
              ),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        if (content.summary.isNotEmpty) Text(content.summary),
        if (content.photoIds.length > 0) Padding(
            padding: const EdgeInsets.only(top: 8.0),
          child: galleryWidget(context),
        )
      ],
    );
  }

  Widget galleryWidget(context) {
    List<i.Image> images = content.photoIds.map((String thumb) {
      String small = 'https://nyx.cz/$thumb';
      String large = small.replaceAllMapped(RegExp(r'(square)(\.[a-z]{3,4})$'), (match) =>'original${match[2]}');

      return i.Image(large, small);
    }).toList();
    return Wrap(children: images.map((image) => PostHeroAttachment(image, images: images)).toList(), spacing: 8, runSpacing: 8,);
  }
}
