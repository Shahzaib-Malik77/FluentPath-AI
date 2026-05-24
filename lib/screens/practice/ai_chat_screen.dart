import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../services/groq_service.dart';

class AIChatScreen extends StatefulWidget {
  final String scenarioTitle;
  final String systemPrompt;

  const AIChatScreen({
    super.key,
    required this.scenarioTitle,
    required this.systemPrompt,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Audio recording SpeechToText variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  
  // Active corrections / grammar feedback states
  String? _grammarCorrection;
  String? _vocabSuggestion;
  String? _correctionExplanation;

  // Active word explorer states
  String? _explorerWord;
  String? _explorerMeaning;
  String? _explorerExample;
  bool _isSavedToLibrary = false;
  ChatProvider? _chatProvider;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_chatProvider == null) {
      _chatProvider = context.read<ChatProvider>();
      _chatProvider!.addListener(_onChatProviderUpdate);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _chatProvider!.startSession(widget.scenarioTitle, widget.systemPrompt);
        _scrollToBottom();
      });
    }
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isRecording) {
              setState(() {
                _isRecording = false;
                _recordTimer?.cancel();
              });
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isRecording = false;
              _recordTimer?.cancel();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Speech Recognition error: ${error.errorMsg}'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
      );
      if (mounted) {
        setState(() {
          _speechAvailable = available;
        });
      }
    } catch (_) {
      // Ignore initialization errors on platforms without stt support
    }
  }

  @override
  void dispose() {
    _chatProvider?.removeListener(_onChatProviderUpdate);
    _messageController.dispose();
    _scrollController.dispose();
    _recordTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  void _onChatProviderUpdate() {
    if (!mounted) return;
    final provider = _chatProvider;
    if (provider != null) {
      if (provider.messages.isNotEmpty && !provider.isLoading) {
        final lastMsg = provider.messages.last;
        if (lastMsg['role'] == 'assistant') {
          _parseAndSetExplorerWord(lastMsg['content'] ?? '');
        }
      }
    }
    _scrollToBottom();
  }

  void _parseAndSetExplorerWord(String aiReply) {
    final reg = RegExp(
      r'📖\s*Word Explorer:\s*([^|]+)\|\s*Meaning:\s*([^|]+)\|\s*Example:\s*(.+)',
      caseSensitive: false,
    );
    final match = reg.firstMatch(aiReply);
    if (match != null) {
      final word = match.group(1)?.replaceAll('*', '').trim() ?? '';
      final meaning = match.group(2)?.replaceAll('*', '').trim() ?? '';
      final example = match.group(3)?.replaceAll('*', '').trim() ?? '';
      
      if (word.isNotEmpty && meaning.isNotEmpty) {
        if (_explorerWord == word) return;
        setState(() {
          _explorerWord = word;
          _explorerMeaning = meaning;
          _explorerExample = example;
          _isSavedToLibrary = false;
        });
        _scrollToBottom();
        return;
      }
    }
    if (_explorerWord != null) {
      setState(() {
        _explorerWord = null;
        _explorerMeaning = null;
        _explorerExample = null;
        _isSavedToLibrary = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  // Real voice recording and transcription using SpeechToText
  void _toggleRecording() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    if (_isRecording) {
      _recordTimer?.cancel();
      await _speech.stop();
      setState(() => _isRecording = false);
    } else {
      if (!_speechAvailable) {
        await _initSpeech();
      }
      
      if (_speechAvailable) {
        setState(() {
          _isRecording = true;
          _recordSeconds = 0;
        });
        
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() => _recordSeconds++);
          }
        });

        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _messageController.text = result.recognizedWords;
              });
            }
          },
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Speech Recognition not available or permission denied.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    }
  }

  Future<void> _analyzeGrammar(String text) async {
    try {
      final feedback = await GroqService.analyzeUserGrammar(text);
      if (mounted && feedback['has_errors'] == true) {
        setState(() {
          _grammarCorrection = feedback['correction'];
          _vocabSuggestion = feedback['vocab_suggestion'];
          _correctionExplanation = feedback['explanation'];
        });
        _scrollToBottom();
      } else {
        setState(() {
          _grammarCorrection = null;
          _vocabSuggestion = null;
          _correctionExplanation = null;
        });
        _scrollToBottom();
      }
    } catch (_) {
      // Quietly ignore network analyzer errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final userProvider = context.watch<UserProvider>();
    final streakProvider = context.watch<StreakProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDarkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgDarkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            // Confirm exit
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.bgMedBrown,
                title: const Text('Exit Session?', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                content: const Text('Your current practice progress will not be saved.', style: TextStyle(color: AppColors.textMuted)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text('Exit', style: TextStyle(color: AppColors.ctaRed, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Column(
          children: [
            Text(
              widget.scenarioTitle,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.streakMint, size: 12),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(chatProvider.durationSeconds),
                  style: const TextStyle(color: AppColors.streakMint, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final duration = chatProvider.durationSeconds;
              
              // End Session
              await chatProvider.endSession();

              // Add Streaks & XP (+20 XP)
              await streakProvider.addXP(20);
              await userProvider.addXP(20);

              if (!context.mounted) return;

              // Celebration Dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.bgMedBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Center(
                    child: Text('🎉 Practice Completed!', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        '⚡ +20 XP',
                        style: TextStyle(
                          color: AppColors.brightGreen,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Well done! You practiced conversational English for ${_formatDuration(duration)}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted, height: 1.4),
                      ),
                    ],
                  ),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx); // Close Dialog
                          navigator.pop(); // Exit Chat Screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'Finish',
              style: TextStyle(
                color: AppColors.brightGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat bubble listing
            Expanded(
              child: chatProvider.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.brightGreen),
                          const SizedBox(height: 16),
                          Text(
                            'AI Tutor is preparing scenario...',
                            style: AppTextStyles.caption.copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final msg = chatProvider.messages[index];
                        final isUser = msg['role'] == 'user';
                        return _buildChatBubble(isUser, msg['content'] ?? '');
                      },
                    ),
            ),

            // Live Grammar & Vocabulary Feedback Box (active when there is a grammar correction OR a difficult word explorer)
            if ((_grammarCorrection != null && _grammarCorrection!.isNotEmpty) || _explorerWord != null)
              _buildGrammarFeedback(),

            // Chat typing / recording action bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgMedBrown,
                border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Audio Simulation Soundwave overlay when recording
                  if (_isRecording)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            'Recording Audio... ${_formatDuration(_recordSeconds)}',
                            style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 14),
                          // Simulated wave bars
                          ...List.generate(
                            5,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 3,
                              height: 12.0 + (index * 4) * (index % 2 == 0 ? 1 : 0.5),
                              decoration: BoxDecoration(
                                color: AppColors.brightGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      // Audio simulation mic button
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isRecording ? AppColors.ctaRed : AppColors.bgDarkGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text input field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.bgDarkGreen,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: InputBorder.none,
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(chatProvider),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Send Icon
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.brightGreen),
                        onPressed: () => _sendMessage(chatProvider),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(bool isUser, String text) {
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(0),
            ),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          ),
          child: SelectableText(
            text,
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // AI message parsing
    String mainText = text;
    String? correctionText;
    String? vocabBoostText;

    // Detect and parse Correction block
    final correctionReg = RegExp(
      r'(💡\s*(?:Correction|Quick Learning Tip):?)([\s\S]*?)(?=🚀|$)',
      caseSensitive: false,
    );
    final correctionMatch = correctionReg.firstMatch(text);
    if (correctionMatch != null) {
      correctionText = correctionMatch.group(2)?.trim();
      mainText = mainText.replaceAll(correctionMatch.group(0)!, '');
    }

    // Detect and parse Vocabulary Boost block
    final vocabReg = RegExp(
      r'(🚀\s*(?:Vocabulary Boost|Smart Alternative|Smart Tip):?)([\s\S]*?)(?=💡|$)',
      caseSensitive: false,
    );
    final vocabMatch = vocabReg.firstMatch(text);
    if (vocabMatch != null) {
      vocabBoostText = vocabMatch.group(2)?.trim();
      mainText = mainText.replaceAll(vocabMatch.group(0)!, '');
    }

    // Double check to clean up any leftover tags/labels in mainText
    mainText = mainText
        .replaceAll(RegExp(r'💡\s*(?:Correction|Quick Learning Tip):?.*', caseSensitive: false), '')
        .replaceAll(RegExp(r'🚀\s*(?:Vocabulary Boost|Smart Alternative|Smart Tip):?.*', caseSensitive: false), '')
        .replaceAll(RegExp(r'📖\s*(?:Word Explorer):?.*', caseSensitive: false), '');

    // Cleanup asterisks/markdown styling to present plain text cleanly
    String cleanText(String t) {
      return t.replaceAll('*', '').replaceAll('~~', '').trim();
    }

    final cleanMain = cleanText(mainText);
    final cleanCorrection = correctionText != null ? cleanText(correctionText) : '';
    final cleanVocab = vocabBoostText != null ? cleanText(vocabBoostText) : '';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: AppColors.bgMedBrown,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header instruction
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '✨ AI Learning Assistant',
                  style: TextStyle(
                    color: AppColors.primaryGreen.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Merienda',
                  ),
                ),
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryGreen,
                  size: 11,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Selectable message words (Main reply)
            SelectableText(
              cleanMain,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textDark,
                height: 1.4,
                fontSize: 14,
              ),
            ),

            // If there's a correction, display in a gorgeous premium custom box
            if (cleanCorrection.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F2), // Elegant soft red/beige
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF8B4B4), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.spellcheck_rounded, color: Color(0xFFC53030), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Correction & Explanation',
                          style: TextStyle(
                            color: const Color(0xFF9B2C2C),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Merienda',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cleanCorrection,
                      style: const TextStyle(
                        color: Color(0xFF742A2A),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // If there's a vocabulary boost, display in a gorgeous premium custom box
            if (cleanVocab.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), // Soft mint green
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.rocket_launch_rounded, color: Color(0xFF16A34A), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Vocabulary Boost',
                          style: TextStyle(
                            color: const Color(0xFF15803D),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Merienda',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cleanVocab,
                      style: const TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrammarFeedback() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBE7), // Light green-beige accent
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brightGreen.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Live Grammar Feedback',
                style: AppTextStyles.bodyDark.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                  fontFamily: 'Merienda',
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _grammarCorrection = null;
                    _vocabSuggestion = null;
                    _correctionExplanation = null;
                    _explorerWord = null;
                    _explorerMeaning = null;
                    _explorerExample = null;
                  });
                  _scrollToBottom();
                },
                child: const Icon(Icons.close_rounded, color: Colors.black54, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Render Grammar Correction if present
          if (_grammarCorrection != null) ...[
            Text(
              'Recommended correction:',
              style: AppTextStyles.caption.copyWith(color: Colors.black54, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              _grammarCorrection!,
              style: AppTextStyles.bodyDark.copyWith(color: AppColors.ctaRed, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
          if (_vocabSuggestion != null) ...[
            const SizedBox(height: 10),
            Text(
              'Vocabulary suggestion:',
              style: AppTextStyles.caption.copyWith(color: Colors.black54, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              _vocabSuggestion!,
              style: AppTextStyles.bodyDark.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
          if (_correctionExplanation != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _correctionExplanation!,
                style: AppTextStyles.caption.copyWith(color: Colors.black87, height: 1.4, fontSize: 11),
              ),
            ),
          ],

          // Divider if both are present
          if ((_grammarCorrection != null || _vocabSuggestion != null) && _explorerWord != null) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.black12, height: 1),
            const SizedBox(height: 12),
          ],

          // 2. Render Vocabulary Explorer (Difficult word from AI response) if present
          if (_explorerWord != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _explorerWord!,
                  style: const TextStyle(
                    color: AppColors.bgDarkGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '• AI Tutor taught a key word',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Meaning
            Text(
              'Meaning:',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.bgDarkGreen.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _explorerMeaning!,
              style: const TextStyle(color: AppColors.bgDarkGreen, fontSize: 13, height: 1.4),
            ),
            
            // Example
            if (_explorerExample != null && _explorerExample!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Example Sentence:',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.bgDarkGreen.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '"$_explorerExample"',
                style: const TextStyle(
                  color: AppColors.bgDarkGreen,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
            
            const SizedBox(height: 14),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSavedToLibrary
                    ? null
                    : () async {
                        setState(() => _isSavedToLibrary = true);
                        final vocabProvider = context.read<VocabularyProvider>();
                        await vocabProvider.addWord(
                          word: _explorerWord!,
                          meaning: _explorerMeaning!,
                          example: _explorerExample ?? 'Learned in AI Chat practice.',
                          category: widget.scenarioTitle,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saved "$_explorerWord" to your Vocabulary Library!'),
                              backgroundColor: AppColors.primaryGreen,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSavedToLibrary ? AppColors.accentGreen : AppColors.primaryGreen,
                  disabledBackgroundColor: AppColors.primaryGreen.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: Icon(
                  _isSavedToLibrary ? Icons.check_circle_outline_rounded : Icons.bookmark_add_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  _isSavedToLibrary ? 'Saved to Vocabulary Library' : 'Save Word to Library',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage(ChatProvider chatProvider) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _scrollToBottom();

    // Trigger local AI grammar analyzer in the background
    _analyzeGrammar(text);

    // Send Message via state provider
    await chatProvider.sendMessage(text);
    _scrollToBottom();
  }
}
