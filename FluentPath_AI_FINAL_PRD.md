# FluentPath AI — COMPLETE DETAILED PRD
**Version:** 2.0 FINAL | **For:** Windsurf / Cursor AI Coding  
**Platform:** Flutter (Android)  
**Database:** SQLite (sqflite)  
**AI:** Groq API (llama3-8b-8192) — Free  
**State Management:** Provider  
**Total Screens:** 16 (15 + Splash)

---

## STUDENT SCREEN DIVISION

| Student | Screens |
|---------|---------|
| **Shahzaib (Student 1)** | Splash, Onboarding, Dashboard, Daily Goals, Profile |
| **Student 2** | Practice Topics, AI Chat, Vocabulary Screen, Saved Words, Vocabulary Quiz |
| **Student 3** | Grammar Quiz, Quiz Result, Notes List, Add/Edit Note, Progress, Achievements |

---

## DESIGN SYSTEM — EXACT COLORS FROM UI SCREENS

```dart
// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const bgDarkGreen   = Color(0xFF0D1F0F);
  static const bgDarkBrown   = Color(0xFF1C0F07);
  static const bgMedBrown    = Color(0xFF2C1A0E);
  static const bgLightBeige  = Color(0xFFF0E8D5);
  static const bgCream       = Color(0xFFE8DCC0);
  static const bgTan         = Color(0xFFD4C4A8);
  static const primaryGreen  = Color(0xFF1B5E20);
  static const accentGreen   = Color(0xFF4CAF50);
  static const brightGreen   = Color(0xFF66BB6A);
  static const ctaRed        = Color(0xFFC0392B);
  static const ctaBrown      = Color(0xFF6D4C28);
  static const streakOrange  = Color(0xFFE67E22);
  static const streakAmber   = Color(0xFFF39C12);
  static const xpPurple      = Color(0xFF7B1FA2);
  static const textWhite     = Color(0xFFF5F0E8);
  static const textBeige     = Color(0xFFD4C4A8);
  static const textDark      = Color(0xFF1A0F07);
  static const textMuted     = Color(0xFF8D6E63);
  static const correct       = Color(0xFF2E7D32);
  static const wrong         = Color(0xFFC62828);
  static const masteredBadge = Color(0xFF1B5E20);
  static const learningBadge = Color(0xFF1565C0);
}
```

```dart
// lib/core/constants/app_text_styles.dart
class AppTextStyles {
  static const heading1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold,   color: AppColors.textWhite);
  static const heading2 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold,   color: AppColors.textWhite);
  static const heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600,   color: AppColors.textWhite);
  static const body     = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textBeige);
  static const bodyDark = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textDark);
  static const caption  = TextStyle(fontSize: 12, fontWeight: FontWeight.w400,   color: AppColors.textMuted);
  static const button   = TextStyle(fontSize: 16, fontWeight: FontWeight.w600,   color: AppColors.textWhite);
  static const wordTitle= TextStyle(fontSize: 32, fontWeight: FontWeight.bold,   color: AppColors.textDark);
}
```

---

## PUBSPEC.YAML

```yaml
name: fluentpath_ai
description: AI-powered English learning app

dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.9.0
  provider: ^6.1.2
  http: ^1.2.1
  shared_preferences: ^2.2.3
  fl_chart: ^0.68.0
  google_fonts: ^6.2.1
  lottie: ^3.1.0
  animate_do: ^3.3.2
  flutter_staggered_grid_view: ^0.7.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/lottie/
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
        - asset: assets/fonts/Poppins-SemiBold.ttf
```

---

## FOLDER STRUCTURE

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── api_keys.dart          ← ADD TO .gitignore
│   └── utils/
│       └── date_helper.dart
├── data/
│   ├── database/
│   │   └── database_helper.dart
│   └── models/
│       ├── user_model.dart
│       ├── session_model.dart
│       ├── vocabulary_model.dart
│       ├── quiz_score_model.dart
│       ├── note_model.dart
│       └── streak_model.dart
├── providers/
│   ├── user_provider.dart
│   ├── chat_provider.dart
│   ├── vocabulary_provider.dart
│   ├── quiz_provider.dart
│   ├── notes_provider.dart
│   └── streak_provider.dart
├── services/
│   └── groq_service.dart
└── screens/
    ├── splash/splash_screen.dart
    ├── onboarding/onboarding_screen.dart
    ├── main_screen.dart
    ├── dashboard/dashboard_screen.dart
    ├── daily_goals/daily_goals_screen.dart
    ├── practice/
    │   ├── practice_topics_screen.dart
    │   └── ai_chat_screen.dart
    ├── vocabulary/
    │   ├── vocabulary_screen.dart
    │   ├── saved_words_screen.dart
    │   └── vocabulary_quiz_screen.dart
    ├── quiz/
    │   ├── grammar_quiz_screen.dart
    │   └── quiz_result_screen.dart
    ├── notes/
    │   ├── notes_list_screen.dart
    │   └── add_edit_note_screen.dart
    ├── progress/progress_screen.dart
    ├── achievements/achievements_screen.dart
    └── profile/profile_screen.dart

assets/
├── images/
│   ├── avatar_0.png  avatar_1.png  avatar_2.png  avatar_3.png  avatar_4.png
│   ├── topic_coffee.png  topic_airport.png  topic_shopping.png
│   ├── topic_doctor.png  topic_hotel.png    topic_interview.png
│   └── level_badge.png
├── lottie/
│   └── confetti.json
└── fonts/
    ├── Poppins-Regular.ttf
    ├── Poppins-Bold.ttf
    └── Poppins-SemiBold.ttf
```

> Generate avatar images using Stitch AI prompts. Download confetti.json free from lottiefiles.com (search "confetti").

---

## API KEY CONFIG

```dart
// lib/core/constants/api_keys.dart
// ⚠️ ADD TO .gitignore — NEVER PUSH TO GITHUB

