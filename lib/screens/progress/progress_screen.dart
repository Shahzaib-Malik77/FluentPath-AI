import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/database/database_helper.dart';
import '../../providers/user_provider.dart';
import '../../providers/streak_provider.dart';
import 'session_history_detail_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Map<String, dynamic>> _sessions = [];
  double _avgMins = 0.0;
  String _favoriteTopic = 'Cafe Order';
  int _totalMins = 0;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final db = DatabaseHelper.instance;
    _sessions = await db.getSessions();

    // Compute stats
    int totalMins = 0;
    final Map<String, int> categoryCounts = {};

    for (final session in _sessions) {
      totalMins += (session['duration_mins'] as int? ?? 0);
      final String cat = session['scenario'] ?? 'General';
      categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
    }

    _totalMins = totalMins;
    _avgMins = _sessions.isNotEmpty ? (_totalMins / 7) : 0.0;

    if (categoryCounts.isNotEmpty) {
      final sortedKeys = categoryCounts.keys.toList()
        ..sort((a, b) => categoryCounts[b]!.compareTo(categoryCounts[a]!));
      _favoriteTopic = sortedKeys.first;
    }

    if (mounted) {
      setState(() {});
    }
  }

  String _formatDate(String isoString) {
    try {
      final parsed = DateTime.parse(isoString);
      final String month = parsed.month.toString().padLeft(2, '0');
      final String day = parsed.day.toString().padLeft(2, '0');
      final String year = parsed.year.toString();
      return '$month/$day/$year';
    } catch (_) {
      return isoString;
    }
  }



  // fl_chart bar groups for historical minutes
  List<BarChartGroupData> _buildChartGroups() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final DateTime targetDate = now.subtract(Duration(days: 6 - index));
      final String dateStr = targetDate.toIso8601String().split('T')[0];

      // Find practice minutes for this day from sessions
      double minutes = 0;
      for (final session in _sessions) {
        if (session['date'] == dateStr) {
          minutes += (session['duration_mins'] as num? ?? 0).toDouble();
        }
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: minutes,
            color: AppColors.brightGreen,
            width: 12,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 30, // Mock baseline max height goal
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ],
      );
    });
  }

  // X-axis headings (Mon-Sun labels)
  Widget _bottomTitles(double value, TitleMeta meta) {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final targetDate = now.subtract(Duration(days: 6 - value.toInt()));
    // DateTime.weekday is 1 for Mon to 7 for Sun
    final int index = targetDate.weekday - 1;
    return SideTitleWidget(
      meta: meta,
      child: Text(
        weekdays[index],
        style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

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
          'Progress Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userProvider.loadUser();
          await streakProvider.loadStreak();
          await _loadProgressData();
        },
        color: AppColors.accentGreen,
        backgroundColor: AppColors.bgMedBrown,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Core Stats Row Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total XP',
                      '${userProvider.totalXP}',
                      Icons.bolt_rounded,
                      AppColors.xpPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Sessions Done',
                      '${_sessions.length}',
                      Icons.chat_bubble_outline_rounded,
                      AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Time',
                      '$_totalMins mins',
                      Icons.access_time_rounded,
                      AppColors.streakMint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart Container (fl_chart)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgMedBrown,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Practice Minutes (Last 7 Days)',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          barGroups: _buildChartGroups(),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: _bottomTitles,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          alignment: BarChartAlignment.spaceAround,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Averages & Highlights
              Text(
                'Insights',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.bgMedBrown,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildInsightRow('Daily Average Time:', '${_avgMins.toStringAsFixed(1)} minutes'),
                    const Divider(color: Colors.white10, height: 24),
                    _buildInsightRow('Favorite Roleplay:', _favoriteTopic),
                    const Divider(color: Colors.white10, height: 24),
                    _buildInsightRow('Current Level Rank:', 'LEVEL ${userProvider.level.toUpperCase()}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Practice History List
              Text(
                'Conversation Log History',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              _sessions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No roleplay logs completed yet.',
                          style: AppTextStyles.caption.copyWith(color: Colors.white30),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sessions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        return _buildHistoryItem(context, session);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bgMedBrown,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> session) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SessionHistoryDetailScreen(session: session),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgMedBrown,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session['scenario'] ?? 'Practice Session',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(session['date'] ?? ''),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '${session['duration_mins'] ?? 0} mins',
                  style: const TextStyle(
                    color: AppColors.brightGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black26,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
