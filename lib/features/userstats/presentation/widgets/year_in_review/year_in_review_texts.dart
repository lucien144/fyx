import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/domain/enums/scroll_landmark.dart';
import 'package:fyx/features/userstats/domain/enums/writing_volume.dart';
import 'package:fyx/features/userstats/domain/enums/year_in_review_character.dart';
import 'package:fyx/features/userstats/domain/enums/year_in_review_rhythm.dart';
import 'package:intl/intl.dart';

/// Czech wording of the Year in Review. Text wrapped in `*asterisks*` is
/// rendered bold. Numbers and units are joined with non-breaking spaces.
abstract final class YearInReviewTexts {
  static const _locale = 'cs_CZ';
  static const nbsp = ' ';

  static const weekdays = ['Pondělí', 'Úterý', 'Středa', 'Čtvrtek', 'Pátek', 'Sobota', 'Neděle'];
  static const weekdaysShort = ['Po', 'Út', 'St', 'Čt', 'Pá', 'So', 'Ne'];
  static const months = [
    'Leden', 'Únor', 'Březen', 'Duben', 'Květen', 'Červen', //
    'Červenec', 'Srpen', 'Září', 'Říjen', 'Listopad', 'Prosinec',
  ];
  static const monthsShort = ['L', 'Ú', 'B', 'D', 'K', 'Č', 'Č', 'S', 'Z', 'Ř', 'L', 'P'];
  static const _monthsGenitive = [
    'ledna', 'února', 'března', 'dubna', 'května', 'června', //
    'července', 'srpna', 'září', 'října', 'listopadu', 'prosince',
  ];

  static String _plural(int n, {required String one, required String few, required String other}) {
    return Intl.plural(n, one: one, few: few, other: other, locale: _locale);
  }

