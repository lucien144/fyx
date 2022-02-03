> 🇨🇿 This repository is managed in czech language although the source code along with comments is written in english.

# Fyx

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/c5dd9261a8154bddb7f317f607307a1c)](https://app.codacy.com/gh/lucien144/fyx?utm_source=github.com&utm_medium=referral&utm_content=lucien144/fyx&utm_campaign=Badge_Grade_Settings)
[![Build Status](https://travis-ci.com/lucien144/fyx.svg?branch=develop)](https://travis-ci.com/lucien144/fyx) [![Coverage Status](https://coveralls.io/repos/github/lucien144/fyx/badge.svg?branch=develop)](https://coveralls.io/github/lucien144/fyx?branch=develop)

Fyx je neoficiální mobilní klient (Android a iOS) pro diskuzní server [Nyx.cz](https://nyx.cz) ve [Flutteru](https://flutter.dev/).

<p align="center">
<a href="https://play.google.com/store/apps/details?id=net.lucien144.fyx" target="_blank"><img src="https://imgur.com/yQvstXc.png" height="60"/></a>
<a href="https://144.wtf/AmcGAl" target="_blank"><img src="https://144.wtf/9VRKzD+" height="60"/></a>
</p>

---
<p align="center">
👍 Podpořte vývoj Fyxu na <a href="http://patreon.com/fyxapp" target="_blank">Patreonu</a> nebo <a href="https://www.nyx.cz/index.php?l=topic;l2=2;id=24237;n=a200"  target="_blank">Nyxu</a>!
</p>

---

## Funkce

Fyx nabízí oproti [oficiálnímu klientovi](https://apps.apple.com/cz/app/nyx/id920743962) několik výhod, ale v něčem také ztrácí. 
Zde je přehled funkcí pro lepší představu.

| Funkce | Fyx | Nyx |
|-|:-:|:-:|
| iOS | ✅ | ✅ |
| Android | ✅ | ❌ |
| Notifikace | ✅ | ✅ |
| Výpis klubů | ✅ | ✅ |
| Historie | ✅ | ✅ |
| Filtr přečtených klubů/historie | ✅ | ✅ |
| Nástěnka / záhlaví klubu | ❌ | ✅ |
| Ukládání do sledovaných | ❌ | ✅ |
| Psaní příspěvků | ✅ | ✅ |
| Mazání příspěvků | ✅ | ✅ |
| Kompaktní mód příspěvku | ✅ | ❌ |
| Nahrávání obrázků | ✅ | ✅ |
| Galerie více obrázků | ✅ | ❌ |
| Ukládání obrázků | ✅ | ✅ |
| Palečkování | ✅ | ✅ |
| Uložení do upomínek | ✅ | ✅ |
| Videa v příspěvku | ✅ | ❌ |
| Spoilery | ✅ | ❌ |
| Zobrazování anket | ✅ | ✅ |
| Zobrazování zdrojáků | ✅ | ❌ |
| Zobrazování videí | ✅ | ❌ |
| Dark mode | ✅ | ✅ |
| Pošta | ✅ | ✅ |
| Hledání | ❌ | ✅ |
| Tržiště | ❌ | ✅ |
| Upozornění | ✅ | ✅ |
| Landscape zobrazení | ❌ | ✅ |

## Roadmap

Pokud vás zajímá plán vývoje a přidáváné nových funkcí, pak se podívejte do [roadmapy](https://github.com/lucien144/fyx/projects/2).

## Jak se zapojit

### Finanční podpora

Pokud chcete vývoj Fyxu, který je nabízen zdarma, finančně podpořit, pak můžete skrz [Patreon účet](http://patreon.com/fyxapp). Příspěvky také můžete posílat bankou - [více informací na nástěnce](https://www.nyx.cz/index.php?l=topic;l2=2;id=24237;n=6162) Fyxu v patřičném [klubu na Nyxu](https://www.nyx.cz/index.php?l=topic;l2=2;id=24237;n=6162).

- [Patreon](http://patreon.com/fyxapp)
- [Bankovní spojení](https://www.nyx.cz/index.php?l=topic;l2=2;id=24237;n=6162)
- Bitcoin: bc1q6m0ptsg3z4u6296m9kqfl4adylt9kxkafw94ul

### Vývoj

Jakákoli pomoc - od každého - vítána! Nejrychleji se zapojíte přes [klub na Nyxu](https://www.nyx.cz/index.php?l=topic;id=24237;n=23dd), který se o vývojem nového klienta zabývá.
Také si můžete projít [Issues](https://github.com/lucien144/fyx/issues) případně [Projects](https://github.com/lucien144/fyx/projects) a poslat pull request.

Build produkce lze spustit zavoláním skpriput `$ ./build.sh`, který zároveň zvýší build verzi o +1.

Tento repozitář používá [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow). Připravujte veškerou práci ve `feature` větvích nebo forku, pak pošlete PR do `develop` větve. PR jsou mergovány pouze adminy (a jako `squash commits`).

## Hlášení chyb
Pokud jste našli chybu, pak ji nahlaste ideálně přes aplikaci. Pokud to nejde, pak přes [Issues](https://github.com/lucien144/fyx/issues) - nezapomeňte uvést verzi aplikace a popsat chybu.

## FAQ

- **Chybí mi možnost odskoku na nejbližší nepřečtený příspěvěk. Bude?**

  Ano, bude.

- **Proč je tento repozitář v češtině?**

  Vzhledem k tomu, že [klub na Nyxu](https://www.nyx.cz/index.php?l=topic;id=24237;n=23dd) věnující se novému klientovi vznikl v češtině, rozhodl jsem se (Lucien) vést tento repozitář také v češtině. Naproti tomu kód a komentáře v kódu jsou v angličtině, protože to je pro mě přiřozené. Dále by měly [Issues](https://github.com/lucien144/fyx/issues) sloužit jako centrální hub pro vedení veškerých chyb a připomínek, což se mi zdá opět lepší vést v češtině pro běžné uživatele. Nicméně, změně na kompletně anglické repo se po diskuzi nebráním...

## Náhled
![https://imgur.com/U00Oghi](https://imgur.com/U00Oghi.gif)
