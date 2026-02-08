import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide PlayerState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grace_stream/theme/app_theme.dart';
import 'package:grace_stream/screens/bible_viewer_screen.dart';
import 'package:grace_stream/screens/worship_screen.dart';
import 'package:grace_stream/screens/bible_settings_screen.dart';
import 'package:grace_stream/screens/app_settings_screens.dart';
import 'package:grace_stream/screens/info_screens.dart';
import 'package:grace_stream/screens/form_screens.dart';
import 'package:grace_stream/providers/player_provider.dart';
import 'package:grace_stream/models/bible_settings.dart';
import 'package:grace_stream/providers/today_verse_provider.dart';
import 'package:grace_stream/providers/reading_goal_provider.dart';
import 'package:grace_stream/providers/bible_provider.dart';
import 'package:grace_stream/providers/bottom_nav_provider.dart';
import 'package:grace_stream/widgets/common_app_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:grace_stream/services/user_action_service.dart';
import 'package:grace_stream/models/bible.dart';
import 'package:grace_stream/models/user_action.dart';
import 'package:grace_stream/widgets/reading_goal_dialog.dart';
import 'package:grace_stream/services/youtube_service.dart';
import 'package:grace_stream/services/reading_goal_service.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(BibleVerseAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(HighlightAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(BookmarkAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(BibleSettingsAdapter());
  }

  // Initialize Services
  await BibleUserActionService().init();
  await ReadingGoalService().init();

  // Placeholder for future Firebase initialization
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const ProviderScope(child: GraceStreamApp()));
}

class GraceStreamApp extends StatelessWidget {
  const GraceStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grace Stream',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const BibleViewerScreen(),
    const WorshipScreen(),
    const LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final currentIndex = ref.watch(bottomNavProvider);

    // 1. 단일 플레이어 위젯 정의 (상태 유지를 위해 고정)
    final playerWidget = playerState.currentSong != null
        ? YoutubePlayer(
            key: const ValueKey('global_youtube_player'),
            controller: ref.read(playerProvider.notifier).controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.primary,
            onReady: () {
              debugPrint('DEBUG: YoutubePlayer onReady - calling play()');
              ref.read(playerProvider.notifier).controller!.play();
            },
          )
        : const SizedBox.shrink();

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // 1. Screen Content
          _screens[currentIndex],

