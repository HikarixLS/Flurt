import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

Widget buildPlatformIframePlayer({
  required String iframeUrl,
  required String viewId,
}) {
  final uniqueId = 'flurt_player_${viewId}_${iframeUrl.hashCode.abs()}';

  ui_web.platformViewRegistry.registerViewFactory(uniqueId, (int id) {
    final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
    iframe.src = iframeUrl;
    iframe.style.border = 'none';
    iframe.style.width = '100%';
    iframe.style.height = '100%';
    iframe.style.backgroundColor = '#000000';
    iframe.allow =
        'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share; fullscreen';
    iframe.setAttribute('allowfullscreen', 'true');
    return iframe;
  });

  return HtmlElementView(
    key: ValueKey(uniqueId),
    viewType: uniqueId,
  );
}
