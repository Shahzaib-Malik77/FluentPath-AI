import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_keys.dart';

class GroqService {
  static Future<String> _call({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    int maxTokens = 500,
    int timeoutSeconds = 15,
  }) async {
    final apiKey = ApiKeys.groqApiKey.trim();
    if (apiKey.isEmpty) {
      throw StateError('Missing GROQ_API_KEY');
    }

    final response = await http.post(
      Uri.parse(ApiKeys.groqBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': ApiKeys.groqModel,
        'max_tokens': maxTokens,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages,
        ],
      }),
    ).timeout(Duration(seconds: timeoutSeconds));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['choices'][0]['message']['content'] as String;
    }
    throw Exception('Groq error: ${response.statusCode}');
  }

  // 1. DAILY TIP
  static Future<String> getDailyTip() async {
    try {
      return await _call(
        systemPrompt: 'You are an expert English coach. Give ONE highly practical, easy-to-understand English learning tip for an intermediate (medium) learner. Focus on daily conversation, common mistakes, or grammar shortcuts. Keep it exactly 2 short, simple sentences. No preamble.',
        messages: [const {'role': 'user', 'content': 'Give me an easy and highly useful English tip for today.'}],
        maxTokens: 100,
      );
    } catch (_) {
      return 'Practice one useful sentence pattern today, then change only one word to make three new sentences. This builds fluency faster than memorizing long lists.';
    }
  }

  // 2. DAILY MOTIVATION
  static Future<String> getDailyMotivation(int streak) async {
    try {
      return await _call(
        systemPrompt: 'You are an encouraging English learning coach. Give a short motivational message in 1-2 sentences max.',
        messages: [{'role': 'user', 'content': 'I have a $streak day learning streak. Motivate me.'}],
        maxTokens: 60,
      );
    } catch (_) {
      return 'Your $streak day streak is real progress. Keep one small promise today and your English will keep compounding.';
    }
  }

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
      '1. Keep your reply extremely short, sweet, professional, and simple. Respond in maximum 1-2 short sentences using very easy, natural, and friendly wording so the user can easily understand you.\n'
      '2. ALWAYS USE SIMPLE, PROFESSIONAL, AND EASY-TO-UNDERSTAND ENGLISH. Do not use overly complex vocabulary, difficult idioms, or long compound sentences. Keep the language highly accessible so the learner can easily understand your meaning without feeling confused.\n'
      '3. Gently coach the user by analyzing their English usage in every turn:\n'
      '   - If the user made a grammar, spelling, or usage error in their last message, append this on a new line:\n'
      '     "💡 Correction: [Briefly explain gently using extremely simple terms: [wrong] -> [right]]"\n'
      '   - If their English is correct, praise them and suggest a simple natural alternative to boost their vocabulary:\n'
      '     "🚀 Vocabulary Boost: [Show an easy native-like alternative phrasing]"\n'
      '4. Keep all text very concise, clear, and easy to read. Total output must be under 150 words.\n'
      '5. IMPORTANT: Do not use any asterisks (*), double asterisks (**), or markdown tags in your response. Output in clean, reader-friendly plain text only.\n'
      '6. DIFFICULT/INTERESTING VOCABULARY COACHING:\n'
      '   - Pick ONE interesting, advanced, or scenario-specific word (like "peppermint", "herbal", "croissant", "barista" in a cafe, or "itinerary", "sightseeing" in travel, etc.) that you ACTUALLY used in your response above.\n'
      '   - NEVER pick extremely simple or basic words like "selection", "have", "want", "like", "sugar", "tea", "water", "coffee", "good".\n'
      '   - Keep the meaning and the example sentence extremely simple, clear, professional, and short.\n'
      '   - Append this tag on a new line at the very end of your reply:\n'
      '     "📖 Word Explorer: [Word] | Meaning: [Short, simple definition] | Example: [Short, easy example sentence using the word]"';

    try {
      return await _call(systemPrompt: systemPrompt, messages: conversationHistory, maxTokens: 200);
    } catch (_) {
      return 'Great start. Try answering with one complete sentence, then add one detail to make it sound more natural.';
    }
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
      systemPrompt: 'You are an English grammar teacher. Generate exactly 10 MCQ questions about: $topic. CRITICAL RULE: The "answer" field MUST contain the EXACT string from one of the elements inside the "options" array. Do not use option letters (like A, B, C, D) or index numbers for "answer"—it must be the EXACT full option text match. Return ONLY valid JSON array, no markdown:\n[{"question":"","options":["","","",""],"answer":"","explanation":""}]',
      messages: [{'role': 'user', 'content': 'Generate grammar quiz about $topic.'}],
      maxTokens: 1200,
      timeoutSeconds: 35,
    );
    try {
      final clean = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> rawList = jsonDecode(clean);
      final List<Map<String, dynamic>> parsedList = [];
      
      for (var q in rawList) {
        if (q is Map) {
          final Map<String, dynamic> question = Map<String, dynamic>.from(q);
          final List<dynamic> options = question['options'] ?? [];
          String ans = (question['answer'] ?? '').toString().trim();
          
          // Check if answer exactly matches one of the options (case-insensitive)
          int matchIndex = -1;
          for (int i = 0; i < options.length; i++) {
            final String opt = options[i].toString().trim();
            if (opt.toLowerCase() == ans.toLowerCase()) {
              matchIndex = i;
              break;
            }
          }
          
          // Match option letters (A, B, C, D) or index numbers (0, 1, 2, 3)
          if (matchIndex == -1 && options.isNotEmpty) {
            final int? parsedIndex = int.tryParse(ans);
            if (parsedIndex != null && parsedIndex >= 0 && parsedIndex < options.length) {
              matchIndex = parsedIndex;
            } else {
              final String cleanAns = ans.toUpperCase();
              if (cleanAns == 'A') matchIndex = 0;
              else if (cleanAns == 'B') matchIndex = 1;
              else if (cleanAns == 'C') matchIndex = 2;
              else if (cleanAns == 'D') matchIndex = 3;
            }
          }
          
          if (matchIndex != -1) {
            question['answer'] = options[matchIndex].toString();
          } else if (options.isNotEmpty) {
            question['answer'] = options[0].toString();
          }
          
          parsedList.add(question);
        }
      }
      return parsedList;
    } catch (_) {
      return [
        {'question': 'She is ___ honest girl.', 'options': ['a', 'an', 'the', 'no article'], 'answer': 'an', 'explanation': 'Use "an" before vowel sounds like in "honest" (silent h).'},
        {'question': 'I ___ to school every day.', 'options': ['go', 'goes', 'going', 'gone'], 'answer': 'go', 'explanation': 'The first-person singular pronoun "I" takes the base form of the verb.'},
        {'question': 'Neither of the two books ___ interesting.', 'options': ['is', 'are', 'were', 'have'], 'answer': 'is', 'explanation': '"Neither" is singular, so it takes a singular verb.'},
        {'question': 'If it rains, we ___ the match.', 'options': ['will cancel', 'cancelled', 'would cancel', 'canceling'], 'answer': 'will cancel', 'explanation': 'First conditional uses present simple in the "if" clause and "will" in the main clause.'},
        {'question': 'Choose the correct sentence:', 'options': ['She is more taller than me.', 'She is taller than I am.', 'She is more tall than me.', 'She is tallest than me.'], 'answer': 'She is taller than I am.', 'explanation': '"Taller" is already a comparative adjective; "more taller" is double comparison and incorrect.'},
        {'question': 'He has been living here ___ five years.', 'options': ['since', 'for', 'from', 'during'], 'answer': 'for', 'explanation': 'Use "for" to indicate a period or duration of time.'},
        {'question': 'They ___ finished their project yesterday.', 'options': ['have', 'had', 'did', 'no auxiliary needed'], 'answer': 'no auxiliary needed', 'explanation': '"Yesterday" indicates a specific completed time in the past, so simple past "finished" is used without an auxiliary verb.'},
        {'question': 'Which word is a conjunction?', 'options': ['beautifully', 'but', 'under', 'happiness'], 'answer': 'but', 'explanation': '"But" is a coordinating conjunction used to connect contrasting clauses.'},
        {'question': 'She is very good ___ speaking English.', 'options': ['in', 'at', 'on', 'with'], 'answer': 'at', 'explanation': 'The standard preposition following "good" when referring to a skill or activity is "at".'},
        {'question': 'The police ___ investigating the case.', 'options': ['is', 'are', 'was', 'has'], 'answer': 'are', 'explanation': '"Police" is a collective noun that always takes a plural verb.'},
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

  // 8. BATCH VOCABULARY GENERATION
  static Future<List<Map<String, String>>> generateVocabularyBatch() async {
    final response = await _call(
      systemPrompt: 'You are an English vocabulary teacher. Generate exactly 10 interesting intermediate/advanced English vocabulary words. Each word must have a phonetic transcription, simple meaning, a real-life example sentence, and a usage tip. Return ONLY valid JSON list array, no markdown or preamble:\n[{"word":"","phonetic":"","meaning":"","example":"","usage_tip":""}]',
      messages: [const {'role': 'user', 'content': 'Generate a batch of 10 useful vocabulary words.'}],
      maxTokens: 1200,
      timeoutSeconds: 35,
    );
    try {
      final clean = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final decoded = jsonDecode(clean) as List<dynamic>;
      return decoded.map((item) => Map<String, String>.from(item as Map)).toList();
    } catch (_) {
      return [
        {
          'word': 'Resilience', 'phonetic': '/rɪˈzɪlɪəns/',
          'meaning': 'The capacity to recover quickly from difficulties; toughness.',
          'example': 'Her resilience helped her overcome the business failure and start a new company.',
          'usage_tip': 'Use when describing someone who bounces back from hardships.',
        },
        {
          'word': 'Ambiguous', 'phonetic': '/æmˈbɪɡjuəs/',
          'meaning': 'Open to more than one interpretation; having a double meaning.',
          'example': 'The instructions she gave were ambiguous, leaving everyone confused.',
          'usage_tip': 'Use when something is unclear or can be understood in multiple ways.',
        },
        {
          'word': 'Meticulous', 'phonetic': '/mɪˈtɪkjələs/',
          'meaning': 'Showing great attention to detail; very careful and precise.',
          'example': 'The researcher kept meticulous records of the experiments.',
          'usage_tip': 'Use when praising someone\'s precision or extreme neatness.',
        },
        {
          'word': 'Pragmatic', 'phonetic': '/præɡˈmætɪk/',
          'meaning': 'Dealing with things sensibly and realistically in a practical way.',
          'example': 'We need a pragmatic solution to this problem rather than an idealistic one.',
          'usage_tip': 'Use when choosing a functional approach over theoretical ideas.',
        },
        {
          'word': 'Eloquence', 'phonetic': '/ˈeləkwəns/',
          'meaning': 'Fluent or persuasive speaking or writing.',
          'example': 'The political leader spoke with great eloquence, inspiring the entire audience.',
          'usage_tip': 'Use when describing beautifully articulated and convincing speech.',
        },
        {
          'word': 'Frugal', 'phonetic': '/ˈfruːɡəl/',
          'meaning': 'Sparing or economical with regard to money or food; simple and plain.',
          'example': 'By living a frugal life, they managed to pay off all their debts in two years.',
          'usage_tip': 'Use to describe careful spending without wasting resources.',
        },
        {
          'word': 'Empathy', 'phonetic': '/ˈempəθi/',
          'meaning': 'The ability to understand and share the feelings of another.',
          'example': 'Showing empathy towards coworkers helps build a positive and collaborative environment.',
          'usage_tip': 'Use when referring to emotional connection and understanding.',
        },
        {
          'word': 'Inevitably', 'phonetic': '/ɪˈnevɪtəbli/',
          'meaning': 'As is certain to happen; unavoidably.',
          'example': 'If you do not practice daily, you will inevitably lose some of your fluency.',
          'usage_tip': 'Use when describing an outcome that cannot be avoided.',
        },
        {
          'word': 'Superfluous', 'phonetic': '/suːˈpɜːrfluəs/',
          'meaning': 'Unnecessary, especially through being more than enough.',
          'example': 'Please delete any superfluous details from the report to keep it brief.',
          'usage_tip': 'Use when describing extra or unneeded things.',
        },
        {
          'word': 'Vindicated', 'phonetic': '/ˈvɪndɪkeɪtɪd/',
          'meaning': 'Clear of blame or suspicion; proven to be right or justified.',
          'example': 'The new evidence completely vindicated him of the original charges.',
          'usage_tip': 'Use when someone is proven correct after being doubted.',
        },
      ];
    }
  }
}
