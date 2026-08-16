import 'package:flutter/material.dart';

Widget buildPlatformIframePlayer({
  required String iframeUrl,
  required String viewId,
}) {
  return Container(
    color: Colors.black,
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.play_circle_fill, size: 64, color: Colors.white54),
        const SizedBox(height: 12),
        const Text(
          'Đang mở luồng phát embed...',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          iframeUrl,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
