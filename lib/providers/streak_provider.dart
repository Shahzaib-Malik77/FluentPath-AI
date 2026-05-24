import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';

class StreakProvider extends ChangeNotifier {
  Map<String, dynamic>? _todayStreak;
  int _currentStreak = 0;
  List<Map<String, dynamic>> _last7Days = [];

  int  get currentStreak    => _currentStreak;
  List<Map<String, dynamic>> get last7Days => _last7Days;
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

  Future<void> addXP(int amount) async {
    await updateTodayStreak(xpAdd: amount);
  }
}
