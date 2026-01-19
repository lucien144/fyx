import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:fyx/theme/skin/Skin.dart';

class TutorialPageArguments {
  final String token;
  final String username;

  TutorialPageArguments({required this.token, required this.username});
}

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  late SkinColors colors;
  List<Widget> _slides = [];

  bool _loggingIn = false;
  bool _hasOpenedNyx = false;
  bool _isLastSlide = false;
  TutorialPageArguments? _arguments;

  @override
  void initState() {
    super.initState();
    AnalyticsProvider().setScreen('Tutorial', 'TutorialPage');
  }

  void buildSlider() {
    setState(() {
      _slides = [
        this.slide(
            L.TUTORIAL_SUCCESS,
            L.TUTORIAL_WELCOME,
            slideButton(L.GENERAL_BEGIN, onTap: () {
              AnalyticsProvider().logTutorialBegin();
              _carouselController.nextPage(duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
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
                            color: colors.primary,
                            size: 16,
                          ), onTap: () {
                    var onError = (error) => setState(() {
                          T.error('Přihlášení se nezdařilo. Chyba: $error', bg: colors.danger);
                          _hasOpenedNyx = false;
                          _loggingIn = false;
                        });

                    setState(() => _loggingIn = true);
                    ApiController().getCredentials().then((credentials) {
                      MainRepository().credentials = credentials!;
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    }).catchError((error) => onError(error));
                  })
                : slideButton(L.TUTORIAL_NYX,
                    icon: Icon(
                      Icons.launch,
                      color: colors.primary,
                      size: 16,
                    ), onTap: () async {
                    setState(() => _hasOpenedNyx = true);
                    String url = 'https://www.nyx.cz/profile/${_arguments!.username}/settings/authorizations';
                    T.openLink(url);
                  }))
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    colors = Skin.of(context).theme.colors;

    if (_arguments == null) {
      _arguments = ModalRoute.of(context)!.settings.arguments as TutorialPageArguments?;
    }

    // TODO: Refactor -> Get rid of this, performance issue, it keeps rebuilding the slider during each swipe.
    buildSlider();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          previousPageTitle: L.GENERAL_LOGIN,
          color: colors.background,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        border: Border.all(color: Colors.transparent, width: 0, style: BorderStyle.none),
        trailing: _isLastSlide
            ? null
            : CupertinoButton(
                padding: EdgeInsets.all(0),
                child: Text(L.GENERAL_SKIP, style: TextStyle(color: colors.background)),
                onPressed: () => _carouselController.jumpToPage(_slides.length - 1),
              ),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: colors.gradient),
        child: CarouselSlider.builder(
          carouselController: _carouselController,
          options: CarouselOptions(
            enableInfiniteScroll: false,
            height: 500,
            onPageChanged: (i, _) {
              if (i == _slides.length - 1) {
                setState(() => _isLastSlide = true);
              } else {
                if (_isLastSlide) {
                  setState(() => _isLastSlide = false);
                }
              }
            },
          ),
          itemCount: _slides.length,
          itemBuilder: (BuildContext context, int i, int realIndex) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: _slides[i],
          ),
        ),
        height: double.infinity,
      ),
    );
  }

  Widget slideButton(String label, {Widget? icon, Function? onTap}) {
    Widget? body;
    Text text = Text(
      label,
      style: TextStyle(color: colors.primary),
    );

    if (icon != null) {
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
        child: body != null ? body : text,
        color: colors.background,
        onPressed: () =>
            onTap is Function ? onTap() : _carouselController.nextPage(duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn),
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.background),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        this.slideCard(Text(copy, textAlign: TextAlign.center)),
        SizedBox(height: 16),
        footer
      ],
    );
  }

  Widget slideCard(Widget child) {
    return Container(height: 250, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16), decoration: colors.shadow, child: child);
  }

  Widget slideToken(String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.background),
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
                      _arguments!.token,
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
              color: colors.primary,
              size: 16,
            ), onTap: () {
          var data = ClipboardData(text: _arguments!.token);
          Clipboard.setData(data).then((_) {
            _carouselController.nextPage(duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.background),
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
