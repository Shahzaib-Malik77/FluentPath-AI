import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/vocabulary_provider.dart';
import '../../core/widgets/background_scaffold.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VocabularyProvider>();
      provider.loadWords();
      provider.ensureDiscoverWordsLoaded();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabProvider = context.watch<VocabularyProvider>();

    return DefaultTabController(
      length: 2,
      child: BackgroundScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 4,
          shadowColor: Colors.black26,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Vocabulary Arena',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.brightGreen,
            indicatorWeight: 4,
            labelColor: AppColors.brightGreen,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.explore_rounded, size: 20),
                    const SizedBox(width: 8),
                    const Text('VOCAB WORDS'),
                    if (vocabProvider.discoverWords.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brightGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${vocabProvider.discoverWords.length}',
                          style: const TextStyle(color: AppColors.brightGreen, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bookmark_rounded, size: 20),
                    const SizedBox(width: 8),
                    const Text('SAVED LIBRARY'),
                    if (vocabProvider.totalWords > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${vocabProvider.totalWords}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Discover AI Words
            _buildDiscoverTab(context, vocabProvider),
            
            // Tab 2: Saved Library
            _buildSavedLibraryTab(context, vocabProvider),
          ],
        ),
        floatingActionButton: _tabController.index == 1
            ? FloatingActionButton(
                onPressed: () => _showAddWordDialog(context, vocabProvider),
                backgroundColor: AppColors.brightGreen,
                foregroundColor: AppColors.bgDarkGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.add_rounded, size: 28),
              )
            : null,
      ),
    );
  }

  // DISCOVER TAB BUILDER
  Widget _buildDiscoverTab(BuildContext context, VocabularyProvider provider) {
    if (provider.isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: AppColors.brightGreen,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Generating 10 premium vocabulary words...',
              style: AppTextStyles.body.copyWith(color: Colors.white70, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Curating definitions, pronunciations & examples...',
              style: AppTextStyles.caption.copyWith(color: Colors.white38),
            ),
          ],
        ),
      );
    }

    if (provider.discoverWords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              'No words generated yet.',
              style: AppTextStyles.body.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => provider.generateVocabularyBatch(),
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('Generate 10 Words', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightGreen,
                foregroundColor: AppColors.bgDarkGreen,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Top banner hint
        Container(
          width: double.infinity,
          color: Colors.black12,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.brightGreen, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap any word card to view real-life examples and usage tips!',
                  style: AppTextStyles.caption.copyWith(color: Colors.white60, fontSize: 11),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: provider.discoverWords.length + 1, // +1 for the load more button
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == provider.discoverWords.length) {
                // Return beautiful load new words button
                return Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.brightGreen, Color(0xFF81C784)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brightGreen.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => provider.generateVocabularyBatch(),
                      icon: const Icon(Icons.autorenew_rounded, size: 24),
                      label: const Text(
                        'Load 10 New Words',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                );
              }

              final item = provider.discoverWords[index];
              return _buildDiscoverCard(context, provider, item);
            },
          ),
        ),
      ],
    );
  }

  // SAVED LIBRARY TAB BUILDER
  Widget _buildSavedLibraryTab(BuildContext context, VocabularyProvider provider) {
    final filtered = provider.words.where((w) {
      final matchesSearch = w['word'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w['meaning'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Elegant Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgMedBrown,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500),
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

        // Subtitle showing count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${filtered.length} saved words',
                style: AppTextStyles.caption.copyWith(color: AppColors.brightGreen, fontWeight: FontWeight.bold),
              ),
              if (provider.masteredCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.streakAmber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.streakAmber.withOpacity(0.3)),
                  ),
                  child: Text(
                    '🎉 ${provider.masteredCount} Mastered',
                    style: const TextStyle(color: AppColors.streakAmber, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Core list of saved vocabulary words
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bookmark_outline_rounded, color: Colors.white24, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No matches found for "$_searchQuery"'
                            : 'No vocabulary words saved yet.',
                        style: AppTextStyles.caption.copyWith(color: Colors.white38),
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 14),
                        TextButton.icon(
                          onPressed: () => _tabController.animateTo(0),
                          icon: const Icon(Icons.explore_rounded, color: AppColors.brightGreen),
                          label: const Text(
                            'Explore AI Discover Tab',
                            style: TextStyle(color: AppColors.brightGreen, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildSavedCard(context, provider, item);
                  },
                ),
        ),
      ],
    );
  }

  // DISCOVER CARD BUILDER
  Widget _buildDiscoverCard(
    BuildContext context,
    VocabularyProvider provider,
    Map<String, String> item,
  ) {
    final bool isSaved = provider.isWordSaved(item['word']!);

    return GestureDetector(
      onTap: () => _showWordDetailSheet(context, provider, {
        'word': item['word']!,
        'phonetic': item['phonetic'] ?? '',
        'meaning': item['meaning']!,
        'example': item['example'] ?? '',
        'usage_tip': item['usage_tip'] ?? '',
        'category': 'AI Generated',
      }),
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
                        item['word']!,
                        style: AppTextStyles.bodyDark.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['meaning']!,
                    style: AppTextStyles.bodyDark.copyWith(
                      color: AppColors.textDark,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Example
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 12, fontStyle: FontStyle.italic, height: 1.3),
                        children: [
                          const TextSpan(text: 'Example: "', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: item['example']!),
                          const TextSpan(text: '"', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Save Button Action
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSaved)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_added_rounded,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark_add_outlined,
                      color: AppColors.primaryGreen,
                      size: 26,
                    ),
                    onPressed: () async {
                      final success = await provider.saveWord(item);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Saved "${item['word']}" to your Saved Library!'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'VIEW',
                              textColor: AppColors.brightGreen,
                              onPressed: () {
                                _tabController.animateTo(1);
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // SAVED CARD BUILDER
  Widget _buildSavedCard(
    BuildContext context,
    VocabularyProvider provider,
    Map<String, dynamic> item,
  ) {
    final bool mastered = item['status'] == 'mastered' || item['is_mastered'] == 1;

    return GestureDetector(
      onTap: () => _showWordDetailSheet(context, provider, item),
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
                          (item['category'] ?? 'General').toString(),
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
                    provider.toggleMastered(item['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          mastered ? 'Word marked as learning.' : 'Word marked as Mastered! 🎉',
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
                    provider.deleteWord(item['id']);
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

  // BOTTOM SHEET DETAILS
  void _showWordDetailSheet(
    BuildContext context,
    VocabularyProvider vocabProvider,
    Map<String, dynamic> item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgDarkGreen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['word'].toString(),
                        style: AppTextStyles.heading1.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 16),
                
                // Meaning
                Text(
                  'Meaning',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: Colors.white60),
                ),
                const SizedBox(height: 6),
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
                const SizedBox(height: 6),
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
                
                if (item['usage_tip'] != null && item['usage_tip'].toString().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Quick Usage Tip',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: Colors.white60),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['usage_tip'].toString(),
                    style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.white70, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ADD WORD MANUAL DIALOG
  void _showAddWordDialog(BuildContext context, VocabularyProvider vocabProvider) {
    final wordController = TextEditingController();
    final meaningController = TextEditingController();
    final exampleController = TextEditingController();
    String category = 'General';

    final List<String> categories = [
      'General',
      'Cafe Order',
      'Airport Check-in',
      'Hotel Reservation',
      'Job Interview',
      'Shopping Help',
      'Taxi Ride',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgDarkGreen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
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
                // Word Field
                const Text(
                  'Word',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: wordController,
                  style: const TextStyle(color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'e.g. Ephemeral',
                    hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                    filled: true,
                    fillColor: AppColors.bgMedBrown,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                
                // Meaning Field
                const Text(
                  'Meaning / Definition',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: meaningController,
                  style: const TextStyle(color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'e.g. Lasting for a very short time',
                    hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                    filled: true,
                    fillColor: AppColors.bgMedBrown,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                
                // Example Field
                const Text(
                  'Example Sentence',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: exampleController,
                  style: const TextStyle(color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'e.g. Fashions are ephemeral, but style is eternal.',
                    hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                    filled: true,
                    fillColor: AppColors.bgMedBrown,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                
                // Category Field
                const Text(
                  'Category',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  dropdownColor: AppColors.bgCream,
                  initialValue: category,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.bgMedBrown,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textDark),
                  items: categories
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
          ),
        );
      },
    );
  }
}
