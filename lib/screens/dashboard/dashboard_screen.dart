import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/database/database_helper.dart';
import '../../providers/user_provider.dart';
import '../../providers/streak_provider.dart';
import '../../services/groq_service.dart';
import '../daily_goals/daily_goals_screen.dart';
import '../practice/practice_topics_screen.dart';
import '../vocabulary/vocabulary_screen.dart';
import '../quiz/grammar_quiz_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _todayMins = 0;
  String _dailyTip = 'Practice 10 minutes of English conversation daily for best results.';
  bool _tipLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<UserProvider>().loadUser();
      await context.read<StreakProvider>().loadStreak();
      _todayMins = await DatabaseHelper.instance.getTodaySessionMins();
      if (mounted) {
        setState(() {});
      }
      _loadDailyTip();
    });
  }

  Future<void> _loadDailyTip() async {
    if (!mounted) return;
    setState(() => _tipLoading = true);
    try {
      final tip = await GroqService.getDailyTip();
      if (mounted) {
        setState(() {
          _dailyTip = tip;
          _tipLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _tipLoading = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final streakProvider = context.watch<StreakProvider>();

    final dailyGoal = userProvider.dailyGoalMins;
    final percent = dailyGoal > 0 ? ((_todayMins / dailyGoal) * 100).clamp(0, 100).toInt() : 0;

    return Scaffold(
      backgroundColor: AppColors.bgDarkGreen,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await userProvider.loadUser();
            await streakProvider.loadStreak();
            _todayMins = await DatabaseHelper.instance.getTodaySessionMins();
            await _loadDailyTip();
          },
          color: AppColors.accentGreen,
          backgroundColor: AppColors.bgMedBrown,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Top Bar (Greeting)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()},',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${userProvider.name}!',
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Streak + Level Chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.bgDarkBrown,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.eco_rounded, color: AppColors.textDark, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${streakProvider.currentStreak} Day Streak',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.brightGreen, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'LEVEL ${userProvider.level.toUpperCase()}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.brightGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Ring progress
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 90,
                                height: 90,
                                child: CircularProgressIndicator(
                                  value: (percent / 100).clamp(0.0, 1.0),
                                  strokeWidth: 10,
                                  color: AppColors.brightGreen,
                                  backgroundColor: Colors.white.withOpacity(0.06),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$percent%',
                                    style: AppTextStyles.heading2.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Done',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Today's Goal",
                                  style: AppTextStyles.heading3.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$_todayMins of $dailyGoal minutes practiced',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.bgDarkBrown,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Keep learning to secure your daily streak!',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section Title: Modules
                Text(
                  'Core Modules',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 14),

                // 2x2 Grid using clean Rows & Columns (highly responsive)
                Row(
                  children: [
                    Expanded(
                      child: _buildGridItem(
                        context,
                        title: 'AI Practice',
                        subtitle: 'Scenario Chats',
                        icon: Icons.chat_bubble_outline_rounded,
                        color: AppColors.primaryGreen,
                        destination: const PracticeTopicsScreen(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildGridItem(
                        context,
                        title: 'Vocabulary',
                        subtitle: 'Learn new words',
                        icon: Icons.book_outlined,
                        color: AppColors.ctaBrown,
                        destination: const VocabularyScreen(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridItem(
                        context,
                        title: 'Grammar Quiz',
                        subtitle: 'Test your rules',
                        icon: Icons.quiz_outlined,
                        color: AppColors.xpPurple,
                        destination: const GrammarQuizScreen(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildGridItem(
                        context,
                        title: 'Daily Goals',
                        subtitle: 'Check milestones',
                        icon: Icons.flag_outlined,
                        color: AppColors.streakMint,
                        destination: const DailyGoalsScreen(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // AI Coach Tip Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgDarkGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentGreen, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.psychology_outlined,
                              color: AppColors.brightGreen,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Master English with AI',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Daily Tips & Wisdom',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.brightGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Animated Tip text or shimmer/loader
                      _tipLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.brightGreen,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              _dailyTip,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withOpacity(0.85),
                                height: 1.5,
                                fontSize: 13,
                              ),
                            ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PracticeTopicsScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.streakMint,
                            foregroundColor: AppColors.bgDarkGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Start Practice Now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgMedBrown,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color == AppColors.primaryGreen ? AppColors.brightGreen : color,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black38,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
