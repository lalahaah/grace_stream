import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Song {
  final int id;
  final String title;
  final String artist;
  final String cover;
  final String videoId;

  final List<String> tags;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.cover,
    required this.videoId,
    this.tags = const [],
  });
}

class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final bool showVideo;

  PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.showVideo = false,
  });

  PlayerState copyWith({Song? currentSong, bool? isPlaying, bool? showVideo}) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      showVideo: showVideo ?? this.showVideo,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  YoutubePlayerController? _controller;

  PlayerNotifier() : super(PlayerState());

  YoutubePlayerController? get controller => _controller;

  void play(Song song) {
    debugPrint(
      'DEBUG: PlayerNotifier.play() called for videoId: ${song.videoId}',
    );

    if (_controller != null) {
      debugPrint('DEBUG: Controller exists. Using load() for new song.');
      _controller!.load(song.videoId);
      state = state.copyWith(currentSong: song, isPlaying: true);
      return;
    }

    debugPrint('DEBUG: Creating new YoutubePlayerController.');
    _controller = YoutubePlayerController(
      initialVideoId: song.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    );

    // 재생 상태 리스너 등록
    _controller!.addListener(() {
      if (!mounted) return;
      if (state.isPlaying != _controller!.value.isPlaying) {
        debugPrint(
          'DEBUG: Controller isPlaying changed to: ${_controller!.value.isPlaying}',
        );
        state = state.copyWith(isPlaying: _controller!.value.isPlaying);
      }
      if (_controller!.value.hasError) {
        final errorCode = _controller!.value.errorCode;
        debugPrint('DEBUG: Controller Error: $errorCode');
        // Error 150: Embedding disabled by owner
        if (errorCode == 150 || errorCode == 101) {
          state = state.copyWith(isPlaying: false);
        }
      }
    });

    state = state.copyWith(currentSong: song, isPlaying: true);
  }

  void togglePlay() {
    if (_controller == null) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    // 상태는 리스너에서 업데이트됨
  }

  void setShowVideo(bool show) {
    state = state.copyWith(showVideo: show);
  }

  void stop() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    state = PlayerState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((
  ref,
) {
  return PlayerNotifier();
});
