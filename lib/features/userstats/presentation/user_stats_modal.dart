import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/domain/entities/global_stat.dart';
import 'package:fyx/features/userstats/domain/enums/global_stat_type.dart';
import 'package:fyx/shared/services/service_locator.dart';

class UserStatsModal extends StatelessWidget {
  const UserStatsModal({super.key});

  /// Convert logical pixels to kilometers
  /// devicePixelRatio - from MediaQuery.devicePixelRatioOf
  double _pxToKm(int pixels, double devicePixelRatio) {
    // Approximate DPI (baseline 160 for Android mdpi)
    final dpi = 160 * devicePixelRatio;
    // 1 inch = 2.54 cm
    final pxPerCm = dpi / 2.54;
    final cm = pixels / pxPerCm;
    // cm to km
    return cm / 100000;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userstatsRepo.getGlobalStatsByYear(DateTime.now().year),
      builder: (_, data) {
        if (data.hasData && data.data != null) {
          var stats = data.data!;

          var km = _pxToKm(stats.valueOf(GlobalStatType.totalScrollPx), MediaQuery.devicePixelRatioOf(context));
          return ListView(shrinkWrap: true, padding: const EdgeInsets.only(left: 32, top: 32, right: 32, bottom: 48), children: [
            Text('Kilometráž: ${km * 1000 < 1 ? [(km * 1000).toStringAsFixed(4), 'm'].join() : [km.toStringAsFixed(2), 'km'].join()}'),
          ]);
        }

        return CupertinoActivityIndicator();
      },
    );
  }
}
