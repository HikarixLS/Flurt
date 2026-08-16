import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_action.dart';
import '../services/room_manager.dart';
import '../services/sync_engine.dart';

class WsPartyHandler {
  final RoomManager roomManager;
  final SyncEngine syncEngine;
  final Uuid _uuid = const Uuid();

  WsPartyHandler({
    RoomManager? roomManager,
    SyncEngine? syncEngine,
  })  : roomManager = roomManager ?? RoomManager(),
        syncEngine = syncEngine ?? SyncEngine();

  Handler get handler {
    return webSocketHandler((WebSocketChannel channel) {
      String? currentParticipantId;

      channel.stream.listen(
        (message) {
          try {
            final Map<String, dynamic> rawJson = jsonDecode(message as String);
            final action = SyncAction.fromJson(rawJson);

            final participantId = action.senderId ??
                action.data['senderId'] as String? ??
                currentParticipantId ??
                _uuid.v4();

            currentParticipantId = participantId;

            final roomId = (action.roomId ?? action.data['roomId'] as String?)
                ?.toUpperCase()
                .trim();

            if (roomId != null && roomId.isNotEmpty) {
              roomManager.registerSocket(participantId, channel, roomId);
            }

            syncEngine.handleAction(
              senderId: participantId,
              action: action,
            );
          } catch (e) {
            try {
              channel.sink.add(
                jsonEncode(
                  SyncAction(
                    action: SyncActionType.error,
                    data: {'message': 'Lỗi định dạng bản tin WebSocket: $e'},
                  ).toJson(),
                ),
              );
            } catch (_) {}
          }
        },
        onDone: () {
          if (currentParticipantId != null) {
            roomManager.unregisterSocket(currentParticipantId!);
          }
        },
        onError: (err) {
          if (currentParticipantId != null) {
            roomManager.unregisterSocket(currentParticipantId!);
          }
        },
        cancelOnError: true,
      );
    });
  }
}
