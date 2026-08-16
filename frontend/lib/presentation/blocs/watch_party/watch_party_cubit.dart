import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/constants/api_constants.dart';
import 'watch_party_state.dart';

class WatchPartyCubit extends Cubit<WatchPartyState> {
  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;
  Timer? _heartbeatTimer;
  Timer? _reactionPruneTimer;
  final Dio _dio = Dio();
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  WatchPartyCubit() : super(WatchPartyState(participantId: const Uuid().v4()));

  String get _resolvedWsUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isEmpty || host == 'localhost' || host == '127.0.0.1') {
        return 'ws://localhost:8080/ws/party';
      }
      // If deployed on github.io or custom domain without local server, can connect to wss
      return 'wss://$host/ws/party';
    }
    return ApiConstants.defaultWsUrl;
  }

  String get _resolvedHttpBackend {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isEmpty || host == 'localhost' || host == '127.0.0.1') {
        return 'http://localhost:8080';
      }
      return 'https://$host';
    }
    return ApiConstants.defaultHttpBackend;
  }

  void setIdentity({required String nickname, String avatar = '🍿'}) {
    emit(state.copyWith(nickname: nickname, avatar: avatar));
  }

  Future<String?> createPartyRoom({
    required String movieSlug,
    required String movieTitle,
    String posterUrl = '',
    int serverIndex = 0,
    String serverName = 'Vietsub #1',
    String episodeSlug = '',
    String episodeName = 'Tập 1',
    String streamUrl = '',
    bool isEmbed = false,
    String? roomName,
    String? nickname,
    String? avatar,
  }) async {
    final activeNickname = nickname ?? state.nickname;
    final activeAvatar = avatar ?? state.avatar;
    final hostId = state.participantId.isNotEmpty ? state.participantId : _uuid.v4();

    emit(state.copyWith(
      status: WsConnectionStatus.connecting,
      nickname: activeNickname,
      avatar: activeAvatar,
      participantId: hostId,
      isHost: true,
      errorMessage: null,
    ));

    try {
      final response = await _dio.post(
        '$_resolvedHttpBackend/api/rooms/create',
        data: {
          'hostId': hostId,
          'hostNickname': activeNickname,
          'hostAvatar': activeAvatar,
          'movieSlug': movieSlug,
          'movieTitle': movieTitle,
          'posterUrl': posterUrl,
          'serverIndex': serverIndex,
          'serverName': serverName,
          'episodeSlug': episodeSlug,
          'episodeName': episodeName,
          'streamUrl': streamUrl,
          'isEmbed': isEmbed,
          'roomName': roomName,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final roomId = response.data['roomId'] as String;
        final roomData = response.data['room'] as Map<String, dynamic>;

        _updateStateFromRoomJson(roomData, activeRoomId: roomId);
        await _connectWebSocket(roomId: roomId);
        return roomId;
      } else {
        emit(state.copyWith(
          status: WsConnectionStatus.error,
          errorMessage: 'Không thể tạo phòng: ${response.data['error'] ?? 'Lỗi máy chủ'}',
        ));
        return null;
      }
    } catch (e) {
      emit(state.copyWith(
        status: WsConnectionStatus.error,
        errorMessage: 'Lỗi kết nối máy chủ Watch Party: $e',
      ));
      return null;
    }
  }

  Future<void> joinPartyRoom({
    required String roomId,
    String? nickname,
    String? avatar,
  }) async {
    final activeNickname = nickname ?? state.nickname;
    final activeAvatar = avatar ?? state.avatar;
    final cleanRoomId = roomId.toUpperCase().trim();

    emit(state.copyWith(
      status: WsConnectionStatus.connecting,
      roomId: cleanRoomId,
      nickname: activeNickname,
      avatar: activeAvatar,
      errorMessage: null,
    ));

    await _connectWebSocket(roomId: cleanRoomId);
  }

  Future<void> _connectWebSocket({required String roomId}) async {
    _wsSubscription?.cancel();
    _channel?.sink.close();

    try {
      final wsUri = Uri.parse(_resolvedWsUrl);
      _channel = WebSocketChannel.connect(wsUri);
      await _channel!.ready;

      emit(state.copyWith(status: WsConnectionStatus.connected, roomId: roomId));

      // Send JOIN_ROOM
      _sendAction(
        action: 'JOIN_ROOM',
        roomId: roomId,
        data: {
          'senderId': state.participantId,
          'nickname': state.nickname,
          'avatar': state.avatar,
        },
      );

      _startHeartbeat();
      _startReactionPruner();

      _wsSubscription = _channel!.stream.listen(
        _onMessageReceived,
        onDone: () {
          emit(state.copyWith(status: WsConnectionStatus.disconnected));
          _stopTimers();
        },
        onError: (error) {
          emit(state.copyWith(
            status: WsConnectionStatus.error,
            errorMessage: 'Mất kết nối máy chủ Watch Party: $error',
          ));
          _stopTimers();
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: WsConnectionStatus.error,
        errorMessage: 'Không thể kết nối đến máy chủ WebSocket: $e',
      ));
    }
  }

  void _onMessageReceived(dynamic rawData) {
    try {
      final Map<String, dynamic> json = jsonDecode(rawData as String);
      final action = json['action'] as String? ?? '';
      final data = (json['data'] as Map<String, dynamic>?) ?? {};

      switch (action) {
        case 'SYNC_STATE':
          _updateStateFromRoomJson(data);
          break;

        case 'PLAY':
          final seconds = (data['seconds'] as num?)?.toDouble() ?? state.playbackSeconds;
          emit(state.copyWith(
            isPlaying: true,
            playbackSeconds: seconds,
            pendingSeekSeconds: seconds,
          ));
          break;

        case 'PAUSE':
          final seconds = (data['seconds'] as num?)?.toDouble() ?? state.playbackSeconds;
          emit(state.copyWith(
            isPlaying: false,
            playbackSeconds: seconds,
            pendingSeekSeconds: seconds,
          ));
          break;

        case 'SEEK':
          final seconds = (data['seconds'] as num?)?.toDouble() ?? 0.0;
          emit(state.copyWith(
            playbackSeconds: seconds,
            pendingSeekSeconds: seconds,
          ));
          break;

        case 'CHANGE_EPISODE':
          final epSlug = data['episodeSlug'] as String? ?? '';
          final epName = data['episodeName'] as String? ?? 'Tập phim';
          final streamUrl = data['streamUrl'] as String? ?? '';
          final isEmbed = data['isEmbed'] as bool? ?? false;
          emit(state.copyWith(
            episodeSlug: epSlug,
            episodeName: epName,
            streamUrl: streamUrl,
            isEmbed: isEmbed,
            isPlaying: true,
            playbackSeconds: 0.0,
            pendingSeekSeconds: 0.0,
          ));
          break;

        case 'CHANGE_SERVER':
          final sIndex = data['serverIndex'] as int? ?? 0;
          final sName = data['serverName'] as String? ?? 'Server';
          final streamUrl = data['streamUrl'] as String? ?? '';
          final isEmbed = data['isEmbed'] as bool? ?? false;
          emit(state.copyWith(
            serverIndex: sIndex,
            serverName: sName,
            streamUrl: streamUrl,
            isEmbed: isEmbed,
          ));
          break;

        case 'CHAT':
          final msg = PartyMessage.fromJson(data);
          final updatedMessages = List<PartyMessage>.from(state.messages)..add(msg);
          emit(state.copyWith(messages: updatedMessages));
          break;

        case 'REACTION':
          _handleIncomingReaction(data);
          break;

        case 'DRIFT_CORRECTION':
          final targetSeconds = (data['targetSeconds'] as num?)?.toDouble() ?? 0.0;
          final isPlaying = data['isPlaying'] as bool? ?? state.isPlaying;
          emit(state.copyWith(
            playbackSeconds: targetSeconds,
            isPlaying: isPlaying,
            pendingSeekSeconds: targetSeconds,
          ));
          break;

        case 'ERROR':
          final msg = data['message'] as String? ?? 'Lỗi không xác định';
          emit(state.copyWith(errorMessage: msg));
          break;
      }
    } catch (e) {
      if (kDebugMode) print('WatchParty message parse error: $e');
    }
  }

  void _handleIncomingReaction(Map<String, dynamic> data) {
    final emoji = data['emoji'] as String? ?? '❤️';
    final senderName = data['senderName'] as String? ?? 'Khán giả';
    final randomX = 0.15 + _random.nextDouble() * 0.7; // random horizontal spawn

    final reactionItem = ReactionItem(
      id: 'rx_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}',
      emoji: emoji,
      senderName: senderName,
      startX: randomX,
    );

    final updatedReactions = List<ReactionItem>.from(state.activeReactions)..add(reactionItem);

    // If reaction message included
    List<PartyMessage> updatedMessages = state.messages;
    if (data['message'] != null && data['message'] is Map<String, dynamic>) {
      final msg = PartyMessage.fromJson(data['message'] as Map<String, dynamic>);
      updatedMessages = List<PartyMessage>.from(state.messages)..add(msg);
    }

    emit(state.copyWith(
      activeReactions: updatedReactions,
      messages: updatedMessages,
    ));
  }

  void _updateStateFromRoomJson(Map<String, dynamic> roomJson, {String? activeRoomId}) {
    final roomId = activeRoomId ?? (roomJson['id'] as String?) ?? state.roomId;
    final hostId = roomJson['hostId'] as String? ?? state.hostId;
    final isHost = (hostId != null && hostId == state.participantId);

    final rawParticipants = roomJson['participants'] as List<dynamic>? ?? [];
    final participants = rawParticipants
        .map((p) => PartyParticipant.fromJson(p as Map<String, dynamic>))
        .toList();

    final rawMessages = roomJson['messages'] as List<dynamic>? ?? [];
    final messages = rawMessages
        .map((m) => PartyMessage.fromJson(m as Map<String, dynamic>))
        .toList();

    emit(state.copyWith(
      roomId: roomId,
      roomName: roomJson['roomName'] as String? ?? state.roomName,
      hostId: hostId,
      isHost: isHost,
      isHostOnlyControl: roomJson['isHostOnlyControl'] as bool? ?? true,
      movieSlug: roomJson['movieSlug'] as String? ?? state.movieSlug,
      movieTitle: roomJson['movieTitle'] as String? ?? state.movieTitle,
      posterUrl: roomJson['posterUrl'] as String? ?? state.posterUrl,
      serverIndex: (roomJson['serverIndex'] as num?)?.toInt() ?? state.serverIndex,
      serverName: roomJson['serverName'] as String? ?? state.serverName,
      episodeSlug: roomJson['episodeSlug'] as String? ?? state.episodeSlug,
      episodeName: roomJson['episodeName'] as String? ?? state.episodeName,
      streamUrl: roomJson['streamUrl'] as String? ?? state.streamUrl,
      isEmbed: roomJson['isEmbed'] as bool? ?? state.isEmbed,
      isPlaying: roomJson['isPlaying'] as bool? ?? state.isPlaying,
      playbackSeconds: (roomJson['playbackSeconds'] as num?)?.toDouble() ?? state.playbackSeconds,
      participants: participants,
      messages: messages,
    ));
  }

  void sendPlay(double seconds) {
    if (!state.canControl) return;
    emit(state.copyWith(isPlaying: true, playbackSeconds: seconds));
    _sendAction(action: 'PLAY', roomId: state.roomId, data: {'seconds': seconds});
  }

  void sendPause(double seconds) {
    if (!state.canControl) return;
    emit(state.copyWith(isPlaying: false, playbackSeconds: seconds));
    _sendAction(action: 'PAUSE', roomId: state.roomId, data: {'seconds': seconds});
  }

  void sendSeek(double seconds) {
    if (!state.canControl) return;
    emit(state.copyWith(playbackSeconds: seconds));
    _sendAction(action: 'SEEK', roomId: state.roomId, data: {'seconds': seconds});
  }

  void sendChangeEpisode({
    required String episodeSlug,
    required String episodeName,
    required String streamUrl,
    required bool isEmbed,
  }) {
    if (!state.canControl) return;
    emit(state.copyWith(
      episodeSlug: episodeSlug,
      episodeName: episodeName,
      streamUrl: streamUrl,
      isEmbed: isEmbed,
      playbackSeconds: 0.0,
      isPlaying: true,
    ));
    _sendAction(
      action: 'CHANGE_EPISODE',
      roomId: state.roomId,
      data: {
        'episodeSlug': episodeSlug,
        'episodeName': episodeName,
        'streamUrl': streamUrl,
        'isEmbed': isEmbed,
      },
    );
  }

  void sendChangeServer({
    required int serverIndex,
    required String serverName,
    required String streamUrl,
    required bool isEmbed,
  }) {
    if (!state.canControl) return;
    emit(state.copyWith(
      serverIndex: serverIndex,
      serverName: serverName,
      streamUrl: streamUrl,
      isEmbed: isEmbed,
    ));
    _sendAction(
      action: 'CHANGE_SERVER',
      roomId: state.roomId,
      data: {
        'serverIndex': serverIndex,
        'serverName': serverName,
        'streamUrl': streamUrl,
        'isEmbed': isEmbed,
      },
    );
  }

  void sendChat(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;
    _sendAction(
      action: 'CHAT',
      roomId: state.roomId,
      data: {
        'content': clean,
        'senderName': state.nickname,
        'senderAvatar': state.avatar,
      },
    );
  }

  void sendReaction(String emoji) {
    _sendAction(
      action: 'REACTION',
      roomId: state.roomId,
      data: {
        'emoji': emoji,
        'senderName': state.nickname,
      },
    );
  }

  void toggleHostOnlyControl() {
    if (!state.isHost) return;
    _sendAction(
      action: 'TOGGLE_HOST_ONLY',
      roomId: state.roomId,
      data: {'isHostOnly': !state.isHostOnlyControl},
    );
  }

  void consumePendingSeek() {
    emit(state.copyWith(clearPendingSeek: true));
  }

  void updateLocalPlayback(double seconds, bool isPlaying) {
    emit(state.copyWith(playbackSeconds: seconds, isPlaying: isPlaying));
  }

  void _sendAction({required String action, String? roomId, Map<String, dynamic> data = const {}}) {
    if (_channel == null || state.status != WsConnectionStatus.connected) return;
    try {
      final payload = {
        'action': action,
        'roomId': roomId ?? state.roomId,
        'senderId': state.participantId,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _channel!.sink.add(jsonEncode(payload));
    } catch (e) {
      if (kDebugMode) print('WatchParty sendAction error: $e');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (state.status == WsConnectionStatus.connected && state.roomId != null) {
        _sendAction(
          action: 'HEARTBEAT',
          roomId: state.roomId,
          data: {
            'seconds': state.playbackSeconds,
            'isPlaying': state.isPlaying,
          },
        );
      }
    });
  }

  void _startReactionPruner() {
    _reactionPruneTimer?.cancel();
    _reactionPruneTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (state.activeReactions.isEmpty) return;
      final now = DateTime.now();
      final fresh = state.activeReactions
          .where((r) => now.difference(r.createdAt).inMilliseconds < 3200)
          .toList();
      if (fresh.length != state.activeReactions.length) {
        emit(state.copyWith(activeReactions: fresh));
      }
    });
  }

  void _stopTimers() {
    _heartbeatTimer?.cancel();
    _reactionPruneTimer?.cancel();
  }

  void leaveRoom() {
    if (state.roomId != null) {
      _sendAction(action: 'LEAVE_ROOM', roomId: state.roomId);
    }
    _stopTimers();
    _wsSubscription?.cancel();
    _channel?.sink.close();
    emit(WatchPartyState(participantId: state.participantId, nickname: state.nickname, avatar: state.avatar));
  }

  @override
  Future<void> close() {
    _stopTimers();
    _wsSubscription?.cancel();
    _channel?.sink.close();
    _dio.close();
    return super.close();
  }
}
