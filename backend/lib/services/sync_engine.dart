import '../models/chat_message.dart';
import '../models/party_room.dart';
import '../models/sync_action.dart';
import 'room_manager.dart';

class SyncEngine {
  final RoomManager roomManager;

  SyncEngine({RoomManager? roomManager})
      : roomManager = roomManager ?? RoomManager();

  String _formatTime(double seconds) {
    final s = seconds.floor();
    final mins = (s ~/ 60).toString().padLeft(2, '0');
    final secs = (s % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void handleAction({
    required String senderId,
    required SyncAction action,
  }) {
    final roomId = action.roomId ?? action.data['roomId'] as String?;
    if (roomId == null) {
      roomManager.sendToClient(
        senderId,
        SyncAction(
          action: SyncActionType.error,
          data: {'message': 'Mã phòng (roomId) không được để trống'},
        ),
      );
      return;
    }

    final room = roomManager.getRoom(roomId);
    if (room == null && action.action != SyncActionType.joinRoom) {
      roomManager.sendToClient(
        senderId,
        SyncAction(
          action: SyncActionType.error,
          data: {'message': 'Phòng xem không tồn tại hoặc đã kết thúc'},
        ),
      );
      return;
    }

    switch (action.action) {
      case SyncActionType.joinRoom:
        _handleJoinRoom(senderId, roomId, action.data);
        break;

      case SyncActionType.leaveRoom:
        roomManager.leaveRoom(roomId: roomId, participantId: senderId);
        break;

      case SyncActionType.play:
        _handlePlay(room!, senderId, action.data);
        break;

      case SyncActionType.pause:
        _handlePause(room!, senderId, action.data);
        break;

      case SyncActionType.seek:
        _handleSeek(room!, senderId, action.data);
        break;

      case SyncActionType.changeEpisode:
        _handleEpisodeChange(room!, senderId, action.data);
        break;

      case SyncActionType.changeServer:
        _handleServerChange(room!, senderId, action.data);
        break;

      case SyncActionType.heartbeat:
        _handleHeartbeat(room!, senderId, action.data);
        break;

      case SyncActionType.chat:
        _handleChat(room!, senderId, action.data);
        break;

      case SyncActionType.reaction:
        _handleReaction(room!, senderId, action.data);
        break;

      case SyncActionType.toggleHostOnly:
        _handleToggleHostOnly(room!, senderId, action.data);
        break;

      default:
        // Echo or broadcast unknown action
        roomManager.broadcastToRoom(roomId, action);
        break;
    }
  }

  void _handleJoinRoom(String senderId, String roomId, Map<String, dynamic> data) {
    final nickname = data['nickname'] as String? ?? 'Khán giả';
    final avatar = data['avatar'] as String? ?? '🍿';

    final room = roomManager.joinRoom(
      roomId: roomId,
      participantId: senderId,
      nickname: nickname,
      avatar: avatar,
    );

    if (room == null) {
      roomManager.sendToClient(
        senderId,
        SyncAction(
          action: SyncActionType.error,
          data: {'message': 'Không tìm thấy phòng có mã $roomId'},
        ),
      );
      return;
    }

    // Broadcast updated state to all participants
    final syncStateAction = SyncAction(
      action: SyncActionType.syncState,
      roomId: room.id,
      data: room.toJson(),
    );
    roomManager.broadcastToRoom(room.id, syncStateAction);
  }

  bool _canControl(PartyRoom room, String senderId) {
    if (!room.isHostOnlyControl) return true;
    return room.hostId == senderId;
  }

  void _handlePlay(PartyRoom room, String senderId, Map<String, dynamic> data) {
    if (!_canControl(room, senderId)) {
      roomManager.sendToClient(
        senderId,
        SyncAction(
          action: SyncActionType.error,
          data: {'message': 'Chỉ Trưởng phòng mới có quyền điều khiển phát phim'},
        ),
      );
      return;
    }

    final seconds = (data['seconds'] as num?)?.toDouble() ?? room.playbackSeconds;
    room.isPlaying = true;
    room.playbackSeconds = seconds;
    room.lastSyncTimestamp = DateTime.now();

    final participant = room.participants[senderId];
    final senderName = participant?.nickname ?? 'Trưởng phòng';

    roomManager.broadcastToRoom(
      room.id,
      SyncAction(
        action: SyncActionType.play,
        roomId: room.id,
        senderId: senderId,
        data: {
          'seconds': seconds,
          'message': '$senderName đã tiếp tục phát video tại ${_formatTime(seconds)}',
        },
      ),
    );
  }

  void _handlePause(PartyRoom room, String senderId, Map<String, dynamic> data) {
    if (!_canControl(room, senderId)) {
      roomManager.sendToClient(
        senderId,
        SyncAction(
          action: SyncActionType.error,
          data: {'message': 'Chỉ Trưởng phòng mới có quyền tạm dừng phim'},
        ),
      );
      return;
    }

    final seconds = (data['seconds'] as num?)?.toDouble() ?? room.playbackSeconds;
    room.isPlaying = false;
    room.playbackSeconds = seconds;
    room.lastSyncTimestamp = DateTime.now();

    final participant = room.participants[senderId];
    final senderName = participant?.nickname ?? 'Trưởng phòng';

    roomManager.broadcastToRoom(
      room.id,
      SyncAction(
        action: SyncActionType.pause,
        roomId: room.id,
        senderId: senderId,
        data: {
          'seconds': seconds,
          'message': '$senderName đã tạm dừng phim tại ${_formatTime(seconds)}',
        },
      ),
    );
  }

  void _handleSeek(PartyRoom room, String senderId, Map<String, dynamic> data) {
    if (!_canControl(room, senderId)) {
      roomManager.sendToClient(
        senderId,
        SyncAction(
          action: SyncActionType.error,
          data: {'message': 'Chỉ Trưởng phòng mới có quyền tua phim'},
        ),
      );
      return;
    }

    final seconds = (data['seconds'] as num?)?.toDouble() ?? 0.0;
    room.playbackSeconds = seconds;
    room.lastSyncTimestamp = DateTime.now();

    final participant = room.participants[senderId];
    final senderName = participant?.nickname ?? 'Trưởng phòng';

    roomManager.broadcastToRoom(
      room.id,
      SyncAction(
        action: SyncActionType.seek,
        roomId: room.id,
        senderId: senderId,
        data: {
          'seconds': seconds,
          'message': '$senderName đã tua phim đến ${_formatTime(seconds)}',
        },
      ),
    );
  }

  void _handleEpisodeChange(PartyRoom room, String senderId, Map<String, dynamic> data) {
    if (!_canControl(room, senderId)) {
      roomManager.sendToClient(
        senderId,
        SyncAction(
          action: SyncActionType.error,
          data: {'message': 'Chỉ Trưởng phòng mới có quyền đổi tập phim'},
        ),
      );
      return;
    }

    final episodeSlug = data['episodeSlug'] as String? ?? '';
    final episodeName = data['episodeName'] as String? ?? 'Tập phim mới';
    final streamUrl = data['streamUrl'] as String? ?? '';
    final isEmbed = data['isEmbed'] as bool? ?? false;

    room.episodeSlug = episodeSlug;
    room.episodeName = episodeName;
    room.streamUrl = streamUrl;
    room.isEmbed = isEmbed;
    room.playbackSeconds = 0.0;
    room.isPlaying = true;
    room.lastSyncTimestamp = DateTime.now();

    final participant = room.participants[senderId];
    final senderName = participant?.nickname ?? 'Trưởng phòng';

    room.messages.add(
      ChatMessage(
        id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'system',
        senderName: 'Hệ thống',
        senderAvatar: '🎬',
        content: '$senderName đã chuyển sang $episodeName',
        type: 'system',
      ),
    );

    roomManager.broadcastToRoom(
      room.id,
      SyncAction(
        action: SyncActionType.changeEpisode,
        roomId: room.id,
        senderId: senderId,
        data: {
          'episodeSlug': episodeSlug,
          'episodeName': episodeName,
          'streamUrl': streamUrl,
          'isEmbed': isEmbed,
          'seconds': 0.0,
        },
      ),
    );
  }

  void _handleServerChange(PartyRoom room, String senderId, Map<String, dynamic> data) {
    if (!_canControl(room, senderId)) return;

    final serverIndex = data['serverIndex'] as int? ?? 0;
    final serverName = data['serverName'] as String? ?? 'Server';
    final streamUrl = data['streamUrl'] as String? ?? '';
    final isEmbed = data['isEmbed'] as bool? ?? false;

    room.serverIndex = serverIndex;
    room.serverName = serverName;
    room.streamUrl = streamUrl;
    room.isEmbed = isEmbed;

    roomManager.broadcastToRoom(
      room.id,
      SyncAction(
        action: SyncActionType.changeServer,
        roomId: room.id,
        senderId: senderId,
        data: {
          'serverIndex': serverIndex,
          'serverName': serverName,
          'streamUrl': streamUrl,
          'isEmbed': isEmbed,
        },
      ),
    );
  }

  void _handleHeartbeat(PartyRoom room, String senderId, Map<String, dynamic> data) {
    final clientSeconds = (data['seconds'] as num?)?.toDouble() ?? 0.0;
    final clientIsPlaying = data['isPlaying'] as bool? ?? false;

    final participant = room.participants[senderId];
    if (participant != null) {
      participant.lastHeartbeat = DateTime.now();
      participant.currentPlaybackSeconds = clientSeconds;
      participant.isPlaying = clientIsPlaying;
    }

    // If sender is Host, update room estimated state
    if (room.hostId == senderId) {
      room.playbackSeconds = clientSeconds;
      room.isPlaying = clientIsPlaying;
      room.lastSyncTimestamp = DateTime.now();
    } else {
      // If sender is Viewer, check for timestamp drift > 1.5s
      final targetSeconds = room.getEstimatedPlaybackTime();
      final drift = (clientSeconds - targetSeconds).abs();
      if (drift > 1.5) {
        // Send corrective seek command to viewer
        roomManager.sendToClient(
          senderId,
          SyncAction(
            action: SyncActionType.driftCorrection,
            roomId: room.id,
            data: {
              'targetSeconds': targetSeconds,
              'isPlaying': room.isPlaying,
              'reason': 'Hiệu chỉnh lệch thời gian (${drift.toStringAsFixed(1)}s)',
            },
          ),
        );
      }
    }
  }

  void _handleChat(PartyRoom room, String senderId, Map<String, dynamic> data) {
    final content = (data['content'] as String?)?.trim() ?? '';
    if (content.isEmpty) return;

    final participant = room.participants[senderId];
    final senderName = participant?.nickname ?? data['senderName'] as String? ?? 'Khán giả';
    final senderAvatar = participant?.avatar ?? data['senderAvatar'] as String? ?? '🍿';

    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_${senderId.hashCode}',
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content,
      type: 'text',
    );

    room.messages.add(message);
    if (room.messages.length > 100) {
      room.messages.removeAt(0);
    }

    roomManager.broadcastToRoom(
      room.id,
      SyncAction(
        action: SyncActionType.chat,
        roomId: room.id,
        senderId: senderId,
        data: message.toJson(),
      ),
    );
  }

  void _handleReaction(PartyRoom room, String senderId, Map<String, dynamic> data) {
    final emoji = data['emoji'] as String? ?? '❤️';
    final participant = room.participants[senderId];
    final senderName = participant?.nickname ?? 'Khán giả';

    final reactionMessage = ChatMessage(
      id: 'rx_${DateTime.now().millisecondsSinceEpoch}_${senderId.hashCode}',
      senderId: senderId,
      senderName: senderName,
      senderAvatar: participant?.avatar ?? '🍿',
      content: '$senderName thả $emoji',
      type: 'reaction',
      reactionEmoji: emoji,
    );

    // Fast reaction broadcast for video floating animations
    roomManager.broadcastToRoom(
      room.id,
      SyncAction(
        action: SyncActionType.reaction,
        roomId: room.id,
        senderId: senderId,
        data: {
          'emoji': emoji,
          'senderName': senderName,
          'senderId': senderId,
          'message': reactionMessage.toJson(),
        },
      ),
    );
  }

  void _handleToggleHostOnly(PartyRoom room, String senderId, Map<String, dynamic> data) {
    if (room.hostId != senderId) return;

    final isHostOnly = data['isHostOnly'] as bool? ?? !room.isHostOnlyControl;
    room.isHostOnlyControl = isHostOnly;

    final notice = isHostOnly
        ? '🔒 Trưởng phòng đã bật chế độ: Chỉ Trưởng phòng được điều khiển'
        : '🔓 Trưởng phòng đã bật chế độ: Tất cả mọi người có thể điều khiển';

    room.messages.add(
      ChatMessage(
        id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'system',
        senderName: 'Hệ thống',
        senderAvatar: isHostOnly ? '🔒' : '🔓',
        content: notice,
        type: 'system',
      ),
    );

    roomManager.broadcastToRoom(
      room.id,
      SyncAction(
        action: SyncActionType.syncState,
        roomId: room.id,
        data: room.toJson(),
      ),
    );
  }
}
