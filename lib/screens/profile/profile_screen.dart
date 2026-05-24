import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../providers/streak_provider.dart';
import '../../data/database/database_helper.dart';
import '../splash/splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final streakProvider = context.watch<StreakProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDarkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgDarkGreen,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Header Avatar & Info Card
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: AppColors.brightGreen.withOpacity(0.12),
                        child: Text(
                          userProvider.avatar,
                          style: const TextStyle(fontSize: 54),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showAvatarPicker(context, userProvider),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.brightGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, color: AppColors.bgDarkGreen, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProvider.name,
                    style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bgMedBrown,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'LEVEL ${userProvider.level.toUpperCase()}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.xpPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.xpPurple.withOpacity(0.5)),
                        ),
                        child: Text(
                          '⚡ ${streakProvider.todayXP} XP Total',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile Settings List Cards
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgLightBeige,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    context,
                    label: 'Edit Name',
                    icon: Icons.person_outline_rounded,
                    onTap: () => _showEditNameSheet(context, userProvider),
                  ),
                  const Divider(color: Colors.black12, height: 1),
                  _buildSettingRow(
                    context,
                    label: 'Daily Study Goal',
                    icon: Icons.flag_outlined,
                    onTap: () => _showEditGoalSheet(context, userProvider),
                  ),
                  const Divider(color: Colors.black12, height: 1),
                  _buildSettingRow(
                    context,
                    label: 'Level Assessment',
                    icon: Icons.g_translate_rounded,
                    onTap: () => _showLevelReassessmentSheet(context, userProvider),
                  ),
                  const Divider(color: Colors.black12, height: 1),
                  _buildSettingRow(
                    context,
                    label: 'Reset All Data',
                    icon: Icons.refresh_rounded,
                    isDestructive: true,
                    onTap: () => _showResetConfirmation(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.ctaRed : AppColors.primaryGreen,
        size: 22,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyDark.copyWith(
          fontWeight: FontWeight.bold,
          color: isDestructive ? AppColors.ctaRed : AppColors.textDark,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.black26,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showAvatarPicker(BuildContext context, UserProvider userProvider) {
    final List<String> avatars = ['👨‍🎓', '👩‍🎓', '🤖', '🦊', '🐨', '🦁', '🦖', '🦄'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDarkGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose your avatar style',
                style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: avatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final av = avatars[index];
                  return GestureDetector(
                    onTap: () async {
                      await userProvider.updateProfile(
                        name: userProvider.name,
                        avatar: av,
                        level: userProvider.level,
                        dailyGoalMins: userProvider.dailyGoalMins,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: userProvider.avatar == av ? AppColors.brightGreen.withOpacity(0.15) : AppColors.bgMedBrown,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: userProvider.avatar == av ? AppColors.brightGreen : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          av,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameSheet(BuildContext context, UserProvider userProvider) {
    final controller = TextEditingController(text: userProvider.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgDarkGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile Name',
                style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bgMedBrown,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;

                    await userProvider.updateProfile(
                      name: name,
                      avatar: userProvider.avatar,
                      level: userProvider.level,
                      dailyGoalMins: userProvider.dailyGoalMins,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightGreen,
                    foregroundColor: AppColors.bgDarkGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditGoalSheet(BuildContext context, UserProvider userProvider) {
    double tempVal = userProvider.dailyGoalMins.toDouble();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDarkGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Set Study Goal (minutes)',
                    style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${tempVal.toInt()} Minutes Daily',
                    style: const TextStyle(color: AppColors.brightGreen, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: tempVal,
                    min: 5,
                    max: 60,
                    divisions: 11,
                    activeColor: AppColors.brightGreen,
                    inactiveColor: Colors.white12,
                    onChanged: (val) {
                      setSheetState(() => tempVal = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await userProvider.updateProfile(
                          name: userProvider.name,
                          avatar: userProvider.avatar,
                          level: userProvider.level,
                          dailyGoalMins: tempVal.toInt(),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brightGreen,
                        foregroundColor: AppColors.bgDarkGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Goal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLevelReassessmentSheet(BuildContext context, UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDarkGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adjust Assessment Level',
                style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Beginner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Simple roleplays and elementary quiz grammar topics.', style: TextStyle(color: Colors.white38, fontSize: 11)),
                onTap: () => _updateLevel(context, userProvider, 'beginner'),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                title: const Text('Intermediate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Everyday conversations and fluid dialogue structures.', style: TextStyle(color: Colors.white38, fontSize: 11)),
                onTap: () => _updateLevel(context, userProvider, 'intermediate'),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                title: const Text('Advanced', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Complex sentence queries and rapid corporate HR simulations.', style: TextStyle(color: Colors.white38, fontSize: 11)),
                onTap: () => _updateLevel(context, userProvider, 'advanced'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateLevel(BuildContext context, UserProvider userProvider, String level) async {
    await userProvider.updateProfile(
      name: userProvider.name,
      avatar: userProvider.avatar,
      level: level,
      dailyGoalMins: userProvider.dailyGoalMins,
    );
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgMedBrown,
        title: const Text('Reset All Databases?', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        content: const Text(
          'Warning! This action is completely destructive and irreversible. You will lose your profiles, study notes, vocabulary list, and current streak history.',
          style: TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.primaryGreen)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              // Destructive database reset
              await DatabaseHelper.instance.clearAll();
              
              // Clear Shared Preferences onboarding flags
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (context.mounted) {
                // Restart visual state by routing user directly to splash/onboarding
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Yes, Reset Everything', style: TextStyle(color: AppColors.ctaRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
