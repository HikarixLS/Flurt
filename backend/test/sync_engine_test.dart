import 'package:test/test.dart';
import '../lib/models/sync_action.dart';
import '../lib/services/room_manager.dart';
import '../lib/services/sync_engine.dart';

void main() {
  group('Flurt Watch Party Backend Tests', () {
    late RoomManager roomManager;
    late SyncEngine syncEngine;

    setUp(() {
      roomManager = RoomManager();
      syncEngine = SyncEngine(roomManager: roomManager);
    });

    test('Create Room and verify default values', () {
      final room = roomManager.createRoom(
        hostId: 'user_host_1',
        hostNickname: 'Alice',
        movieSlug: 'cuc-han-2026',
        movieTitle: 'Cực Hạn (2026)',
        posterUrl: 'https://example.com/poster.jpg',
        episodeSlug: 'tap-full',
        episodeName: 'FULL',
        streamUrl: 'https://example.com/stream.m3u8',
      );

      expect(room.id.length, 6);
      expect(room.hostId, 'user_host_1');
      expect(room.movieSlug, 'cuc-han-2026');
      expect(room.participants.containsKey('user_host_1'), isTrue);
      expect(room.participants['user_host_1']!.isHost, isTrue);
    });

    test('Join Room and broadcast sync state', () {
      final room = roomManager.createRoom(
        hostId: 'user_host_1',
        hostNickname: 'Alice',
        movieSlug: 'cuc-han-2026',
        movieTitle: 'Cực Hạn (2026)',
      );

      final joinedRoom = roomManager.joinRoom(
        roomId: room.id,
        participantId: 'user_guest_2',
        nickname: 'Bob',
      );

      expect(joinedRoom, isNotNull);
      expect(joinedRoom!.participants.length, 2);
      expect(joinedRoom.participants.containsKey('user_guest_2'), isTrue);
      expect(joinedRoom.participants['user_guest_2']!.isHost, isFalse);
    });

    test('Host controls Play and Pause sync', () {
      final room = roomManager.createRoom(
        hostId: 'user_host_1',
        hostNickname: 'Alice',
        movieSlug: 'cuc-han-2026',
        movieTitle: 'Cực Hạn (2026)',
      );

      // Play
      syncEngine.handleAction(
        senderId: 'user_host_1',
        action: SyncAction(
          action: SyncActionType.play,
          roomId: room.id,
          data: {'seconds': 120.5},
        ),
      );

      expect(room.isPlaying, isTrue);
      expect(room.playbackSeconds, 120.5);

      // Pause
      syncEngine.handleAction(
        senderId: 'user_host_1',
        action: SyncAction(
          action: SyncActionType.pause,
          roomId: room.id,
          data: {'seconds': 130.0},
        ),
      );

      expect(room.isPlaying, isFalse);
      expect(room.playbackSeconds, 130.0);
    });
  });
}
