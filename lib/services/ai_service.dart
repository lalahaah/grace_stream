import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiServiceProvider = Provider((ref) => AIService());

class AIService {
  // Use a secure way to store/retrieve API Key in production
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';

  late final GenerativeModel _model;

  AIService() {
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
}