class ApiKeys {
  static const groqApiKey  = String.fromEnvironment('GROQ_API_KEY');
  static const groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const groqModel   = 'llama3-8b-8192';
}
```

---

## DATABASE — 6 TABLES (database_helper.dart)

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fluentpath.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE user_profile (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      name            TEXT NOT NULL,
      avatar_index    INTEGER DEFAULT 0,
      level           TEXT DEFAULT 'Beginner',
      total_xp        INTEGER DEFAULT 0,
      daily_goal_mins INTEGER DEFAULT 15,
      selected_tutor  TEXT DEFAULT 'Friendly Buddy',
      created_at      TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE sessions (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      scenario      TEXT NOT NULL,
      tutor_persona TEXT NOT NULL,
      chat_history  TEXT NOT NULL,
      duration_mins INTEGER DEFAULT 0,
      date          TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE vocabulary (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      word       TEXT NOT NULL,
      phonetic   TEXT,
      meaning    TEXT NOT NULL,
      example    TEXT,
      usage_tip  TEXT,
      status     TEXT DEFAULT 'learning',
      date_added TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE quiz_scores (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      quiz_type       TEXT NOT NULL,
      topic           TEXT NOT NULL,
      score           INTEGER NOT NULL,
      total_questions INTEGER NOT NULL,
      xp_earned       INTEGER DEFAULT 0,
      wrong_answers   TEXT,
      date            TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE notes (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      title      TEXT NOT NULL,
      body       TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE streaks (
      id             INTEGER PRIMARY KEY AUTOINCREMENT,
      date           TEXT NOT NULL UNIQUE,
      practiced      INTEGER DEFAULT 0,
      words_learned  INTEGER DEFAULT 0,
      quiz_completed INTEGER DEFAULT 0,
      xp_earned      INTEGER DEFAULT 0
    )''');
  }

  // ── USER ──────────────────────────────────────────────
  Future<int> insertUser(Map<String, dynamic> user) async =>
    (await database).insert('user_profile', user);

  Future<Map<String, dynamic>?> getUser() async {
    final r = await (await database).query('user_profile', limit: 1);
    return r.isNotEmpty ? r.first : null;
  }

  Future<int> updateUser(Map<String, dynamic> values) async =>
    (await database).update('user_profile', values, where: 'id = ?', whereArgs: [1]);

  // ── SESSIONS ──────────────────────────────────────────
  Future<int> insertSession(Map<String, dynamic> s) async =>
    (await database).insert('sessions', s);

  Future<List<Map<String, dynamic>>> getSessions() async =>
    (await database).query('sessions', orderBy: 'date DESC');

  Future<int> getTodaySessionMins() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final r = await (await database).rawQuery(
      'SELECT COALESCE(SUM(duration_mins),0) as t FROM sessions WHERE date=?', [today]);
    return r.first['t'] as int;
  }

  // ── VOCABULARY ────────────────────────────────────────
  Future<int> insertWord(Map<String, dynamic> w) async =>
    (await database).insert('vocabulary', w);

  Future<List<Map<String, dynamic>>> getWords({String? status}) async {
    final db = await database;
    if (status != null && status != 'all')
      return db.query('vocabulary', where: 'status=?', whereArgs: [status], orderBy: 'date_added DESC');
    return db.query('vocabulary', orderBy: 'date_added DESC');
  }

  Future<int> getWordCount() async {
    final r = await (await database).rawQuery('SELECT COUNT(*) as c FROM vocabulary');
    return r.first['c'] as int;
  }

  Future<int> getTodayWordCount() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final r = await (await database).rawQuery(
      'SELECT COUNT(*) as c FROM vocabulary WHERE date_added=?', [today]);
    return r.first['c'] as int;
  }

  Future<int> updateWordStatus(int id, String status) async =>
    (await database).update('vocabulary', {'status': status}, where: 'id=?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> searchWords(String q) async =>
    (await database).query('vocabulary', where: 'word LIKE ?', whereArgs: ['%$q%']);

  // ── QUIZ SCORES ───────────────────────────────────────
  Future<int> insertQuizScore(Map<String, dynamic> s) async =>
    (await database).insert('quiz_scores', s);

  Future<List<Map<String, dynamic>>> getLastQuizScores(int limit) async =>
    (await database).query('quiz_scores', orderBy: 'date DESC', limit: limit);

  Future<double> getAverageQuizScore() async {
    final r = await (await database).rawQuery(
      'SELECT AVG(CAST(score AS FLOAT)/total_questions*100) as avg FROM quiz_scores');
    return (r.first['avg'] as double?) ?? 0.0;
  }

  Future<bool> quizDoneToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final r = await (await database).rawQuery(
      'SELECT COUNT(*) as c FROM quiz_scores WHERE date=?', [today]);
    return (r.first['c'] as int) > 0;
  }

  // ── NOTES ─────────────────────────────────────────────
  Future<int> insertNote(Map<String, dynamic> n) async =>
    (await database).insert('notes', n);

  Future<List<Map<String, dynamic>>> getNotes() async =>
    (await database).query('notes', orderBy: 'updated_at DESC');

  Future<int> updateNote(int id, Map<String, dynamic> v) async =>
    (await database).update('notes', v, where: 'id=?', whereArgs: [id]);

  Future<int> deleteNote(int id) async =>
    (await database).delete('notes', where: 'id=?', whereArgs: [id]);

  // ── STREAKS ───────────────────────────────────────────
  Future<void> upsertTodayStreak(Map<String, dynamic> data) async =>
    (await database).insert('streaks', data, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<Map<String, dynamic>?> getTodayStreak() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final r = await (await database).query('streaks', where: 'date=?', whereArgs: [today]);
    return r.isNotEmpty ? r.first : null;
  }

  Future<List<Map<String, dynamic>>> getLast7DaysStreaks() async {
    final ago = DateTime.now().subtract(Duration(days: 6)).toIso8601String().split('T')[0];
    return (await database).query('streaks', where: 'date>=?', whereArgs: [ago], orderBy: 'date ASC');
  }

  Future<int> getCurrentStreak() async {
    final db = await database;
    final days = await db.query('streaks', where: 'xp_earned>0', orderBy: 'date DESC');
    if (days.isEmpty) return 0;
    int streak = 0;
    DateTime expected = DateTime.now();
    for (var day in days) {
      final d = DateTime.parse(day['date'] as String);
      if (expected.difference(d).inDays <= 1) { streak++; expected = d; }
      else break;
    }
    return streak;
  }
}
```

---

## GROQ SERVICE (groq_service.dart)

