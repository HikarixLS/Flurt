import 'chat_message.dart';
import 'participant.dart';

class PartyRoom {
  final String id;
  String roomName;
  String hostId;
  String movieSlug;
  String movieTitle;
  String posterUrl;
  int serverIndex;
  String serverName;
  String episodeSlug;
  String episodeName;
  String streamUrl;
  bool isEmbed;
  bool isPlaying;
  double playbackSeconds;
  DateTime lastSyncTimestamp;
  bool isHostOnlyControl;
  final Map<String, Participant> participants;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  PartyRoom({
    required this.id,
    required this.roomName,
    required this.hostId,
    required this.movieSlug,
    required this.movieTitle,
    this.posterUrl = '',
    this.serverIndex = 0,
    this.serverName = 'Vietsub #1',
    this.episodeSlug = '',
    this.episodeName = 'Tập 1',
    this.streamUrl = '',
    this.isEmbed = false,
    this.isPlaying = false,
    this.playbackSeconds = 0.0,
    DateTime? lastSyncTimestamp,
    this.isHostOnlyControl = true,
    Map<String, Participant>? participants,
    List<ChatMessage>? messages,
    DateTime? createdAt,
  })  : lastSyncTimestamp = lastSyncTimestamp ?? DateTime.now(),
        participants = participants ?? {},
        messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now();

  double getEstimatedPlaybackTime() {
    if (!isPlaying) {
      return playbackSeconds;
    }
    final elapsed = DateTime.now().difference(lastSyncTimestamp).inMilliseconds / 1000.0;
    return playbackSeconds + elapsed;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomName': roomName,
        'hostId': hostId,
        'movieSlug': movieSlug,
        'movieTitle': movieTitle,
        'posterUrl': posterUrl,
        'serverIndex': serverIndex,
        'serverName': serverName,
        'episodeSlug': episodeSlug,
        'episodeName': episodeName,
        'streamUrl': streamUrl,
        'isEmbed': isEmbed,
        'isPlaying': isPlaying,
        'playbackSeconds': getEstimatedPlaybackTime(),
        'lastSyncTimestamp': lastSyncTimestamp.toIso8601String(),
        'isHostOnlyControl': isHostOnlyControl,
        'participants': participants.values.map((p) => p.toJson()).toList(),
        'messages': messages.take(50).map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };
}
