import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_message.dart';
import '../models/party_room.dart';
import '../models/participant.dart';
import '../models/sync_action.dart';

class RoomManager {
  static final RoomManager _instance = RoomManager._internal();
  factory RoomManager() => _instance;
  RoomManager._internal();

  final Map<String, PartyRoom> _rooms = {};
  final Map<String, WebSocketChannel> _clientSockets = {};
  final Map<String, String> _clientToRoom = {}; // participantId -> roomId
  final Random _random = Random();

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    String code;
    do {
      code = List.generate(6, (index) => chars[_random.nextInt(chars.length)]).join();
    } while (_rooms.containsKey(code));
    return code;
  }

  PartyRoom createRoom({
    required String hostId,
    required String hostNickname,
    String hostAvatar = '👑',
    required String movieSlug,
    required String movieTitle,
    String posterUrl = '',
    int serverIndex = 0,
    String serverName = 'Vietsub #1',
    String episodeSlug = '',
    String episodeName = 'Tập 1',
    String streamUrl = '',
    bool isEmbed = false,
    String? customRoomName,
  }) {
    final roomId = _generateRoomCode();
    final host = Participant(
      id: hostId,
      nickname: hostNickname,
      avatar: hostAvatar,
      isHost: true,
    );

    final room = PartyRoom(
      id: roomId,
      roomName: customRoomName ?? 'Phòng xem phim của $hostNickname',
      hostId: hostId,
      movieSlug: movieSlug,
      movieTitle: movieTitle,
      posterUrl: posterUrl,
      serverIndex: serverIndex,
      serverName: serverName,
      episodeSlug: episodeSlug,
      episodeName: episodeName,
      streamUrl: streamUrl,
      isEmbed: isEmbed,
      participants: {hostId: host},
      messages: [
        ChatMessage(
          id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'Hệ thống',
          senderAvatar: '⚡',
          content: '🎉 Chào mừng đến với phòng xem chung! Mã phòng: $roomId',
          type: 'system',
        ),
      ],
    );

    _rooms[roomId] = room;
    return room;
  }

  PartyRoom? getRoom(String roomId) => _rooms[roomId.toUpperCase().trim()];

  void registerSocket(String participantId, WebSocketChannel channel, String roomId) {
    _clientSockets[participantId] = channel;
    _clientToRoom[participantId] = roomId;
  }

  void unregisterSocket(String participantId) {
    _clientSockets.remove(participantId);
    final roomId = _clientToRoom.remove(participantId);
    if (roomId != null) {
      leaveRoom(roomId: roomId, participantId: participantId);
    }
  }

  PartyRoom? joinRoom({
    required String roomId,
    required String participantId,
    required String nickname,
    String avatar = '🍿',
  }) {
    final cleanRoomId = roomId.toUpperCase().trim();
    final room = _rooms[cleanRoomId];
    if (room == null) return null;

    final isHost = room.participants.isEmpty || room.hostId == participantId;
    final participant = Participant(
      id: participantId,
      nickname: nickname,
      avatar: avatar,
      isHost: isHost,
    );

    room.participants[participantId] = participant;
    if (isHost) {
      room.hostId = participantId;
    }

    // Add system notification
    room.messages.add(
      ChatMessage(
        id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'system',
        senderName: 'Hệ thống',
        senderAvatar: '👋',
        content: '$nickname đã tham gia phòng xem!',
        type: 'system',
      ),
    );

    return room;
  }

  void leaveRoom({
    required String roomId,
    required String participantId,
  }) {
    final cleanRoomId = roomId.toUpperCase().trim();
    final room = _rooms[cleanRoomId];
    if (room == null) return;

    final leavingUser = room.participants.remove(participantId);
    if (leavingUser != null) {
      room.messages.add(
        ChatMessage(
          id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'Hệ thống',
          senderAvatar: '🚪',
          content: '${leavingUser.nickname} đã rời khỏi phòng.',
          type: 'system',
        ),
      );
    }

    // Check if room is empty
    if (room.participants.isEmpty) {
      _rooms.remove(cleanRoomId);
      return;
    }

    // If host left, transfer host to next participant
    if (room.hostId == participantId) {
      final newHost = room.participants.values.first;
      newHost.isHost = true;
      room.hostId = newHost.id;

      room.messages.add(
        ChatMessage(
          id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'Hệ thống',
          senderAvatar: '👑',
          content: '👑 ${newHost.nickname} đã trở thành Trưởng phòng mới!',
          type: 'system',
        ),
      );
    }

    // Broadcast updated state
    broadcastToRoom(
      cleanRoomId,
      SyncAction(
        action: SyncActionType.syncState,
        roomId: cleanRoomId,
        data: room.toJson(),
      ),
    );
  }

  void broadcastToRoom(String roomId, SyncAction action, {String? excludeSenderId}) {
    final cleanRoomId = roomId.toUpperCase().trim();
    final room = _rooms[cleanRoomId];
    if (room == null) return;

    final jsonPayload = jsonEncode(action.toJson());
    for (final participantId in room.participants.keys) {
      if (excludeSenderId != null && participantId == excludeSenderId) {
        continue;
      }
      final socket = _clientSockets[participantId];
      if (socket != null) {
        try {
          socket.sink.add(jsonPayload);
        } catch (e) {
          // Socket might have closed
        }
      }
    }
  }

  void sendToClient(String participantId, SyncAction action) {
    final socket = _clientSockets[participantId];
    if (socket != null) {
      try {
        socket.sink.add(jsonEncode(action.toJson()));
      } catch (e) {
        // Socket might have closed
      }
    }
  }

  int get activeRoomCount => _rooms.length;
  int get activeConnectionCount => _clientSockets.length;
}
