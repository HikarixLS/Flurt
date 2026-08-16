import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/home/home_cubit.dart';
import '../../blocs/home/home_state.dart';
import '../../widgets/hero/hero_banner.dart';
import '../../widgets/movie/movie_slider.dart';
import '../../widgets/navbar/app_navbar.dart';
import '../../widgets/party/create_party_dialog.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.isLoading && state.heroMovies.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Đang tải dữ liệu điện ảnh...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          if (state.errorMessage != null && state.heroMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.accentRose),
                  const SizedBox(height: 12),
                  Text(state.errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HomeCubit>().fetchHomeData(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Spotlight Carousel
                HeroBanner(featuredMovies: state.heroMovies),

                const SizedBox(height: 24),

                // Watch Party Promo Banner
                _buildWatchPartyPromo(context),

                const SizedBox(height: 24),

                // Newly Updated Slider
                MovieSlider(
                  title: 'Phim Mới Cập Nhật',
                  subtitle: 'Những tập phim và tựa phim mới nhất trên hệ thống',
                  icon: Icons.auto_awesome_rounded,
                  movies: state.newlyUpdated,
                  onViewAll: () => context.go('/catalog'),
                ),

                const SizedBox(height: 20),

                // Single Movies Slider
                MovieSlider(
                  title: 'Phim Lẻ Chiếu Rạp',
                  subtitle: 'Phim điện ảnh bom tấn hấp dẫn chuẩn HD',
                  icon: Icons.movie_filter_rounded,
                  movies: state.singleMovies,
                  onViewAll: () => context.go('/catalog?type=phim-le'),
                ),

                const SizedBox(height: 20),

                // Series Movies Slider
                MovieSlider(
                  title: 'Phim Bộ Dài Tập',
                  subtitle: 'Phim truyền hình lôi cuốn, cập nhật liên tục',
                  icon: Icons.tv_rounded,
                  movies: state.seriesMovies,
                  onViewAll: () => context.go('/catalog?type=phim-bo'),
                ),

                const SizedBox(height: 20),

                // TV Shows Slider
                MovieSlider(
                  title: 'TV Shows & Truyền Hình',
                  subtitle: 'Chương trình giải trí, gameshow nổi bật',
                  icon: Icons.live_tv_rounded,
                  movies: state.tvShows,
                  onViewAll: () => context.go('/catalog?type=tv-shows'),
                ),

                const SizedBox(height: 20),

                // Animations Slider
                MovieSlider(
                  title: 'Anime & Phim Hoạt Hình',
                  subtitle: 'Thế giới hoạt hình đặc sắc từ Nhật Bản và thế giới',
                  icon: Icons.animation_rounded,
                  movies: state.animationMovies,
                  onViewAll: () => context.go('/catalog?genre=hoat-hinh'),
                ),

                const SizedBox(height: 48),

                // Footer
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWatchPartyPromo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A), Color(0xFF0C4A6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.groups_rounded, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'TÍNH NĂNG ĐẶC BIỆT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Xem Phim Cùng Nhau Thời Gian Thực (Watch Party)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tạo phòng 6 chữ số, đồng bộ phát/tạm dừng/tua chuẩn xác, trò chuyện và thả reaction emoji trực tiếp cùng bạn bè!',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CreatePartyDialog(),
              );
            },
            icon: const Icon(Icons.bolt_rounded),
            label: const Text('Bắt Đầu Xem Chung'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  'FLURT CINEMA & WATCH PARTY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Ứng dụng xem phim Full-Stack Dart & Flutter Web • Tích hợp API NguonC • Đồng bộ phòng xem chung Real-Time',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
