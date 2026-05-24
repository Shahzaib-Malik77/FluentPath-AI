import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';

class NotesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notes = [];
  String _searchQuery = '';

  List<Map<String, dynamic>> get notes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes.where((n) =>
      (n['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (n['body'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Future<void> loadNotes() async { 
    _notes = await DatabaseHelper.instance.getNotes(); 
    notifyListeners(); 
  }
  
  void setSearch(String q) { 
    _searchQuery = q; 
    notifyListeners(); 
  }

  Future<int> addNote(String title, String body, String category) async {
    final now = DateTime.now().toIso8601String();
    final id = await DatabaseHelper.instance.insertNote({
      'title': title,
      'body': body,
      'category': category,
      'created_at': now,
      'updated_at': now
    });
    await loadNotes(); 
    return id;
  }

  Future<void> updateNote(int id, String title, String body, String category) async {
    await DatabaseHelper.instance.updateNote(id, {
      'title': title,
      'body': body,
      'category': category,
      'updated_at': DateTime.now().toIso8601String()
    });
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id); 
    await loadNotes();
  }
}
