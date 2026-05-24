import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';

class UserProvider extends ChangeNotifier {
  static const List<String> avatars = ['👨‍🎓', '👩‍🎓', '🤖', '🦊', '🐨', '🦁', '🦖', '🦄'];

  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;
  String get name          => _user?['name'] ?? 'User';
  int    get totalXP       => _user?['total_xp'] ?? 0;
  int    get avatarIndex   => _user?['avatar_index'] ?? 0;
  String get avatar        => avatarIndex < avatars.length ? avatars[avatarIndex] : avatars[0];
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
  Future<void> updateProfile({
    String? name,
    String? avatar,
    String? level,
    int? dailyGoalMins,
  }) async {
    final Map<String, dynamic> values = {};
    if (name != null) values['name'] = name;
    if (avatar != null) {
      final index = avatars.indexOf(avatar);
      if (index != -1) {
        values['avatar_index'] = index;
      }
    }
    if (level != null) values['level'] = level;
    if (dailyGoalMins != null) values['daily_goal_mins'] = dailyGoalMins;

    if (values.isNotEmpty) {
      await DatabaseHelper.instance.updateUser(values);
      await loadUser();
    }
  }
  Future<bool> hasUser() async =>
    (await DatabaseHelper.instance.getUser()) != null;
}
