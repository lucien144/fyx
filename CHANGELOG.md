# Changelog

Tento soubor vychází z [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
verzování z [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Nevydáno]

## [0.4.0]

### Nové
- Nefunguje toggle kategorie v pull2refresh listu #98 
- Odpovědi na vlastní příspěvky jsou vždy na seznamu sledovaných nahoře.
- Zobrazovat odpovědi na vrchu listu #87
- Kopírování textu / Sdílení odkazu příspěvku #55 
- Crashlytics & Analytics #89

### Změněno
- Flutter upgrade: v1.17 -> 1.20 #77
- Flutter upgrade: v1.20 -> 1.22.0-12.3.pre #104 
- Aktualizace knihoven #78
- Prazdny klub zobrazuje “nacist znovu...” #17

### Opraveno
- Focus pri psani zpravy #93
- Video je deformovane ve fullscreen modu #85
- Některé názvy klubů se ořezávají... #47
- Reset badge u pošty #46
- Pull 2 Refresh: nefunguje pokud je list kratsi nez screen #81
- Interní odkazy #39
- Nefunguji dalsi interni prokliky #88
- Vstup do zakazanyho auditka vtaci error #16
- Návštěva klubu poprvé vrací error #31
- photo_view@0.9.2 - nefunguje správně zavírání a swipe #105
- Zavření náhledu obrázku klikem mimo obrázek #42

## [0.3.0 RC1] - 2020-06-22

### Nové

- Přidat základní nastavení [#59](https://github.com/lucien144/fyx/issues/59)
  - Nastavení hlavní obrazovky (historie / sledované)
  - Vypnutí kompaktního zobrazení (+ odstranění z navigation baru)
  - Přidání o aplikaci a další...
- Přidat indikátor načítání pull2refresh [#58](https://github.com/lucien144/fyx/issues/58)
- Kluby: filtrovat nepřečtené [#61](https://github.com/lucien144/fyx/issues/) [#60](https://github.com/lucien144/fyx/issues/61)

### Změněno

- Lépe zvýraznit nepřečtené [#15](https://github.com/lucien144/fyx/issues/60)
- Upravit Kompaktní zobrazování příspěvků [#62](https://github.com/lucien144/fyx/issues/15)

### Opraveno

- Resume nerefreshuje seznam klubu [#57](https://github.com/lucien144/fyx/issues/62)
- Chyba zobrazení příspěvku [#53](https://github.com/lucien144/fyx/issues/57)
- Nefungují základní textová default gesta [#79](https://github.com/lucien144/fyx/issues/53)
- Nefunguje galerie v normálním příspěvku [#56](https://github.com/lucien144/fyx/issues/) [#62](https://github.com/lucien144/fyx/issues/79)
- Nezobrazují se náhledy na linky [#44](https://github.com/lucien144/fyx/issues/56)
