enum WsConnectionStatus { initial, connecting, connected, disconnected, error }

class PartyParticipant {
  final String id;
  final String nickname;
  final String avatar;
  final bool isHost;
  final bool isReady;
  final double currentPlaybackSeconds;
  final bool isPlaying;

  PartyParticipant({
    required this.id,
    required this.nickname,
    this.avatar = '🍿',
    this.isHost = false,
    this.isReady = true,
    this.currentPlaybackSeconds = 0.0,
    this.isPlaying = false,
  });

  factory PartyParticipant.fromJson(Map<String, dynamic> json) => PartyParticipant(
        id: json['id'] as String? ?? '',
        nickname: json['nickname'] as String? ?? 'Khán giả',
        avatar: json['avatar'] as String? ?? '🍿',
        isHost: json['isHost'] as bool? ?? false,
        isReady: json['isReady'] as bool? ?? true,
        currentPlaybackSeconds:
            (json['currentPlaybackSeconds'] as num?)?.toDouble() ?? 0.0,
        isPlaying: json['isPlaying'] as bool? ?? false,
      );
}

class PartyMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final DateTime timestamp;
  final String type; // 'text', 'system', 'reaction'
  final String? reactionEmoji;

  PartyMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    required this.timestamp,
    this.type = 'text',
    this.reactionEmoji,
  });

  factory PartyMessage.fromJson(Map<String, dynamic> json) => PartyMessage(
        id: json['id'] as String? ?? '',
        senderId: json['senderId'] as String? ?? '',
        senderName: json['senderName'] as String? ?? '',
        senderAvatar: json['senderAvatar'] as String? ?? '🍿',
        content: json['content'] as String? ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        type: json['type'] as String? ?? 'text',
        reactionEmoji: json['reactionEmoji'] as String?,
      );
}

class ReactionItem {
  final String id;
  final String emoji;
  final String senderName;
  final double startX; // Normalized X position (0.1 to 0.9)
  final DateTime createdAt;

  ReactionItem({
    required this.id,
    required this.emoji,
    required this.senderName,
    required this.startX,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class WatchPartyState {
  final WsConnectionStatus status;
  final String? roomId;
  final String? roomName;
  final String? hostId;
  final String participantId;
  final String nickname;
  final String avatar;
  final bool isHost;
  final bool isHostOnlyControl;
  final String movieSlug;
  final String movieTitle;
  final String posterUrl;
  final int serverIndex;
  final String serverName;
  final String episodeSlug;
  final String episodeName;
  final String streamUrl;
  final bool isEmbed;
  final bool isPlaying;
  final double playbackSeconds;
  final List<PartyParticipant> participants;
  final List<PartyMessage> messages;
  final List<ReactionItem> activeReactions;
  final String? errorMessage;
  final double? pendingSeekSeconds;

  WatchPartyState({
    this.status = WsConnectionStatus.initial,
    this.roomId,
    this.roomName,
    this.hostId,
    this.participantId = '',
    this.nickname = 'Khán giả',
    this.avatar = '🍿',
    this.isHost = false,
    this.isHostOnlyControl = true,
    this.movieSlug = '',
    this.movieTitle = '',
    this.posterUrl = '',
    this.serverIndex = 0,
    this.serverName = 'Vietsub #1',
    this.episodeSlug = '',
    this.episodeName = 'Tập 1',
    this.streamUrl = '',
    this.isEmbed = false,
    this.isPlaying = false,
    this.playbackSeconds = 0.0,
    this.participants = const [],
    this.messages = const [],
    this.activeReactions = const [],
    this.errorMessage,
    this.pendingSeekSeconds,
  });

  bool get canControl => !isHostOnlyControl || isHost;

  WatchPartyState copyWith({
    WsConnectionStatus? status,
    String? roomId,
    String? roomName,
    String? hostId,
    String? participantId,
    String? nickname,
    String? avatar,
    bool? isHost,
    bool? isHostOnlyControl,
    String? movieSlug,
    String? movieTitle,
    String? posterUrl,
    int? serverIndex,
    String? serverName,
    String? episodeSlug,
    String? episodeName,
    String? streamUrl,
    bool? isEmbed,
    bool? isPlaying,
    double? playbackSeconds,
    List<PartyParticipant>? participants,
    List<PartyMessage>? messages,
    List<ReactionItem>? activeReactions,
    String? errorMessage,
    double? pendingSeekSeconds,
    bool clearPendingSeek = false,
  }) {
    return WatchPartyState(
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      hostId: hostId ?? this.hostId,
      participantId: participantId ?? this.participantId,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      isHost: isHost ?? this.isHost,
      isHostOnlyControl: isHostOnlyControl ?? this.isHostOnlyControl,
      movieSlug: movieSlug ?? this.movieSlug,
      movieTitle: movieTitle ?? this.movieTitle,
      posterUrl: posterUrl ?? this.posterUrl,
      serverIndex: serverIndex ?? this.serverIndex,
      serverName: serverName ?? this.serverName,
      episodeSlug: episodeSlug ?? this.episodeSlug,
      episodeName: episodeName ?? this.episodeName,
      streamUrl: streamUrl ?? this.streamUrl,
      isEmbed: isEmbed ?? this.isEmbed,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackSeconds: playbackSeconds ?? this.playbackSeconds,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      activeReactions: activeReactions ?? this.activeReactions,
      errorMessage: errorMessage,
      pendingSeekSeconds: clearPendingSeek ? null : (pendingSeekSeconds ?? this.pendingSeekSeconds),
    );
  }
}
