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

- **Proč nelze k příspěvku nahrát víc obrázků najednou?**

  To bohužel nepodporuje Nyx.
  
- **Nikde nevidím možnost smazat příspěvek.**

  Zatím není podporováno, ale bude - viz. [roadmapa](https://github.com/lucien144/fyx/projects/2).

- **Proč je tento repozitář v češtině?**

  Vzhledem k tomu, že [klub na Nyxu](https://www.nyx.cz/index.php?l=topic;id=24237;n=23dd) věnující se novému klientovi vznikl v češtině, rozhodl jsem se (Lucien) vést tento repozitář také v češtině. Naproti tomu kód a komentáře v kódu jsou v angličtině, protože to je pro mě přiřozené. Dále by měly [Issues](https://github.com/lucien144/fyx/issues) sloužit jako centrální hub pro vedení veškerých chyb a připomínek, což se mi zdá opět lepší vést v češtině pro běžné uživatele. Nicméně, změně na kompletně anglické repo se po diskuzi nebráním...

## Náhledy
<table>
	<tr>
		<th width="33%">
			<p><a title="history"></a> Výpis historie
			<p><kbd><img src="https://user-images.githubusercontent.com/5161085/104580475-a1b6ef80-565d-11eb-8003-a412416e5d14.PNG">
		<th width="33%">
			<p><a title="bookmarks"></a> Výpis diskuzí
			<p><kbd><img src="https://user-images.githubusercontent.com/5161085/104580503-a9769400-565d-11eb-90bf-8ff1865d8385.PNG">
    <th width="33%">
			<p><a title="detail"></a> Detail diskuze (v kompaktním módu)
			<p><kbd><img src="https://user-images.githubusercontent.com/5161085/104580520-ad0a1b00-565d-11eb-9571-2326ee2dfad7.PNG">
	<tr>
		<th width="33%">
			<p><a title="gallery"></a> Galerie (náhled obrázku v příspěvku)
			<p><kbd><img src="https://user-images.githubusercontent.com/5161085/104580526-ae3b4800-565d-11eb-870e-acc8e764965f.PNG">
		<th width="33%">
			<p><a title="poll"></a> Anketa
			<p><kbd><img src="https://user-images.githubusercontent.com/5161085/104580528-af6c7500-565d-11eb-9b2e-59852aa182b5.PNG">
		<th width="33%">
			<p><a title="syntax"></a> Zvýraznění syntaxe
			<p><kbd><img src="https://user-images.githubusercontent.com/5161085/104580530-b0050b80-565d-11eb-9ec6-2ed9376814c0.PNG">
  <tr>
		<th width="33%">
			<p><a title="spoiler"></a> Spoilery
			<p><kbd><img src="https://user-images.githubusercontent.com/5161085/104580531-b0050b80-565d-11eb-9130-a44cfe19ab56.PNG">
		<th width="33%">
			<p><a title="reply"></a> Psaní odpovědi
			<p><kbd><img src="https://user-images.githubusercontent.com/5161085/104581181-83052880-565e-11eb-8ff0-d1baa088886f.PNG">
		<th width="33%">
			<p><a title="settings"></a> Nastavení
			<p><kbd><img src="https://user-images.githubusercontent.com/5161085/104581195-87314600-565e-11eb-9e2a-6cc20ebf743a.PNG">
</table>
