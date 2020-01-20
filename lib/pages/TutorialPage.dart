import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
  List<Widget> _slides;

  bool _hasOpenedNyx = false;
  bool _isLastSlide = false;
  String _token = '';

  @override
  void initState() {
    super.initState();
    buildSlider();
  }

  void buildSlider() {
    setState(() {
      _slides = [
        this.slide(
            'Paráda 🤘',
            'První část autorizace se zdařila.\n\nNyní je potřeba uložit speciální klíč (něco jako heslo) pod tvůj účet na nyxu.\n\nTím se autorizace dokončí a budeš moci začít používat Fyx.',
            null),
        this.slideToken('1/6'),
        this.slideTutorial('2/6', 1, 'Klíč bude nyní potřeba uložit do sekce Osobní...'),
        this.slideTutorial('3/6', 2, '... dále přejdi do Nastavení ...'),
        this.slideTutorial('4/6', 3, '... v podmenu klikni na Autorizace ...'),
        this.slideTutorial('5/6', 4, '... a klíč vlož do prázdného pole na řádku s nápisem "Fyx".'),
        this.slide(
            '6/6',
            'Nyní zbývá otevřít Nyx, uložit kód podle návodu a přihlásit se!',
            _hasOpenedNyx
                ? slideButton('Přihlásit se',
                    icon: Icon(
                      Icons.lock,
                      color: T.COLOR_SECONDARY,
                      size: 16,
                    ),
                    onTap: () => Navigator.of(context).pushNamed('/home'))
                : slideButton('Otevřít nyx.cz',
                    icon: Icon(
                      Icons.launch,
                      color: T.COLOR_SECONDARY,
                      size: 16,
                    ), onTap: () async {
                    setState(() => _hasOpenedNyx = true);
                    const url = 'https://www.nyx.cz/index.php?l=user;l2=2;section=authorizations;n=1ba4';
                    try {
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        PlatformTheme.error('Nepodařilo se otevřít prohlížeč.');
                      }
                    } catch (e) {
                      PlatformTheme.error('Nepodařilo se otevřít prohlížeč.');
                    }
                  }))
      ];
      _slider = CarouselSlider.builder(
        enableInfiniteScroll: false,
        itemCount: _slides.length,
        itemBuilder: (BuildContext context, int i) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: _slides[i],
        ),
        height: 500,
        onPageChanged: (i) {
          print(i);
          print(_slides.length);
          if (i == _slides.length - 1) {
            setState(() => _isLastSlide = true);
          } else {
            if (_isLastSlide) {
              setState(() => _isLastSlide = false);
            }
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_token == '') {
      _token = ModalRoute.of(context).settings.arguments;
    }

    buildSlider();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Přihlášení',
        backgroundColor: Colors.transparent,
        actionsForegroundColor: Colors.white,
        border: Border.all(color: Colors.transparent, width: 0, style: BorderStyle.none),
        trailing: _isLastSlide
            ? null
            : CupertinoButton(
                padding: EdgeInsets.all(0),
                child: Text('Přeskočit'),
                onPressed: () => _slider.jumpToPage(_slides.length - 1),
              ),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xff2F4858)])),
        child: _slider,
        height: double.infinity,
      ),
    );
  }

  Widget slideButton(String label, {Widget icon, Function onTap}) {
    Widget body;
    Text text = Text(
      label,
      style: TextStyle(color: T.COLOR_SECONDARY),
    );

    if (icon is Widget) {
      body = Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        icon,
        SizedBox(
          width: 4,
        ),
        text
      ]);
    }

    return CupertinoButton(
      child: body is Widget ? body : text,
      color: Colors.white,
      onPressed: () => onTap is Function ? onTap() : _slider.nextPage(duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn),
    );
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
        this.slideCard(Text(copy, textAlign: TextAlign.center)),
        SizedBox(height: 16),
        footer != null ? footer : slideButton('Začít')
      ],
    );
  }

  Widget slideCard(Widget child) {
    return Container(height: 250, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16), decoration: T.CART_SHADOW_DECORATION, child: child);
  }

  Widget slideToken(String title) {
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
                      _token,
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
        slideButton('Zkopírovat',
            icon: Icon(
              Icons.content_copy,
              color: T.COLOR_SECONDARY,
              size: 16,
            ), onTap: () {
          var data = ClipboardData(text: _token);
          Clipboard.setData(data).then((_) {
            _slider.nextPage(duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
          });
        })
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
        slideButton('Další krok')
      ],
    );
  }
}
