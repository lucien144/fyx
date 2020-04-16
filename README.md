> 🇨🇿 This repository is managed in czech language although the source code along with comments is written in english.

# Fyx

[![Build Status](https://travis-ci.com/lucien144/fyx.svg?branch=develop)](https://travis-ci.com/lucien144/fyx) [![Coverage Status](https://coveralls.io/repos/github/lucien144/fyx/badge.svg?branch=develop)](https://coveralls.io/github/lucien144/fyx?branch=develop)

Fyx je neoficiální mobilní klient pro diskuzní server [Nyx.cz](https://nyx.cz) ve [Flutteru](https://flutter.dev/). V tuto chvíli je psaný a optimalizovaný pro iOS, ale v plánu je i Android verze.

## Funkce
- Tutoriál k autorizaci
- Kluby
  - Historie (+ zobrazení prémiových ikon: odkazy, obrázky)
  - Sledované
  - Palcování
  - Uložení do připomínek
  - Skrytí spoilerů
  - Galerie obrázků pokud jich je v příspěvku více
  - Experimentální layout příspěvků
  - In-app browser
  - Psaní příspěvků (+ odesílání obrázků)
- Pošta
  - Odesílání
  - Přečteno / Nepřečteno
  - Badge nepřečtených

## Roadmap

- v0.3: první veřejný release
  - Login
  - Příspěvky: zobrazení (galerie, odkazy, ...), psaní, palcování, připomínky
  - Kluby: historie, sledované
  - Pošta: psaní, připomínky
- v0.4:
  - Notifikace
- v0.5
  - Hledání: pošta, kluby a příspěvky
- v0.6
  - Kluby: nástěnka, přidání/odebrání ze sledovaných
  - Mazání: pošty, příspěvků
- v0.7
  - Přehled
  - Upozornění (~ notices)
- v0.8
  - Pošta: konverzace
- v0.8
  - Marketplace
v0.9
  - Lidé, přátelé
  - Události

### Priority mimo roadmapu

*Toto se pravděpodobně přidá prioritně někam do roadmapy, záleží na diskuzi.*

1. Android verze s hybridnínm designem
1. Darkmode

## Jak se zapojit
Jakákoli pomoc - od každého - vítána! Nejrychleji se zapojíte přes [klub na Nyxu](https://www.nyx.cz/index.php?l=topic;id=24237;n=23dd), který se o vývojem nového klienta zabývá.
Také si můžete projít [Issues](https://github.com/lucien144/fyx/issues) případně [Projects](https://github.com/lucien144/fyx/projects) a poslat pull request.

### Gitflow
Tento repozitář používá [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow). Připravujte veškerou práci ve `feature` větvích nebo forku, pak pošlete PR do `develop` větve. PR jsou mergovány pouze adminy (a jako `squash commits`).

## Hlášení chyb
Pokud jste našli chybu, pak ji nahlaste ideálně přes aplikaci. Pokud to nejde, pak přes [Issues](https://github.com/lucien144/fyx/issues) - nezapomeňte uvést verzi aplikace a popsat chybu.

## FAQ

- **Q:** Proč není podporovaný i Android?

  **A:** Protože je to moc práce a iOS je pro mě (Lucien) nativní prostředí. Aplikace má v sobě fragmenty přípravy pro Android (viz. [`PlatformAwareWidget`](https://github.com/lucien144/fyx/blob/develop/lib/PlatformAwareWidget.dart)), ale později jsem se rozhodl jít pro mě lehčí cestou, vydat první verzi asap a Android případně řešit s grafiky, kteří by připravili hodnotný hybridní design funkční jak na Androidu tak i na iOS.

- **Q:** Kde je uživatelský profil a nastavení?

  **A:** Cílem bylo vytvořit jednoduchou a malou aplikaci - proto (v tuto chvíli) není v aplikaci např. hamburger menu, uživatelský profil nebo nastavení. Předpokladem je, že toto se časem změní - záleží na uživatelské diskuzi.

- **Q:** Proč je tento repozitář v češtině?

  **A:** Vzhledem k tomu, že [klub na Nyxu](https://www.nyx.cz/index.php?l=topic;id=24237;n=23dd) věnující se novému klientovi vznikl v češtině, rozhodl jsem se (Lucien) vést tento repozitář také v češtině. Naproti tomu kód a komentáře v kódu jsou v angličtině, protože to je pro mě přiřozené. Dále by měly [Issues](https://github.com/lucien144/fyx/issues) sloužit jako centrální hub pro vedení veškerých chyb a připomínek, což se mi zdá opět lepší vést v češtině pro běžné uživatele. Nicméně, změně na kompletně anglické repo se po diskuzi nebráním...

## Náhled

![](sources/preview.gif)