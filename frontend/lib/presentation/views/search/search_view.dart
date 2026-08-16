import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/search/search_cubit.dart';
import '../../blocs/search/search_state.dart';
import '../../widgets/movie/movie_card.dart';
import '../../widgets/navbar/app_navbar.dart';

class SearchView extends StatefulWidget {
  final String? initialQuery;

  const SearchView({super.key, this.initialQuery});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SearchCubit>().search(query: widget.initialQuery!, page: 1, isRefresh: true);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppNavbar(
        searchController: _controller,
        onSearchSubmitted: (q) {
          context.read<SearchCubit>().search(query: q, page: 1, isRefresh: true);
        },
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input Box
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: widget.initialQuery == null || widget.initialQuery!.isEmpty,
                    style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên phim, đạo diễn, diễn viên cần tìm...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryLight, size: 24),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: AppColors.textMuted),
                              onPressed: () {
                                _controller.clear();
                                context.read<SearchCubit>().clearSearch();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                    onChanged: (val) => context.read<SearchCubit>().onQueryChanged(val),
                    onSubmitted: (val) => context.read<SearchCubit>().search(query: val, page: 1, isRefresh: true),
                  ),
                ),

                const SizedBox(height: 16),

                // Popular / Recent Searches Chips
                if (state.recentSearches.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      const Text(
                        'Từ khóa gợi ý & tìm kiếm gần đây:',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: state.recentSearches.map((term) {
                      return InkWell(
                        onTap: () {
                          _controller.text = term;
                          context.read<SearchCubit>().search(query: term, page: 1, isRefresh: true);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            term,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Search Results Header
                if (state.query.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        'Kết quả tìm kiếm cho: "${state.query}"',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (!state.isSearching)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${state.totalItems} kết quả',
                            style: const TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Grid or States
                if (state.isSearching)
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
                          const Icon(Icons.error_outline, size: 40, color: AppColors.accentRose),
                          const SizedBox(height: 10),
                          Text(state.errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  )
                else if (state.query.isNotEmpty && state.results.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'Không tìm thấy kết quả nào cho "${state.query}"',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Hãy thử tìm kiếm với tên phim tiếng Việt hoặc tiếng Anh khác.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.results.isNotEmpty)
                  LayoutBuilder(
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
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: state.results[index],
                            width: double.infinity,
                            height: (width / crossAxisCount) * 1.35,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
