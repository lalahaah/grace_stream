import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/providers/player_provider.dart';

final youtubeServiceProvider = Provider((ref) => YoutubeService());

class YoutubeService {
  final Dio _dio = Dio();
  static String _apiKey = const String.fromEnvironment('YOUTUBE_API_KEY');
  final String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  YoutubeService() {
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
    _loadApiKey();
  }

  void _loadApiKey() {
    // 샌드박스 환경 문제를 원천 차단하기 위해 키를 직접 주입합니다.
    _apiKey = 'AIzaSyBKBnIq5eTfiIFkefST1jVwI4SSMgPQjsY';
  }

  Future<List<Song>> searchWorship(
    String query, {
    String order = 'relevance',
  }) async {
    debugPrint(
      'DEBUG: YoutubeService.searchWorship(query: $query, order: $order)',
    );
    if (_apiKey.isEmpty) {
      debugPrint('ERROR: YOUTUBE_API_KEY is empty.');
      return [];
    }

    // 글로벌 검색 품질을 위해 핵심 키워드를 보강합니다.
    final enhancedQuery =
        query.toLowerCase().contains('ccm') ||
            query.toLowerCase().contains('worship') ||
            query.toLowerCase().contains('praise')
        ? query
        : '$query CCM Worship Praise';

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'q': enhancedQuery,
          'type': 'video',
          'videoEmbeddable': 'true',
          'order': order, // relevance, viewCount, date, rating, title
          'maxResults': 15,
          'key': _apiKey,
        },
      );

      debugPrint('DEBUG: Response status: ${response.statusCode}');
      final List items = response.data['items'] ?? [];
      debugPrint('DEBUG: Found ${items.length} items.');

      return items.map((item) {
        final snippet = item['snippet'];
        final videoId = item['id']['videoId'];
        final thumbnails = snippet['thumbnails'];
        final coverUrl =
            thumbnails['high']?['url'] ??
            thumbnails['medium']?['url'] ??
            thumbnails['default']?['url'] ??
            '';

        return Song(
          id: videoId.hashCode,
          title: snippet['title'],
          artist: snippet['channelTitle'],
          cover: coverUrl,
          videoId: videoId,
          tags: [],
        );
      }).toList();
    } on DioException catch (e) {
      debugPrint('ERROR: YouTube API Search Failed!');
      debugPrint('ERROR Message: ${e.message}');
      debugPrint('ERROR Status: ${e.response?.statusCode}');
      debugPrint('ERROR Data: ${e.response?.data}');

      // Key issues identification
      if (e.response?.statusCode == 403) {
        debugPrint('CRITICAL: API Key might be invalid or restricted.');
      }
      return [];
    } catch (e) {
      debugPrint('ERROR: General exception searching YouTube: $e');
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
      final thumbnails = snippet['thumbnails'];
      final coverUrl =
          thumbnails['high']?['url'] ??
          thumbnails['medium']?['url'] ??
          thumbnails['default']?['url'] ??
          '';

      return Song(
        id: DateTime.now().millisecondsSinceEpoch,
        title: snippet['title'],
        artist: snippet['channelTitle'],
        cover: coverUrl,
        videoId: videoId,
        tags: [],
      );
    } catch (e) {
      return null;
    }
  }
}