```dart
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
    ).timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['choices'][0]['message']['content'] as String;
    }
    throw Exception('Groq error: ${response.statusCode}');
  }

  // 1. DAILY TIP
  static Future<String> getDailyTip() => _call(
    systemPrompt: 'You are an English coach. Give ONE practical English tip in exactly 2 short sentences. Be specific. No preamble.',
    messages: [{'role': 'user', 'content': 'Give me today English tip.'}],
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
    String system;
    switch (persona) {
      case 'Professional Mentor':
        system = 'You are Alex, a professional English mentor. Scenario: $scenario. Be formal, concise, 2-3 sentences. Correct grammar: "Grammar note: [wrong] → [right]".';
        break;
      case 'The Challenger':
        system = 'You are Max, an advanced English coach. Scenario: $scenario. 2-3 sentences. Correct errors directly: "~~[wrong]~~ → [right]". Use complex vocabulary.';
        break;
      default:
        system = 'You are Buddy, a warm friendly English tutor. Scenario: $scenario. Reply in 2-3 short friendly sentences. Gently correct grammar mistakes by showing: "~~[wrong]~~ → [right]" then continue.';
    }
    return _call(systemPrompt: system, messages: conversationHistory, maxTokens: 200);
  }

  // 4. VOCABULARY WORD GENERATION
  static Future<Map<String, String>> generateVocabularyWord() async {
    final response = await _call(
      systemPrompt: 'You are an English vocabulary teacher. Generate ONE useful intermediate English word. Return ONLY valid JSON, no markdown:\n{"word":"","phonetic":"","meaning":"","example":"","usage_tip":""}',
      messages: [{'role': 'user', 'content': 'Generate a vocabulary word.'}],
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
}
```
---

## PROVIDERS

### user_provider.dart
```dart
import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;
  String get name          => _user?['name'] ?? 'User';
  int    get totalXP       => _user?['total_xp'] ?? 0;
  int    get avatarIndex   => _user?['avatar_index'] ?? 0;
  int    get dailyGoalMins => _user?['daily_goal_mins'] ?? 15;
  String get selectedTutor => _user?['selected_tutor'] ?? 'Friendly Buddy';
  String get level {
    final x = totalXP;
    if (x < 500)  return 'Beginner';
    if (x < 1500) return 'Intermediate';
    return 'Advanced';
  }
  int get xpToNextLevel => totalXP < 500 ? 500 : totalXP < 1500 ? 1500 : 9999;
  String get nextLevel  => totalXP < 500 ? 'Intermediate' : 'Advanced';
  bool get isLoaded     => _user != null;

  Future<void> loadUser() async {
    _user = await DatabaseHelper.instance.getUser();
    notifyListeners();
  }
  Future<void> addXP(int amount) async {
    await DatabaseHelper.instance.updateUser({'total_xp': totalXP + amount});
    await loadUser();
  }
  Future<void> updateProfile(Map<String, dynamic> values) async {
    await DatabaseHelper.instance.updateUser(values);
    await loadUser();
  }
  Future<bool> hasUser() async =>
    (await DatabaseHelper.instance.getUser()) != null;
}
```

### chat_provider.dart
```dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/groq_service.dart';
import '../data/database/database_helper.dart';

class ChatProvider extends ChangeNotifier {
  List<Map<String, String>> messages = [];
  bool isLoading = false;
  String currentScenario = '';
  String currentPersona  = '';
  int sessionSeconds = 0;
  Timer? _timer;

  void initSession(String scenario, String persona) {
    messages = []; currentScenario = scenario;
    currentPersona = persona; sessionSeconds = 0;
    _startTimer(); _sendInitialGreeting(); notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (_) { sessionSeconds++; notifyListeners(); });
  }

  Future<void> _sendInitialGreeting() async {
    isLoading = true; notifyListeners();
    try {
      final g = await GroqService.chatWithTutor(
        scenario: currentScenario, persona: currentPersona,
        conversationHistory: [{'role':'user','content':'Start our $currentScenario practice with a friendly greeting.'}]);
      messages.add({'role':'assistant','content':g});
    } catch (_) {
      messages.add({'role':'assistant','content':"Hello! Let's practice $currentScenario together. I'm ready when you are!"});
    }
    isLoading = false; notifyListeners();
  }

  Future<void> sendMessage(String userMessage) async {
    messages.add({'role':'user','content':userMessage});
    isLoading = true; notifyListeners();
    try {
      final r = await GroqService.chatWithTutor(
        scenario: currentScenario, persona: currentPersona, conversationHistory: messages);
      messages.add({'role':'assistant','content':r});
    } catch (_) {
      messages.add({'role':'assistant','content':'Sorry, connection issue. Please try again.'});
    }
    isLoading = false; notifyListeners();
  }

  Future<int> endSession() async {
    _timer?.cancel();
    final mins = (sessionSeconds / 60).ceil();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await DatabaseHelper.instance.insertSession({
      'scenario': currentScenario, 'tutor_persona': currentPersona,
      'chat_history': messages.toString(), 'duration_mins': mins, 'date': today,
    });
    return mins;
  }

  String get formattedTime {
    final m = sessionSeconds ~/ 60, s = sessionSeconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override void dispose() { _timer?.cancel(); super.dispose(); }
}
```

### vocabulary_provider.dart
```dart
import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';
import '../services/groq_service.dart';

class VocabularyProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _words = [];
  Map<String, String>? currentWord;
  bool isGenerating = false;
  String filterStatus = 'all';

  List<Map<String, dynamic>> get words =>
    filterStatus == 'all' ? _words : _words.where((w) => w['status'] == filterStatus).toList();
  int get totalWords    => _words.length;
  int get masteredCount => _words.where((w) => w['status'] == 'mastered').length;

  Future<void> loadWords() async {
    _words = await DatabaseHelper.instance.getWords();
    notifyListeners();
  }

  Future<void> generateNewWord() async {
    isGenerating = true; notifyListeners();
    try { currentWord = await GroqService.generateVocabularyWord(); }
    catch (_) { currentWord = {'word':'Resilience','phonetic':'/rɪˈzɪlɪəns/','meaning':'Ability to recover from difficulties.','example':'Her resilience helped her overcome challenges.','usage_tip':'Use when describing strength after hardship.'}; }
    isGenerating = false; notifyListeners();
  }

  Future<bool> saveCurrentWord() async {
    if (currentWord == null) return false;
    final today = DateTime.now().toIso8601String().split('T')[0];
    await DatabaseHelper.instance.insertWord({
      'word': currentWord!['word']!, 'phonetic': currentWord!['phonetic'] ?? '',
      'meaning': currentWord!['meaning']!, 'example': currentWord!['example'] ?? '',
      'usage_tip': currentWord!['usage_tip'] ?? '', 'status': 'learning', 'date_added': today,
    });
    await loadWords(); return true;
  }

  Future<void> markMastered(int id) async {
    await DatabaseHelper.instance.updateWordStatus(id, 'mastered');
    await loadWords();
  }

  void setFilter(String status) { filterStatus = status; notifyListeners(); }
}
```

