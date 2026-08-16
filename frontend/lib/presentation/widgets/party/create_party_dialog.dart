import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/watch_party/watch_party_cubit.dart';

class CreatePartyDialog extends StatefulWidget {
  final String? initialMovieSlug;
  final String? initialMovieTitle;
  final String? initialPosterUrl;
  final String? initialRoomCode;

  const CreatePartyDialog({
    super.key,
    this.initialMovieSlug,
    this.initialMovieTitle,
    this.initialPosterUrl,
    this.initialRoomCode,
  });

  @override
  State<CreatePartyDialog> createState() => _CreatePartyDialogState();
}

class _CreatePartyDialogState extends State<CreatePartyDialog> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _nicknameController = TextEditingController(text: 'Khán giả ${DateTime.now().millisecond}');
  final TextEditingController _roomCodeController = TextEditingController();
  final TextEditingController _movieSearchController = TextEditingController();
  String _selectedAvatar = '🍿';
  bool _isLoading = false;

  final List<String> _avatars = ['🍿', '🎬', '👑', '🐱', '🦊', '🚀', '🐼', '🔥', '✨', '⚡'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialRoomCode != null ? 1 : 0,
    );
    if (widget.initialRoomCode != null) {
      _roomCodeController.text = widget.initialRoomCode!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nicknameController.dispose();
    _roomCodeController.dispose();
    _movieSearchController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateRoom() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) return;

    final movieSlug = widget.initialMovieSlug ?? 'cuc-han-2026';
    final movieTitle = widget.initialMovieTitle ?? 'Cực Hạn (2026)';
    final posterUrl = widget.initialPosterUrl ?? '';

    setState(() => _isLoading = true);

    final cubit = context.read<WatchPartyCubit>();
    cubit.setIdentity(nickname: nickname, avatar: _selectedAvatar);

    final roomId = await cubit.createPartyRoom(
      movieSlug: movieSlug,
      movieTitle: movieTitle,
      posterUrl: posterUrl,
      nickname: nickname,
      avatar: _selectedAvatar,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (roomId != null) {
        Navigator.of(context).pop();
        context.go('/watch-party?room=$roomId');
      }
    }
  }

  Future<void> _handleJoinRoom() async {
    final code = _roomCodeController.text.trim().toUpperCase();
    final nickname = _nicknameController.text.trim();

    if (code.isEmpty || nickname.isEmpty) return;

    final cubit = context.read<WatchPartyCubit>();
    cubit.setIdentity(nickname: nickname, avatar: _selectedAvatar);

    Navigator.of(context).pop();
    context.go('/watch-party?room=$code');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 440,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.surfaceElevated, AppColors.surface],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.groups_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Flurt Watch Party',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primaryLight,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(text: 'Tạo phòng mới'),
                Tab(text: 'Tham gia bằng mã'),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nickname
                  const Text(
                    'Biệt danh của bạn',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nicknameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên hiển thị...',
                      prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppColors.textMuted),
                      fillColor: AppColors.surfaceElevated,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Avatar Picker
                  const Text(
                    'Chọn biểu tượng đại diện',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _avatars.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final av = _avatars[index];
                        final isSelected = av == _selectedAvatar;

                        return InkWell(
                          onTap: () => setState(() => _selectedAvatar = av),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(av, style: const TextStyle(fontSize: 18)),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab Views Content
                  SizedBox(
                    height: 130,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Create Tab
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Phim được chọn:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.movie_outlined, color: AppColors.secondary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.initialMovieTitle ?? 'Cực Hạn (2026) - Mặc định',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _handleCreateRoom,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.add_circle_outline, size: 18),
                                label: Text(_isLoading ? 'Đang tạo phòng...' : 'Tạo phòng xem ngay'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Join Tab
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mã phòng (6 ký tự)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _roomCodeController,
                              textCapitalization: TextCapitalization.characters,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                color: AppColors.secondary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'VD: ABC123',
                                prefixIcon: const Icon(Icons.tag, size: 18, color: AppColors.textMuted),
                                fillColor: AppColors.surfaceElevated,
                              ),
                              onSubmitted: (_) => _handleJoinRoom(),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: _handleJoinRoom,
                                icon: const Icon(Icons.login_rounded, size: 18),
                                label: const Text('Tham gia phòng'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
