import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/providers/player_provider.dart';

final youtubeServiceProvider = Provider((ref) => YoutubeService());

class YoutubeService {
  final Dio _dio = Dio();
  static String _apiKey = const String.fromEnvironment('YOUTUBE_API_KEY');
  final String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  YoutubeService() {
    _loadApiKey();
  }

  void _loadApiKey() {
    if (_apiKey.isEmpty) {
      try {
        final file = File('secrets.json');
        if (file.existsSync()) {
          final content = jsonDecode(file.readAsStringSync());
          _apiKey = content['YOUTUBE_API_KEY'] ?? '';
        }
      } catch (_) {
        // Ignore
      }
    }
  }

  Future<List<Song>> searchWorship(String query) async {
    if (_apiKey.isEmpty) {
      print(
        'Warning: YOUTUBE_API_KEY is empty. Check secrets.json and --dart-define-from-file.',
      );
      return [];
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': 10,
          'key': _apiKey,
        },
      );

      final List items = response.data['items'];
      return items.map((item) {
        final snippet = item['snippet'];
        final videoId = item['id']['videoId'];
        return Song(
          id: videoId.hashCode, // Use hash of videoId for consistency
          title: snippet['title'],
          artist: snippet['channelTitle'],
          cover: snippet['thumbnails']['high']['url'],
          videoId: videoId,
          tags: [],
        );
      }).toList();
    } catch (e) {
      print('Error searching YouTube: $e');
      return [];
    }
  }

  Future<Song?> getVideoDetails(String videoId) async {
    if (_apiKey.isEmpty) return null;

    try {
      final response = await _dio.get(
        '$_baseUrl/videos',
        queryParameters: {'part': 'snippet', 'id': videoId, 'key': _apiKey},
      );

      final items = response.data['items'] as List;
      if (items.isEmpty) return null;

      final snippet = items.first['snippet'];
      return Song(
        id: DateTime.now().millisecondsSinceEpoch,
        title: snippet['title'],
        artist: snippet['channelTitle'],
        cover: snippet['thumbnails']['high']['url'],
        videoId: videoId,
        tags: [],
      );
    } catch (e) {
      return null;
    }
  }
}
