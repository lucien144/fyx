import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/theme/T.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  CarouselSlider _slider;

  @override
  Widget build(BuildContext context) {
    _slider = carouselFactory(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        actionsForegroundColor: Colors.white,
        border: Border.all(color: Colors.transparent, width: 0.0, style: BorderStyle.none),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xff2F4858)])),
        child: _slider,
        height: double.infinity,
      ),
    );
  }

  Widget carouselFactory(BuildContext context) {
    String token = ModalRoute.of(context).settings.arguments;
    List<Widget> slides = [
      this.slide(
          'Paráda 🤘',
          'První část autorizace se zdařila.\n\nNyní je potřeba uložit speciální klíč (něco jako heslo) pod tvůj účet na nyxu.\n\nTím se autorizace dokončí a budeš moci začít používat Fyx.',
          null),
      this.slideToken('1/6', token),
      this.slideTutorial('2/6', 1, 'Klíč bude nyní potřeba uložit do sekce Osobní...'),
      this.slideTutorial('3/6', 2, '... dále přejdi do Nastavení ...'),
      this.slideTutorial('4/6', 3, '... v podmenu klikni na Autorizace ...'),
      this.slideTutorial('5/6', 4, '... a klíč vlož do prázdného pole na řádku s nápisem "Fyx".'),
      this.slide(
          '6/6',
          Column(
            children: <Widget>[
              Text(
                'Nyní zbývá otevřít Nyx, uložit kód podle návodu a přihlásit se! Pokud jsi kód již uložil, můžeš se rovnou přihlásit.',
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CupertinoButton(
                        child: Text('Otevřít nyx.cz'),
                        onPressed: () async {
                          const url = 'https://www.nyx.cz/index.php?l=user;l2=2;section=authorizations;n=1ba4';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            PlatformTheme.error('Nepodařilo se otevřít prohlížeč.');
                          }
                        },
                      ),
                      Icon(
                        Icons.launch,
                        size: 16,
                      )
                    ],
                  )
                ]),
              ),
            ],
          ),
          slideButton('Přihlásit se', () => Navigator.of(context).pushNamed('/home')))
    ];

    return CarouselSlider.builder(
      enableInfiniteScroll: false,
      itemCount: slides.length,
      itemBuilder: (BuildContext context, int i) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: slides[i],
      ),
      height: 500,
    );
  }

  Widget slideButton(String label, Function onTap) {
    return CupertinoButton(
      child: Text(
        label,
        style: TextStyle(color: T.COLOR_SECONDARY),
      ),
      color: Colors.white,
      onPressed: () => onTap is Function ? onTap() : _slider.nextPage(duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn),
    );
  }

  Widget slideCard(Widget child) {
    return Container(height: 230, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16), decoration: T.CART_SHADOW_DECORATION, child: child);
  }

  Widget slide(String title, dynamic middle, Widget footer) {
    Widget body;

    if (middle is String) {
      body = Text(middle, textAlign: TextAlign.center);
    }

    if (middle is Widget) {
      body = middle;
    }

    if (body == null) {
      throw Exception('Middle section can be String or Widget only!');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        this.slideCard(body),
        SizedBox(height: 16),
        footer != null ? footer : slideButton('Začít', null)
      ],
    );
  }

  Widget slideToken(String title, String token) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        this.slideCard(
          Column(
            children: <Widget>[
              Text(
                'Začneme tím, že si zkopíruješ potřebný klíč do schránky:',
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SelectableText(
                      token,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        CupertinoButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.content_copy,
                color: T.COLOR_SECONDARY,
                size: 16,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                'Zkopírovat',
                style: TextStyle(color: T.COLOR_SECONDARY),
              ),
            ],
          ),
          onPressed: () {
            var data = ClipboardData(text: token);
            Clipboard.setData(data).then((_) {
              _slider.nextPage(duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
            });
          },
          color: Colors.white,
        )
      ],
    );
  }

  Widget slideTutorial(String title, int step, String copy) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        this.slideCard(Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(copy, textAlign: TextAlign.center),
            Image.asset(
              'assets/tutorial-$step.png',
              width: 300,
            )
          ],
        )),
        SizedBox(height: 16),
        slideButton('Další krok', null)
      ],
    );
  }
}
