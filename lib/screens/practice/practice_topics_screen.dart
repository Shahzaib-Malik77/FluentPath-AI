import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/user_provider.dart';
import 'ai_chat_screen.dart';

class PracticeTopicsScreen extends StatelessWidget {
  const PracticeTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final List<Map<String, dynamic>> presets = [
      {
        'title': 'Cafe Order',
        'difficulty': 'Beginner',
        'diffColor': AppColors.accentGreen,
        'description': 'Practice ordering drinks and snacks from a London coffee shop barista.',
        'icon': Icons.coffee_rounded,
        'bg': const Color(0xFF3E2723),
        'prompt': 'You are a warm, polite barista at a bustling London cafe named Coffee Haven. Speak British English. The user is a customer ordering coffee and food. Help them select items, ask for milk/sugar preferences, and complete their order. Keep responses conversational, concise, and under 3 sentences. Do not write transcripts or user replies.',
      },
      {
        'title': 'Job Interview',
        'difficulty': 'Advanced',
        'diffColor': AppColors.ctaRed,
        'description': 'Simulate a formal HR job interview in English for a tech company role.',
        'icon': Icons.work_outline_rounded,
        'bg': const Color(0xFF1E3C72),
        'prompt': 'You are an HR Manager conducting a professional job interview at a global tech company. Ask structured questions regarding experience, handling challenges, and career goals. Let the user answer each question before introducing the next. Keep answers professional, encouraging, and under 3 sentences.',
      },
      {
        'title': 'Airport Check-in',
        'difficulty': 'Beginner',
        'diffColor': AppColors.accentGreen,
        'description': 'Talk to airport desk staff to check your bags and print your ticket.',
        'icon': Icons.flight_takeoff_rounded,
        'bg': const Color(0xFF00796B),
        'prompt': 'You are an airport check-in desk agent for Global Airways at JFK Airport. Help the user check in for their flight, verify their baggage weight, ask for passport details, and issue their boarding pass. Keep answers clear, polite, and under 3 sentences.',
      },
      {
        'title': 'Hotel Reservation',
        'difficulty': 'Intermediate',
        'diffColor': const Color(0xFFB25E00),
        'description': 'Interact with a hotel receptionist to check in or book an extra night.',
        'icon': Icons.hotel_rounded,
        'bg': const Color(0xFF512DA8),
        'prompt': 'You are a hotel front-desk receptionist at the Grand Royal Hotel. Help the user check in, explain hotel amenities (Wi-Fi, breakfast hours), and handle any booking updates. Keep answers highly welcoming, polite, and under 3 sentences.',
      },
      {
        'title': 'Shopping Help',
        'difficulty': 'Intermediate',
        'diffColor': const Color(0xFFB25E00),
        'description': 'Ask a retail shop assistant for product locations or refunds.',
        'icon': Icons.shopping_bag_outlined,
        'bg': const Color(0xFFC2185B),
        'prompt': 'You are a helpful retail sales assistant at a modern clothing department store. Help the user find sizes, explain active discounts, and direct them to changing rooms. Keep answers warm, friendly, and under 3 sentences.',
      },
      {
        'title': 'Taxi Ride',
        'difficulty': 'Beginner',
        'diffColor': AppColors.accentGreen,
        'description': 'Give directions to a local taxi driver to get to your destination safely.',
        'icon': Icons.local_taxi_rounded,
        'bg': const Color(0xFFF57C00),
        'prompt': 'You are a friendly city taxi driver. Ask the user for their destination, suggest routes, make light small talk about the city, and help them with baggage. Keep answers warm, conversational, and under 3 sentences.',
      },
    ];

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
          'AI Practice Hub',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header User Info Banner
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.accentGreen.withOpacity(0.2),
                  child: Text(
                    userProvider.avatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'English Practice Lounge',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.brightGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Select a roleplay scenario below to speak with AI',
                        style: AppTextStyles.caption.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Custom scenario launch card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgMedBrown,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.brightGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology_rounded, color: AppColors.brightGreen, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Have a custom topic?',
                          style: AppTextStyles.bodyDark.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Describe any custom scenario for the AI',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _showCustomScenarioDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brightGreen,
                      foregroundColor: AppColors.bgDarkGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Create',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Presets grid list
            Text(
              'Available Scenarios',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: presets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = presets[index];
                return _buildTopicCard(context, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgMedBrown,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circle Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.streakMint.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'], color: AppColors.streakMint, size: 28),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title'],
                              style: AppTextStyles.bodyDark.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item['diffColor'].withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: item['diffColor'].withOpacity(0.5), width: 1),
                            ),
                            child: Text(
                              item['difficulty'],
                              style: AppTextStyles.caption.copyWith(
                                color: item['diffColor'],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['description'],
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AIChatScreen(
                                  scenarioTitle: item['title'],
                                  systemPrompt: item['prompt'],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Start Scenario',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomScenarioDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

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
                    'Custom Scenario Builder',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Design your own immersive practice scene. Specify a topic title and details of who the AI should pretend to be.',
                style: AppTextStyles.caption.copyWith(color: Colors.white60),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  labelText: 'Scenario Title (e.g. Asking Directions)',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.bgMedBrown,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.title_rounded, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descController,
                style: const TextStyle(color: AppColors.textDark),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Who is the AI? (e.g. A police officer in Boston)',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.bgMedBrown,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.description_outlined, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final desc = descController.text.trim();
                    if (title.isEmpty || desc.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill out all fields.')),
                      );
                      return;
                    }
                    Navigator.pop(context); // Close sheet

                    final customPrompt =
                        'You are an AI character practicing English with the user. Your role: $desc. Keep answers engaging, natural, conversational, and under 3 sentences. Assist the user with correct speaking patterns and prompt them politely when needed.';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AIChatScreen(
                          scenarioTitle: title,
                          systemPrompt: customPrompt,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightGreen,
                    foregroundColor: AppColors.bgDarkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Launch Custom Scenario',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
