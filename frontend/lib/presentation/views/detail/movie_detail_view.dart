import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/detail/movie_detail_cubit.dart';
import '../../blocs/detail/movie_detail_state.dart';
import '../../widgets/movie/movie_slider.dart';
import '../../widgets/navbar/app_navbar.dart';
import '../../widgets/party/create_party_dialog.dart';
import '../../widgets/player/cinema_video_player.dart';

class MovieDetailView extends StatefulWidget {
  final String slug;

  const MovieDetailView({super.key, required this.slug});

  @override
  State<MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<MovieDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<MovieDetailCubit>().fetchMovieDetail(widget.slug);
  }

  @override
  void didUpdateWidget(MovieDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      context.read<MovieDetailCubit>().fetchMovieDetail(widget.slug);
    }
  }

  String _cleanDescription(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Đang nạp nguồn phim...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          if (state.errorMessage != null || state.movie == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.accentRose),
                  const SizedBox(height: 12),
                  Text(state.errorMessage ?? 'Không tìm thấy phim', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<MovieDetailCubit>().fetchMovieDetail(widget.slug),
                    child: const Text('Tải lại'),
                  ),
                ],
              ),
            );
          }

          final movie = state.movie!;
          final currentEpisode = state.currentEpisode;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cinema Video Player Area
                Container(
                  color: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: state.isCinemaMode ? 0 : 24,
                    vertical: state.isCinemaMode ? 0 : 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: CinemaVideoPlayer(
                        streamUrl: currentEpisode?.activeStreamUrl ?? '',
                        isEmbed: state.isEmbedMode || (currentEpisode != null && !currentEpisode.isDirectStream),
                        movieTitle: movie.name,
                        episodeName: currentEpisode?.name ?? 'Tập 1',
                        isCinemaMode: state.isCinemaMode,
                        onToggleCinemaMode: () => context.read<MovieDetailCubit>().toggleCinemaMode(),
                      ),
                    ),
                  ),
                ),

                // Controls & Episodes Selector & Movie Details
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Watch Party & Stream Action Toolbar
                          _buildActionBar(context, state),

                          const SizedBox(height: 24),

                          // Server Switcher & Episode Grid
                          if (movie.episodes.isNotEmpty)
                            _buildEpisodesSection(context, state),

                          const SizedBox(height: 28),

                          // Movie Metadata & Synopsis
                          _buildMovieDetails(context, movie),

                          const SizedBox(height: 36),

                          // Related Movies
                          if (state.relatedMovies.isNotEmpty)
                            MovieSlider(
                              title: 'Phim Liên Quan & Đề Xuất',
                              subtitle: 'Các tựa phim hấp dẫn có thể bạn sẽ thích',
                              icon: Icons.recommend_rounded,
                              movies: state.relatedMovies,
                            ),

                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, MovieDetailState state) {
    final movie = state.movie!;
    final currentEpisode = state.currentEpisode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Title snippet
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (currentEpisode != null)
                Text(
                  'Đang chọn: ${currentEpisode.name} (${state.currentServer?.serverName ?? "Server 1"})',
                  style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                ),
            ],
          ),

          // Action Buttons
          Wrap(
            spacing: 10,
            children: [
              // Watch Party Button
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
                icon: const Icon(Icons.groups_rounded, size: 18),
                label: const Text('Tạo Phòng Xem Chung'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),

              // Cinema Mode Toggle
              OutlinedButton.icon(
                onPressed: () => context.read<MovieDetailCubit>().toggleCinemaMode(),
                icon: Icon(
                  state.isCinemaMode ? Icons.fullscreen_exit : Icons.fullscreen,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                label: Text(state.isCinemaMode ? 'Thoát Rạp Phim' : 'Chế Độ Rạp Phim'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              // Share Button
              OutlinedButton.icon(
                onPressed: () {
                  final url = Uri.base.toString();
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép liên kết phim vào bộ nhớ tạm!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.share_outlined, size: 16, color: AppColors.textSecondary),
                label: const Text('Chia sẻ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesSection(BuildContext context, MovieDetailState state) {
    final movie = state.movie!;
    final cubit = context.read<MovieDetailCubit>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Server Switcher
          Row(
            children: [
              const Icon(Icons.video_library_outlined, color: AppColors.primaryLight, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Danh Sách Tập Phim',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Server tabs
              if (movie.episodes.length > 1)
                Wrap(
                  spacing: 6,
                  children: List.generate(movie.episodes.length, (idx) {
                    final isSelected = idx == state.selectedServerIndex;
                    return InkWell(
                      onTap: () => cubit.selectServer(idx),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryLight : AppColors.border,
                          ),
                        ),
                        child: Text(
                          movie.episodes[idx].serverName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),

          // Episodes Grid
          if (state.currentServer != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(state.currentServer!.items.length, (epIdx) {
                final ep = state.currentServer!.items[epIdx];
                final isCurrent = epIdx == state.selectedEpisodeIndex;

                return InkWell(
                  onTap: () => cubit.selectEpisode(epIdx),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.primary : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent ? AppColors.primaryLight : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrent) ...[
                          const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          ep.name.startsWith('Tập') ? ep.name : 'Tập ${ep.name}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCurrent ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildMovieDetails(BuildContext context, dynamic movie) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 650;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              if (!isMobile) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 180,
                    height: 260,
                    child: CachedNetworkImage(
                      imageUrl: movie.posterUrl.isNotEmpty ? movie.posterUrl : movie.thumbUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.surfaceElevated),
                      errorWidget: (_, __, ___) => Container(color: AppColors.surfaceElevated),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],

              // Meta Details & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    if (movie.originalName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        movie.originalName,
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Badges row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (movie.quality.isNotEmpty)
                          _buildBadge(movie.quality, AppColors.accentRose),
                        if (movie.language.isNotEmpty)
                          _buildBadge(movie.language, Colors.blueGrey),
                        if (movie.currentEpisode.isNotEmpty)
                          _buildBadge(movie.currentEpisode, AppColors.secondary, isDarkText: true),
                        if (movie.year.isNotEmpty)
                          _buildBadge(movie.year, AppColors.surfaceElevated),
                        if (movie.time.isNotEmpty)
                          _buildBadge(movie.time, AppColors.surfaceElevated),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Genres
                    if (movie.genres.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: movie.genres.map<Widget>((g) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              g,
                              style: const TextStyle(fontSize: 11, color: AppColors.primaryLight),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Casts & Directors
                    if (movie.casts != null && movie.casts!.isNotEmpty) ...[
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                          children: [
                            const TextSpan(text: 'Diễn viên: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                            TextSpan(text: movie.casts),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],

                    if (movie.director != null && movie.director!.isNotEmpty) ...[
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                          children: [
                            const TextSpan(text: 'Đạo diễn: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                            TextSpan(text: movie.director),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 12),

                    // Synopsis
                    const Text(
                      'Nội dung phim:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _cleanDescription(movie.description),
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(String label, Color color, {bool isDarkText = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDarkText ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
