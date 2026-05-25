import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String? _customAvatarBase64;
  String? get customAvatarBase64 => _customAvatarBase64;

  UserProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    var u = await DatabaseHelper.instance.getUser();
    final prefs = await SharedPreferences.getInstance();
    
    if (u == null) {
      final isOnboarded = prefs.getBool('isOnboarded') ?? false;
      if (isOnboarded) {
        // Self-heal: Database is empty but user is onboarded. Insert default profile.
        await DatabaseHelper.instance.insertUser({
          'name': 'User',
          'avatar_index': 0,
          'level': 'Beginner',
          'total_xp': 0,
          'daily_goal_mins': 15,
          'selected_tutor': 'Friendly Buddy',
          'created_at': DateTime.now().toIso8601String(),
        });
        u = await DatabaseHelper.instance.getUser();
      }
    }
    
    _user = u;
    _customAvatarBase64 = prefs.getString('custom_avatar_base64');
    notifyListeners();
  }

  Future<void> updateCustomAvatar(String? base64Str) async {
    _customAvatarBase64 = base64Str;
    final prefs = await SharedPreferences.getInstance();
    if (base64Str != null) {
      await prefs.setString('custom_avatar_base64', base64Str);
    } else {
      await prefs.remove('custom_avatar_base64');
    }
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
      // Optimistic update for smooth, lag-free UI feedback
      if (_user != null) {
        _user = Map<String, dynamic>.from(_user!)..addAll(values);
      } else {
        _user = {
          'name': name ?? 'User',
          'avatar_index': values['avatar_index'] ?? 0,
          'level': level ?? 'Beginner',
          'total_xp': 0,
          'daily_goal_mins': dailyGoalMins ?? 15,
          'selected_tutor': 'Friendly Buddy',
        };
      }
      notifyListeners();

      await DatabaseHelper.instance.updateUser(values);
      await loadUser();
    }
  }

  Future<bool> hasUser() async =>
    (await DatabaseHelper.instance.getUser()) != null;
}
