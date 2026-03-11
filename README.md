> 🇨🇿 This repository is managed in czech language although the source code along with comments is written in english.

# Fyx

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/c5dd9261a8154bddb7f317f607307a1c)](https://app.codacy.com/gh/lucien144/fyx?utm_source=github.com&utm_medium=referral&utm_content=lucien144/fyx&utm_campaign=Badge_Grade_Settings)
[![Codemagic build status](https://api.codemagic.io/apps/64d5e8624479a8f7a878b6c9/64d5e8624479a8f7a878b6c8/status_badge.svg)](https://codemagic.io/apps/64d5e8624479a8f7a878b6c9/64d5e8624479a8f7a878b6c8/latest_build)
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

Fyx nabízí oproti [oficiálnímu klientovi](https://apps.apple.com/cz/app/nyx/id920743962) několik výhod:

| Funkce | Fyx | Nyx |
|-|:-:|:-:|
| iOS | ✅ | ✅ |
| Android | ✅ | ❌ |
| Galerie více obrázků | ✅ | ❌ |
| Videa v příspěvku | ✅ | ❌ |
| Spoilery | ✅ | ❌ |
| Ankety | ✅ | ❌ |
| Zobrazování videí | ✅ | ❌ |
| Skiny (Forest, ...) | ✅ | ❌ |
| Nastavení velikosti písma | ✅ | ❌ |
| Odskok k prvnímu nepřečtenému | ✅ | ❌ |
| iPad podpora | ✅ | ❌ |
| Kompaktní mód příspěvku | ✅ | ❌ |
| Notifikace | ✅ | ✅ |
| Výpis klubů | ✅ | ✅ |
| Historie | ✅ | ✅ |
| Filtr přečtených klubů/historie | ✅ | ✅ |
| Nástěnka / záhlaví klubu | ✅ | ✅ |
| Ukládání do sledovaných | ✅ | ✅ |
| Psaní příspěvků | ✅ | ✅ |
| Mazání příspěvků | ✅ | ✅ |
| Nahrávání obrázků | ✅ | ✅ |
| Ukládání obrázků | ✅ | ✅ |
| Palečkování | ✅ | ✅ |
| Uložení do upomínek | ✅ | ✅ |
| Zobrazování zdrojáků | ✅ | ✅ |
| Dark mode | ✅ | ✅ |
| Pošta | ✅ | ✅ |
| Hledání | ✅ | ✅ |
| Tržiště | ✅ | ✅ |
| Upozornění | ✅ | ✅ |
| Landscape zobrazení | ✅ | ✅ |

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

#### Spuštění

Aplikace používá knihovnu Freezed pro snadnější generování modelů, před každým spuštěním a buildem je proto nutné spustit:

```shell
$ dart run build_runner build --delete-conflicting-outputs
```

### CI/CD

Pro úspěšný build je potřeba nastavit správně Firebase, doporučuji se podívat na `.env.example`, `ios/firebase_app_id_file.json.example` a skript níže. 

Buildy se spouští automaticky přes [![Codemagic build status](https://api.codemagic.io/apps/64d5e8624479a8f7a878b6c9/64d5e8624479a8f7a878b6c8/status_badge.svg)](https://codemagic.io/apps/64d5e8624479a8f7a878b6c9/64d5e8624479a8f7a878b6c8/latest_build) v případě nového tagu ve formátu `vX.Y.Z+XXX` na branchích `develop` a `master`.

#### iOS
```shell
mv ios/firebase_app_id_file.json.example ios/firebase_app_id_file.json
sed -i '' "s/{GOOGLE_APP_ID}/$GOOGLE_APP_ID/g" ios/firebase_app_id_file.json
sed -i '' "s/{FIREBASE_PROJECT_ID}/$FIREBASE_PROJECT_ID/g" ios/firebase_app_id_file.json
sed -i '' "s/{GCM_SENDER_ID}/$GCM_SENDER_ID/g" ios/firebase_app_id_file.json
```

## Hlášení chyb
Pokud jste našli chybu, pak ji nahlaste ideálně přes aplikaci. Pokud to nejde, pak přes [Issues](https://github.com/lucien144/fyx/issues) - nezapomeňte uvést verzi aplikace a popsat chybu.

## FAQ

- **Proč je tento repozitář v češtině?**

  Vzhledem k tomu, že [klub na Nyxu](https://www.nyx.cz/index.php?l=topic;id=24237;n=23dd) věnující se novému klientovi vznikl v češtině, rozhodl jsem se (Lucien) vést tento repozitář také v češtině. Naproti tomu kód a komentáře v kódu jsou v angličtině, protože to je pro mě přiřozené. Dále by měly [Issues](https://github.com/lucien144/fyx/issues) sloužit jako centrální hub pro vedení veškerých chyb a připomínek, což se mi zdá opět lepší vést v češtině pro běžné uživatele. Nicméně, změně na kompletně anglické repo se po diskuzi nebráním...

## Náhledy obrazovek a funkcí

<details><summary>Průchod aplikací</summary>
<img src="https://imgur.com/U00Oghi.gif">
</details>

<details><summary>Odskok na první nepřečtený</summary>
<img src="https://nyx.cz/files/000/024/2488581_c5ecbfff4f2539635330/original.gif?name=autoscroll.gif">
</details>

<details><summary>Forest skin, nastavení písma</summary>
<img src="https://x.144.wtf/xkin1h+">
</details>

<details><summary>Hromadné akce (mazání, ...)</summary>
<img src="https://nyx.cz/files/000/024/2488580_08c9850b3d378dcb0079/original.gif?name=delete_batch.gif">
</details>

<details><summary>Book, unbook, nástěnka, hledání v diskuzi</summary>
<img src="https://nyx.cz/files/000/024/2488576_115fd940e8870959cd5f/original.gif?name=discussion-actions.gif">
</details>

<details><summary>Hledání klubů</summary>
<img src="https://nyx.cz/files/000/024/2488575_a04450db46eb11ba5f0c/original.gif?name=search.gif">
</details>

<details><summary>Filtrování v historii</summary>
<img src="https://nyx.cz/files/000/024/2488573_060d813c9b1369e2439c/original.gif?name=filter.gif">
</details>

<details><summary>Spoilery</summary>
<img src="https://i.imgur.com/4P84HJD.jpg">
</details>

<details><summary>iPad verze</summary>
<img src="https://nyx.cz/files/000/024/2481297_1ecd8988381cde23830d/original.gif?name=CleanShot+2022-06-08+at+12.32.49.gif">
</details>