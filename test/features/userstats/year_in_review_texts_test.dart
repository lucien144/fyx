import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/domain/enums/scroll_landmark.dart';
import 'package:fyx/features/userstats/domain/enums/writing_volume.dart';
import 'package:fyx/features/userstats/domain/enums/year_in_review_character.dart';
import 'package:fyx/features/userstats/domain/enums/year_in_review_rhythm.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';

const _s = YearInReviewTexts.nbsp;

TimeSlide _time(int seconds) => YearInReviewSlide.time(seconds: seconds, appLaunches: 0, galleryOpens: 0) as TimeSlide;

DoomscrollSlide _doom(double meters) {
  final landmark = ScrollLandmark.fromMeters(meters);
  return YearInReviewSlide.doomscroll(
    meters: meters,
    landmark: landmark,
    landmarkCount: landmark.countIn(meters),
    healthPercent: 50,
    appLaunches: 0,
    galleryOpens: 0,
  ) as DoomscrollSlide;
}

WritingSlide _writing(int characters) {
  return YearInReviewSlide.writing(
    characters: characters,
    volume: WritingVolume.fromCharacters(characters),
    posts: 0,
    replies: 0,
    attachments: 0,
    mails: 0,
  ) as WritingSlide;
}

void main() {
  test('thousands are separated by a non-breaking space', () {
    expect(YearInReviewTexts.number(0), '0');
    expect(YearInReviewTexts.number(999), '999');
    expect(YearInReviewTexts.number(8635), '8${_s}635');
    expect(YearInReviewTexts.number(1234567), '1${_s}234${_s}567');
  });

  test('duration and distance', () {
    expect(YearInReviewTexts.duration(34 * 3600 + 53 * 60), '34h 53m');
    expect(YearInReviewTexts.duration(53 * 60), '53m');
    expect(YearInReviewTexts.distance(653.4), '653${_s}m');
    expect(YearInReviewTexts.distance(1234), '1,2${_s}km');
    expect(YearInReviewTexts.distance(12000), '12${_s}km');
  });

  test('day plurals', () {
    expect(YearInReviewTexts.days(1), '1${_s}den');
    expect(YearInReviewTexts.days(3), '3${_s}dny');
    expect(YearInReviewTexts.days(5), '5${_s}dní');
    expect(YearInReviewTexts.days(239), '239${_s}dní');
    expect(YearInReviewTexts.streakUnit(1), 'den v řadě');
  });

  test('time comparison', () {
    expect(YearInReviewTexts.timeComparison(_time(600)), 'To je míň než jeden celovečerní film.');
    expect(YearInReviewTexts.timeComparison(_time(90 * 60)), 'To je 1${_s}celovečerní film v kuse.');
    expect(YearInReviewTexts.timeComparison(_time(3 * 90 * 60)), 'To je 3${_s}celovečerní filmy v kuse.');
    expect(
      YearInReviewTexts.timeComparison(_time(34 * 3600 + 53 * 60)),
      'To je *1,5${_s}dne* v kuse. Nebo 23${_s}celovečerních filmů.',
    );
    expect(YearInReviewTexts.timeComparison(_time(48 * 3600)), 'To je *2${_s}dny* v kuse. Nebo 32${_s}celovečerních filmů.');
  });

  test('doomscroll sentence', () {
    expect(
      YearInReviewTexts.doomSentence(_doom(653)),
      'Tvůj palec scrolloval přes 653${_s}m feedu. To je *10${_s}Petřínských rozhleden* čistého pekla.',
    );
    expect(YearInReviewTexts.doomSentence(_doom(40)), endsWith('Zatím ani jedna Petřínská rozhledna.'));
    expect(YearInReviewTexts.doomSentence(_doom(70)), contains('*1${_s}Petřínská rozhledna*'));
    expect(YearInReviewTexts.doomSentence(_doom(2600)), contains('*12${_s}Žižkovských věží*'));
    expect(YearInReviewTexts.doomSentence(_doom(27000)), contains('*3${_s}Mount Everesty*'));
    expect(YearInReviewTexts.secretGalleries(1331), '> NALEZENO 1${_s}331 TAJNÝCH GALERIÍ');
    expect(YearInReviewTexts.secretGalleries(1), '> NALEZENA 1 TAJNÁ GALERIE');
  });

  test('writing sentence', () {
    expect(YearInReviewTexts.writingSentence(_writing(100)), 'Ani jedna normostrana. Méně je někdy více.');
    expect(
      YearInReviewTexts.writingSentence(_writing(8635)),
      'Zhruba 5${_s}normostran. Krátká povídka, rozepsaná po diskuzích.',
    );
    expect(YearInReviewTexts.writingSentence(_writing(2 * 1800)), startsWith('Zhruba 2${_s}normostrany.'));
    expect(YearInReviewTexts.writingSentence(_writing(200 * 1800)), endsWith('Tohle už je román.'));
    expect(YearInReviewTexts.charactersUnit(8635), 'znaků');
  });

  test('ratings sentence drops the percentage when nothing was rated', () {
    final rated = YearInReviewSlide.ratings(likes: 206, dislikes: 2, character: YearInReviewCharacter.forrestGump);
    final silent = YearInReviewSlide.ratings(likes: 0, dislikes: 0, character: YearInReviewCharacter.silentBob);

    expect(YearInReviewTexts.ratingsSentence(rated as RatingsSlide), startsWith('99$_s% pozitivity. Život je jako'));
    expect(YearInReviewTexts.ratingsSentence(silent as RatingsSlide), 'Všechno vidíš, nic neřekneš.');
  });

  test('record hint', () {
    final behind = YearInReviewSlide.streak(longest: 239, current: 190, litDots: 39) as StreakSlide;
    final leading = YearInReviewSlide.streak(longest: 12, current: 12, litDots: 5) as StreakSlide;

    expect(YearInReviewTexts.recordHint(behind), 'Ještě 50${_s}dní\na máš rekord');
    expect(YearInReviewTexts.recordHint(leading), 'Právě trháš\nrekord');
  });

  test('headlines', () {
    expect(YearInReviewTexts.rhythmHeadline(YearInReviewRhythm.earlyBird), 'Ranní\nptáče.');
    expect(YearInReviewTexts.rhythmHeadline(YearInReviewRhythm.craftsman), 'Fachman.');
    expect(
      YearInReviewTexts.summaryHeadline(YearInReviewRhythm.barfly, YearInReviewCharacter.darthVader),
      'Barový povaleč\ns duší Dartha Vadera',
    );
    expect(YearInReviewTexts.summaryHeadline(null, YearInReviewCharacter.silentBob), 'Tichý Bob');
  });

  test('counted-from date', () {
    expect(YearInReviewTexts.countedFromLong(DateTime(2026, 3, 14)), 'Počítáno od 14.${_s}března 2026.');
    expect(YearInReviewTexts.countedFromShort(DateTime(2026, 3, 14)), 'od 14.${_s}3.');
  });
}
