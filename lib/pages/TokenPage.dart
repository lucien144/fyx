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
  int _slidesCounter = 1;

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
    List<Widget> slides = [this.slideOne(), this.slideTwo(token), this.slideThree()];

    return CarouselSlider.builder(
      enableInfiniteScroll: false,
      enlargeCenterPage: true,
      itemCount: slides.length,
      itemBuilder: (BuildContext context, int i) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: slides[i],
      ),
      height: 500,
    );
  }

  Widget slideCard(Widget child) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: T.CART_SHADOW_DECORATION,
        child: child);
  }

  Widget slideOne() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Paráda 🤘',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        this.slideCard(Column(
            children: <Widget>[
              Text(
                  'První krok autorizace se zdařil.\n\nNyní je potřeba uložit speciální autorizační klíč pod tvůj\núčet na nyxu.\nTím se autorizace dokončí a budeš moci začít používat Fyx.', textAlign: TextAlign.center)
            ],
          ),
        ),
        SizedBox(height: 16),
        CupertinoButton(
          child: Text(
            'Začít',
            style: TextStyle(color: T.COLOR_SECONDARY),
          ),
          color: Colors.white,
          onPressed: () => _slider.nextPage(duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn),
        )
      ],
    );
  }

  Widget slideTwo(String token) {
    _slidesCounter++;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '1/$_slidesCounter',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        this.slideCard(Column(
            children: <Widget>[
              Text('Začneme tím, že si zkopíruješ potřebný klíč do schránky:', textAlign: TextAlign.center,),
              SizedBox(
                height: 8,
              ),
              SelectableText(
                token, textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        SizedBox(height: 16),
        CupertinoButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.content_copy, color: T.COLOR_SECONDARY),
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

  Widget slideThree() {
    _slidesCounter++;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '2/$_slidesCounter',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        this.slideCard(Column(
          children: <Widget>[
            Text('Klíč bude nyní potřeba uložit do sekce Osobní...', textAlign: TextAlign.center),
            Image.asset('assets/tutorial-1.png', width: 300,)
          ],
        )),
        SizedBox(height: 16),
        CupertinoButton(
          child: Text(
            'Další krok',
            style: TextStyle(color: T.COLOR_SECONDARY),
          ),
          onPressed: () {},
          color: Colors.white,
        )
      ],
    );
  }
}
