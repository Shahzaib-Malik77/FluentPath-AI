import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/vocabulary_provider.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  
  final List<String> _categories = [
    'All',
    'General',
    'Cafe Order',
    'Airport Check-in',
    'Hotel Reservation',
    'Job Interview',
    'Shopping Help',
    'Taxi Ride',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VocabularyProvider>().loadWords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabProvider = context.watch<VocabularyProvider>();
    
    // Perform searching & category filtering
    final filtered = vocabProvider.words.where((w) {
      final matchesSearch = w['word'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w['meaning'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || w['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

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
          'Vocabulary Library',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Search Bar
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
                  hintText: 'Search words or meanings...',
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

          // Horizontal Category slider
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textMuted,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                    selectedColor: AppColors.primaryGreen,
                    backgroundColor: AppColors.bgMedBrown,
                    elevation: isSelected ? 2 : 0,
                    pressElevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),

          // Subtitle showing count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Showing ${filtered.length} words',
              style: AppTextStyles.caption.copyWith(color: AppColors.brightGreen, fontWeight: FontWeight.bold),
            ),
          ),

          // Core grid/list of vocabulary words
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book_rounded, color: Colors.white24, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No vocabulary words saved yet.',
                          style: AppTextStyles.caption.copyWith(color: Colors.white38),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildVocabCard(context, vocabProvider, item);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWordDialog(context, vocabProvider),
        backgroundColor: AppColors.brightGreen,
        foregroundColor: AppColors.bgDarkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildVocabCard(
    BuildContext context,
    VocabularyProvider vocabProvider,
    Map<String, dynamic> item,
  ) {
    final bool mastered = item['is_mastered'] == 1;

    return GestureDetector(
      onTap: () => _showWordDetailSheet(context, vocabProvider, item),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgLightBeige,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item['word'].toString(),
                        style: AppTextStyles.bodyDark.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Category pill label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['category'].toString(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['meaning'].toString(),
                    style: AppTextStyles.bodyDark.copyWith(
                      color: AppColors.textDark,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Example: "${item['example']}"',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                // Star Bookmark Icon
                IconButton(
                  icon: Icon(
                    mastered ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: mastered ? AppColors.streakAmber : Colors.black26,
                  ),
                  onPressed: () {
                    vocabProvider.toggleMastered(item['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          mastered ? 'Word marked as active learning.' : 'Word marked as Mastered! 🎉',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                // Trash icon
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.black26),
                  onPressed: () {
                    vocabProvider.deleteWord(item['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Word deleted from library.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWordDetailSheet(
    BuildContext context,
    VocabularyProvider vocabProvider,
    Map<String, dynamic> item,
  ) {
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
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['word'].toString().toUpperCase(),
                        style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Phonetic pronunciation helper & Speak button simulation
                  Row(
                    children: [
                      Text(
                        '/ ${item['word'].toString().toLowerCase()} /',
                        style: const TextStyle(color: AppColors.brightGreen, fontStyle: FontStyle.italic, fontSize: 15),
                      ),
                      const SizedBox(width: 14),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: AppColors.brightGreen),
                        onPressed: () {
                          // Simulate TTS voice feedback action
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🔊 Pronunciation audio: "${item['word']}" played successfully!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  
                  // Meaning
                  Text(
                    'Meaning',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: Colors.white60),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['meaning'].toString(),
                    style: AppTextStyles.body.copyWith(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // Example
                  Text(
                    'Example Usage',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: Colors.white60),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"${item['example']}"',
                      style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic, fontSize: 13, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Synonyms
                  Text(
                    'AI Synonyms Helper',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: Colors.white60),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildSynonymPill('excellent'),
                      const SizedBox(width: 8),
                      _buildSynonymPill('superb'),
                      const SizedBox(width: 8),
                      _buildSynonymPill('outstanding'),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSynonymPill(String word) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brightGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brightGreen.withOpacity(0.3)),
      ),
      child: Text(
        word,
        style: const TextStyle(color: AppColors.brightGreen, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showAddWordDialog(BuildContext context, VocabularyProvider vocabProvider) {
    final wordController = TextEditingController();
    final meaningController = TextEditingController();
    final exampleController = TextEditingController();
    String category = 'General';

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
                    'Add New Word',
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
                controller: wordController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  labelText: 'Word',
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
                controller: meaningController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  labelText: 'Meaning / Definition',
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
                controller: exampleController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  labelText: 'Example Sentence',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: AppColors.bgMedBrown,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                items: _categories
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: AppColors.textDark))))
                    .toList(),
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
                    final word = wordController.text.trim();
                    final meaning = meaningController.text.trim();
                    final example = exampleController.text.trim();
                    if (word.isEmpty || meaning.isEmpty || example.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill out all fields.')),
                      );
                      return;
                    }
                    
                    await vocabProvider.addWord(
                      word: word,
                      meaning: meaning,
                      example: example,
                      category: category,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Saved "$word"!'),
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
                  child: const Text('Save Word', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
