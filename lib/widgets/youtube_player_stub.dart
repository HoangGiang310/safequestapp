import 'package:flutter/material.dart';

Widget buildPlatformYouTubePlayer({
  required String videoId,
  required double width,
  required double height,
  bool autoPlay = true,
}) {
  return Container(
    width: width,
    height: height,
    color: Colors.black,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_fill, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            'YouTube Video: $videoId',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
