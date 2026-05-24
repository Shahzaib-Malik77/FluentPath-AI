import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/notes_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _category;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title'].toString());
    _contentController = TextEditingController(text: widget.note['content'].toString());
    _category = widget.note['category'].toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDarkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgDarkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Note',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          // Delete Note Icon Button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.bgMedBrown,
                  title: const Text('Delete this Note?', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                  content: const Text('Are you sure you want to permanently erase this study note?', style: TextStyle(color: AppColors.textMuted)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.primaryGreen)),
                    ),
                    TextButton(
                      onPressed: () async {
                        await notesProvider.deleteNote(widget.note['id']);
                        if (context.mounted) {
                          Navigator.pop(ctx); // Close Dialog
                          Navigator.pop(context); // Exit Details
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Note deleted.')),
                          );
                        }
                      },
                      child: const Text('Delete', style: TextStyle(color: AppColors.ctaRed)),
                    ),
                  ],
                ),
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
            // Note Category Pills Dropdown
            Text(
              'Topic Category',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.bgCream,
              initialValue: _category,
              decoration: InputDecoration(
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
                  setState(() => _category = val);
                }
              },
            ),
            const SizedBox(height: 20),

            // Note Title field
            Text(
              'Title',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textDark),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bgMedBrown,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter title...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 20),

            // Note Content field
            Text(
              'Note Contents',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: AppColors.textDark, height: 1.4),
              maxLines: 10,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bgMedBrown,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Write your notes or explanations here...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 32),

            // Save Changes button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final title = _titleController.text.trim();
                  final content = _contentController.text.trim();

                  if (title.isEmpty || content.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill out all fields.')),
                    );
                    return;
                  }

                  await notesProvider.updateNote(
                    widget.note['id'],
                    title,
                    content,
                    _category,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Updated "$title" successfully!'),
                        backgroundColor: AppColors.accentGreen,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ctaRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
