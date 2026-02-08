import 'package:flutter/material.dart';
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
import 'package:hive_flutter/hive_flutter.dart';
import 'package:grace_stream/services/user_action_service.dart';
import 'package:grace_stream/models/bible.dart';
import 'package:grace_stream/models/user_action.dart';
import 'package:grace_stream/widgets/common_app_bar.dart';
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

  // Initialize User Action Service
  await BibleUserActionService().init();

  // TODO: Setup Firebase when configuration is ready
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
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BibleViewerScreen(),
    const WorshipScreen(),
    const LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Screen Content
          _screens[_currentIndex],

          // Floating Mini Player
          if (playerState.currentSong != null && !playerState.showVideo)
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: _buildMiniPlayer(playerState),
            ),

          // Custom Bottom Navigation
          Positioned(bottom: 24, left: 24, right: 24, child: _buildBottomNav()),

          // Video Overlay (if needed)
          if (playerState.showVideo && playerState.currentSong != null)
            _buildVideoOverlay(playerState),
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
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
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

  Widget _buildVideoOverlay(PlayerState player) {
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
              // Actual YouTube player would go here, using a placeholder for now
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: AppColors.primary,
                      size: 64,
                    ),
                  ),
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
                      setState(() => _currentIndex = 1);
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

  final Map<String, Map<String, String>> _emotionContent = {
    '위로': {
      'verse': '"수고하고 무거운 짐 진 자들아 다 내게로 오라 내가 내희를 쉬게 하리라"',
      'ref': '마태복음 11:28',
      'ai': '지친 당신의 마음을 주님께서 알고 계십니다. 오늘 하루 주님 안에서 참된 안식을 누리시길 기도합니다.',
      'ccm': '어노인팅 - 내 모습 이대로',
    },
    '감사': {
      'verse': '"범사에 감사하라 이것이 그리스도 예수 안에서 너희를 향하신 하나님의 뜻이니라"',
      'ref': '데살로니가전서 5:18',
      'ai': '모든 상황 속에서 감사의 제목을 찾아보세요. 감사는 기적을 부르는 통로가 됩니다.',
      'ccm': '마커스워십 - 감사함으로',
    },
    '평안': {
      'verse': '"나의 평안을 너희에게 주노라 내가 너희에게 주는 것은 세상이 주는 것과 같지 아니하니라"',
      'ref': '요한복음 14:27',
      'ai': '세상이 줄 수 없는 하늘의 평안이 당신의 마음과 생각을 지키시길 원합니다.',
      'ccm': '평안을 너에게 주노라',
    },
    '용기': {
      'verse': '"강하고 담대하라 두려워하지 말며 놀라지 말라 네가 어디로 가든지 네 하나님 여호와가 너와 함께 하느니라"',
      'ref': '여호수아 1:9',
      'ai': '주님께서 당신과 함께 걸어가고 계십니다. 어떤 도전 앞에서도 두려워하지 말고 믿음으로 전진하세요.',
      'ccm': '예수전도단 - 주님 우리게 하신 일',
    },
    '기쁨': {
      'verse': '"주 안에서 항상 기뻐하라 내가 다시 말하노니 기뻐하라"',
      'ref': '빌립보서 4:4',
      'ai': '환경에 좌우되지 않는 주님의 기쁨이 당신의 힘이 되길 소망합니다.',
      'ccm': '기뻐하며 경배하세',
    },
    '소망': {
      'verse': '"소망의 하나님이 모든 기쁨과 평강을 믿음 안에서 너희에게 충만하게 하사"',
      'ref': '로마서 15:13',
      'ai': '우리의 유일한 소망 되신 주님만을 바라볼 때, 하늘의 위로가 넘쳐날 것입니다.',
      'ccm': '이 몸의 소망 무언가',
    },
    '인도': {
      'verse': '"사람이 마음으로 자기의 길을 계획할지라도 그의 걸음을 인도하시는 이는 여호와시니라"',
      'ref': '잠언 16:9',
      'ai': '오늘 당신의 모든 걸음을 주님께 맡겨보세요. 가장 선한 길로 인도하실 것입니다.',
      'ccm': '주님 말씀하시면',
    },
    '휴식': {
      'verse': '"그가 나를 푸른 풀밭에 누이시며 쉴 만한 물가로 인도하시는도다"',
      'ref': '시편 23:2',
      'ai': '바쁜 일상 속에서도 주님이 주시는 쉼을 누리세요. 영혼이 새롭게 소생할 것입니다.',
      'ccm': '목마른 사슴',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProgressCard(context),
                const SizedBox(height: 32),
                _buildCategoryGrid(),
                const SizedBox(height: 32),
                _buildAIDailyVerseCard(context),
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

  Widget _buildProgressCard(BuildContext context) {
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
                  '"창세기 1-3장 읽기"',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
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
                    '읽기 시작하기',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
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
                  value: 0.65,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: Colors.white,
                  strokeWidth: 8,
                ),
              ),
              const Text(
                '65%',
                style: TextStyle(
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
                  onTap: () => setState(() => _selectedEmotion = cat['name']!),
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

  Widget _buildAIDailyVerseCard(BuildContext context) {
    final content = _emotionContent[_selectedEmotion]!;

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
            content['verse']!,
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
            content['ref']!,
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
                  content['ai']!,
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
            onTap: () {
              ref
                  .read(playerProvider.notifier)
                  .play(
                    Song(
                      id: 101,
                      title: content['ccm']!,
                      artist: "오늘의 추천 찬양",
                      cover:
                          "https://images.unsplash.com/photo-1519307212971-dd9561667ffb?w=400&q=80",
                      videoId: "dQw4w9WgXcQ",
                    ),
                  );
            },
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '추천 CCM',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        content['ccm']!,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFE2E8F0)),
              ],
            ),
          ),
        ],
      ),
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
