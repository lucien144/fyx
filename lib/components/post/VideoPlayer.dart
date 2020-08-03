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

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl?.isEmpty ?? true) {
      return;
    }

    videoPlayerController = VideoPlayerController.network(widget.videoUrl);
  }

  Future<bool> initVideo(BuildContext context) async {
    await videoPlayerController.initialize();

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final aspectRatio = videoPlayerController.value.initialized ? videoPlayerController.value.aspectRatio : (width > height ? width / height : height / width);

    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: aspectRatio,
        placeholder: Container(
          color: T.COLOR_PRIMARY,
          child: Icon(
            Icons.camera_roll,
            color: Colors.white.withAlpha(75),
            size: 32,
          ),
          alignment: Alignment.center,
        ));
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
        future: initVideo(context),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return AspectRatio(aspectRatio: videoPlayerController.value.aspectRatio, child: Chewie(controller: chewieController));
          } else if (snapshot.hasError) {
            return PlatformTheme.somethingsWrongButton(widget.element.outerHtml);
          }
          return Center(child: CupertinoActivityIndicator());
        });
  }
}