### quiz_provider.dart
```dart
import 'package:flutter/material.dart';
import '../services/groq_service.dart';
import '../data/database/database_helper.dart';

class QuizProvider extends ChangeNotifier {
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0, score = 0;
  String? selectedAnswer;
  bool showExplanation = false, isLoading = false;
  String currentTopic = '';
  List<Map<String, dynamic>> wrongAnswers = [];

  Future<void> generateGrammarQuiz(String topic) async {
    isLoading = true; currentTopic = topic; currentIndex = 0;
    score = 0; wrongAnswers = []; selectedAnswer = null;
    showExplanation = false; notifyListeners();
    try { questions = await GroqService.generateGrammarQuiz(topic); }
    catch (_) { questions = []; }
    isLoading = false; notifyListeners();
  }

  void selectAnswer(String answer) {
    if (selectedAnswer != null) return;
    selectedAnswer = answer; showExplanation = true;
    if (answer == questions[currentIndex]['answer']) { score++; }
    else { wrongAnswers.add({'question': questions[currentIndex]['question'], 'yourAnswer': answer, 'correctAnswer': questions[currentIndex]['answer'], 'explanation': questions[currentIndex]['explanation']}); }
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++; selectedAnswer = null; showExplanation = false; notifyListeners();
    }
  }

  bool get isLastQuestion => currentIndex >= questions.length - 1;
  int get totalQuestions  => questions.length;
  double get percentage   => totalQuestions > 0 ? score / totalQuestions : 0;
  int get xpEarned        => (score * 20) + (percentage == 1.0 ? 50 : 0);

  Future<void> saveScore(String quizType) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await DatabaseHelper.instance.insertQuizScore({
      'quiz_type': quizType, 'topic': currentTopic, 'score': score,
      'total_questions': totalQuestions, 'xp_earned': xpEarned,
      'wrong_answers': wrongAnswers.toString(), 'date': today,
    });
  }
}
```

### notes_provider.dart
```dart
import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';

class NotesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notes = [];
  String _searchQuery = '';

  List<Map<String, dynamic>> get notes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes.where((n) =>
      (n['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (n['body'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Future<void> loadNotes() async { _notes = await DatabaseHelper.instance.getNotes(); notifyListeners(); }
  void setSearch(String q) { _searchQuery = q; notifyListeners(); }

  Future<int> addNote(String title, String body) async {
    final now = DateTime.now().toIso8601String();
    final id = await DatabaseHelper.instance.insertNote({'title':title,'body':body,'created_at':now,'updated_at':now});
    await loadNotes(); return id;
  }

  Future<void> updateNote(int id, String title, String body) async {
    await DatabaseHelper.instance.updateNote(id, {'title':title,'body':body,'updated_at':DateTime.now().toIso8601String()});
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id); await loadNotes();
  }
}
```

### streak_provider.dart
```dart
import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';

class StreakProvider extends ChangeNotifier {
  Map<String, dynamic>? _todayStreak;
  int _currentStreak = 0;
  List<Map<String, dynamic>> _last7Days = [];

  int  get currentStreak    => _currentStreak;
  List get last7Days         => _last7Days;
  bool get practicedToday    => (_todayStreak?['practiced'] ?? 0) == 1;
  int  get todayWordsLearned => _todayStreak?['words_learned'] ?? 0;
  bool get quizCompletedToday=> (_todayStreak?['quiz_completed'] ?? 0) == 1;
  int  get todayXP           => _todayStreak?['xp_earned'] ?? 0;

  Future<void> loadStreak() async {
    _todayStreak = await DatabaseHelper.instance.getTodayStreak();
    _currentStreak = await DatabaseHelper.instance.getCurrentStreak();
    _last7Days = await DatabaseHelper.instance.getLast7DaysStreaks();
    notifyListeners();
  }

  Future<void> updateTodayStreak({bool? practiced, int? wordsLearned, bool? quizCompleted, int? xpAdd}) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final cur = _todayStreak ?? {'date':today,'practiced':0,'words_learned':0,'quiz_completed':0,'xp_earned':0};
    await DatabaseHelper.instance.upsertTodayStreak({
      'date': today,
      'practiced': practiced == true ? 1 : (cur['practiced'] ?? 0),
      'words_learned': wordsLearned ?? (cur['words_learned'] ?? 0),
      'quiz_completed': quizCompleted == true ? 1 : (cur['quiz_completed'] ?? 0),
      'xp_earned': (cur['xp_earned'] ?? 0) + (xpAdd ?? 0),
    });
    await loadStreak();
  }
}
```

---

## MAIN.DART

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/user_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/streak_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
      ChangeNotifierProvider(create: (_) => VocabularyProvider()),
      ChangeNotifierProvider(create: (_) => QuizProvider()),
      ChangeNotifierProvider(create: (_) => NotesProvider()),
      ChangeNotifierProvider(create: (_) => StreakProvider()),
    ],
    child: const FluentPathApp(),
  ));
}

