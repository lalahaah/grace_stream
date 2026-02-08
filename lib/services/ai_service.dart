import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiServiceProvider = Provider((ref) => AIService());

class AIService {
  // Use a secure way to store/retrieve API Key in production
  static String _apiKey = const String.fromEnvironment('GEMINI_API_KEY');
  late GenerativeModel _model;

  AIService() {
    _initModel();
  }

  void _initModel() {
    // 샌드박스 환경 문제를 원천 차단하기 위해 키를 직접 주입합니다.
    _apiKey = 'AIzaSyDKC8wr_Mz5flqk8vy4Ko7zaVtS8VV9Jgk';
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);
  }

  Future<String> explainVerse(
    String bookName,
    String chapter,
    String verse,
    String text,
  ) async {
    final prompt =
        '''
너는 성경 전문가이자 따뜻한 목회자야. 
다음 성경 구절을 초등학생도 이해할 수 있을 정도로 쉽고 친절하게 설명해줘.
말투는 부드럽고 따뜻하게 해줘.

구절: $bookName $chapter:$verse - "$text"

설명 구조:
1. 이 구절이 무슨 뜻인가요? (핵심 의미)
2. 우리 삶에 어떻게 적용할 수 있을까요? (짧은 교훈)
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '죄송해요, 설명을 생성하지 못했어요.';
    } catch (e) {
      return '오류가 발생했습니다: $e';
    }
  }

  Future<String> explainWord(String word, String contextText) async {
    final prompt =
        '''
성경을 읽다가 나온 이 단어의 의미를 성경적 배경과 함께 설명해줘.
단어: "$word"
문맥: "$contextText"

설명 구조:
- 성경적 의미와 당시 배경
- 오늘날 우리가 어떻게 이해하면 좋을지
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '단어 설명을 찾지 못했어요.';
    } catch (e) {
      return '오류가 발생했습니다: $e';
    }
  }

  Future<String> getWorshipRecommendation(
    String bookName,
    String chapter,
    String chapterContent,
  ) async {
    if (_apiKey.isEmpty) {
      return 'AI 추천을 위해 GEMINI_API_KEY 설정이 필요합니다.\nsecrets.json 파일을 확인해주세요.';
    }

    final prompt =
        '''
너는 찬양 큐레이터이자 영적 멘토야. 
사용자가 현재 성경의 특정 장을 읽고 있어. 이 장의 주제와 분위기에 어울리는 찬양 추천 메시지를 작성해줘.

현재 읽고 있는 장: $bookName $chapter장
내용 요약: ${chapterContent.length > 500 ? '${chapterContent.substring(0, 500)}...' : chapterContent}

요구사항:
1. "오늘 읽으신 [구절]과 어울리는 [테마] 찬양"과 같은 한 문장의 강렬한 배너 문구를 먼저 작성해줘.
2. 그 아래에 왜 이 찬양 테마를 추천하는지 짧은(2문장 이내) 해설을 덧붙여줘.
3. 한국어로 작성해줘.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '오늘의 추천 메시지를 생성하지 못했습니다.';
    } catch (e) {
      debugPrint('Error getting AI recommendation: $e');
      return '추천 메시지를 가져오는 중 오류가 발생했습니다: ${e.toString()}';
    }
  }

  Future<Map<String, String>> getEmotionVerse(String emotion) async {
    final prompt =
        '''
너는 성경 전문가이자 따뜻한 목회자 매니저야.
사용자가 현재 "$emotion"의 감정을 느끼고 있어. 이 감정에 깊은 위로와 공감을 줄 수 있는 오늘의 성경 말씀과 해설, 그리고 어울리는 찬양을 추천해줘.

요구사항:
1. $emotion의 감정에 가장 잘 어울리는 성경 구절을 선정해줘.
2. 선정된 구절에 대한 따뜻한 AI 해설을 2~3문장으로 작성해줘.
3. 이 구절 및 감정과 가장 잘 어울리는 한국 CCM(찬양) 제목을 하나 추천해줘.

응답은 반드시 아래의 JSON 형식으로만 해줘. 다른 설명은 하지 마.
{
  "verse": "성경 구절 내용",
  "ref": "성경 장-절 정보",
  "ai": "따뜻한 AI 해설 내용",
  "ccm": "추천 CCM 곡 제목"
}
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? '';

      // JSON 파싱 시도 (더 견고하게)
      String cleanJson = text;
      if (text.contains('{') && text.contains('}')) {
        cleanJson = text.substring(
          text.indexOf('{'),
          text.lastIndexOf('}') + 1,
        );
      }

      final decoded = jsonDecode(cleanJson) as Map<String, dynamic>;

      return {
        'verse': decoded['verse']?.toString() ?? '',
        'ref': decoded['ref']?.toString() ?? '',
        'ai': decoded['ai']?.toString() ?? '',
        'ccm': decoded['ccm']?.toString() ?? '',
      };
    } catch (e) {
      debugPrint('AIService: Error in getEmotionVerse: $e');
      rethrow; // Let the provider handle the error and avoid caching bad data
    }
  }
}
