import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
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
    // If not provided via dart-define, try to load from secrets.json (for local dev)
    if (_apiKey.isEmpty) {
      try {
        final file = File(Directory.current.path + '/secrets.json');
        if (file.existsSync()) {
          final content = jsonDecode(file.readAsStringSync());
          final key = content['GEMINI_API_KEY'] ?? '';
          if (key.isNotEmpty) {
            _apiKey = key;
          }
        }
      } catch (e) {
        print('Error loading Gemini API Key from secrets.json: $e');
      }
    }
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
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
내용 요약: ${chapterContent.length > 500 ? chapterContent.substring(0, 500) + '...' : chapterContent}

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
      print('Error getting AI recommendation: $e');
      return '추천 메시지를 가져오는 중 오류가 발생했습니다: ${e.toString()}';
    }
  }
}
