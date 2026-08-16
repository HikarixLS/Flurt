import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import '../lib/handlers/ws_party_handler.dart';
import '../lib/services/room_manager.dart';

void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final roomManager = RoomManager();
  final wsHandler = WsPartyHandler(roomManager: roomManager);
  final uuid = const Uuid();

  final app = Router();

  // Health check
  app.get('/api/health', (Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'healthy',
        'activeRooms': roomManager.activeRoomCount,
        'activeConnections': roomManager.activeConnectionCount,
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });

  // REST: Create Room
  app.post('/api/rooms/create', (Request request) async {
    try {
      final body = await request.readAsString();
      final Map<String, dynamic> data =
          body.isNotEmpty ? jsonDecode(body) as Map<String, dynamic> : {};

      final hostId = (data['hostId'] as String?) ?? uuid.v4();
      final hostNickname = (data['hostNickname'] as String?) ?? 'Trưởng phòng';
      final hostAvatar = (data['hostAvatar'] as String?) ?? '👑';
      final movieSlug = (data['movieSlug'] as String?) ?? '';
      final movieTitle = (data['movieTitle'] as String?) ?? 'Phim';
      final posterUrl = (data['posterUrl'] as String?) ?? '';
      final serverIndex = (data['serverIndex'] as int?) ?? 0;
      final serverName = (data['serverName'] as String?) ?? 'Vietsub #1';
      final episodeSlug = (data['episodeSlug'] as String?) ?? '';
      final episodeName = (data['episodeName'] as String?) ?? 'Tập 1';
      final streamUrl = (data['streamUrl'] as String?) ?? '';
      final isEmbed = (data['isEmbed'] as bool?) ?? false;
      final customRoomName = data['roomName'] as String?;

      final room = roomManager.createRoom(
        hostId: hostId,
        hostNickname: hostNickname,
        hostAvatar: hostAvatar,
        movieSlug: movieSlug,
        movieTitle: movieTitle,
        posterUrl: posterUrl,
        serverIndex: serverIndex,
        serverName: serverName,
        episodeSlug: episodeSlug,
        episodeName: episodeName,
        streamUrl: streamUrl,
        isEmbed: isEmbed,
        customRoomName: customRoomName,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'roomId': room.id,
          'hostId': hostId,
          'room': room.toJson(),
        }),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }
  });

  // REST: Get Room Info
  app.get('/api/rooms/<roomId>', (Request request, String roomId) {
    final room = roomManager.getRoom(roomId);
    if (room == null) {
      return Response.notFound(
        jsonEncode({'success': false, 'error': 'Phòng không tồn tại'}),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }
    return Response.ok(
      jsonEncode({'success': true, 'room': room.toJson()}),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });

  // Stream / M3U8 CORS Reverse Proxy
  app.get('/api/proxy', (Request request) async {
    final targetUrl = request.url.queryParameters['url'];
    if (targetUrl == null || targetUrl.isEmpty) {
      return Response.badRequest(body: 'Thiếu query param: url');
    }

    try {
      final uri = Uri.parse(targetUrl);
      final response = await http.get(uri, headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Referer': '${uri.scheme}://${uri.host}/',
      });

      return Response(
        response.statusCode,
        body: response.bodyBytes,
        headers: {
          'content-type':
              response.headers['content-type'] ?? 'application/octet-stream',
          'access-control-allow-origin': '*',
        },
      );
    } catch (e) {
      return Response.internalServerError(body: 'Lỗi Proxy: $e');
    }
  });

  // Mount WebSocket
  app.all('/ws/party', wsHandler.handler);

  // Setup pipeline with CORS
  final handler = const Pipeline()
      .addMiddleware(corsHeaders(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        },
      ))
      .addMiddleware(logRequests())
      .addHandler(app.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('=====================================================');
  print('🎬 FLURT WATCH PARTY SERVER STARTED');
  print('📡 HTTP Server: http://localhost:${server.port}');
  print('🔌 WebSocket:   ws://localhost:${server.port}/ws/party');
  print('=====================================================');
}
