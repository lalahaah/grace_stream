import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/theme/app_theme.dart';
import 'package:grace_stream/providers/player_provider.dart';

class WorshipScreen extends ConsumerStatefulWidget {
  const WorshipScreen({super.key});

  @override
  ConsumerState<WorshipScreen> createState() => _WorshipScreenState();
}

class _WorshipScreenState extends ConsumerState<WorshipScreen> {
  final List<Song> _mockWorships = [
    Song(
      id: 1,
      title: "은혜 아래 (Under Grace)",
      artist: "웨이메이커",
      cover:
          "https://images.unsplash.com/photo-1519307212971-dd9561667ffb?w=400&q=80",
      videoId: "mC6f9ID2Y-c",
    ),
    Song(
      id: 2,
      title: "길을 만드시는 주",
      artist: "레위지파",
      cover:
          "https://images.unsplash.com/photo-1499209974431-9dac3adaf471?w=400&q=80",
      videoId: "dQw4w9WgXcQ",
    ),
    Song(
      id: 3,
      title: "임재 (Presence)",
      artist: "마커스워십",
      cover:
          "https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=400&q=80",
      videoId: "dQw4w9WgXcQ",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '인기 워십 리스트',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              '더보기',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _mockWorships.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final song = _mockWorships[index];
          return _buildWorshipItem(song);
        },
      ),
    );
  }

  Widget _buildWorshipItem(Song song) {
    return GestureDetector(
      onTap: () => ref.read(playerProvider.notifier).play(song),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                song.cover,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    song.artist,
                    style: TextStyle(color: AppColors.textLight, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ref.read(playerProvider.notifier).play(song);
                ref.read(playerProvider.notifier).setShowVideo(true);
              },
              icon: const Icon(
                Icons.videocam_outlined,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
