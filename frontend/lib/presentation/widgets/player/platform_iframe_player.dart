import 'package:flutter/material.dart';
import 'platform_iframe_player_stub.dart'
    if (dart.library.js_interop) 'platform_iframe_player_web.dart'
    as impl;

class PlatformIframePlayer extends StatelessWidget {
  final String iframeUrl;
  final String viewId;

  const PlatformIframePlayer({
    super.key,
    required this.iframeUrl,
    this.viewId = 'main',
  });

  @override
  Widget build(BuildContext context) {
    if (iframeUrl.isEmpty) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text(
          'Không có luồng phát video',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return impl.buildPlatformIframePlayer(
      iframeUrl: iframeUrl,
      viewId: viewId,
    );
  }
}
