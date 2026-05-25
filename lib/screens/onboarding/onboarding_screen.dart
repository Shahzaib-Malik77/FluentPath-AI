import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/database/database_helper.dart';
import '../../providers/user_provider.dart';
import '../main_screen.dart';
import '../../core/widgets/background_scaffold.dart';

import '../../core/widgets/app_avatar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  int _selectedAvatar = 0;
  String? _customAvatarBase64;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'AI-Powered Conversations',
      'subtitle': 'Practice speaking with dynamic AI tutors in realistic scenarios like cafes, airport lounges, or interviews.',
      'icon': Icons.forum_rounded,
      'gradient': [Colors.teal, Colors.green],
    },
    {
      'title': 'Interactive Grammars & Quizzes',
      'subtitle': 'Improve grammar rules, try challenging AI generated quizzes and unlock rewarding milestone badges.',
      'icon': Icons.auto_awesome_rounded,
      'gradient': [Colors.indigo, Colors.blue],
    },
    {
      'title': 'Personalize Your Profile',
      'subtitle': 'Enter your details below to setup your FluentPath profile and initialize your AI learning adventure.',
      'icon': Icons.face_rounded,
      'gradient': [const Color(0xFF8CD3A5), const Color(0xFF1E4627)],
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: AppColors.wrong,
        ),
      );
      return;
    }

    final db = DatabaseHelper.instance;
    await db.insertUser({
      'name': name,
      'avatar_index': _selectedAvatar,
      'level': 'Beginner',
      'total_xp': 0,
      'daily_goal_mins': 15,
      'selected_tutor': 'Friendly Buddy',
      'created_at': DateTime.now().toIso8601String(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboarded', true);
    if (_customAvatarBase64 != null) {
      await prefs.setString('custom_avatar_base64', _customAvatarBase64!);
    } else {
      await prefs.remove('custom_avatar_base64');
    }

    if (mounted) {
      await context.read<UserProvider>().loadUser();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  Future<void> _pickCustomAvatar() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _customAvatarBase64 = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.wrong,
          ),
        );
      }
    }
  }

  Widget _buildAvatarWidget(int index, bool isSelected) {
    return AppAvatar(
      avatarIndex: index,
      size: 54,
      isSelected: isSelected && _customAvatarBase64 == null,
      onTap: () => setState(() {
        _selectedAvatar = index;
        _customAvatarBase64 = null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return BackgroundScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top page tracker
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FluentPath AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Merienda',
                    ),
                  ),
                  if (_currentPage == 2)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '3/3',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Central illustration & description slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: 3,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  final isLast = index == 2;
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!keyboardOpen) ...[
                          const SizedBox(height: 30),
                           // Premium styled illustration using containers/icons
                           isLast
                               ? Padding(
                                   padding: const EdgeInsets.only(top: 10),
                                   child: GestureDetector(
                                     onTap: _pickCustomAvatar,
                                     child: Stack(
                                       alignment: Alignment.center,
                                       children: [
                                         AppAvatar(
                                           avatarIndex: _selectedAvatar,
                                           customAvatarBase64: _customAvatarBase64,
                                           size: 130,
                                         ),
                                         Positioned(
                                           bottom: 0,
                                           right: 0,
                                           child: Container(
                                             padding: const EdgeInsets.all(8),
                                             decoration: const BoxDecoration(
                                               color: AppColors.brightGreen,
                                               shape: BoxShape.circle,
                                             ),
                                             child: const Icon(
                                               Icons.camera_alt_rounded,
                                               color: Colors.white,
                                               size: 18,
                                             ),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 )
                               : Container(
                                   width: 140,
                                   height: 140,
                                   decoration: BoxDecoration(
                                     shape: BoxShape.circle,
                                     gradient: LinearGradient(
                                       colors: data['gradient'],
                                       begin: Alignment.topLeft,
                                       end: Alignment.bottomRight,
                                     ),
                                     boxShadow: [
                                       BoxShadow(
                                         color: (data['gradient'] as List<Color>)[0].withOpacity(0.4),
                                         blurRadius: 24,
                                         spreadRadius: 2,
                                       ),
                                     ],
                                   ),
                                   child: Icon(
                                     data['icon'],
                                     size: 70,
                                     color: Colors.white,
                                   ),
                                 ),
                           const SizedBox(height: 40),
                        ],
                        Text(
                          data['title'],
                          style: AppTextStyles.heading1.copyWith(fontSize: 24),
                          textAlign: CenterAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data['subtitle'],
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white.withOpacity(0.65),
                            height: 1.6,
                          ),
                          textAlign: CenterAlign.center,
                        ),
                        if (isLast) ...[
                          const SizedBox(height: 32),
                          // Name Input
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Enter your name',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.12),
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textBeige),
                              hintText: 'e.g. John Doe',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.accentGreen, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Pick Avatar
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 12),
                              child: Text(
                                'Pick your avatar',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                8,
                                (idx) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: _buildAvatarWidget(idx, _selectedAvatar == idx),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Action bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot Indicator
                  Row(
                    children: List.generate(
                      3,
                      (idx) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == idx 
                            ? Colors.white 
                            : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next / Get Started Button
                  if (_currentPage < 2)
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ctaBrown,
                        foregroundColor: AppColors.primaryGreen,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Next  ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: ElevatedButton(
                          onPressed: _submitOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ctaBrown,
                            foregroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            'Get Started  →',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CenterAlign placeholder class
class CenterAlign {
  static const center = TextAlign.center;
}
