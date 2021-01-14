> 🇨🇿 This repository is managed in czech language although the source code along with comments is written in english.

# Fyx

[![Build Status](https://travis-ci.com/lucien144/fyx.svg?branch=develop)](https://travis-ci.com/lucien144/fyx) [![Coverage Status](https://coveralls.io/repos/github/lucien144/fyx/badge.svg?branch=develop)](https://coveralls.io/github/lucien144/fyx?branch=develop)

Fyx je neoficiální mobilní klient pro diskuzní server [Nyx.cz](https://nyx.cz) ve [Flutteru](https://flutter.dev/). V tuto chvíli je psaný a optimalizovaný pro iOS, ale v plánu je i Android verze.

<p align="center">
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
| Android | 🛠 | ✅ |
| Notifikace | ✅ | ✅ |
| Výpis klubů | ✅ | ✅ |
| Historie | ✅ | ✅ |
| Filtr přečtených klubů/historie | ✅ | ✅ |
| Nástěnka / záhlaví klubu | ❌ | ✅ |
| Ukládání do sledovaných | ❌ | ✅ |
| Psaní příspěvků | ✅ | ✅ |
| Mazání příspěvků | ❌ | ✅ |
| Kompaktní mód příspěvku | ✅ | ❌ |
| Nahrávání obrázků | ✅ | ✅ |
| Galerie více obrázků | ✅ | ❌ |
| Ukládání obrázků | ✅ | ✅ |
| Palečkování | ✅ | ✅ |
| Uložení do upomínek | ✅ | ✅ |
| Videa v příspěvku | ✅ | ❌ |
| Spoilery | ✅ | ❌ |
| Zobrazování anket | ✅ | ❌ |
| Zobrazování zdrojáků | ✅ | ❌ |
| Zobrazování videí | ✅ | ❌ |
| Dark mode | ❌ | ✅ |
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

### Vývoj

Jakákoli pomoc - od každého - vítána! Nejrychleji se zapojíte přes [klub na Nyxu](https://www.nyx.cz/index.php?l=topic;id=24237;n=23dd), který se o vývojem nového klienta zabývá.
Také si můžete projít [Issues](https://github.com/lucien144/fyx/issues) případně [Projects](https://github.com/lucien144/fyx/projects) a poslat pull request.

Build produkce lze spustit zavoláním skpriput `$ ./ios/build.sh`, který zároveň zvýší build verzi o +1.

Tento repozitář používá [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow). Připravujte veškerou práci ve `feature` větvích nebo forku, pak pošlete PR do `develop` větve. PR jsou mergovány pouze adminy (a jako `squash commits`).

## Hlášení chyb
Pokud jste našli chybu, pak ji nahlaste ideálně přes aplikaci. Pokud to nejde, pak přes [Issues](https://github.com/lucien144/fyx/issues) - nezapomeňte uvést verzi aplikace a popsat chybu.

## FAQ

- **Proč není podporovaný i Android?**

  Na Androidu se pracuje. Předpoklad je přelom Q2 a Q3 2021.

- **Proč nelze k příspěvku nahrát víc obrázků najednou?**

  To bohužel nepodporuje Nyx.
  
- **Nikde nevidím možnost smazat příspěvek.**

  Zatím není podporováno, ale bude - viz. [roadmapa](https://github.com/lucien144/fyx/projects/2).

- **Proč je tento repozitář v češtině?**

  Vzhledem k tomu, že [klub na Nyxu](https://www.nyx.cz/index.php?l=topic;id=24237;n=23dd) věnující se novému klientovi vznikl v češtině, rozhodl jsem se (Lucien) vést tento repozitář také v češtině. Naproti tomu kód a komentáře v kódu jsou v angličtině, protože to je pro mě přiřozené. Dále by měly [Issues](https://github.com/lucien144/fyx/issues) sloužit jako centrální hub pro vedení veškerých chyb a připomínek, což se mi zdá opět lepší vést v češtině pro běžné uživatele. Nicméně, změně na kompletně anglické repo se po diskuzi nebráním...

## Náhledy

| | | |
|:-------------------------:|:-------------------------:|:-------------------------:|
| ![](sources/screenshots/discussion.gif) **Diskuze** | ![](sources/screenshots/reddit-like.gif) **Experimentální náhledy** | ![](sources/screenshots/mail.gif) **Pošta** |
| ![](sources/screenshots/tutorial.gif)  **Login / Tutoriál** | - | - |
