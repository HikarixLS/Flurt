import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/watch_party/watch_party_cubit.dart';
import '../../blocs/watch_party/watch_party_state.dart';
import '../../widgets/navbar/app_navbar.dart';
import '../../widgets/party/create_party_dialog.dart';
import '../../widgets/party/party_chat_panel.dart';
import '../../widgets/party/party_participants_panel.dart';
import '../../widgets/party/reaction_overlay.dart';
import '../../widgets/player/cinema_video_player.dart';

class WatchPartyView extends StatefulWidget {
  final String? roomId;

  const WatchPartyView({super.key, this.roomId});

  @override
  State<WatchPartyView> createState() => _WatchPartyViewState();
}

class _WatchPartyViewState extends State<WatchPartyView> {
  bool _isCinemaMode = false;
  int _activeSideTab = 0; // 0: Chat, 1: Participants

  @override
  void initState() {
    super.initState();
    _checkAndJoinRoom();
  }

  @override
  void didUpdateWidget(WatchPartyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomId != widget.roomId) {
      _checkAndJoinRoom();
    }
  }

  void _checkAndJoinRoom() {
    final roomId = widget.roomId;
    if (roomId != null && roomId.isNotEmpty) {
      final cubit = context.read<WatchPartyCubit>();
      if (cubit.state.roomId != roomId || cubit.state.status != WsConnectionStatus.connected) {
        cubit.joinPartyRoom(roomId: roomId);
      }
    }
  }

  void _copyRoomLink(BuildContext context, String roomId) {
    final currentUrl = Uri.base.origin;
    final shareUrl = '$currentUrl/watch-party?room=$roomId';
    Clipboard.setData(ClipboardData(text: shareUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép link mời: $shareUrl'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      body: BlocConsumer<WatchPartyCubit, WatchPartyState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.accentRose,
              ),
            );
          }
        },
        builder: (context, state) {
          // If no room is specified or initial disconnected state
          if (widget.roomId == null && state.roomId == null) {
            return _buildNoRoomPrompt(context);
          }

          if (state.status == WsConnectionStatus.connecting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Đang kết nối phòng Watch Party...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final cubit = context.read<WatchPartyCubit>();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 960;

              return Row(
                children: [
                  // Main Video Player & Controls Area
                  Expanded(
                    flex: isDesktop ? 7 : 12,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isDesktop ? 20 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Watch Party Header Bar
                          _buildPartyHeaderBar(context, state, cubit),

                          const SizedBox(height: 14),

                          // Player Canvas with Reaction Overlay
                          Stack(
                            children: [
                              CinemaVideoPlayer(
                                streamUrl: state.streamUrl,
                                isEmbed: state.isEmbed,
                                movieTitle: state.movieTitle,
                                episodeName: state.episodeName,
                                isCinemaMode: _isCinemaMode,
                                isPartySynced: true,
                                targetSeekSeconds: state.pendingSeekSeconds,
                                onToggleCinemaMode: () => setState(() => _isCinemaMode = !_isCinemaMode),
                                onPlay: (s) => cubit.sendPlay(s),
                                onPause: (s) => cubit.sendPause(s),
                                onSeek: (s) => cubit.sendSeek(s),
                                onProgress: (cur, tot) {
                                  cubit.updateLocalPlayback(cur, state.isPlaying);
                                },
                              ),

                              // Floating Emoji Reaction Overlay
                              Positioned.fill(
                                child: ReactionOverlay(reactions: state.activeReactions),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Control Permission Banner
                          _buildControlNotice(state),

                          const SizedBox(height: 16),

                          // Mobile Tabs for Chat / Participants
                          if (!isDesktop) ...[
                            _buildMobileSideTabs(context, state, cubit),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Right Sidebar (Desktop Chat & Roster)
                  if (isDesktop)
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: double.infinity,
                        margin: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
                        child: Column(
                          children: [
                            // Side Tabs
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildSideTabButton(
                                      label: 'Chat (${state.messages.length})',
                                      icon: Icons.chat_bubble_outline,
                                      isSelected: _activeSideTab == 0,
                                      onTap: () => setState(() => _activeSideTab = 0),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildSideTabButton(
                                      label: 'Thành viên (${state.participants.length})',
                                      icon: Icons.people_outline,
                                      isSelected: _activeSideTab == 1,
                                      onTap: () => setState(() => _activeSideTab = 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Tab View
                            Expanded(
                              child: _activeSideTab == 0
                                  ? PartyChatPanel(
                                      messages: state.messages,
                                      roomId: state.roomId,
                                      participantCount: state.participants.length,
                                      onSendMessage: (txt) => cubit.sendChat(txt),
                                      onSendReaction: (emoji) => cubit.sendReaction(emoji),
                                    )
                                  : PartyParticipantsPanel(
                                      participants: state.participants,
                                      hostId: state.hostId,
                                      isHostOnlyControl: state.isHostOnlyControl,
                                      isCurrentUserHost: state.isHost,
                                      onToggleHostControl: () => cubit.toggleHostOnlyControl(),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPartyHeaderBar(BuildContext context, WatchPartyState state, WatchPartyCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.groups_rounded, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      state.roomName ?? 'Phòng xem phim chung',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentEmerald.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.accentEmerald.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_manual_record, size: 8, color: AppColors.accentEmerald),
                          SizedBox(width: 4),
                          Text(
                            'LIVE SYNC',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentEmerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  '${state.movieTitle} • ${state.episodeName}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Copy Link Button
          if (state.roomId != null)
            ElevatedButton.icon(
              onPressed: () => _copyRoomLink(context, state.roomId!),
              icon: const Icon(Icons.link, size: 16),
              label: Text('Mã: ${state.roomId} (Sao chép)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),

          const SizedBox(width: 8),

          // Leave Room Button
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.accentRose),
            tooltip: 'Rời phòng',
            onPressed: () {
              cubit.leaveRoom();
              context.go('/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlNotice(WatchPartyState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            state.isHostOnlyControl ? Icons.lock : Icons.lock_open,
            size: 16,
            color: state.isHostOnlyControl ? AppColors.accentRose : AppColors.accentEmerald,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.isHostOnlyControl
                  ? (state.isHost
                      ? 'Bạn là Trưởng phòng (Host) - bạn có toàn quyền điều khiển phát, tạm dừng và tua phim.'
                      : 'Chế độ Host-Only: Chỉ Trưởng phòng mới có thể điều khiển phát/dừng phim.')
                  : 'Chế độ Tự do: Bất kỳ ai trong phòng cũng có thể điều khiển phát/dừng phim.',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isSelected ? AppColors.primaryLight : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSideTabs(BuildContext context, WatchPartyState state, WatchPartyCubit cubit) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSideTabButton(
                  label: 'Chat (${state.messages.length})',
                  icon: Icons.chat_bubble_outline,
                  isSelected: _activeSideTab == 0,
                  onTap: () => setState(() => _activeSideTab = 0),
                ),
              ),
              Expanded(
                child: _buildSideTabButton(
                  label: 'Thành viên (${state.participants.length})',
                  icon: Icons.people_outline,
                  isSelected: _activeSideTab == 1,
                  onTap: () => setState(() => _activeSideTab = 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 380,
          child: _activeSideTab == 0
              ? PartyChatPanel(
                  messages: state.messages,
                  roomId: state.roomId,
                  participantCount: state.participants.length,
                  onSendMessage: (txt) => cubit.sendChat(txt),
                  onSendReaction: (emoji) => cubit.sendReaction(emoji),
                )
              : PartyParticipantsPanel(
                  participants: state.participants,
                  hostId: state.hostId,
                  isHostOnlyControl: state.isHostOnlyControl,
                  isCurrentUserHost: state.isHost,
                  onToggleHostControl: () => cubit.toggleHostOnlyControl(),
                ),
        ),
      ],
    );
  }

  Widget _buildNoRoomPrompt(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.groups_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Flurt Watch Party',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn chưa tham gia phòng xem chung nào.\nHãy tạo phòng mới hoặc nhập mã 6 ký tự để bắt đầu!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CreatePartyDialog(),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Tạo hoặc Tham Gia Phòng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
