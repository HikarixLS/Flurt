class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final DateTime timestamp;
  final String type; // 'text', 'system', 'reaction'
  final String? reactionEmoji;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    DateTime? timestamp,
    this.type = 'text',
    this.reactionEmoji,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'reactionEmoji': reactionEmoji,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String,
        senderAvatar: json['senderAvatar'] as String? ?? '🍿',
        content: json['content'] as String,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : DateTime.now(),
        type: json['type'] as String? ?? 'text',
        reactionEmoji: json['reactionEmoji'] as String?,
      );
}
