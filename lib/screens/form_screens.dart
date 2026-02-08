import 'package:flutter/material.dart';
import 'package:grace_stream/theme/app_theme.dart';

class FormScreen extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> fields;
  final String submitLabel;

  const FormScreen({
    super.key,
    required this.title,
    required this.description,
    required this.fields,
    this.submitLabel = '제출하기',
  });

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ...fields,
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('제출되었습니다. 감사합니다!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  submitLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistRegisterScreen extends StatelessWidget {
  const ArtistRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FormScreen(
      title: 'CCM 아티스트 등록',
      description:
          'Grace Stream에서 당신의 찬양을 더 많은 사람들에게 들려주세요. 등록 신청을 하시면 담당자가 연락드립니다.',
      fields: [
        _buildTextField('활동명 (아티스트명)', '예: 그레이스 콰이어'),
        _buildTextField('소속 (교회/단체)', '예: 은혜교회'),
        _buildTextField('대표곡 유튜브 링크', 'https://youtube.com/...'),
        _buildTextField('연락처', '010-0000-0000'),
      ],
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PraiseRecommendScreen extends StatelessWidget {
  const PraiseRecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FormScreen(
      title: '찬양 추천하기',
      description: '은혜로운 찬양을 추천해주세요. 검토 후 Grace Stream에 추가하겠습니다.',
      fields: [
        _buildTextField('곡 제목', '예: 하나님의 은혜'),
        _buildTextField('아티스트', '예: 박종호'),
        _buildTextField('추천 이유', '이 곡을 들으면서 많은 위로를 받았습니다.', maxLines: 5),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InquiryScreen extends StatelessWidget {
  const InquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FormScreen(
      title: '1:1 문의',
      description: '앱 사용 중 불편한 점이나 제안하고 싶은 내용을 남겨주세요.',
      fields: [
        _buildTextField('문의 제목', '예: 성경 데이터 오류 제보'),
        _buildTextField('문의 내용', '어떤 내용인가요?', maxLines: 8),
        _buildTextField('답변 받을 이메일', 'example@gmail.com'),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