class FluentPathApp extends StatelessWidget {
  const FluentPathApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluentPath AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: AppColors.bgDarkGreen,
      ),
      home: const SplashScreen(),
    );
  }
}
```

---

## BOTTOM NAVIGATION — main_screen.dart

```dart
import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'notes/notes_list_screen.dart';
import 'progress/progress_screen.dart';
import 'profile/profile_screen.dart';
import '../core/constants/app_colors.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});
  @override State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _index;
  final _screens = const [DashboardScreen(), NotesListScreen(), ProgressScreen(), ProfileScreen()];

  @override void initState() { super.initState(); _index = widget.initialIndex; }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _screens[_index],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _index,
      onTap: (i) => setState(() => _index = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.primaryGreen,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      selectedFontSize: 12, unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded),        label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.note_alt_outlined),   label: 'Notes'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded),   label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
      ],
    ),
  );
}
```

---

# SCREEN SPECIFICATIONS

---

## SCREEN 1 — SPLASH SCREEN
**File:** `screens/splash/splash_screen.dart` | **Student: Shahzaib**

**UI:**
- Background: `AppColors.bgDarkGreen` full screen
- Center column: white rounded square container (100x100, BR 24px) with mic icon (60px dark green) — OR `Image.asset('assets/images/app_logo.png')` 
- App name RichText: "FluentPath " white bold 32sp + "AI" `AppColors.ctaRed` bold 32sp
- Tagline: "Speak Better. Learn Smarter." white italic opacity 0.8, 14sp
- Audio wave: Row of 12 animated bars, each 4px wide, green, heights animating 8px–48px using AnimationController stagger
- Bottom: "v1.0" white opacity 0.3, 12sp

**Logic:**
```dart
// initState:
Future.delayed(Duration(milliseconds: 2500), () async {
  final prefs = await SharedPreferences.getInstance();
  final isOnboarded = prefs.getBool('isOnboarded') ?? false;
  Navigator.pushReplacement(context, MaterialPageRoute(
    builder: (_) => isOnboarded ? MainScreen() : OnboardingScreen()
  ));
});
```

---

## SCREEN 2 — ONBOARDING SCREEN
**File:** `screens/onboarding/onboarding_screen.dart` | **Student: Shahzaib**

**UI:**
- Background: `AppColors.bgDarkGreen`
- `PageView` with 3 pages, `PageController`
- Top right: "3/3" chip on last page (dark green rounded)
- Dot indicator row (3 dots, active = white, inactive = white opacity 0.3)
- Pages 1 & 2: large illustration icon (120px), bold heading white 24sp, subtitle white opacity 0.6 14sp, "Next →" right-aligned button
- Page 3 (extra content):
  - Illustration at top
  - Heading + subtitle
  - "Enter your name" label white bold 14sp
  - TextField: filled white12, rounded 16px, person icon prefix, white text
  - "Pick your avatar" label
  - Row of 5 `CircleAvatar` (radius 30), `Image.asset('assets/images/avatar_X.png')`, selected has `accentGreen` border ring 3px
  - "Get Started →" button: dark brown (`Color(0xFF6D4C28)`), full width, height 56, rounded 16px, white bold text

**Logic:**
```dart
// Get Started onPressed:
if (nameController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter your name')));
  return;
}
final db = DatabaseHelper.instance;
await db.insertUser({
  'name': nameController.text.trim(),
  'avatar_index': selectedAvatar,
  'level': 'Beginner',
  'total_xp': 0,
  'daily_goal_mins': 15,
  'selected_tutor': 'Friendly Buddy',
  'created_at': DateTime.now().toIso8601String(),
});
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('isOnboarded', true);
await context.read<UserProvider>().loadUser();
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
```

---

## SCREEN 3 — DASHBOARD
**File:** `screens/dashboard/dashboard_screen.dart` | **Student: Shahzaib**

**UI (top to bottom, scrollable):**
- No AppBar — custom top bar with greeting + notification bell icon
- **Greeting:** `"Good morning/afternoon/evening, $name!"` white bold 22sp (detect by hour)
- **Progress Card** (`Color(0xFF1A3A1A)`, rounded 20px, border white12):
  - Row: "🔥 $streak Day Streak" chip (dark brown bg) + "LEVEL $level" chip (green border)
  - `CircularProgressIndicator` 100x100, value = todayMins/dailyGoalMins, green stroke, dark bg track
  - Center text: `"$percent%"` white bold 22sp + "Today's Progress" white 11sp
  - Below ring: `"$todayMins/$dailyGoalMins minutes practiced"` accentGreen 14sp
- **Module Grid** 2×2: Practice, Vocabulary, Quiz, Goals — each dark brown card (icon in green circle, title white bold, subtitle white opacity 0.5, chevron right)
- **AI Tip Banner** (dark green card, accentGreen border): AI robot icon + "Master English with AI" text + daily tip (shimmer while loading) + "Start Now" ctaRed button

**Logic:**
```dart
// initState:
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await context.read<UserProvider>().loadUser();
    await context.read<StreakProvider>().loadStreak();
    _todayMins = await DatabaseHelper.instance.getTodaySessionMins();
    setState(() {});
    _loadDailyTip();
  });
}

Future<void> _loadDailyTip() async {
  setState(() => _tipLoading = true);
  try { _dailyTip = await GroqService.getDailyTip(); }
  catch (_) { _dailyTip = 'Practice 10 minutes of English conversation daily for best results.'; }
  setState(() => _tipLoading = false);
}
```

---

## SCREEN 4 — DAILY GOALS
**File:** `screens/daily_goals/daily_goals_screen.dart` | **Student: Shahzaib**

**UI:**
- AppBar dark green: "Daily Goals", back arrow, 3-dot icon
- **Streak Banner** (orange-amber gradient, rounded 20px): flame image (or 🔥 64sp) + "14 Day Streak!" white bold 28sp + subtitle
- **7-Day Calendar Row** (dark green card): 7 circles for Mon–Sun. Completed = filled accentGreen + checkmark. Today = accentGreen border ring. Missed = white12 fill. Day number below each.
- **3 Goal Cards** (light cream `bgLightBeige`):
  - Icon in white circle, title dark bold 15sp
  - `LinearProgressIndicator` (accentGreen / ctaRed), "current/target" label below
  - XP badge (green pill, right side)
  - Checkbox (accentGreen when completed)
- **XP Summary Card** (dark green): purple XP circle + "Today's XP:" + number bold 24sp + bolt icon
- Lottie confetti when all 3 goals done (check `SharedPreferences 'confetti_date'` to avoid replay)

**SQLite reads:**
```dart
// In initState:
_todayMins   = await DatabaseHelper.instance.getTodaySessionMins();
_todayWords  = await DatabaseHelper.instance.getTodayWordCount();
_quizDone    = await DatabaseHelper.instance.quizDoneToday();
_streak      = await DatabaseHelper.instance.getCurrentStreak();
_last7Days   = await DatabaseHelper.instance.getLast7DaysStreaks();
_todayStreak = await DatabaseHelper.instance.getTodayStreak();
```

---

## SCREEN 5 — PRACTICE TOPICS
**File:** `screens/practice/practice_topics_screen.dart` | **Student 2**

**UI:**
- Background: `bgDarkGreen`
- Custom top: back button (white rounded square) + "Choose a Topic" white bold 26sp center + subtitle
- 2-column `GridView` of 6 scenario cards (dark brown `bgMedBrown`, rounded 16px):
  - Top image area: `Image.asset('assets/images/topic_X.png')` in dark brown container
  - Difficulty chip: Beginner (accentGreen), Intermediate (amber), Advanced (ctaRed) — with icon
  - Title white bold 15sp, description white opacity 0.55 11sp 2 lines

**Hardcoded topic data:**
```dart
final topics = [
  {'title':'Coffee Shop','difficulty':'Beginner','image':'topic_coffee','desc':'Practice ordering drinks, snacks and chatting.'},
  {'title':'Airport','difficulty':'Beginner','image':'topic_airport','desc':'Learn conversations for your travels.'},
  {'title':'Shopping','difficulty':'Beginner','image':'topic_shopping','desc':'Practice buying things and asking for help.'},
  {'title':'Doctor Visit','difficulty':'Intermediate','image':'topic_doctor','desc':'Talk to doctor and describe your health.'},
  {'title':'Hotel Check-In','difficulty':'Intermediate','image':'topic_hotel','desc':'Practice booking rooms and hotel services.'},
  {'title':'Job Interview','difficulty':'Advanced','image':'topic_interview','desc':'Prepare for interviews and answer confidently.'},
];
```

**Navigation:** `onTap` → `AIChatScreen(scenario: title, persona: userProvider.selectedTutor)`

---

## SCREEN 6 — AI CHAT SCREEN
**File:** `screens/practice/ai_chat_screen.dart` | **Student 2**

**UI:**
- Background: `bgDarkBrown`
- AppBar dark green: back button, avatar + tutor name center, "End Session" ctaRed right
- Timer chip below AppBar: clock icon + `"03:24"` white (counts up)
- **Chat ListView** (messages):
  - User: right-aligned, `primaryGreen` bubble, white text, timestamp + double-tick
  - AI: left-aligned, `bgMedBrown` bubble, warm white text, small robot avatar left
  - AI grammar correction: strikethrough red "~~wrong~~" + green "✅ correct"
  - Typing indicator: 3 animated bouncing dots when `isLoading`
- **Bottom input bar**: mic icon (decorative), rounded text field (`bgMedBrown`), send button (accentGreen circle)

**Logic:**
```dart
// On send:
void _sendMessage() async {
  final msg = _controller.text.trim();
  if (msg.isEmpty) return;
  _controller.clear();
  await context.read<ChatProvider>().sendMessage(msg);
  _scrollToBottom();
}

