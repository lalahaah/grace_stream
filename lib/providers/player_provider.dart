import 'package:flutter_riverpod/flutter_riverpod.dart';

class Song {
  final int id;
  final String title;
  final String artist;
  final String cover;
  final String videoId;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.cover,
    required this.videoId,
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
  PlayerNotifier() : super(PlayerState());

  void play(Song song) {
    state = state.copyWith(currentSong: song, isPlaying: true);
  }

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void setShowVideo(bool show) {
    state = state.copyWith(showVideo: show);
  }

  void stop() {
    state = PlayerState();
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((
  ref,
) {
  return PlayerNotifier();
});
