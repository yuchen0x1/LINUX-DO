import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // 确保在初始化后重新构建以显示第一帧
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      })
      ..addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: theme.dividerColor),
        color: theme.primaryColor.withValues(alpha: 0.1),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.w),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.w),
              topRight: Radius.circular(8.w),
            ),
            child: AspectRatio(
              aspectRatio:
                  _isInitialized ? _controller.value.aspectRatio : 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isInitialized)
                    VideoPlayer(_controller)
                  else
                    Container(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      child: const Center(
                        child: DisSquareLoading(),
                      ),
                    ),
                  if (_isInitialized)
                    AnimatedOpacity(
                      opacity: _isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        child: Container(
                          color: Colors.black26,
                          child: Center(
                            child: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 50.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.w),
                bottomRight: Radius.circular(8.w),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? CupertinoIcons.pause : CupertinoIcons.play,
                    color: Theme.of(context).primaryColor,
                    size: 20.w,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                ),
                Expanded(
                  child: _isInitialized
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.w),
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Theme.of(context).primaryColor,
                              bufferedColor: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.3),
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 8.w, horizontal: 4.w),
                          ),
                        )
                      : SizedBox(height: 32.w),
                ),
                // 全屏逻辑后续添加
                // IconButton(
                //   icon: Icon(
                //     CupertinoIcons.fullscreen,
                //     color: Theme.of(context).primaryColor,
                //     size: 20.w,
                //   ),
                //   onPressed: () {
                //     // 全屏播放
                //     _controller.pause();
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (context) => FullScreenVideoPlayer(videoUrl: widget.videoUrl),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
