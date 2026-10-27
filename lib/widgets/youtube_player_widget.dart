import 'package:flutter/material.dart';
import 'youtube_player_stub.dart'
    if (dart.library.html) 'youtube_player_web.dart';

class YouTubePlayerWidget extends StatelessWidget {
  final String videoId;
  final double? width;
  final double? height;
  final bool autoPlay;
  final BorderRadius? borderRadius;

  const YouTubePlayerWidget({
    super.key,
    required this.videoId,
    this.width,
    this.height,
    this.autoPlay = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = width ??
            (constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : 360.0);
        final effectiveHeight = height ?? (effectiveWidth * 9 / 16);

        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Container(
            color: Colors.black,
            child: buildPlatformYouTubePlayer(
              videoId: videoId,
              width: effectiveWidth,
              height: effectiveHeight,
              autoPlay: autoPlay,
            ),
          ),
        );
      },
    );
  }
}
