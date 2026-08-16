import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/catalog/catalog_cubit.dart';
import '../../blocs/catalog/catalog_state.dart';
import '../../widgets/movie/movie_card.dart';
import '../../widgets/navbar/app_navbar.dart';

class CatalogView extends StatefulWidget {
  final String? initialType;
  final String? initialGenre;
  final String? initialCountry;
  final String? initialYear;

  const CatalogView({
    super.key,
    this.initialType,
    this.initialGenre,
    this.initialCountry,
    this.initialYear,
  });

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<CatalogCubit>().initCatalog(
          type: widget.initialType,
          genre: widget.initialGenre,
          country: widget.initialCountry,
          year: widget.initialYear,
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Kho Phim Điện Ảnh & Truyền Hình',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Khám phá hơn hàng ngàn bộ phim bom tấn cập nhật liên tục',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),

                const SizedBox(height: 20),

                // Filters Container
                _buildFilters(context, state),

                const SizedBox(height: 24),

                // Results Count
                Row(
                  children: [
                    Text(
                      'Hiển thị: ${state.movies.length} kết quả (Trang ${state.currentPage}/${state.totalPages})',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Movie Grid
                if (state.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (state.errorMessage != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 44, color: AppColors.accentRose),
                          const SizedBox(height: 10),
                          Text(state.errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.read<CatalogCubit>().fetchMovies(page: 1, isRefresh: true),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.movies.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'Không tìm thấy bộ phim nào phù hợp với bộ lọc.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildGrid(state),

                const SizedBox(height: 32),

                // Pagination Buttons
                if (state.totalPages > 1 && !state.isLoading)
                  _buildPagination(context, state),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context, CatalogState state) {
    final cubit = context.read<CatalogCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Format Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Tất cả định dạng',
                  isSelected: state.selectedType == 'all' && state.selectedGenre == null && state.selectedCountry == null && state.selectedYear == null,
                  onTap: () => cubit.resetFilters(),
                ),
                _buildFilterChip(
                  label: 'Phim Lẻ',
                  isSelected: state.selectedType == 'phim-le',
                  onTap: () => cubit.setType('phim-le'),
                ),
                _buildFilterChip(
                  label: 'Phim Bộ',
                  isSelected: state.selectedType == 'phim-bo',
                  onTap: () => cubit.setType('phim-bo'),
                ),
                _buildFilterChip(
                  label: 'TV Shows',
                  isSelected: state.selectedType == 'tv-shows',
                  onTap: () => cubit.setType('tv-shows'),
                ),
                _buildFilterChip(
                  label: 'Đang Chiếu',
                  isSelected: state.selectedType == 'dang-chieu',
                  onTap: () => cubit.setType('dang-chieu'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Row 2: Genre Dropdown & Country Dropdown & Year Dropdown
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              // Genre Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: state.selectedGenre != null ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: state.selectedGenre,
                    hint: const Text('Thể loại', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    dropdownColor: AppColors.surfaceElevated,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tất cả thể loại')),
                      ...ApiConstants.genres.map(
                        (g) => DropdownMenuItem(value: g['slug'], child: Text(g['name']!)),
                      ),
                    ],
                    onChanged: (val) => cubit.setGenre(val),
                  ),
                ),
              ),

              // Country Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: state.selectedCountry != null ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: state.selectedCountry,
                    hint: const Text('Quốc gia', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    dropdownColor: AppColors.surfaceElevated,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tất cả quốc gia')),
                      ...ApiConstants.countries.map(
                        (c) => DropdownMenuItem(value: c['slug'], child: Text(c['name']!)),
                      ),
                    ],
                    onChanged: (val) => cubit.setCountry(val),
                  ),
                ),
              ),

              // Year Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: state.selectedYear != null ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: state.selectedYear,
                    hint: const Text('Năm phát hành', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    dropdownColor: AppColors.surfaceElevated,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tất cả các năm')),
                      ...ApiConstants.years.map(
                        (y) => DropdownMenuItem(value: y, child: Text(y)),
                      ),
                    ],
                    onChanged: (val) => cubit.setYear(val),
                  ),
                ),
              ),

              // Reset Button
              TextButton.icon(
                onPressed: () => cubit.resetFilters(),
                icon: const Icon(Icons.refresh, size: 16, color: AppColors.textMuted),
                label: const Text('Đặt lại', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryLight : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(CatalogState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 5;
        if (width < 600) {
          crossAxisCount = 2;
        } else if (width < 900) {
          crossAxisCount = 3;
        } else if (width < 1200) {
          crossAxisCount = 4;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.58,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
          ),
          itemCount: state.movies.length,
          itemBuilder: (context, index) {
            return MovieCard(
              movie: state.movies[index],
              width: double.infinity,
              height: (width / crossAxisCount) * 1.35,
            );
          },
        );
      },
    );
  }

  Widget _buildPagination(BuildContext context, CatalogState state) {
    final cubit = context.read<CatalogCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: state.currentPage > 1
              ? () {
                  cubit.fetchMovies(page: state.currentPage - 1, isRefresh: true);
                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                }
              : null,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Trang trước'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'Trang ${state.currentPage} / ${state.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: state.hasMore
              ? () {
                  cubit.fetchMovies(page: state.currentPage + 1, isRefresh: true);
                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                }
              : null,
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: const Text('Trang sau'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
