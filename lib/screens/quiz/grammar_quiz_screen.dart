import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/streak_provider.dart';
import '../../core/widgets/background_scaffold.dart';

class GrammarQuizScreen extends StatefulWidget {
  const GrammarQuizScreen({super.key});

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  bool _quizFinished = false;
  int _earnedXP = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().generateQuiz();
    });
  }

  Future<void> _finishQuiz(QuizProvider quizProvider) async {
    final int score = quizProvider.score;
    final int total = quizProvider.questions.length;
    final double accuracy = total > 0 ? (score / total) : 0;

    // Calculate XP Rewards
    if (accuracy == 1.0) {
      _earnedXP = 30;
    } else if (accuracy >= 0.6) {
      _earnedXP = 15;
    } else {
      _earnedXP = 5;
    }

    // Save XP rewards to database
    final userProvider = context.read<UserProvider>();
    final streakProvider = context.read<StreakProvider>();
    
    await userProvider.addXP(_earnedXP);
    await streakProvider.addXP(_earnedXP);
    await quizProvider.saveQuizScore(_earnedXP);

    setState(() {
      _quizFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    
    if (_quizFinished) {
      return _buildScoreScreen(quizProvider);
    }

    if (quizProvider.questions.isEmpty) {
      return BackgroundScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.brightGreen),
              const SizedBox(height: 16),
              Text(
                'AI is generating grammar questions...',
                style: AppTextStyles.caption.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = quizProvider.questions[quizProvider.currentIndex];
    final List<String> options = List<String>.from(currentQuestion['options']);
    final String questionText = currentQuestion['question'];
    final String correctAnswer = currentQuestion['answer'];

    final int qNum = quizProvider.currentIndex + 1;
    final int totalQ = quizProvider.questions.length;

    return BackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.bgMedBrown,
                title: const Text('Quit Quiz?', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                content: const Text('Your current score progress will be lost.', style: TextStyle(color: AppColors.textMuted)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Resume', style: TextStyle(color: AppColors.accentGreen)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text('Quit', style: TextStyle(color: AppColors.ctaRed)),
                  ),
                ],
              ),
            );
          },
        ),
        title: const Text(
          'Grammar Quiz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Progress Header Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question $qNum of $totalQ',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.brightGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Score: ${quizProvider.score}',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: qNum / totalQ,
                minHeight: 6,
                color: AppColors.brightGreen,
                backgroundColor: Colors.white.withOpacity(0.06),
              ),
            ),
            const SizedBox(height: 24),

            // Question sheet card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgLightBeige,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                questionText,
                style: AppTextStyles.bodyDark.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Option selection list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = options[index];
                final bool isSelected = quizProvider.selectedAnswer == option;
                final bool isAnswered = quizProvider.isAnswered;
                final bool isCorrect = option == correctAnswer;

                Color cardColor = Colors.white;
                Color borderColor = Colors.transparent;
                Widget? trailingIcon;

                if (isAnswered) {
                  if (isCorrect) {
                    borderColor = AppColors.accentGreen;
                    cardColor = const Color(0xFFE8F5E9); // Solid, fully opaque premium light pastel green
                    trailingIcon = const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen);
                  } else if (isSelected) {
                    borderColor = AppColors.ctaRed;
                    cardColor = const Color(0xFFFFEBEE); // Solid, fully opaque premium light pastel red/pink
                    trailingIcon = const Icon(Icons.cancel_rounded, color: AppColors.ctaRed);
                  }
                } else if (isSelected) {
                  borderColor = AppColors.primaryGreen;
                  cardColor = const Color(0xFFF1F8E9); // Solid soft mint/white for selected state
                }

                return GestureDetector(
                  onTap: isAnswered
                      ? null
                      : () {
                          quizProvider.selectAnswer(option);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderColor != Colors.transparent
                            ? borderColor
                            : Colors.white.withOpacity(0.08),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: AppTextStyles.bodyDark.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: AppColors.textDark,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Submit / Next action button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: quizProvider.selectedAnswer == null
                    ? null
                    : () {
                        if (!quizProvider.isAnswered) {
                          quizProvider.submitAnswer();
                        } else {
                          // Advance question or finish
                          if (quizProvider.currentIndex < totalQ - 1) {
                            quizProvider.nextQuestion();
                          } else {
                            _finishQuiz(quizProvider);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brightGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white10,
                  disabledForegroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  !quizProvider.isAnswered
                      ? 'Submit Answer'
                      : (quizProvider.currentIndex < totalQ - 1 ? 'Next Question' : 'View Results'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreScreen(QuizProvider quizProvider) {
    final int score = quizProvider.score;
    final int total = quizProvider.questions.length;
    final double accuracy = total > 0 ? (score / total) * 100 : 0.0;

    return BackgroundScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Circular score icon
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.brightGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.brightGreen,
                  size: 72,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Quiz Completed!',
                style: AppTextStyles.heading1.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You scored $score out of $total questions.',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),

              // Result Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.bgMedBrown,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Accuracy:', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        Text('${accuracy.toInt()}%', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('XP Reward:', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        Text('⚡ +$_earnedXP XP', style: const TextStyle(color: AppColors.brightGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Finished back action button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    quizProvider.resetQuiz();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightGreen,
                    foregroundColor: AppColors.bgDarkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
