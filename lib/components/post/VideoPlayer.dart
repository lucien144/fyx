import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/theme/T.dart';
import 'package:html/dom.dart' as dom;
import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  final dom.Element element;
  String videoUrl;

  VideoPlayer(this.element) {
    videoUrl = element.attributes['src'];
    var urls = element.querySelectorAll('source').map((element) => element.attributes['src']).toList();
    if ([null, ''].contains(videoUrl) && urls.length > 0) {
      videoUrl = urls.firstWhere((url) => url.endsWith('.mp4'));
      if (videoUrl.isEmpty) {
        videoUrl = urls.first;
      }
    }
  }

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  double _aspectRatio;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl?.isEmpty ?? true) {
      return;
    }

    videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    videoPlayerController.addListener(() {
      if (_aspectRatio == null) {
        setState(() => _aspectRatio = videoPlayerController.value.aspectRatio);
      }
    });

    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: _aspectRatio ?? 3 / 4,
        placeholder: Container(
          color: T.COLOR_PRIMARY,
          child: Icon(
            Icons.camera_roll,
            color: Colors.white.withAlpha(75),
            size: 32,
          ),
          alignment: Alignment.center,
        ));
  }

  Future<bool> initVideo() async {
    await videoPlayerController.initialize();
    return true;
  }

  @override
  void dispose() {
    if (chewieController != null) {
      chewieController.dispose();
    }
    if (videoPlayerController != null) {
      videoPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl?.isEmpty ?? true) {
      return PlatformTheme.somethingsWrongButton(widget.element.outerHtml);
    }

    return FutureBuilder(
        future: initVideo(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return AspectRatio(aspectRatio: videoPlayerController.value.aspectRatio, child: Chewie(controller: chewieController));
          }
          return Center(child: CupertinoActivityIndicator());
        });
  }
}
