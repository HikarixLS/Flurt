class SyncActionType {
  static const String joinRoom = 'JOIN_ROOM';
  static const String leaveRoom = 'LEAVE_ROOM';
  static const String play = 'PLAY';
  static const String pause = 'PAUSE';
  static const String seek = 'SEEK';
  static const String changeEpisode = 'CHANGE_EPISODE';
  static const String changeServer = 'CHANGE_SERVER';
  static const String heartbeat = 'HEARTBEAT';
  static const String chat = 'CHAT';
  static const String reaction = 'REACTION';
  static const String toggleHostOnly = 'TOGGLE_HOST_ONLY';
  static const String syncState = 'SYNC_STATE';
  static const String driftCorrection = 'DRIFT_CORRECTION';
  static const String error = 'ERROR';
}

class SyncAction {
  final String action;
  final String? roomId;
  final String? senderId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SyncAction({
    required this.action,
    this.roomId,
    this.senderId,
    this.data = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'action': action,
        if (roomId != null) 'roomId': roomId,
        if (senderId != null) 'senderId': senderId,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SyncAction.fromJson(Map<String, dynamic> json) => SyncAction(
        action: json['action'] as String,
        roomId: json['roomId'] as String?,
        senderId: json['senderId'] as String?,
        data: (json['data'] as Map<String, dynamic>?) ?? {},
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
