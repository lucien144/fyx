import 'package:flutter/widgets.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:fyx/features/premium/presentation/viewmodel/premium_viewmodel.dart';
import 'package:fyx/features/userstats/presentation/viewmodel/year_in_review_viewmodel.dart';
import 'package:fyx/features/userstats/presentation/year_in_review_screen.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// Menu entry for the Year in Review. Renders nothing outside the January
/// Window or for users it is not offered to.
class YearInReviewMenuItem extends WatchingWidget {
  const YearInReviewMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = watchIt<PremiumViewModel>().state.isPremium;
    final viewModel = watchIt<YearInReviewViewModel>();
    final year = viewModel.state.windowYear;
    if (year == null || !viewModel.isOfferedTo(isPremium: isPremium)) return const SizedBox.shrink();

    final colors = Skin.of(context).theme.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => YearInReviewScreen.open(context, year: year, source: YearInReviewSource.menu),
      child: Column(
        children: [
          Icon(MdiIcons.partyPopper, size: 34, color: colors.grey),
          Text('Rok s Fyxem', style: TextStyle(fontSize: 11, color: colors.grey)),
        ],
      ),
    );
  }
}
