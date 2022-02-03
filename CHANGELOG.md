# Changelog

Tento soubor vychází z [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
verzování z [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.7.0] - 2021/07/12
### Nové
- První hybridní verze pro Android a iOS
- Tržiště #217 #201
- Oprava anket a přidání hlasování #149

### Změněno
- Skrýt floating button když nemám práva čtení #218
- Pod YT videem se zobrazují dva!! #180
- Nahradit nekonečno číslem #198
- Zredukovat zbytečný padding kolem příspěvku #215
- Možnost posílat HTML a zobrazování invalidního HTML #229
- LaunchIcons #178
- Upgrade některých knihoven #207

### Opraveno
- Reload neoznačuje nepřečtené -> přečtené #186
- Rozbitý syntax highlight #148
- Přestaly fungovat spoilery #200
- Chyba zobrazení příspěvku pokud v diskuzi žádné nejsou #212
- Chyba zobrazení příspěvku #165
- Chyba zobrazení příspěvku - jeden příspěvek zcela brání vyrenderovat diskuzi #214
- Prazdne auditko #122
- Zaporne hodnoty u neprectenych prispevku #194
- Prokliky na jiné diskuze z odpovědí #206
- Chybová hláška při vstupu do soukromé diskuze #208
- Nezobrazují se badges #174
- Pouze prispevky tohoto ID #211
- Dvakrát zobrazený příspěvek #209
- Cyklení zobrazení příspěvků #139
- Nezobrazení diskuze s velmi dlouhým příspěvkem #224
- Revize interních odkazů #226
- Ztráta contextu při otevření notifikace #227
- Chybý rebuild widget tree při pull 2 refresh #228
- Zlobí zobrazování náhledu v kompakt modu #169

## [0.6.1] - 2021/04/23

### Nové
- Nefungují prokliky notifikací #154

### Opraveno
- Nenačítají se avataři #155
- Pošta nezobrazuje odeslaný příspěvek #170
- Odeslaná pošta má prohozené odesiltele #171
- Obnovení home resetuje notifikace pošty #161
- Vykopnutí z diskuze při novém příspěvku, který se mi notifikuje #141
- Opravit odkaz na podmínky užívání #157

### Změněno
- Po probuzení bez připojení k internetu se zobrazí chyba místo přednačtených příspěvků #160
- Po uspání a probuzení aplikace může diskuze odskrolovat jinam #159
- Přehodit api z alpha na www #156
- Vrátit zpět BACKERS.md #158

## [0.6.0] - 2021/04/02

### Nové
- Napojení na nové API
- Možnost nahrání více obrázků najednou

### Opraveno
- Při kliku na zvoneček se vždy zobrazí chyba. #142
- Nefungují obrázky v poště #147

## [0.5.0] - 2021/02/02

### Nové
- Push notifikace #14
- Upozornění / notifikační centrum #6
- Syntax highlight - tag <code/> #8
- Zobrazování anket #38
- Možnost ukládat obrázky #127
- Nastavení > výchozí obrazovka > Ukládat poslední stav #91
- Kontextová nabídka uživatele (filtrovat v diskuzi, poslat zprávu, ...) #113
- Vylepšená práce s nahráváním fotek (fix performance, přidána kvalita, rozlišení, ...) #69
- UI feedback palečkování, uložení do připomínek... #118

### Opraveno
- Reload zanořené diskuze #97
- Přeskakující kursor #124
- Po nahrání obrázku se i při blikajícím kurzoru schová klávesnice #119
- Další drobné bugy

### Změněno
- Nová kudlanka #112
- Drobné UI fixy #116 #120

## [0.4.1] - 2020/11/09

### Nové
- Vypnout autocorrect (nově nastavitelné) #109

### Opraveno
- nelze otvirat odkazy #111
- nefunguje sharesheet pokud jsou u příspěvku pouze obrázky #110
- galerie - obrazek jde pres notch #82
- náhled YT vide je po rozkliknutí prázdný #100
- občas se nezobrazuje jméno v odpovedi #102
- crash: opětovné přidání fotky #107
- WYSIWYG parser odsazuje text #101 
- opravena implementace Sentry

### Změněno
- zvýrazněné stránkování a zavření v galerii

## [0.4.0] - 2020/10/08

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


## [0.3.0] - 2020/07/29

### Opraveno
- App resetovala nastavení výchozí obrazovky

## [0.3.0] - 2020/07/26

### Nové
- Přidat základní nastavení #59
- Nastavení hlavní obrazovky (historie / sledované)
- Vypnutí kompaktního zobrazení (+ odstranění z navigation baru)
- Přidání o aplikaci a další...
- Přidat indikátor načítání pull2refresh #58
- Kluby: filtrovat nepřečtené #61 #60
- Blokování uživatele, příspěvku, pošty #83
- Oznamování nevhodného obsahu #83
- Resetování vnitnří cache #83

### Změněno
- Lépe zvýraznit nepřečtené #15
- Upravit Kompaktní zobrazování příspěvků #62
- Upraven layout příspěvků kvůli #83

### Opraveno
- Resume nerefreshuje seznam klubu #57
- Chyba zobrazení příspěvku #53
- Nefungují základní textová default gesta #79
- Nefunguje galerie v normálním příspěvku #56 #62
- Nezobrazují se náhledy na linky #44
- Nefungují základní textová default gesta #79
