import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/database/database_helper.dart';
import '../../providers/user_provider.dart';
import '../../providers/streak_provider.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({super.key});

  @override
  State<DailyGoalsScreen> createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen> with SingleTickerProviderStateMixin {
  int _todayMins = 0;
  int _todayWords = 0;
  bool _quizDone = false;
  int _streak = 0;
  List<Map<String, dynamic>> _last7Days = [];
  bool _showConfetti = false;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    _todayMins = await db.getTodaySessionMins();
    _todayWords = await db.getTodayWordCount();
    _quizDone = await db.quizDoneToday();
    _streak = await db.getCurrentStreak();
    _last7Days = await db.getLast7DaysStreaks();

    final userProvider = context.read<UserProvider>();
    final streakProvider = context.read<StreakProvider>();
    await userProvider.loadUser();
    await streakProvider.loadStreak();

    if (mounted) {
      setState(() {});
    }

    _checkGoalsCompletion(userProvider.dailyGoalMins);
  }

  Future<void> _checkGoalsCompletion(int minutesGoal) async {
    final bool pDone = _todayMins >= minutesGoal;
    final bool vDone = _todayWords >= 5;
    final bool qDone = _quizDone;

    if (pDone && vDone && qDone) {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastConfettiDate = prefs.getString('confetti_date') ?? '';

      if (lastConfettiDate != today) {
        await prefs.setString('confetti_date', today);
        if (mounted) {
          setState(() => _showConfetti = true);
          _confettiController.forward().then((_) {
            if (mounted) {
              setState(() => _showConfetti = false);
            }
          });
        }
      }
    }
  }

  // Generate weekday headings and checkmark checks
  List<Widget> _buildCalendarRow() {
    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    // Monday is 1, Sunday is 7 in DateTime
    final int currentWeekday = now.weekday;

    return List.generate(7, (index) {
      // Find the date for this weekday index
      final int offsetDays = index + 1 - currentWeekday;
      final DateTime targetDate = now.add(Duration(days: offsetDays));
      final String dateStr = targetDate.toIso8601String().split('T')[0];

      // Check if this day is practiced/XP earned in _last7Days
      bool completed = false;
      for (final day in _last7Days) {
        if (day['date'] == dateStr && (day['xp_earned'] ?? 0) > 0) {
          completed = true;
          break;
        }
      }

      final bool isToday = offsetDays == 0;
      final bool isFuture = offsetDays > 0;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? AppColors.accentGreen
                  : (isToday
                      ? Colors.transparent
                      : (isFuture ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.08))),
              border: Border.all(
                color: isToday ? AppColors.accentGreen : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: completed
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : Text(
                      '${targetDate.day}',
                      style: AppTextStyles.caption.copyWith(
                        color: isToday
                            ? AppColors.accentGreen
                            : (isFuture ? AppColors.textMuted.withValues(alpha: 0.4) : AppColors.textDark),
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            weekdays[index],
            style: AppTextStyles.caption.copyWith(
              color: isToday ? AppColors.accentGreen : AppColors.textMuted,
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final streakProvider = context.watch<StreakProvider>();
    final minutesGoal = userProvider.dailyGoalMins;

    final double pProgress = minutesGoal > 0 ? (_todayMins / minutesGoal).clamp(0.0, 1.0) : 0.0;
    final double vProgress = (_todayWords / 5).clamp(0.0, 1.0);
    final double qProgress = _quizDone ? 1.0 : 0.0;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.bgDarkGreen,
          appBar: AppBar(
            backgroundColor: AppColors.bgDarkGreen,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Daily Goals',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Streak calendar synced to SQLite!')),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Streak Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.streakMint, AppColors.streakAmber],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.streakMint.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 54)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_streak Day Streak!',
                              style: AppTextStyles.heading1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You are building a super habit. Keep going!',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 7-Day Calendar card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgMedBrown,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Progress',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _buildCalendarRow(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Goal Cards Heading
                Text(
                  "Today's Milestones",
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // 1. Practice Goal Card
                _buildGoalCard(
                  title: 'Practice Conversations',
                  subtitle: 'Spend time speaking with AI tutors',
                  current: '$_todayMins min',
                  target: '$minutesGoal min',
                  progress: pProgress,
                  icon: Icons.chat_bubble_outline_rounded,
                  xp: '+20 XP',
                  completed: _todayMins >= minutesGoal,
                ),
                const SizedBox(height: 12),

                // 2. Vocabulary Goal Card
                _buildGoalCard(
                  title: 'Save New Words',
                  subtitle: 'Discover and bookmark useful vocab',
                  current: '$_todayWords words',
                  target: '5 words',
                  progress: vProgress,
                  icon: Icons.bookmark_border_rounded,
                  xp: '+10 XP',
                  completed: _todayWords >= 5,
                ),
                const SizedBox(height: 12),

                // 3. Quiz Goal Card
                _buildGoalCard(
                  title: 'Complete a Quiz',
                  subtitle: 'Pass vocabulary or grammar quiz',
                  current: _quizDone ? '1 quiz' : '0 quizzes',
                  target: '1 quiz',
                  progress: qProgress,
                  icon: Icons.quiz_outlined,
                  xp: '+30 XP',
                  completed: _quizDone,
                ),
                const SizedBox(height: 24),

                // XP Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgMedBrown,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.xpPurple,
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's XP Earned",
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '⚡ ${streakProvider.todayXP} XP Total',
                            style: AppTextStyles.heading2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Confetti animation layer
        if (_showConfetti)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: ConfettiPainter(progress: _confettiController.value),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String subtitle,
    required String current,
    required String target,
    required double progress,
    required IconData icon,
    required String xp,
    required bool completed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLightBeige,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 24),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyDark.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        xp,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                // Progress
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: completed ? AppColors.accentGreen : AppColors.ctaRed,
                    backgroundColor: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$current / $target',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDark.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Checkbox
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? AppColors.accentGreen : Colors.transparent,
              border: Border.all(
                color: completed ? AppColors.accentGreen : AppColors.textMuted.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: completed
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
          ),
        ],
      ),
    );
  }
}

// Custom Painter for standard animated confetti fallback
class ConfettiPainter extends CustomPainter {
  final double progress;
  ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.pink, Colors.purple, Colors.tealAccent];
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw 80 random particle paths
    for (int i = 0; i < 80; i++) {
      paint.color = colors[i % colors.length].withOpacity(1.0 - progress);
      // Determine vertical trajectory
      final double x = (size.width / 2) + 200 * progress * ((i % 2 == 0) ? -1 : 1) * ((i % 5) / 5) * 1.5;
      final double y = (size.height / 3) + 400 * progress - 100 * (1.0 - progress);
      canvas.drawCircle(Offset(x, y), 5 + (i % 4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
