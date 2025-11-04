import 'package:flutter/material.dart';
import 'package:fyx/components/premium_feature_bottom_sheet.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/premium_feature_enum.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PremiumFeature extends StatelessWidget {
  const PremiumFeature({
    Key? key,
    required this.child,
    required this.feature,
    this.color,
  }) : super(key: key);

  final Widget child;
  final PremiumFeatureEnum feature;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Skin.of(context).theme.colors;

    if (MainRepository().credentials!.isPremiumUser) {
      return this.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showCupertinoModalBottomSheet(
          context: context,
          backgroundColor: colors?.barBackground,
          barrierColor: colors?.dark.withOpacity(0.5),
          builder: (BuildContext context) => PremiumFeatureBottomSheet(feature: feature)),
      child: Stack(
        children: [
          Opacity(
            child: this.child,
            opacity: 0.5,
          ),
          Positioned.fill(
              child: Container(
            child: Icon(MdiIcons.lock, color: this.color ?? colors.primary),
            color: Colors.transparent,
          ))
        ],
      ),
    );
  }
}
