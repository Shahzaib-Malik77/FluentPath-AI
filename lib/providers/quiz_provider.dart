import 'package:flutter/material.dart';
import '../services/groq_service.dart';
import '../data/database/database_helper.dart';

class QuizProvider extends ChangeNotifier {
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  bool showExplanation = false;
  bool isLoading = false;
  String currentTopic = '';
  List<Map<String, dynamic>> wrongAnswers = [];

  Future<void> generateQuiz() async {
    await generateGrammarQuiz("Grammar & Syntax Rules");
  }

  Future<void> generateGrammarQuiz(String topic) async {
    isLoading = true; 
    currentTopic = topic; 
    currentIndex = 0;
    score = 0; 
    wrongAnswers = []; 
    selectedAnswer = null;
    isAnswered = false;
    showExplanation = false; 
    notifyListeners();
    try { 
      questions = await GroqService.generateGrammarQuiz(topic); 
    } catch (_) { 
      questions = []; 
    }
    isLoading = false; 
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (isAnswered) return;
    selectedAnswer = answer; 
    notifyListeners();
  }

  void submitAnswer() {
    if (selectedAnswer == null || isAnswered) return;
    isAnswered = true;
    showExplanation = true;
    
    final correctAnswer = questions[currentIndex]['answer'];
    if (selectedAnswer == correctAnswer) {
      score++; 
    } else { 
      wrongAnswers.add({
        'question': questions[currentIndex]['question'], 
        'yourAnswer': selectedAnswer, 
        'correctAnswer': correctAnswer, 
        'explanation': questions[currentIndex]['explanation'] ?? 'Double check grammar rules next time!'
      }); 
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++; 
      selectedAnswer = null; 
      isAnswered = false;
      showExplanation = false; 
      notifyListeners();
    }
  }

  void resetQuiz() {
    currentIndex = 0;
    score = 0;
    wrongAnswers = [];
    selectedAnswer = null;
    isAnswered = false;
    showExplanation = false;
    notifyListeners();
  }

  bool get isLastQuestion => currentIndex >= questions.length - 1;
  int get totalQuestions  => questions.length;
  double get percentage   => totalQuestions > 0 ? score / totalQuestions : 0;
  int get xpEarned        => (score * 20) + (percentage == 1.0 ? 50 : 0);

  Future<void> saveQuizScore(int earnedXP) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await DatabaseHelper.instance.insertQuizScore({
      'quiz_type': 'Grammar Quiz', 
      'topic': currentTopic.isEmpty ? 'Grammar & Syntax Rules' : currentTopic, 
      'score': score,
      'total_questions': totalQuestions, 
      'xp_earned': earnedXP,
      'wrong_answers': wrongAnswers.toString(), 
      'date': today,
    });
  }
}
