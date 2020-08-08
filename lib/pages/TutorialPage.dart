import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  CarouselSlider _slider;
  List<Widget> _slides;

  bool _loggingIn = false;
  bool _hasOpenedNyx = false;
  bool _isLastSlide = false;
  String _token = '';

  @override
  void initState() {
    super.initState();
    buildSlider();

    AnalyticsProvider().setScreen('Tutorial', 'TutorialPage');
  }

  void buildSlider() {
    setState(() {
      _slides = [
        this.slide(L.TUTORIAL_SUCCESS, L.TUTORIAL_WELCOME,
            slideButton(L.GENERAL_BEGIN, onTap: () {
              AnalyticsProvider().logTutorialBegin();
              _slider.nextPage(duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
            })),
        this.slideToken('1/6'),
        this.slideTutorial('2/6', 1, L.TUTORIAL_TOKEN),
        this.slideTutorial('3/6', 2, L.TUTORIAL_SETTINGS),
        this.slideTutorial('4/6', 3, L.TUTORIAL_AUTH),
        this.slideTutorial('5/6', 4, L.TUTORIAL_INPUT),
        this.slide(
            '6/6',
            L.TUTORIAL_FINAL,
            _hasOpenedNyx
                ? slideButton(_loggingIn ? 'Přihlašuji...' : 'Přihlásit se',
                    icon: _loggingIn
                        ? CupertinoActivityIndicator()
                        : Icon(
                            Icons.lock,
                            color: T.COLOR_SECONDARY,
                            size: 16,
                          ), onTap: () {
                    var onError = (error) => setState(() {
                          PlatformTheme.error('Přihlášení se nezdařilo. Chyba: $error');
                          _hasOpenedNyx = false;
                          _loggingIn = false;
                        });

                    setState(() => _loggingIn = true);
                    ApiController().provider.getCredentials().then((credentials) {
                      // Save the credentials for later use.
                      MainRepository().credentials = credentials;
                      // Test the authorization. If all is OK, go to /home screen...
                      ApiController().testAuth().then((isOk) {
                        if (isOk) {
                          Navigator.of(context).pushNamed('/home');
                          AnalyticsProvider().logTutorialComplete();
                        }
                      }).catchError((error) => onError(error));
                    }).catchError((error) => onError(error));
                  })
                : slideButton(L.TUTORIAL_NYX,
                    icon: Icon(
                      Icons.launch,
                      color: T.COLOR_SECONDARY,
                      size: 16,
                    ), onTap: () async {
                    setState(() => _hasOpenedNyx = true);
                    const url = 'https://www.nyx.cz/index.php?l=user;l2=2;section=authorizations;n=1ba4';
                    PlatformTheme.openLink(url);
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
        previousPageTitle: L.GENERAL_LOGIN,
        backgroundColor: Colors.transparent,
        actionsForegroundColor: Colors.white,
        border: Border.all(color: Colors.transparent, width: 0, style: BorderStyle.none),
        trailing: _isLastSlide
            ? null
            : CupertinoButton(
                padding: EdgeInsets.all(0),
                child: Text(L.GENERAL_SKIP),
                onPressed: () => _slider.jumpToPage(_slides.length - 1),
              ),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: T.GRADIENT),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: CupertinoButton(
        padding: EdgeInsets.all(0),
        child: body is Widget ? body : text,
        color: Colors.white,
        onPressed: () => onTap is Function ? onTap() : _slider.nextPage(duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn),
      ),
    );
  }

  Widget slide(String title, String copy, Widget footer) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        this.slideCard(Text(copy, textAlign: TextAlign.center)),
        SizedBox(height: 16),
        footer != null ? footer : slideButton(L.GENERAL_BEGIN)
      ],
    );
  }

  Widget slideCard(Widget child) {
    return Container(height: 250, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16), decoration: T.CARD_SHADOW_DECORATION, child: child);
  }

  Widget slideToken(String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        this.slideCard(
          Column(
            children: <Widget>[
              Text(
                L.TUTORIAL_TOKEN_COPY,
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
        slideButton(L.GENERAL_COPY,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
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
        slideButton(L.GENERAL_NEXT_STEP)
      ],
    );
  }
}
