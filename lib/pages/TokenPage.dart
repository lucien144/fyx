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
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        actionsForegroundColor: Colors.white,
        border: Border.all(color: Colors.transparent, width: 0.0, style: BorderStyle.none),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xff2F4858)])),
        child: carouselFactory(context),
        height: double.infinity,
      ),
    );
  }

  Widget carouselFactory(BuildContext context) {
    List<Widget> slides = [this.slideOne(context), this.slideTwo(context)];

    return CarouselSlider.builder(
      enableInfiniteScroll: false,
      itemCount: slides.length,
      itemBuilder: (BuildContext context, int i) => slides[i],
      height: 400,
    );
  }

  Widget slideOne(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Paráda 🤘',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: T.CART_DECORATION,
          child: Column(
            children: <Widget>[
              Text(
                  'První krok autorizace se zdařil. Nyní je potřeba uložit speciální autorizační klíč pod tvůj účet na nyxu. Tím se autorizace dokončí a budeš moci začít používat Fyx.')
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
          onPressed: () => print(''),
        )
      ],
    );
  }

  Widget slideTwo(BuildContext context) {
    final token = ModalRoute.of(context).settings.arguments;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '1. krok',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: T.CART_DECORATION,
          child: Column(
            children: <Widget>[
              Text('Začneme tím, že si zkopíruješ potřebný klíč do schrnánky:'),
              SizedBox(
                height: 8,
              ),
              SelectableText(
                token,
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
            Clipboard.setData(data).then((_) => print('TODO: Toast it!'));
          },
          color: Colors.white,
        )
      ],
    );
  }
}
