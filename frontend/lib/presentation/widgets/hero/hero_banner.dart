import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/film_item_model.dart';
import '../party/create_party_dialog.dart';

class HeroBanner extends StatefulWidget {
  final List<FilmItemModel> featuredMovies;

  const HeroBanner({
    super.key,
    required this.featuredMovies,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  int _currentIndex = 0;
  Timer? _autoPlayTimer;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.featuredMovies.length > 1) {
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 7), (_) {
        if (!mounted) return;
        final nextIndex = (_currentIndex + 1) % widget.featuredMovies.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _cleanDescription(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featuredMovies.isEmpty) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final bannerHeight = size.height > 850 ? 540.0 : 460.0;

    return SizedBox(
      height: bannerHeight,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.featuredMovies.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final movie = widget.featuredMovies[index];
              return _buildSlide(context, movie);
            },
          ),

          // Bottom Slide Indicators
          if (widget.featuredMovies.length > 1)
            Positioned(
              bottom: 24,
              right: 32,
              child: Row(
                children: List.generate(widget.featuredMovies.length, (idx) {
                  final isCurrent = idx == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isCurrent ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.primaryLight : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlide(BuildContext context, FilmItemModel movie) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Backdrop Image
        CachedNetworkImage(
          imageUrl: movie.posterUrl.isNotEmpty ? movie.posterUrl : movie.thumbUrl,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          placeholder: (_, __) => Container(color: AppColors.surface),
          errorWidget: (_, __, ___) => Container(color: AppColors.surface),
        ),

        // Gradient Left-to-Right and Top-to-Bottom
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF080B11),
                Color(0xEE080B11),
                Color(0x99080B11),
                Colors.transparent,
              ],
              stops: [0.0, 0.35, 0.65, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.heroOverlayGradient,
          ),
        ),

        // Content
        Positioned(
          left: isMobile ? 20 : 48,
          bottom: isMobile ? 24 : 48,
          right: isMobile ? 20 : (size.width * 0.35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'HOT SPOTLIGHT',
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
                  const SizedBox(width: 10),
                  if (movie.quality != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentRose,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        movie.quality!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  if (movie.currentEpisode != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        movie.currentEpisode!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Title
              Text(
                movie.name,
                style: TextStyle(
                  fontSize: isMobile ? 24 : 38,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.15,
                  letterSpacing: -0.5,
                  shadows: const [
                    Shadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 2)),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (movie.originalName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  movie.originalName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Description
              if (movie.description != null && movie.description!.isNotEmpty)
                Text(
                  _cleanDescription(movie.description),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 20),

              // Action Buttons
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (movie.slug.isNotEmpty) {
                        context.go('/film/${movie.slug}');
                      }
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text('Xem Ngay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => CreatePartyDialog(
                          initialMovieSlug: movie.slug,
                          initialMovieTitle: movie.name,
                          initialPosterUrl: movie.posterUrl,
                        ),
                      );
                    },
                    icon: const Icon(Icons.groups_rounded, size: 20),
                    label: const Text('Tạo Phòng Watch Party'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      shadowColor: AppColors.primary.withValues(alpha: 0.6),
                      elevation: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
