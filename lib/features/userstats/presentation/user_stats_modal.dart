import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/features/userstats/domain/entities/daily_usage.dart';
import 'package:fyx/features/userstats/domain/entities/global_stat.dart';
import 'package:fyx/features/userstats/domain/entities/hourly_usage.dart';
import 'package:fyx/features/userstats/domain/enums/global_stat_type.dart';
import 'package:fyx/model/Discussion.dart';
import 'package:fyx/shared/services/service_locator.dart';

import '../domain/entities/discussion_visit.dart';

class UserStatsModal extends StatelessWidget {
  const UserStatsModal({super.key});

  static const _weekdayNames = {
    1: 'Pondělí',
    2: 'Úterý',
    3: 'Středa',
    4: 'Čtvrtek',
    5: 'Pátek',
    6: 'Sobota',
    7: 'Neděle',
  };

  static const _monthNames = {
    1: 'Leden',
    2: 'Únor',
    3: 'Březen',
    4: 'Duben',
    5: 'Květen',
    6: 'Červen',
    7: 'Červenec',
    8: 'Srpen',
    9: 'Září',
    10: 'Říjen',
    11: 'Listopad',
    12: 'Prosinec',
  };

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
    var year = DateTime.now().year;

    return FutureBuilder(
      future: Future.wait([
        userstatsRepo.getGlobalStatsByYear(year),
        userstatsRepo.getDiscussionVisitsByYear(year),
        userstatsRepo.getDailyUsageByYear(year),
        userstatsRepo.getHourlyUsageByYear(year),
      ]),
      builder: (_, data) {
        if (data.hasData && data.data != null) {
          List<GlobalStat> globalStats = data.data![0] as List<GlobalStat>;
          List<DiscussionVisit> discussionVisits = data.data![1] as List<DiscussionVisit>;
          List<DailyUsage> dailyUsage = data.data![2] as List<DailyUsage>;
          List<HourlyUsage> hourlyUsage = data.data![3] as List<HourlyUsage>;
          var km = _pxToKm(globalStats.valueOf(GlobalStatType.totalScrollPx), MediaQuery.devicePixelRatioOf(context));

          final peakHour = hourlyUsage.peakHour;
          final peakWeekday = dailyUsage.peakWeekday;
          final peakMonth = dailyUsage.peakMonth;

          return ListView(shrinkWrap: true, padding: const EdgeInsets.only(left: 32, top: 32, right: 32, bottom: 48), children: [
            Text('Doomscrolling: ${km < 1 ? [(km * 1000).toStringAsFixed(4), 'm'].join() : [km.toStringAsFixed(4), 'km'].join()}'),
            Text('Spuštění aplikace: ${globalStats.valueOf(GlobalStatType.appLaunches)}'),
            Text('Otevření galerie: ${globalStats.valueOf(GlobalStatType.galleryOpens)}'),
            const SizedBox(height: 8),
            Text('Lajků: ${globalStats.valueOf(GlobalStatType.likes)}'),
            Text('Disslajků: ${globalStats.valueOf(GlobalStatType.dislikes)}'),
            const SizedBox(height: 8),
            Text('Přispěvky - nové: ${globalStats.valueOf(GlobalStatType.postsCreated)}'),
            Text('Přispěvky - odpovědi: ${globalStats.valueOf(GlobalStatType.postReplies)}'),
            Text('Přispěvky - příloh: ${globalStats.valueOf(GlobalStatType.postAttachments)}'),
            Text('Přispěvky - délka: ${globalStats.valueOf(GlobalStatType.postsLength)}'),
            const SizedBox(height: 8),
            Text('Pošta - nové: ${globalStats.valueOf(GlobalStatType.mailsCreated)}'),
            Text('Pošta - příloh: ${globalStats.valueOf(GlobalStatType.mailAttachments)}'),
            Text('Pošta - délka: ${globalStats.valueOf(GlobalStatType.mailsLength)}'),
            const SizedBox(height: 8),
            Text('Longest streak: ${dailyUsage.longestStreak}'),
            Text('Current streak: ${dailyUsage.currentStreak}'),
            const SizedBox(height: 8),
            if (peakHour >= 0) Text('Nejaktivnější hodina: $peakHour:00'),
            if (peakWeekday >= 0) Text('Nejaktivnější den: ${_weekdayNames[peakWeekday]}'),
            if (peakMonth >= 0) Text('Nejaktivnější měsíc: ${_monthNames[peakMonth]}'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 10 diskuzí',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...discussionVisits
                    .map(
                      (dv) => Row(
                        children: [
                          Text(' - '),
                          Expanded(child: Text(dv.discussionName, overflow: TextOverflow.ellipsis)),
                          Text(dv.visits.toString()),
                        ],
                      ),
                    )
                    .toList()
              ],
            )
          ]);
        }

        return CupertinoActivityIndicator();
      },
    );
  }
}
