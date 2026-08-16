import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/film_item_model.dart';
import 'movie_card.dart';

class MovieSlider extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<FilmItemModel> movies;
  final VoidCallback? onViewAll;

  const MovieSlider({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.movies,
    this.onViewAll,
  });

  @override
  State<MovieSlider> createState() => _MovieSliderState();
}

class _MovieSliderState extends State<MovieSlider> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 600,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 600,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, color: AppColors.primaryLight, size: 18),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),

              // Scroll Navigation Buttons
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                onPressed: _scrollLeft,
                splashRadius: 20,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onPressed: _scrollRight,
                splashRadius: 20,
              ),

              if (widget.onViewAll != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: widget.onViewAll,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Xem tất cả',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.secondary),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Horizontal List
        SizedBox(
          height: 310,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: widget.movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return MovieCard(movie: widget.movies[index]);
            },
          ),
        ),
      ],
    );
  }
}
