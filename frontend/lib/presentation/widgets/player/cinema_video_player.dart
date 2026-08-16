import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import 'platform_iframe_player.dart';

class CinemaVideoPlayer extends StatefulWidget {
  final String streamUrl;
  final bool isEmbed;
  final String movieTitle;
  final String episodeName;
  final bool isCinemaMode;
  final VoidCallback? onToggleCinemaMode;
  final Function(double seconds)? onSeek;
  final Function(double seconds)? onPlay;
  final Function(double seconds)? onPause;
  final Function(double current, double total)? onProgress;
  final double? targetSeekSeconds;
  final bool isPartySynced;
  final String viewId;

  const CinemaVideoPlayer({
    super.key,
    required this.streamUrl,
    this.isEmbed = true,
    this.movieTitle = '',
    this.episodeName = '',
    this.isCinemaMode = false,
    this.onToggleCinemaMode,
    this.onSeek,
    this.onPlay,
    this.onPause,
    this.onProgress,
    this.targetSeekSeconds,
    this.isPartySynced = false,
    this.viewId = 'cinema',
  });

  @override
  State<CinemaVideoPlayer> createState() => _CinemaVideoPlayerState();
}

class _CinemaVideoPlayerState extends State<CinemaVideoPlayer> {
  VideoPlayerController? _videoController;
  bool _isDirectPlayerInitialized = false;
  final bool _showControls = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (!widget.isEmbed && widget.streamUrl.isNotEmpty) {
      _initDirectPlayer(widget.streamUrl);
    }
  }

  @override
  void didUpdateWidget(CinemaVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl || oldWidget.isEmbed != widget.isEmbed) {
      if (!widget.isEmbed && widget.streamUrl.isNotEmpty) {
        _initDirectPlayer(widget.streamUrl);
      } else {
        _disposeDirectPlayer();
      }
    }

    if (widget.targetSeekSeconds != null &&
        widget.targetSeekSeconds != oldWidget.targetSeekSeconds &&
        _videoController != null &&
        _isDirectPlayerInitialized) {
      _videoController!.seekTo(Duration(milliseconds: (widget.targetSeekSeconds! * 1000).toInt()));
    }
  }

  Future<void> _initDirectPlayer(String url) async {
    await _disposeDirectPlayer();
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      _videoController!.addListener(_onDirectPlayerUpdate);
      setState(() {
        _isDirectPlayerInitialized = true;
      });
      _videoController!.play();
    } catch (e) {
      setState(() {
        _isDirectPlayerInitialized = false;
      });
    }
  }

  void _onDirectPlayerUpdate() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    final pos = _videoController!.value.position.inMilliseconds / 1000.0;
    final dur = _videoController!.value.duration.inMilliseconds / 1000.0;
    widget.onProgress?.call(pos, dur);
  }

  Future<void> _disposeDirectPlayer() async {
    if (_videoController != null) {
      _videoController!.removeListener(_onDirectPlayerUpdate);
      await _videoController!.dispose();
      _videoController = null;
      _isDirectPlayerInitialized = false;
    }
  }

  @override
  void dispose() {
    _disposeDirectPlayer();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (_videoController != null && _isDirectPlayerInitialized) {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          widget.onPause?.call(_videoController!.value.position.inMilliseconds / 1000.0);
        } else {
          _videoController!.play();
          widget.onPlay?.call(_videoController!.value.position.inMilliseconds / 1000.0);
        }
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_videoController != null && _isDirectPlayerInitialized) {
        final current = _videoController!.value.position;
        final target = current + const Duration(seconds: 10);
        _videoController!.seekTo(target);
        widget.onSeek?.call(target.inMilliseconds / 1000.0);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_videoController != null && _isDirectPlayerInitialized) {
        final current = _videoController!.value.position;
        final target = current - const Duration(seconds: 10);
        _videoController!.seekTo(target < Duration.zero ? Duration.zero : target);
        widget.onSeek?.call((target < Duration.zero ? Duration.zero : target).inMilliseconds / 1000.0);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
      widget.onToggleCinemaMode?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: widget.isCinemaMode ? BorderRadius.zero : BorderRadius.circular(16),
            border: Border.all(
              color: widget.isPartySynced ? AppColors.primary.withValues(alpha: 0.6) : AppColors.border,
              width: widget.isPartySynced ? 2 : 1,
            ),
            boxShadow: widget.isPartySynced
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    )
                  ]
                : [
                    const BoxShadow(
                      color: Colors.black54,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Player Area
              if (widget.isEmbed || !_isDirectPlayerInitialized)
                PlatformIframePlayer(
                  iframeUrl: widget.streamUrl,
                  viewId: widget.viewId,
                )
              else if (_videoController != null && _isDirectPlayerInitialized)
                VideoPlayer(_videoController!)
              else
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),

              // Cinema Header Overlay
              if (_showControls && widget.movieTitle.isNotEmpty)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xCC000000), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (widget.isPartySynced) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.groups, size: 14, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'WATCH PARTY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            '${widget.movieTitle} - ${widget.episodeName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.onToggleCinemaMode != null)
                          IconButton(
                            icon: Icon(
                              widget.isCinemaMode ? Icons.fullscreen_exit : Icons.fullscreen,
                              color: Colors.white70,
                            ),
                            tooltip: widget.isCinemaMode ? 'Thoát rạp phim (F)' : 'Chế độ rạp phim (F)',
                            onPressed: widget.onToggleCinemaMode,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
