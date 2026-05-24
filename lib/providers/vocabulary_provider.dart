import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';
import '../services/groq_service.dart';

class VocabularyProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _words = [];
  Map<String, String>? currentWord;
  bool isGenerating = false;
  String filterStatus = 'all';

  List<Map<String, dynamic>> get words =>
    filterStatus == 'all' ? _words : _words.where((w) => w['status'] == filterStatus).toList();
  int get totalWords    => _words.length;
  int get masteredCount => _words.where((w) => w['status'] == 'mastered').length;

  Future<void> loadWords() async {
    _words = await DatabaseHelper.instance.getWords();
    notifyListeners();
  }

  Future<void> generateNewWord() async {
    isGenerating = true; 
    notifyListeners();
    try { 
      currentWord = await GroqService.generateVocabularyWord(); 
    } catch (_) { 
      currentWord = {
        'word':'Resilience',
        'phonetic':'/rɪˈzɪlɪəns/',
        'meaning':'Ability to recover from difficulties.',
        'example':'Her resilience helped her overcome challenges.',
        'usage_tip':'Use when describing strength after hardship.'
      }; 
    }
    isGenerating = false; 
    notifyListeners();
  }

  Future<bool> saveCurrentWord() async {
    if (currentWord == null) return false;
    final today = DateTime.now().toIso8601String().split('T')[0];
    await DatabaseHelper.instance.insertWord({
      'word': currentWord!['word']!, 
      'phonetic': currentWord!['phonetic'] ?? '',
      'meaning': currentWord!['meaning']!, 
      'example': currentWord!['example'] ?? '',
      'usage_tip': currentWord!['usage_tip'] ?? '', 
      'status': 'learning', 
      'date_added': today,
    });
    await loadWords(); 
    return true;
  }

  Future<void> markMastered(int id) async {
    await DatabaseHelper.instance.updateWordStatus(id, 'mastered');
    await loadWords();
  }

  Future<void> toggleMastered(int id) async {
    final word = _words.firstWhere((w) => w['id'] == id);
    final newStatus = word['status'] == 'mastered' ? 'learning' : 'mastered';
    await DatabaseHelper.instance.updateWordStatus(id, newStatus);
    await loadWords();
  }

  Future<void> deleteWord(int id) async {
    await DatabaseHelper.instance.deleteWord(id);
    await loadWords();
  }

  Future<void> addWord({
    required String word,
    required String meaning,
    required String example,
    required String category,
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await DatabaseHelper.instance.insertWord({
      'word': word,
      'phonetic': '',
      'meaning': meaning,
      'example': example,
      'usage_tip': '',
      'category': category,
      'status': 'learning',
      'date_added': today,
    });
    await loadWords();
  }

  void setFilter(String status) { 
    filterStatus = status; 
    notifyListeners(); 
  }
}
