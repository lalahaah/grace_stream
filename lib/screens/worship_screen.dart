import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/theme/app_theme.dart';
import 'package:grace_stream/providers/player_provider.dart';
import 'package:grace_stream/providers/worship_provider.dart';
import 'package:grace_stream/widgets/common_app_bar.dart';

class WorshipScreen extends ConsumerStatefulWidget {
  const WorshipScreen({super.key});

  @override
  ConsumerState<WorshipScreen> createState() => _WorshipScreenState();
}

class _WorshipScreenState extends ConsumerState<WorshipScreen> {
  final List<Map<String, String>> _categories = [
    {'name': '평안', 'icon': '🌿'},
    {'name': '감사', 'icon': '🙏'},
    {'name': '위로', 'icon': '🕊️'},
    {'name': '용기', 'icon': '🦁'},
    {'name': '기쁨', 'icon': '☀️'},
    {'name': '소망', 'icon': '⚓'},
    {'name': '간구', 'icon': '🛐'},
    {'name': '회개', 'icon': '⛪'},
  ];

  final List<Map<String, String>> _artists = [
    {
      'name': '웨이메이커',
      'image':
          'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=100&q=80',
    },
    {
      'name': '레위지파',
      'image':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&q=80',
    },
    {
      'name': '마커스워십',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80',
    },
    {
      'name': '어노인팅',
      'image':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&q=80',
    },
    {
      'name': '아이제야61',
      'image':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // 1. SliverAppBar
          CommonAppBar.sliver(
            context,
            pinned: true,
            centerWidget: const Text(
              'CCM & 워십',
              style: TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            additionalActions: [
              IconButton(
                onPressed: () => _showSearchDialog(context),
                icon: const Icon(Icons.search, color: AppColors.textLight),
              ),
            ],
          ),

          // 2. 오늘의 픽 (Today's Featured Banner)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('오늘의 픽'),
                  const SizedBox(height: 16),
                  ref
                      .watch(worshipAIRecommendationProvider)
                      .when(
                        data: (msg) => GestureDetector(
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).state =
                                "오늘의 추천 찬양";
                          },
                          child: _buildFeaturedBanner(msg),
                        ),
                        loading: () => _buildFeaturedBanner('고민 중...'),
                        error: (e, _) => _buildFeaturedBanner(e.toString()),
                      ),
                ],
              ),
            ),
          ),

          // 3. 감정/상황별 테마 (Categories Horizontal List)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverToBoxAdapter(child: _buildSectionTitle('상황별 테마')),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected =
                      ref.watch(selectedCategoryProvider) == cat['name'];
                  return _buildCategoryItem(cat, isSelected);
                },
              ),
            ),
          ),

          // 4. 인기 아티스트 (Artist Hub)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverToBoxAdapter(child: _buildSectionTitle('아티스트 허브')),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _artists.length,
                itemBuilder: (context, index) {
                  return _buildArtistItem(_artists[index]);
                },
              ),
            ),
          ),

          // 5. 추천 찬양 리스트
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            sliver: SliverToBoxAdapter(child: _buildSectionTitle('추천 찬양')),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: Builder(
              builder: (context) {
                final songs = ref.watch(filteredWorshipsProvider);
                if (songs.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('찬양 정보를 불러오는 중입니다...'),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = songs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildWorshipItem(song),
                    );
                  }, childCount: songs.length),
                );
              },
            ),
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('찬양 검색'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '검색어를 입력하세요 (예: 심종호 찬양)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              ref.read(selectedCategoryProvider.notifier).state = value;
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(selectedCategoryProvider.notifier).state =
                    controller.text;
                Navigator.pop(context);
              }
            },
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textMain,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildFeaturedBanner(String message) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.indigoShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.auto_awesome,
              size: 140,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI 맞춤 추천',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, String> cat, bool isSelected) {
    return GestureDetector(
      onTap: () {
        final current = ref.read(selectedCategoryProvider);
        if (current == cat['name']) {
          ref.read(selectedCategoryProvider.notifier).state = null;
        } else {
          ref.read(selectedCategoryProvider.notifier).state = cat['name'];
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? AppTheme.indigoShadow
                    : AppTheme.softShadow,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(cat['icon']!, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cat['name']!,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistItem(Map<String, String> artist) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = artist['name'];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: ClipOval(
                child: Image.network(
                  artist['image']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artist['name']!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
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
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.music_note,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
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
                // Toggle favorite UI only for now
              },
              icon: const Icon(
                Icons.favorite_border,
                color: AppColors.textLight,
                size: 20,
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
