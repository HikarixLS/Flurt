class Participant {
  final String id;
  String nickname;
  String avatar;
  bool isHost;
  bool isReady;
  DateTime lastHeartbeat;
  double currentPlaybackSeconds;
  bool isPlaying;

  Participant({
    required this.id,
    required this.nickname,
    this.avatar = '🍿',
    this.isHost = false,
    this.isReady = true,
    DateTime? lastHeartbeat,
    this.currentPlaybackSeconds = 0.0,
    this.isPlaying = false,
  }) : lastHeartbeat = lastHeartbeat ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'avatar': avatar,
        'isHost': isHost,
        'isReady': isReady,
        'currentPlaybackSeconds': currentPlaybackSeconds,
        'isPlaying': isPlaying,
      };

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json['id'] as String,
        nickname: json['nickname'] as String? ?? 'Khán giả',
        avatar: json['avatar'] as String? ?? '🍿',
        isHost: json['isHost'] as bool? ?? false,
        isReady: json['isReady'] as bool? ?? true,
        currentPlaybackSeconds:
            (json['currentPlaybackSeconds'] as num?)?.toDouble() ?? 0.0,
        isPlaying: json['isPlaying'] as bool? ?? false,
      );
}
