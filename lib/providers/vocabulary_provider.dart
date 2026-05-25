import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';
import '../services/groq_service.dart';

class VocabularyProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _words = [];
  List<Map<String, String>> discoverWords = [];
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

  Future<void> ensureDiscoverWordsLoaded() async {
    if (discoverWords.isEmpty && !isGenerating) {
      await generateVocabularyBatch();
    }
  }

  Future<void> generateVocabularyBatch() async {
    isGenerating = true; 
    notifyListeners();
    try { 
      discoverWords = await GroqService.generateVocabularyBatch(); 
    } catch (_) { 
      discoverWords = [];
    }
    isGenerating = false; 
    notifyListeners();
  }

  bool isWordSaved(String word) {
    return _words.any((w) => w['word'].trim().toLowerCase() == word.trim().toLowerCase());
  }

  Future<bool> saveWord(Map<String, String> word) async {
    if (isWordSaved(word['word']!)) return false;
    final today = DateTime.now().toIso8601String().split('T')[0];
    await DatabaseHelper.instance.insertWord({
      'word': word['word']!, 
      'phonetic': word['phonetic'] ?? '',
      'meaning': word['meaning']!, 
      'example': word['example'] ?? '',
      'usage_tip': word['usage_tip'] ?? '', 
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