// End session:
void _endSession() async {
  showDialog(/* confirm dialog */);
  // On confirm:
  final mins = await chatProvider.endSession();
  await streakProvider.updateTodayStreak(practiced: true, xpAdd: 20);
  await userProvider.addXP(20);
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Session saved! +20 XP 🎯')));
}

// Auto-scroll:
void _scrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  });
}
```

---

## SCREEN 7 — VOCABULARY SCREEN
**File:** `screens/vocabulary/vocabulary_screen.dart` | **Student 2**

**UI:**
- Background: `bgDarkGreen`
- AppBar: back button, "Word 3 of ∞" warm white 14sp center, speaker icon right (decorative)
- Progress dots row (4 small rectangles, first ctaRed/brown, rest white24)
- **Large Word Card** (`bgCream` #E8DCC0, rounded 24px, elevation shadow):
  - Brown circle with book icon (top center)
  - Word: dark bold 36sp center
  - Phonetic: muted italic 14sp center
  - Green diamond divider
  - Meaning row: green circle icon (book) + "Meaning:" bold + text
  - Example row: green circle icon (chat) + "Example:" bold + italic text
  - Usage Tip row: green circle icon (bulb) + "Usage Tip:" bold + text
- "Next Word →" button: dark brown outline, warm white text, full width
- "Save Word 💾" button: ctaRed fill, white text, full width

**Logic:**
```dart
// initState: vocabProvider.generateNewWord()
// Show shimmer/loading on card while isGenerating = true

// Save Word:
final saved = await vocabProvider.saveCurrentWord();
if (saved) {
  await streakProvider.updateTodayStreak(
    wordsLearned: streakProvider.todayWordsLearned + 1, xpAdd: 10);
  await userProvider.addXP(10);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Word saved! +10 XP 📚')));
  _wordCounter++;
  vocabProvider.generateNewWord();
}
```

---

## SCREEN 8 — SAVED WORDS
**File:** `screens/vocabulary/saved_words_screen.dart` | **Student 2**

**UI:**
- AppBar dark green: "My Vocabulary" white bold, 3-dot icon
- **Search bar** (`bgMedBrown` rounded 28px): search + filter icons, white hint text
- **Filter TabBar**: All / Learning / Mastered, green underline on active, `bgLightBeige` body bg
- **Stats Row** (2 dark brown cards): "48 Words Total" with book icon + "32 Mastered" with trophy icon
- **Word list** (`bgTan` cards #D4C4A8, rounded 16px):
  - Word bold dark 18sp + status badge (green "Mastered" or blue "Learning") + bookmark icon
  - Phonetic muted italic 12sp
  - "Meaning:" bold + text; "Example:" italic
  - "Mark Mastered" outlined green button (bottom right)
- Empty state: book icon + "No words yet!" + "Start Learning" button

**SQLite:**
```dart
// initState: vocabProvider.loadWords()
// On filter tab change: vocabProvider.setFilter('mastered')
// On mark mastered: vocabProvider.markMastered(id)
// Search: filter _words list locally in provider
```

---

## SCREEN 9 — VOCABULARY QUIZ
**File:** `screens/vocabulary/vocabulary_quiz_screen.dart` | **Student 2**

**UI:**
- AppBar dark green: "Vocabulary Quiz" + "Q 3/10" chip
- Green progress bar below AppBar
- Score row: "✓ 2 | ✗ 0" (correct/wrong counts, right-aligned)
- **Question card** (`bgMedBrown`, rounded 20px, gold border):
  - Question mark icon (gold circle)
  - "What does this word mean?" gold italic 13sp
  - Diamond divider line
  - Word: white bold 32sp center
- **4 Options** (A B C D) dark brown cards → tap to answer:
  - Unselected: `bgMedBrown`
  - Correct selected: green fill + green border + checkmark
  - Wrong selected: red fill + red border
  - Correct revealed (after wrong tap): semi-transparent green
- "Next Question →" button (golden text, dark brown bg) — appears after selection

**Logic:**
```dart
// initState:
final allWords = await DatabaseHelper.instance.getWords();
if (allWords.length < 4) {
  showDialog(/* Need at least 4 saved words */);
  return;
}
// Pick 10 random words (or all if < 10)
// For each: correct = word's meaning, 3 wrongs = random other meanings
// Shuffle 4 options

