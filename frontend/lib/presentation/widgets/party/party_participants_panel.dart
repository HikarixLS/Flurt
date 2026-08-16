import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/watch_party/watch_party_state.dart';

class PartyParticipantsPanel extends StatelessWidget {
  final List<PartyParticipant> participants;
  final String? hostId;
  final bool isHostOnlyControl;
  final bool isCurrentUserHost;
  final VoidCallback? onToggleHostControl;

  const PartyParticipantsPanel({
    super.key,
    required this.participants,
    this.hostId,
    this.isHostOnlyControl = true,
    this.isCurrentUserHost = false,
    this.onToggleHostControl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.people_outline_rounded, size: 18, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Thành viên (${participants.length})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Host Permission Toggle
          if (isCurrentUserHost && onToggleHostControl != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isHostOnlyControl ? Icons.lock_outline : Icons.lock_open,
                    size: 16,
                    color: isHostOnlyControl ? AppColors.accentRose : AppColors.accentEmerald,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isHostOnlyControl ? 'Chỉ Trưởng phòng điều khiển' : 'Mọi người tự do điều khiển',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Switch(
                    value: isHostOnlyControl,
                    onChanged: (_) => onToggleHostControl!(),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),

          // Participants List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final p = participants[index];
                final isHost = p.id == hostId || p.isHost;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isHost
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isHost
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Text(p.avatar, style: const TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.nickname,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (p.isPlaying)
                              const Row(
                                children: [
                                  Icon(Icons.play_circle_fill, size: 10, color: AppColors.accentEmerald),
                                  SizedBox(width: 4),
                                  Text(
                                    'Đang phát',
                                    style: TextStyle(fontSize: 10, color: AppColors.accentEmerald),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (isHost)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Host 👑',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