  /// 8635 → "8 635" (non-breaking space as the thousands separator).
  static String number(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(nbsp);
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// One decimal place with a decimal comma; whole numbers stay whole.
  static String decimal(double value) {
    final tenths = (value * 10).round();
    return tenths % 10 == 0 ? number(tenths ~/ 10) : '${number(tenths ~/ 10)},${tenths % 10}';
  }

  static String header(int year) => 'FYX $year';

  static const disclaimer =
      'Všechna data jsou držená lokálně. Nic se nikam neposílá. Při smazání aplikace se smažou i statistiky.\nOvěřit lze ve zdrojácích na Githubu.';

  static String countedFromLong(DateTime day) => 'Počítáno od ${day.day}.$nbsp${_monthsGenitive[day.month - 1]} ${day.year}.';

  static String countedFromShort(DateTime day) => 'od ${day.day}.$nbsp${day.month}.';

  // ---- Time ----

  static ({int hours, int minutes}) hoursAndMinutes(int seconds) => (hours: seconds ~/ 3600, minutes: (seconds % 3600) ~/ 60);

  static String duration(int seconds) {
    final time = hoursAndMinutes(seconds);
    return time.hours > 0 ? '${number(time.hours)}h ${time.minutes}m' : '${time.minutes}m';
  }

  static String _films(int n) {
    return '${number(n)}$nbsp${_plural(n, one: 'celovečerní film', few: 'celovečerní filmy', other: 'celovečerních filmů')}';
  }

  static String timeComparison(TimeSlide slide) {
    if (slide.films < 1) return 'To je míň než jeden celovečerní film.';
    if (slide.days < 1) return 'To je ${_films(slide.films)} v kuse.';

    final tenths = (slide.days * 10).round();
    // A fractional count takes the genitive singular ("1,5 dne").
    final unit = tenths % 10 == 0 ? _plural(tenths ~/ 10, one: 'den', few: 'dny', other: 'dní') : 'dne';
    return 'To je *${decimal(slide.days)}$nbsp$unit* v kuse. Nebo ${_films(slide.films)}.';
  }

  // ---- Doomscroll ----

  static ({String value, String unit}) distanceParts(double meters) {
    if (meters < 1000) return (value: number(meters.round()), unit: 'm');
    return (value: decimal(meters / 1000), unit: 'km');
  }

  static String distance(double meters) {
    final parts = distanceParts(meters);
    return '${parts.value}$nbsp${parts.unit}';
  }

  static String landmarks(ScrollLandmark landmark, int count) {
    final name = switch (landmark) {
      ScrollLandmark.petrin =>
        _plural(count, one: 'Petřínská rozhledna', few: 'Petřínské rozhledny', other: 'Petřínských rozhleden'),
      ScrollLandmark.zizkov => _plural(count, one: 'Žižkovská věž', few: 'Žižkovské věže', other: 'Žižkovských věží'),
      ScrollLandmark.everest => _plural(count, one: 'Mount Everest', few: 'Mount Everesty', other: 'Mount Everestů'),
    };
    return '${number(count)}$nbsp$name';
  }

  static String doomSentence(DoomscrollSlide slide) {
    final lead = 'Tvůj palec scrolloval přes ${distance(slide.meters)} feedu.';
    if (slide.landmarkCount < 1) return '$lead Zatím ani jedna Petřínská rozhledna.';
    return '$lead To je *${landmarks(slide.landmark, slide.landmarkCount)}* čistého pekla.';
  }

  static String secretGalleries(int count) {
    final n = number(count);
    return '> ${_plural(count, one: 'NALEZENA $n TAJNÁ GALERIE', few: 'NALEZENY $n TAJNÉ GALERIE', other: 'NALEZENO $n TAJNÝCH GALERIÍ')}';
  }

  // ---- Writing ----

  static String charactersUnit(int count) => _plural(count, one: 'znak', few: 'znaky', other: 'znaků');

  static String writingSentence(WritingSlide slide) {
    final pages = WritingVolume.pagesOf(slide.characters);
    final lead = 'Zhruba ${number(pages)}$nbsp${_plural(pages, one: 'normostrana', few: 'normostrany', other: 'normostran')}.';
    return switch (slide.volume) {
      WritingVolume.none => 'Ani jedna normostrana. Méně je někdy více.',
      WritingVolume.shortStory => '$lead Krátká povídka, rozepsaná po diskuzích.',
      WritingVolume.novella => '$lead Slušná novela, rozepsaná po diskuzích.',
      WritingVolume.novel => '$lead Tohle už je román.',
    };
  }

  // ---- Ratings ----

  static String characterSentence(YearInReviewCharacter character) {
    return switch (character) {
      YearInReviewCharacter.forrestGump => 'Život je jako bonboniéra a ty rozdáváš jen sladké.',
      YearInReviewCharacter.gandalf => 'Většinou laskavý čaroděj. Ale občas někomu řekneš: Neprojdeš!',
      YearInReviewCharacter.shrek => 'Navenek zlobr, ale paleček ti občas ujede.',
      YearInReviewCharacter.darthVader => 'Tvůj nedostatek palečků mě znepokojuje.',
      YearInReviewCharacter.silentBob => 'Všechno vidíš, nic neřekneš.',
    };
  }

  static String ratingsSentence(RatingsSlide slide) {
    final percent = slide.positivePercent;
    final sentence = characterSentence(slide.character);
    return percent == null ? sentence : '$percent$nbsp% pozitivity. $sentence';
  }

  // ---- Streak ----

  static String days(int count) => '${number(count)}$nbsp${_plural(count, one: 'den', few: 'dny', other: 'dní')}';

  static String streakUnit(int count) => '${_plural(count, one: 'den', few: 'dny', other: 'dní')} v řadě';

  static String recordHint(StreakSlide slide) {
    return slide.isRecordRunning ? 'Právě trháš\nrekord' : 'Ještě ${days(slide.daysToRecord)}\na máš rekord';
  }

  // ---- Rhythm ----

  static String rhythmName(YearInReviewRhythm rhythm) {
    return switch (rhythm) {
      YearInReviewRhythm.earlyBird => 'Ranní ptáče',
      YearInReviewRhythm.craftsman => 'Fachman',
      YearInReviewRhythm.barfly => 'Barový povaleč',
      YearInReviewRhythm.nightBird => 'Noční pták',
    };
  }

  /// The name broken into lines for the big headline.
  static String rhythmHeadline(YearInReviewRhythm rhythm) => '${rhythmName(rhythm).replaceFirst(' ', '\n')}.';

  static String hour(int hour) => '$hour:00';

  // ---- Top discussions ----

  static String topSentence(int visits) => 'Ta první tě viděla *${number(visits)}×*. Tam je tvůj druhý domov.';

  // ---- Summary ----

  static String characterName(YearInReviewCharacter character) {
    return switch (character) {
      YearInReviewCharacter.forrestGump => 'Forrest Gump',
      YearInReviewCharacter.gandalf => 'Gandalf',
      YearInReviewCharacter.shrek => 'Shrek',
      YearInReviewCharacter.darthVader => 'Darth Vader',
      YearInReviewCharacter.silentBob => 'Tichý Bob',
    };
  }

  static String _characterGenitive(YearInReviewCharacter character) {
    return switch (character) {
      YearInReviewCharacter.forrestGump => 'Forresta Gumpa',
      YearInReviewCharacter.gandalf => 'Gandalfa',
      YearInReviewCharacter.shrek => 'Shreka',
      YearInReviewCharacter.darthVader => 'Dartha Vadera',
      YearInReviewCharacter.silentBob => 'Tichého Boba',
    };
  }

  static String summaryHeadline(YearInReviewRhythm? rhythm, YearInReviewCharacter character) {
    if (rhythm == null) return characterName(character);
    return '${rhythmName(rhythm)}\ns duší ${_characterGenitive(character)}';
  }
}
