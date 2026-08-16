import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../party/create_party_dialog.dart';

class AppNavbar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final Function(String)? onSearchSubmitted;

  const AppNavbar({
    super.key,
    this.searchController,
    this.onSearchSubmitted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.go('/search?q=${Uri.encodeComponent(query)}');
      widget.onSearchSubmitted?.call(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Row(
            children: [
              // Logo
              InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      ShaderMask(
                        shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                        child: const Text(
                          'FLURT',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'PARTY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Navigation Links (Desktop)
              if (!isMobile) ...[
                _buildNavLink(context, 'Trang chủ', '/'),
                _buildNavLink(context, 'Danh mục', '/catalog'),
                _buildNavLink(context, 'Phim lẻ', '/catalog?type=phim-le'),
                _buildNavLink(context, 'Phim bộ', '/catalog?type=phim-bo'),
                _buildNavLink(context, 'TV Shows', '/catalog?type=tv-shows'),
                _buildNavLink(context, 'Hoạt hình', '/catalog?genre=hoat-hinh'),
              ],

              const Spacer(),

              // Search Bar
              Container(
                width: isMobile ? 140 : 260,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: isMobile ? 'Tìm...' : 'Tìm kiếm phim, diễn viên...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _submitSearch(),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              const SizedBox(width: 14),

              // Watch Party Button
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CreatePartyDialog(),
                  );
                },
                icon: const Icon(Icons.groups_rounded, size: 18),
                label: Text(isMobile ? 'Party' : 'Watch Party'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String title, String route) {
    final currentLoc = GoRouterState.of(context).uri.toString();
    final isSelected = (route == '/' && currentLoc == '/') || (route != '/' && currentLoc.startsWith(route));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
