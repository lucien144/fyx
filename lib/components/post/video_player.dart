import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:html/dom.dart' as dom;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  final dom.Element element;
  final bool blur;
  late final String? videoUrl;

  VideoPlayer(this.element, {this.blur = false});

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  bool? $isVideoPlayerLoaded = false;
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  late SkinColors colors;
  late String? videoUrl;
  bool _blur = false;

  @override
  void initState() {
    super.initState();
    _blur = widget.blur;
    videoUrl = widget.element.attributes['src'];
    var urls = widget.element.querySelectorAll('source').map((element) => element.attributes['src']).toList();

    if ([null, ''].contains(videoUrl) && urls.length > 0) {
      videoUrl = urls.firstWhere((url) => url is String && url.isNotEmpty);
      if (videoUrl?.startsWith('/') == true) {
        videoUrl = 'https://nyx.cz$videoUrl';
      }
    }

    if (videoUrl != null && videoUrl!.isNotEmpty) {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl!))
        ..initialize()
            .then((_) => setState(() => $isVideoPlayerLoaded = true))
            .timeout(Duration(seconds: 3), onTimeout: () => setState(() => $isVideoPlayerLoaded = null));
    }
  }

  ChewieController initChewie(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final aspectRatio =
        videoPlayerController!.value.isInitialized ? videoPlayerController!.value.aspectRatio : (width > height ? width / height : height / width);

    return ChewieController(
        videoPlayerController: videoPlayerController!,
        aspectRatio: aspectRatio,
        errorBuilder: (_, error) => Container(
              child: T.somethingsWrongButton(widget.element.outerHtml, icon: Icons.play_disabled, title: 'Video se nepodařilo spustit.\n$error', stack: error),
            ),
        placeholder: Container(
          color: colors.primary,
          child: Icon(
            Icons.camera_roll,
            color: colors.background.withAlpha(75),
            size: 32,
          ),
          alignment: Alignment.center,
        ));
  }

  @override
  void dispose() {
    if (chewieController != null) {
      chewieController!.dispose();
    }
    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    colors = Skin.of(context).theme.colors;
    if (videoUrl?.isEmpty ?? true) {
      return T.somethingsWrongButton(widget.element.outerHtml);
    }

    return Stack(
      children: [
        Card(
            elevation: 0,
            color: colors.background,
            child: Column(
              children: <Widget>[
                if ($isVideoPlayerLoaded == true)
                  AspectRatio(aspectRatio: videoPlayerController!.value.aspectRatio, child: Chewie(controller: initChewie(context))),
                if ($isVideoPlayerLoaded == false) CupertinoActivityIndicator(),
                if ($isVideoPlayerLoaded == null) T.somethingsWrongButton(widget.element.outerHtml, icon: Icons.play_disabled, title: 'Video se nepodařilo načíst.'),
                SizedBox(
                  height: 8,
                ),
                _sourceButton(),
                SizedBox(
                  height: 8,
                )
              ],
            )),
        if (_blur)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _blur = false),
              behavior: HitTestBehavior.opaque,
              child: T.nsfwMask(),
            ),
          ),
        if (_blur)
          Positioned.fill(
              child: IgnorePointer(
            child: Align(
              child: Icon(
                MdiIcons.playCircle,
                color: colors.light.withOpacity(0.5),
                size: 64,
              ),
              alignment: Alignment.center,
            ),
          ))
      ],
    );
  }

  Widget _sourceButton() {
    return GestureDetector(
      onTap: () => T.openLink(videoUrl!, mode: SettingsProvider().linksMode),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: RichText(
          overflow: TextOverflow.ellipsis,
          text: TextSpan(children: [
            TextSpan(text: 'Zdroj: ', style: DefaultTextStyle.of(context).style.merge(TextStyle(fontSize: 12, color: colors.text))),
            TextSpan(
              text: videoUrl!.replaceAll('', '\u{200B}'),
              style: TextStyle(fontSize: 12, color: colors.primary, decoration: TextDecoration.underline),
            )
          ]),
        ),
      ),
    );
  }
}