// On finish: Navigator.pushReplacement → QuizResultScreen(
//   score: score, total: totalQ, wrongAnswers: [], quizType: 'vocabulary', topic: 'My Words')
```

---

## SCREEN 10 — GRAMMAR QUIZ
**File:** `screens/quiz/grammar_quiz_screen.dart` | **Student 3**

**UI:**
- Two-tone bg: top 35% dark green, bottom 65% `bgLightBeige`
- AppBar transparent on dark green: back button, "Grammar Quiz" white bold, circular timer (top right)
- Topic chip (green pill, dropdown arrow): tap → `AlertDialog` with 4 topic options
- "Q 2 of 10" golden text + green progress bar
- **Question card** (`bgLightBeige`, rounded 20px, shadow):
  - Dark circle "?" icon + "Choose the correct option:" muted 13sp
  - Question text: dark bold 20sp, line height 1.4
- **4 Options** (white rounded cards):
  - Default: white bg, no border
  - Correct selected: light green bg + green border + checkmark
  - Wrong selected: light red bg + red border
  - After answer: explanation card (very light green bg, accentGreen border, bulb icon)
- "Next Question →" ctaRed button, full width

**Topics:** Tenses | Articles | Prepositions | Sentence Structure

**Timer:**
```dart
// 20-second countdown per question
Timer.periodic(Duration(seconds: 1), (t) {
  if (_timeLeft > 0) { setState(() => _timeLeft--); }
  else { t.cancel(); _autoSkip(); } // auto-wrong on timeout
});
// Cancel and reset on each new question
```

**Loading state** (while Groq generates): centered loading animation + "✨ Generating your quiz..."

---

## SCREEN 11 — QUIZ RESULT
**File:** `screens/quiz/quiz_result_screen.dart` | **Student 3**

**UI (full screen, no AppBar, scrollable):**
- Background: `bgDarkGreen`
- Trophy image/emoji 🏆 (100px) centered top
- Result title: "Perfect Score!" / "Excellent!" / "Good Job!" / "Keep Practicing!" — white bold 28sp
- Result subtitle white opacity 0.6 13sp
- **Score circle** (`bgCream` fill, `accentGreen` `CircularProgressIndicator` border 10px wide): "$score/$total" dark bold 32sp inside
- "$percent%" white bold 22sp + "Your Score" muted below
- **XP Earned card** (`bgMedBrown`, gold border): ⚡ "+$xpEarned XP Earned!" white bold 20sp
- **Correct/Wrong row**: 2 cards — green "✅ Correct: $score" + red "❌ Wrong: $wrong"
- **`ExpansionTile`** "Review Wrong Answers": each wrong answer shows question, your answer (red), correct (green), explanation (italic)
- Bottom buttons row: "🔄 Try Again" (outlined white) + "🏠 Go Home" (ctaRed filled)

**Logic:**
```dart
// This screen receives score, total, wrongAnswers, quizType via constructor
// initState:
await quizProvider.saveScore(quizType);
await streakProvider.updateTodayStreak(quizCompleted: true, xpAdd: xpEarned);
await userProvider.addXP(xpEarned);
```

---

## SCREEN 12 — NOTES LIST
**File:** `screens/notes/notes_list_screen.dart` | **Student 3**

**UI:**
- Background: `bgDarkBrown`
- Custom top bar (no AppBar): "My Notes" white bold 26sp + search icon + add icon
- Animated search bar (toggle on search icon tap): `bgMedBrown` rounded, white hint
- **Masonry Grid** 2 columns (`MasonryGridView.count`):
  - Note card colors cycling: sage green, tan, olive, warm beige, dusty green, mocha
  - Each card: icon (top left) + 3-dot menu (top right) + title dark bold 15sp + body preview 2-3 lines dark opacity 0.7 12sp + date bottom right muted 11sp
  - Varying heights = masonry effect
- **FAB** `ctaRed` rounded "+" (bottom right, above bottom nav `Positioned(bottom: 80, right: 20)`)
- Empty state: note icon + "No notes yet!" + "Tap + to create"

**Logic:**
```dart
// initState: notesProvider.loadNotes()
// Tap card → AddEditNoteScreen(note: notes[i], isEditing: true)
// Long press → bottom sheet with Edit / Delete options
// Delete: showDialog confirm → notesProvider.deleteNote(id)
// FAB → AddEditNoteScreen(isEditing: false)
```

---

## SCREEN 13 — ADD/EDIT NOTE
**File:** `screens/notes/add_edit_note_screen.dart` | **Student 3**

**UI:**
- Background: `bgDarkBrown`
- AppBar dark green: back arrow, "New Note"/"Edit Note" white bold, "Save" `ctaRed` bold text action
- Title `TextField`: no border, `Color(0xFFD4C4A8)` text, 26sp bold, placeholder "Note title..." white24
- `Divider` white12
- Body `TextField`: no border, same text color, 15sp, height 1.6, multiline, expands = true, placeholder "Start writing your note..."
- **Formatting toolbar** (bottom, dark green pill rounded 16px):
  - B | I | U | list icon (decorative, visual only)

**Logic:**
```dart
// isEditing = true: pre-fill controllers
// Save:
if (_titleController.text.trim().isEmpty) { showSnackBar('Please add a title'); return; }
if (isEditing) { await notesProvider.updateNote(noteId!, title, body); }
else           { await notesProvider.addNote(title, body); }
Navigator.pop(context);
```

---

## SCREEN 14 — PROGRESS
**File:** `screens/progress/progress_screen.dart` | **Student 3**

**UI:**
- AppBar dark green: "My Progress" white bold
- **Level Card** (green gradient `1B5E20 → 2E7D32`, rounded 20px):
  - Left: shield badge `Image.asset` or `Icon(Icons.shield, gold, 40)` in circle (70px)
  - Right: "Your Level" gold 12sp, level chip (dark bg, accentGreen border, dot indicator), "$totalXP / $nextXP XP" white bold 22sp, linear progress bar, "Keep going! $remaining XP to $next" white opacity 0.7 11sp
- **Weekly Activity** bar chart (`fl_chart BarChart`, dark brown card):
  - 7 bars Mon–Sun, accentGreen, today's bar highlighted with tooltip
  - X-axis day labels, grid lines white10
- **Stats Row** 3 white cards: Sessions / Words / Quizzes
- **Quiz Performance** bar chart (last 5 quizzes, green if ≥60%, amber if <60%)

**Data loading:**
```dart
// initState:
_sessions   = (await DatabaseHelper.instance.getSessions()).length;
_words      = await DatabaseHelper.instance.getWordCount();
_quizzes    = (await DatabaseHelper.instance.getLastQuizScores(100)).length;
_last7Days  = await DatabaseHelper.instance.getLast7DaysStreaks();
_last5Quiz  = await DatabaseHelper.instance.getLastQuizScores(5);
await context.read<UserProvider>().loadUser();
```

---

## SCREEN 15 — ACHIEVEMENTS
**File:** `screens/achievements/achievements_screen.dart` | **Student 3**

**UI:**
- AppBar dark green: "Achievements"
- **Streak Hero Card** (`Color(0xFF1A3A1A)`, green glow border):
  - Flame image/emoji 🔥 80px + "$streak Day Streak!" white bold 24sp + "Total XP: ⚡$totalXP" + level chip
- **Badge Grid** 2 columns (`GridView`):
  - 6 badges: 3 Day Streak 🔥, 7 Day Streak ⚡, 14 Day Streak 🏆, 30 Day Streak 👑, Word Collector 📚, Quiz Master 🎯
  - Unlocked card: `Color(0xFF1A3A1A)` bg, green border, full color icon, "EARNED ✓" green chip
  - Locked card: dark bg, white10 border, grayscale icon (opacity 0.3) with 🔒 overlay, "LOCKED" white38 chip

**Badge unlock conditions:**
```dart
streak >= 3   → 3 Day Streak
streak >= 7   → 7 Day Streak
streak >= 14  → 14 Day Streak
streak >= 30  → 30 Day Streak
wordCount >= 25 → Word Collector
quizCount >= 5  → Quiz Master
```

---

## SCREEN 16 — PROFILE
**File:** `screens/profile/profile_screen.dart` | **Student: Shahzaib**

**UI:**
- Top 1/3: dark green gradient bg
  - Edit pencil icon (top right, white rounded circle)
  - CircleAvatar radius 42: avatar image with accentGreen border ring
  - Name text (editable TextField when edit mode on)
  - Level chip (dark bg, accentGreen border + dot)
  - "⚡ $totalXP XP" white 14sp
- Stats row (3 dark brown cards): Sessions / Words / Quizzes
- Settings card (`bgMedBrown`, rounded 16px):
  - Daily Goal: ListTile + green Slider (5–60 mins, step 5)
  - AI Tutor: ListTile + current value green + chevron
  - App Theme: ListTile + Switch (decorative)
- Sign Out button (ctaRed outlined, full width)

**Logic:**
```dart
// Edit name: toggle isEditMode, show TextField
// Save name: userProvider.updateProfile({'name': newName})
// Slider change end: userProvider.updateProfile({'daily_goal_mins': val.toInt()})
// Sign Out:
showDialog(/* confirm */);
// On confirm:
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
Navigator.pushAndRemoveUntil(context,
  MaterialPageRoute(builder: (_) => OnboardingScreen()),
  (route) => false);
