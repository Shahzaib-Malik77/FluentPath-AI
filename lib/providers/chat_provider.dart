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

  int get durationSeconds => sessionSeconds;

  void startSession(String scenario, String persona) {
    initSession(scenario, persona);
  }

  void initSession(String scenario, String persona) {
    messages = []; 
    currentScenario = scenario;
    currentPersona = persona; 
    sessionSeconds = 0;
    _startTimer(); 
    _sendInitialGreeting(); 
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) { 
      sessionSeconds++; 
      notifyListeners(); 
    });
  }

  Future<void> _sendInitialGreeting() async {
    isLoading = true; 
    notifyListeners();
    try {
      final g = await GroqService.chatWithTutor(
        scenario: currentScenario, 
        persona: currentPersona,
        conversationHistory: [{'role':'user','content':'Start our $currentScenario practice with a friendly greeting.'}]
      );
      messages.add({'role':'assistant','content':g});
    } catch (_) {
      messages.add({'role':'assistant','content':"Hello! Let's practice $currentScenario together. I'm ready when you are!"});
    }
    isLoading = false; 
    notifyListeners();
  }

  Future<void> sendMessage(String userMessage) async {
    messages.add({'role':'user','content':userMessage});
    isLoading = true; 
    notifyListeners();
    try {
      final r = await GroqService.chatWithTutor(
        scenario: currentScenario, 
        persona: currentPersona, 
        conversationHistory: messages
      );
      messages.add({'role':'assistant','content':r});
    } catch (_) {
      messages.add({'role':'assistant','content':'Sorry, connection issue. Please try again.'});
    }
    isLoading = false; 
    notifyListeners();
  }

  Future<int> endSession() async {
    _timer?.cancel();
    final mins = (sessionSeconds / 60).ceil();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await DatabaseHelper.instance.insertSession({
      'scenario': currentScenario, 
      'tutor_persona': currentPersona,
      'chat_history': messages.toString(), 
      'duration_mins': mins, 
      'date': today,
    });
    return mins;
  }

  String get formattedTime {
    final m = sessionSeconds ~/ 60, s = sessionSeconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override 
  void dispose() { 
    _timer?.cancel(); 
    super.dispose(); 
  }
}
