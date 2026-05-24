import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/notes_provider.dart';
import 'note_detail_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String isoString) {
    try {
      final parsed = DateTime.parse(isoString);
      // Format: MM/dd/yyyy
      final String month = parsed.month.toString().padLeft(2, '0');
      final String day = parsed.day.toString().padLeft(2, '0');
      final String year = parsed.year.toString();
      return '$month/$day/$year';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    
    // Perform local filtering based on _searchQuery
    final filteredNotes = notesProvider.notes.where((note) {
      final matchesTitle = note['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesContent = note['content'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = note['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTitle || matchesContent || matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDarkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgDarkGreen,
        elevation: 0,
        title: const Text(
          'Study Notes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real-time Search Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgMedBrown,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Search notes by title or content...',
                  hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.black45),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.black45),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
              ),
            ),
          ),

          // Count Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'You have ${filteredNotes.length} notes saved',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.brightGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Staggered Note Grid or List
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.note_alt_outlined, color: Colors.white24, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No study notes found.',
                          style: AppTextStyles.caption.copyWith(color: Colors.white38),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredNotes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = filteredNotes[index];
                      return _buildNoteCard(context, notesProvider, item);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context, notesProvider),
        backgroundColor: AppColors.brightGreen,
        foregroundColor: AppColors.bgDarkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    NotesProvider notesProvider,
    Map<String, dynamic> item,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteDetailScreen(note: item),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgMedBrown,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['category'].toString().toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Delete Note Icon
                GestureDetector(
                  onTap: () {
                    notesProvider.deleteNote(item['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Study note deleted.')),
                    );
                  },
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.black45, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              item['title'].toString(),
              style: AppTextStyles.bodyDark.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            // Description snippet
            Text(
              item['content'].toString(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            // Timestamp Footer (MM/dd/yyyy)
            Text(
              _formatDate(item['timestamp'].toString()),
              style: AppTextStyles.caption.copyWith(
                color: Colors.black38,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, NotesProvider notesProvider) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String category = 'Grammar';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Study Note',
                    style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: AppColors.bgMedBrown,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                style: const TextStyle(color: AppColors.textDark),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Write your notes or explanations here...',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: AppColors.bgMedBrown,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Category Choice Dropdown
              DropdownButtonFormField<String>(
                dropdownColor: AppColors.bgCream,
                initialValue: category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: AppColors.bgMedBrown,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: AppColors.textDark),
                items: const [
                  DropdownMenuItem(value: 'Grammar', child: Text('Grammar Rule', style: TextStyle(color: AppColors.textDark))),
                  DropdownMenuItem(value: 'Vocabulary', child: Text('Vocabulary Phrase', style: TextStyle(color: AppColors.textDark))),
                  DropdownMenuItem(value: 'Phonetics', child: Text('Phonetic Tip', style: TextStyle(color: AppColors.textDark))),
                  DropdownMenuItem(value: 'General', child: Text('General Concept', style: TextStyle(color: AppColors.textDark))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    category = val;
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final content = contentController.text.trim();
                    if (title.isEmpty || content.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill out all fields.')),
                      );
                      return;
                    }
                    
                    await notesProvider.addNote(
                      title,
                      content,
                      category,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Saved note: "$title"!'),
                          backgroundColor: AppColors.accentGreen,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightGreen,
                    foregroundColor: AppColors.bgDarkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Note', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