          // 2. Global Player Instance (상시 유지하여 소리 끊김 방지)
          if (playerState.currentSong != null) ...[
            if (playerState.showVideo)
              _buildVideoOverlay(playerState, playerWidget)
            else
              // 화면에서 보이지 않도록 좌측 멀리 배치하고 투명도를 낮춤 (엔진 활성화를 위해 렌더링은 유지)
              Positioned(
                top: 0,
                left: -1000,
                child: Opacity(
                  opacity: 0.01,
                  child: SizedBox(width: 1, height: 1, child: playerWidget),
                ),
              ),

            // 3. Floating Mini Player
            // 홈 화면이고 현재 재생 중인 곡이 AI 추천 말씀의 ccm 곡인 경우 미니 플레이어를 숨깁니다. (인라인 플레이어 사용)
            if (!playerState.showVideo &&
                !(currentIndex == 0 &&
                    playerState.currentSong?.artist == 'AI 추천 찬양'))
              Positioned(
                bottom: 112,
                left: 24,
                right: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ref
                            .watch(playerProvider.notifier)
                            .controller
                            ?.value
                            .errorCode ==
                        150)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '권한 제한으로 재생할 수 없는 곡입니다. 다른 곡을 선택해주세요.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildMiniPlayer(playerState),
                  ],
                ),
              ),
          ],

          // 4. Custom Bottom Navigation
          Positioned(bottom: 24, left: 24, right: 24, child: _buildBottomNav()),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.backgroundLight,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. 사용자 프로필 및 계정 (Top Section)
          _buildDrawerHeader(),

          // 2. 성경 및 플레이어 설정 (Setting Section)
          _buildDrawerSectionTitle('환경 설정'),
          _buildDrawerItem(Icons.font_download_outlined, '성경 폰트 및 스타일'),
          _buildDrawerItem(Icons.high_quality_outlined, '오디오 품질 설정'),
          _buildDrawerItem(Icons.timer_outlined, '취면 예약'),

          const Divider(height: 32, thickness: 1, indent: 24, endIndent: 24),

          // 3. 플랫폼 확장 및 상생 (Business Section)
          _buildDrawerSectionTitle('커뮤니티 및 참여'),
          _buildDrawerItem(Icons.person_add_alt_1_outlined, 'CCM 아티스트 등록'),
          _buildDrawerItem(Icons.recommend_outlined, '찬양 추천하기'),
          _buildDrawerItem(Icons.campaign_outlined, '공지사항 및 이벤트'),

          const Divider(height: 32, thickness: 1, indent: 24, endIndent: 24),

          // 4. 고객 지원 및 법적 고지 (Support Section)
          _buildDrawerSectionTitle('지원'),
          _buildDrawerItem(Icons.info_outline, '출처 및 저작권'),
          _buildDrawerItem(Icons.description_outlined, '이용약관'),
          _buildDrawerItem(Icons.privacy_tip_outlined, '개인정보 처리방침'),
          _buildDrawerItem(Icons.help_outline, '자주 묻는 질문 (FAQ)'),
          _buildDrawerItem(Icons.contact_support_outlined, '1:1 문의'),
          _buildDrawerItem(Icons.code_outlined, '오픈소스 라이선스'),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primary, size: 36),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '성령충만',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'grace@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Grace Pro 멤버십',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '현재 창세기 통독 중 (45%)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: AppColors.textMain, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMain,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer

        Widget? screen;
        switch (title) {
          case '성경 폰트 및 스타일':
          case '배경색 선택':
            screen = const BibleSettingsScreen();
            break;
          case '오디오 품질 설정':
            screen = const AudioSettingsScreen();
            break;
          case '취면 예약':
            screen = const SleepTimerScreen();
            break;
          case 'CCM 아티스트 등록':
          case '찬양 추천하기':
          case '공지사항 및 이벤트':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('서비스 준비 중입니다. 곧 찾아뵙겠습니다!'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          case '출처 및 저작권':
            screen = const InfoScreen(
              title: '출처 및 저작권',
              content: CopyrightScreen(),
            );
            break;
          case '이용약관':
            screen = const InfoScreen(
              title: '이용약관',
              content: TermsOfServiceScreen(),
            );
            break;
          case '개인정보 처리방침':
            screen = const InfoScreen(
              title: '개인정보 처리방침',
              content: PrivacyPolicyScreen(),
            );
            break;
          case '자주 묻는 질문 (FAQ)':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('서비스 준비 중입니다. 곧 찾아뵙겠습니다!'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          case '1:1 문의':
            screen = const InquiryScreen();
            break;
          case '오픈소스 라이선스':
            showLicensePage(
              context: context,
              applicationName: 'Grace Stream',
              applicationVersion: '1.0.0',
            );
            return;
        }

        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen!),
          );
        }
      },
    );
  }

  Widget _buildMiniPlayer(PlayerState player) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              player.currentSong!.cover,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 44,
                height: 44,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.music_note, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(playerProvider.notifier).setShowVideo(true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    player.currentSong!.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    player.currentSong!.artist,
                    style: TextStyle(color: AppColors.textLight, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(playerProvider.notifier).togglePlay(),
            icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () => ref.read(playerProvider.notifier).stop(),
            icon: Icon(Icons.close, size: 18, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_outlined, Icons.home, 0, '홈'),
          _navItem(Icons.music_note_outlined, Icons.music_note, 2, '찬양'),

          // Center Search Button
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: AppTheme.indigoShadow,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),

          _navItem(Icons.book_outlined, Icons.book, 1, '성경'),
          _navItem(Icons.bookmark_outline, Icons.bookmark, 3, '보관함'),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData inactiveIcon,
    IconData activeIcon,
    int index,
    String label,
  ) {
    final currentIndex = ref.watch(bottomNavProvider);
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => ref.read(bottomNavProvider.notifier).state = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppColors.primary : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textLight,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoOverlay(PlayerState player, Widget playerWidget) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.95),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () =>
                          ref.read(playerProvider.notifier).setShowVideo(false),
                    ),
                    Column(
                      children: [
                        Text(
                          player.currentSong!.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          player.currentSong!.artist,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: playerWidget,
                ),
              ),
              const SizedBox(height: 32),
              // 고도화: 가사 및 성경 연동 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPlayerActionBtn(Icons.article_outlined, '가사 보기', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('준비 중인 기능입니다.')),
                      );
                    }),
                    _buildPlayerActionBtn(Icons.menu_book, '성경 이동', () {
                      ref.read(playerProvider.notifier).setShowVideo(false);
                      ref.read(bottomNavProvider.notifier).state = 1;
                    }),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  '"찬양 중에 거하시는 주님을 만나보세요"',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerActionBtn(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 28),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedEmotion = '평안'; // Default emotion

  @override
  void initState() {
    super.initState();
    debugPrint('DEBUG: HomeScreen initState called');
    // 초기 로딩 시 기본 감정으로 말씀 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('DEBUG: fetchVerse triggered for $_selectedEmotion');
      ref.read(todayVerseProvider.notifier).fetchVerse(_selectedEmotion);
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiVerseState = ref.watch(todayVerseProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Consumer(
                  builder: (context, ref, child) =>
                      _buildProgressCard(context, ref),
                ),
                const SizedBox(height: 32),
                _buildCategoryGrid(),
                const SizedBox(height: 32),
                _buildAIDailyVerseCard(context, aiVerseState),
                const SizedBox(height: 120), // Bottom padding for floating nav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return CommonAppBar.sliver(context);
  }

  Widget _buildProgressCard(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(readingGoalProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.indigoShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 통독 목표',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goal != null ? goal.rangeText : '"목표를 설정해보세요"',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _showGoalSettingDialog(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        side: const BorderSide(color: Colors.white, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        goal != null ? '목표 변경하기' : '목표 설정하기',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (goal != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // 1. 읽지 않은 첫 번째 장 찾기
                          int targetChapter = goal.startChapter;
                          for (
                            int i = goal.startChapter;
                            i <= goal.endChapter;
                            i++
                          ) {
                            if (!goal.readChapters.contains(i)) {
                              targetChapter = i;
                              break;
                            }
                          }
                          // 2. 위치 업데이트
                          ref.read(currentPositionProvider.notifier).state = (
                            bookId: goal.bookId,
                            chapter: targetChapter.toString(),
                          );
                          // 3. 탭 전환
                          ref.read(bottomNavProvider.notifier).state = 1;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '지금 읽기',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: goal?.progress ?? 0.0,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: Colors.white,
                  strokeWidth: 8,
                ),
              ),
              Text(
                '${((goal?.progress ?? 0.0) * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGoalSettingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ReadingGoalDialog(),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': '평안', 'icon': '🌿'},
      {'name': '감사', 'icon': '🙏'},
      {'name': '위로', 'icon': '🕊️'},
      {'name': '용기', 'icon': '🦁'},
      {'name': '기쁨', 'icon': '☀️'},
      {'name': '소망', 'icon': '⚓'},
      {'name': '인도', 'icon': '🗺️'},
      {'name': '휴식', 'icon': '🛋️'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            '오늘의 감정',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedEmotion == cat['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedEmotion = cat['name']!);
                    ref
                        .read(todayVerseProvider.notifier)
                        .fetchVerse(cat['name']!);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.backgroundLight,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat['icon']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name']!,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAIDailyVerseCard(BuildContext context, TodayVerseState state) {
    if (state.isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppTheme.softShadow,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'AI가 당신을 위한 말씀을 준비 중입니다...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (state.error != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppTheme.softShadow,
        ),
        child: Center(
          child: Text(
            state.error!,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      );
    }

    final data = state.data;
    if (data.isEmpty) return const SizedBox.shrink();

    final playerState = ref.watch(playerProvider);
    final isThisSongPlaying = playerState.currentSong?.artist == 'AI 추천 찬양';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "TODAY'S VERSE",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.bookmark_outline, color: Color(0xFFE2E8F0)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            data.verse,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.ref,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.message_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI 해설',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data.ai,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              if (isThisSongPlaying) {
                ref.read(playerProvider.notifier).togglePlay();
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('추천 찬양을 찾는 중입니다...')),
              );
              final youtube = ref.read(youtubeServiceProvider);
              final results = await youtube.searchWorship(data.ccm);

              if (results.isNotEmpty) {
                final song = results.first;
                final aiSong = Song(
                  id: song.id,
                  title: song.title,
                  artist: 'AI 추천 찬양',
                  cover: song.cover,
                  videoId: song.videoId,
                );
                ref.read(playerProvider.notifier).play(aiSong);
              } else {
                final fallbackResults = await youtube.searchWorship(
                  '인기 찬양 베스트 CCM',
                );
                if (fallbackResults.isNotEmpty) {
                  final song = fallbackResults.first;
                  final aiSong = Song(
                    id: song.id,
                    title: song.title,
                    artist: 'AI 추천 찬양',
                    cover: song.cover,
                    videoId: song.videoId,
                  );
                  ref.read(playerProvider.notifier).play(aiSong);
                } else {
                  ref
                      .read(playerProvider.notifier)
                      .play(
                        Song(
                          id: 2001,
                          title: "주가 주되심을 (Official)",
                          artist: "AI 추천 찬양",
                          cover:
                              "https://i.ytimg.com/vi/1TSgDWi323g/hqdefault.jpg",
                          videoId: "1TSgDWi323g",
                        ),
                      );
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isThisSongPlaying
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(24),
                border: isThisSongPlaying
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isThisSongPlaying
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isThisSongPlaying && playerState.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isThisSongPlaying
                              ? playerState.currentSong!.title
                              : data.ccm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isThisSongPlaying ? '현재 재생 중' : 'AI 추천 찬양',
                          style: TextStyle(
                            color: isThisSongPlaying
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: isThisSongPlaying
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isThisSongPlaying)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildSimpleVisualizer(),
                    ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('보관함에 저장되었습니다.')),
                      );
                    },
                    icon: const Icon(
                      Icons.favorite_border,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('추천 영상을 불러오는 중입니다...')),
                      );
                      final youtube = ref.read(youtubeServiceProvider);
                      final results = await youtube.searchWorship(data.ccm);
                      if (results.isNotEmpty) {
                        ref.read(playerProvider.notifier).play(results.first);
                        ref.read(playerProvider.notifier).setShowVideo(true);
                      } else {
                        // 검색 결과가 없는 경우 인기 영상으로 재검색
                        final fallbackResults = await youtube.searchWorship(
                          '인기 찬양 베스트 CCM',
                        );
                        if (fallbackResults.isNotEmpty) {
                          ref
                              .read(playerProvider.notifier)
                              .play(fallbackResults.first);
                          ref.read(playerProvider.notifier).setShowVideo(true);
                        } else {
                          // 백업 곡 재생
                          ref
                              .read(playerProvider.notifier)
                              .play(
                                Song(
                                  id: 1001,
                                  title: "소원 (One Desire)",
                                  artist: "꿈이있는자유",
                                  cover:
                                      "https://i.ytimg.com/vi/mC6f9ID2Y-c/hqdefault.jpg",
                                  videoId: "mC6f9ID2Y-c",
                                ),
                              );
                          ref.read(playerProvider.notifier).setShowVideo(true);
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.videocam_outlined,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleVisualizer() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 3,
          height: 12 + (index * 4 % 8).toDouble(),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

// class WorshipScreen extends StatelessWidget {
//   const WorshipScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('찬양')),
//       body: const Center(child: Text('찬양 스트리밍 (구현 예정)')),
//     );
//   }
// }

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CommonAppBar.standard(
        context,
        centerWidget: const Text(
          '보관함',
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(child: Text('북마크 및 기록 (구현 예정)')),
    );
  }
}
