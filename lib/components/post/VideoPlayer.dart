import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/theme/T.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  final String videoUrl;

  VideoPlayer(this.videoUrl);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
        autoInitialize: true,
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

  @override
  void dispose() {
    chewieController.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: chewieController);
  }
}
