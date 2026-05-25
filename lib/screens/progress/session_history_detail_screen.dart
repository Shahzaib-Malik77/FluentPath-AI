import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/background_scaffold.dart';

class SessionHistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> session;

  const SessionHistoryDetailScreen({
    super.key,
    required this.session,
  });

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[1]}/${parts[2]}/${parts[0]}';
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  List<dynamic> _parseChatLogs() {
    try {
      final String rawJson = session['chat_history'] ?? '[]';
      return jsonDecode(rawJson) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatLogs = _parseChatLogs();

    return BackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transcript Log',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Stats summary
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgMedBrown,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['scenario'] ?? 'Real-Life Scenario',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completed: ${_formatDate(session['date'] ?? '')}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    ),
                    Text(
                      'Practiced: ${session['duration_mins'] ?? 0} mins',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brightGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable messages list
          Expanded(
            child: chatLogs.isEmpty
                ? Center(
                    child: Text(
                      'No dialogue transcripts parsed.',
                      style: AppTextStyles.caption.copyWith(color: Colors.white30),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: chatLogs.length,
                    itemBuilder: (context, index) {
                      final msg = chatLogs[index];
                      final isUser = msg['role'] == 'user';
                      return _buildChatBubble(context, isUser, msg['content'] ?? '');
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, bool isUser, String text) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryGreen : AppColors.bgMedBrown,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Text(
          text,
          style: AppTextStyles.body.copyWith(
            color: isUser ? Colors.white : AppColors.textDark,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
