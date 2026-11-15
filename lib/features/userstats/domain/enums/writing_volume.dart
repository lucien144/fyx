/// How much the user wrote in a year, measured in standard pages.
enum WritingVolume {
  none,
  shortStory,
  novella,
  novel;

  /// A Czech standard page ("normostrana").
  static const charactersPerPage = 1800;

  static WritingVolume fromCharacters(int characters) {
    final pages = characters / charactersPerPage;
    if (pages < 1) return none;
    if (pages < 20) return shortStory;
    if (pages < 100) return novella;
    return novel;
  }

  static int pagesOf(int characters) => (characters / charactersPerPage).round();
}
