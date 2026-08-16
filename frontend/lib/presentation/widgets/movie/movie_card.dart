import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/film_item_model.dart';
import '../party/create_party_dialog.dart';

class MovieCard extends StatefulWidget {
  final FilmItemModel movie;
  final double width;
  final double height;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 175,
    this.height = 250,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (movie.slug.isNotEmpty) {
            context.go('/film/${movie.slug}');
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          curve: Curves.easeOutCubic,
          transform: _isHovered
              ? Matrix4.translationValues(0, -6, 0)
              : Matrix4.identity(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Frame
              Container(
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isHovered
                        ? AppColors.primary.withValues(alpha: 0.8)
                        : AppColors.border,
                    width: _isHovered ? 1.5 : 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          const BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Poster Image
                    CachedNetworkImage(
                      imageUrl: movie.posterUrl.isNotEmpty ? movie.posterUrl : movie.thumbUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceElevated,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceElevated,
                        child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                      ),
                    ),

                    // Top Left Badges (Quality & Language)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        children: [
                          if (movie.quality != null && movie.quality!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentRose,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                movie.quality!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (movie.language != null && movie.language!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white24, width: 0.8),
                              ),
                              child: Text(
                                movie.language!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Top Right Episode Badge
                    if (movie.currentEpisode != null && movie.currentEpisode!.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            movie.currentEpisode!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                    // Dark Gradient Bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.cardOverlayGradient,
                        ),
                      ),
                    ),

                    // Hover Play & Party Button Overlay
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black45,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.6),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => CreatePartyDialog(
                                        initialMovieSlug: movie.slug,
                                        initialMovieTitle: movie.name,
                                        initialPosterUrl: movie.posterUrl,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.secondary),
                                    ),
                                    child: const Icon(
                                      Icons.groups_rounded,
                                      color: AppColors.secondary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Title & Year
              Text(
                movie.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              Row(
                children: [
                  if (movie.year != null && movie.year!.isNotEmpty)
                    Text(
                      movie.year!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  if (movie.year != null && movie.year!.isNotEmpty && movie.time != null)
                    const Text(' • ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  if (movie.time != null && movie.time!.isNotEmpty)
                    Expanded(
                      child: Text(
                        movie.time!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
