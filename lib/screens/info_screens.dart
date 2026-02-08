import 'package:flutter/material.dart';
import 'package:grace_stream/theme/app_theme.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final Widget content;

  const InfoScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: content,
    );
  }
}

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notices = [
      {
        'title': 'Grace Stream 정식 출시 안내',
        'date': '2026.02.01',
        'important': true,
      },
      {'title': '성경 검색 기능 업데이트 공지', 'date': '2026.01.25', 'important': false},
      {'title': '설 연휴 고객센터 운영 안내', 'date': '2026.01.20', 'important': false},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: notices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final notice = notices[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notice['important'] as bool)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '중요',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                notice['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notice['date'] as String,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        _FAQItem(
          question: '성경 데이터는 어디서 가져오나요?',
          answer:
              'Grace Stream의 성경 데이터는 공공 데이터 포털 및 저작권이 만료된 개역한글판 등을 기반으로 제공됩니다.',
        ),
        _FAQItem(
          question: '오프라인에서도 찬양을 들을 수 있나요?',
          answer: '현재는 스트리밍 방식만 지원하며, 추후 오프라인 다운로드 기능을 제공할 예정입니다.',
        ),
        _FAQItem(
          question: '아이디를 잊어버렸어요.',
          answer: '이메일 주소를 통해 비밀번호 재설정 및 계정 찾기가 가능합니다.',
        ),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.question,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            trailing: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CopyrightScreen extends StatelessWidget {
  const CopyrightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '출처 및 저작권 고지',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          _textBlock('성경 데이터', '개역한글판 (저작권 만료), 관련 API 서비스 (Bible Brain 등)'),
          _textBlock(
            '찬양 및 이미지',
            '각 소유권자 및 유튜브 API (YouTube Data API v3) 약관을 준수합니다.',
          ),
          _textBlock('폰트', 'Google Fonts (Nanum Myeongjo, Noto Sans KR 등)'),
          const SizedBox(height: 40),
          const Text(
            'Grace Stream은 모든 저작권자의 권리를 존중하며, 관련 고지 사항에 대한 문의는 고객지원으로 연락 주시기 바랍니다.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textBlock(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '개인정보 처리방침',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24),
          _PolicySection(
            title: '1. 수집하는 개인정보 항목',
            content:
                '앱 이용 과정에서 서비스 이용 기록, 기기 정보 등이 자동으로 생성되어 수집될 수 있습니다. 문의하기를 이용할 경우 이메일 주소를 수집합니다.',
          ),
          _PolicySection(
            title: '2. 개인정보의 수집 및 이용 목적',
            content: '서비스 제공 및 개선, 고객 문의 응대, 서비스 이용 기록 분석 등을 목적으로 개인정보를 이용합니다.',
          ),
          _PolicySection(
            title: '3. 개인정보의 보유 및 이용 기간',
            content: '원칙적으로 개인정보 수집 및 이용 목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다.',
          ),
        ],
      ),
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이용약관',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24),
          _PolicySection(
            title: '제1조 (목적)',
            content:
                '본 약관은 Grace Stream(이하 "서비스")이 제공하는 제반 서비스의 이용과 관련하여 회사와 회원과의 권리, 의무 및 책임사항 등을 규정함을 목적으로 합니다.',
          ),
          _PolicySection(
            title: '제2조 (서비스의 제공 및 변경)',
            content:
                '서비스는 성경 읽기, 찬양 스트리밍 등의 기능을 제공하며, 운영상 필요한 경우 서비스 내용을 변경할 수 있습니다.',
          ),
          _PolicySection(
            title: '제3조 (이용자의 의무)',
            content:
                '이용자는 관계 법령 및 본 약관의 규정, 이용안내 등을 준수하여야 하며, 기타 서비스 운영에 방해되는 행위를 해서는 안 됩니다.',
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
