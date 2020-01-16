import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/theme/T.dart';

class TokenPage extends StatefulWidget {
  @override
  _TokenPageState createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
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
          'Nyní zbývá otevřít Nyx, uložit kód podle návodu a přihlásit se!',
          Column(children: <Widget>[
            slideButton('Otevřít nyx.cz', null),
            SizedBox(
              height: 8,
            ),
            slideButton('Přihlásit se', null)
          ]))
    ];

    return CarouselSlider.builder(
      enableInfiniteScroll: false,
      enlargeCenterPage: false,
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

  Widget slide(String title, String copy, Widget footer) {
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
            children: <Widget>[Text(copy, textAlign: TextAlign.center)],
          ),
        ),
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