```

---

## NAVIGATION FLOW

```
SplashScreen (2.5s)
    │
    ├─ isOnboarded=false ──► OnboardingScreen ──► MainScreen(index:0)
    └─ isOnboarded=true  ─────────────────────► MainScreen(index:0)
                                                      │
               ┌──────────────────────────────────────┤
               │         Bottom Nav (4 tabs)          │
               │  [Home] [Notes] [Progress] [Profile] │
               └──────────────────────────────────────┘
                   │          │           │          │
            Dashboard   NotesList   Progress    Profile
                │              │
          ┌─────┴──┐     AddEditNote
          │  4 btns │
    ┌─────┼─────────┼──────────┐
    │     │         │          │
  Goals Practice  Vocab      Quiz
          │         │          │
   PracticeTopics VocabScreen GrammarQuiz
          │         │          │
       AIChat  SavedWords  QuizResult
               │
           VocabQuiz ──► QuizResult
```

---

## IMPLEMENTATION ORDER (Follow This Exactly)

```
STEP 1 — Project Setup
  □ flutter create fluentpath_ai
  □ Add all packages to pubspec.yaml
  □ Add Poppins fonts to assets/fonts/
  □ Create placeholder images in assets/images/
  □ Download confetti.json → assets/lottie/
  □ Create .gitignore entry for api_keys.dart

STEP 2 — Core Files
  □ app_colors.dart
  □ app_text_styles.dart
  □ api_keys.dart (with Groq key)
  □ database_helper.dart (all tables + CRUD)
  □ groq_service.dart (all 5 methods)

STEP 3 — Providers (all 6)
  □ Wire in main.dart MultiProvider

STEP 4 — Screens (build in this order)
  □ splash_screen.dart
  □ onboarding_screen.dart
  □ main_screen.dart (bottom nav)
  □ dashboard_screen.dart
  □ daily_goals_screen.dart
  □ practice_topics_screen.dart
  □ ai_chat_screen.dart
  □ vocabulary_screen.dart
  □ saved_words_screen.dart
  □ vocabulary_quiz_screen.dart
  □ grammar_quiz_screen.dart
  □ quiz_result_screen.dart
  □ notes_list_screen.dart
  □ add_edit_note_screen.dart
  □ progress_screen.dart
  □ achievements_screen.dart
  □ profile_screen.dart

STEP 5 — Test Everything
  □ SQLite: CRUD each table
  □ Groq: all 5 API calls
  □ Navigation: every button
  □ Streak: goals update correctly
  □ Quiz: both grammar + vocabulary
```

---

## 10 CRITICAL NOTES FOR AI CODER

```
1. DATABASE INIT
   In main() before runApp():
   await DatabaseHelper.instance.database; // initialize tables

2. GROQ JSON PARSING
   Always: response.replaceAll('```json','').replaceAll('```','').trim()
   Always wrap in try-catch with fallback data

3. LOADING STATES
   Every Groq call needs setState(() => _loading = true/false)
   Never await without UI feedback

4. DATE FORMAT (use everywhere)
   final today = DateTime.now().toIso8601String().split('T')[0];
   // Result: "2025-05-22"

5. AUTO-SCROLL IN CHAT
   WidgetsBinding.instance.addPostFrameCallback((_) {
     _scroll.animateTo(_scroll.position.maxScrollExtent,
       duration: Duration(milliseconds: 300), curve: Curves.easeOut);
   });

6. TIMER DISPOSAL
   @override void dispose() { _timer?.cancel(); super.dispose(); }

7. STREAK UPSERT
   SQLite INSERT OR REPLACE handles duplicate dates automatically

8. IMAGE FALLBACK
   errorBuilder: (ctx, e, s) => Icon(Icons.image_not_supported, color: Colors.white24)

9. GOOGLE FONTS
   theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme())

10. GROQ RATE LIMIT = 30 req/min (free tier)
    Add if needed: await Future.delayed(Duration(milliseconds: 500));
```
