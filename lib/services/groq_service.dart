import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_keys.dart';

class GroqService {
  static Future<String> _call({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    int maxTokens = 500,
  }) async {
    final response = await http.post(
      Uri.parse(ApiKeys.groqBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiKeys.groqApiKey}',
      },
      body: jsonEncode({
        'model': ApiKeys.groqModel,
        'max_tokens': maxTokens,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages,
        ],
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['choices'][0]['message']['content'] as String;
    }
    throw Exception('Groq error: ${response.statusCode}');
  }

  // 1. DAILY TIP
  static Future<String> getDailyTip() => _call(
    systemPrompt: 'You are an English coach. Give ONE practical English tip in exactly 2 short sentences. Be specific. No preamble.',
    messages: [const {'role': 'user', 'content': 'Give me today English tip.'}],
    maxTokens: 80,
  );

  // 2. DAILY MOTIVATION
  static Future<String> getDailyMotivation(int streak) => _call(
    systemPrompt: 'You are an encouraging English learning coach. Give a short motivational message in 1-2 sentences max.',
    messages: [{'role': 'user', 'content': 'I have a $streak day learning streak. Motivate me.'}],
    maxTokens: 60,
  );

  // 3. AI TUTOR CHAT
  static Future<String> chatWithTutor({
    required String scenario,
    required String persona,
    required List<Map<String, String>> conversationHistory,
  }) async {
    // 'persona' contains the role prompt (e.g. "You are a warm, polite barista...")
    final systemPrompt = 
      '$persona\n\n'
      'CRITICAL TEACHING INSTRUCTIONS:\n'
      '1. Keep your reply extremely short, sweet, and simple. Respond in maximum 1-2 short sentences using very easy, natural, and friendly wording so the user can easily understand you.\n'
      '2. Gently coach the user by analyzing their English usage in every turn:\n'
      '   - If the user made a grammar, spelling, or usage error in their last message, append this on a new line:\n'
      '     "💡 Correction: [Briefly explain gently: [wrong] -> [right]]"\n'
      '   - If their English is correct, praise them and suggest a natural alternative to boost their vocabulary:\n'
      '     "🚀 Vocabulary Boost: [Show a native-like alternative phrasing]"\n'
      '3. Keep all text very concise, clear, and easy to read. Total output must be under 150 words.\n'
      '4. IMPORTANT: Do not use any asterisks (*), double asterisks (**), or markdown tags in your response. Output in clean, reader-friendly plain text only.\n'
      '5. DIFFICULT/INTERESTING VOCABULARY COACHING:\n'
      '   - Pick ONE interesting, advanced, or scenario-specific word (like "peppermint", "herbal", "croissant", "barista" in a cafe, or "itinerary", "sightseeing" in travel, etc.) that you ACTUALLY used in your response above.\n'
      '   - NEVER pick extremely simple or basic words like "selection", "have", "want", "like", "sugar", "tea", "water", "coffee", "good".\n'
      '   - Keep the meaning and the example sentence extremely simple, clear, and short.\n'
      '   - Append this tag on a new line at the very end of your reply:\n'
      '     "📖 Word Explorer: [Word] | Meaning: [Short, simple definition] | Example: [Short, easy example sentence using the word]"';

    return _call(systemPrompt: systemPrompt, messages: conversationHistory, maxTokens: 200);
  }

  // 4. VOCABULARY WORD GENERATION
  static Future<Map<String, String>> generateVocabularyWord() async {
    final response = await _call(
      systemPrompt: 'You are an English vocabulary teacher. Generate ONE useful intermediate English word. Return ONLY valid JSON, no markdown:\n{"word":"","phonetic":"","meaning":"","example":"","usage_tip":""}',
      messages: [const {'role': 'user', 'content': 'Generate a vocabulary word.'}],
      maxTokens: 200,
    );
    try {
      final clean = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return Map<String, String>.from(jsonDecode(clean));
    } catch (_) {
      return {
        'word': 'Persevere', 'phonetic': '/ˌpɜːrsɪˈvɪər/',
        'meaning': 'To continue doing something despite difficulty.',
        'example': 'You must persevere to achieve your goals.',
        'usage_tip': 'Use when describing not giving up despite obstacles.',
      };
    }
  }

  // 5. GRAMMAR QUIZ GENERATION
  static Future<List<Map<String, dynamic>>> generateGrammarQuiz(String topic) async {
    final response = await _call(
      systemPrompt: 'You are an English grammar teacher. Generate exactly 10 MCQ questions about: $topic. Return ONLY valid JSON array, no markdown:\n[{"question":"","options":["","","",""],"answer":"","explanation":""}]',
      messages: [{'role': 'user', 'content': 'Generate grammar quiz about $topic.'}],
      maxTokens: 1000,
    );
    try {
      final clean = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return List<Map<String, dynamic>>.from(jsonDecode(clean));
    } catch (_) {
      return [
        {'question': 'She is ___ honest girl.', 'options': ['a','an','the','no article'], 'answer': 'an', 'explanation': 'Use "an" before vowel sounds.'},
        {'question': 'I ___ to school every day.', 'options': ['go','goes','going','gone'], 'answer': 'go', 'explanation': '"I" takes base form of verb.'},
      ];
    }
  }

  // 6. LIVE GRAMMAR ANALYZER
  static Future<Map<String, dynamic>> analyzeUserGrammar(String text) async {
    try {
      final response = await _call(
        systemPrompt: 'You are an English teacher. Analyze the user statement. If it contains grammar/spelling errors, set has_errors to true, correct it, provide a better vocabulary suggestion, and briefly explain why. Otherwise, set has_errors to false. Return ONLY valid JSON, no markdown:\n{"has_errors":false,"correction":"","vocab_suggestion":"","explanation":""}',
        messages: [{'role': 'user', 'content': text}],
        maxTokens: 300,
      );
      final clean = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(clean) as Map<String, dynamic>;
    } catch (_) {
      return {
        'has_errors': false,
        'correction': null,
        'vocab_suggestion': null,
        'explanation': null,
      };
    }
  }

  // 7. GET WORD DEFINITION
  static Future<Map<String, String>> getWordDefinition(String word) async {
    try {
      final response = await _call(
        systemPrompt: 'You are an English vocabulary teacher. Define the given word. Return ONLY valid JSON, no markdown:\n{"meaning":"","example":""}',
        messages: [{'role': 'user', 'content': 'Define the word: $word'}],
        maxTokens: 200,
      );
      final clean = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return Map<String, String>.from(jsonDecode(clean));
    } catch (_) {
      return {
        'meaning': 'Standard English vocabulary term.',
        'example': 'This word is useful in daily conversations.',
      };
    }
  }
}
