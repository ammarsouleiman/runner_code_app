import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class OpenChatScreen extends StatefulWidget {
  const OpenChatScreen({super.key});

  @override
  State<OpenChatScreen> createState() => _OpenChatScreenState();
}

class _OpenChatScreenState extends State<OpenChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;
  Timer? _timeUpdateTimer;

  // Voice recognition
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  late AnimationController _voiceAnimationController;
  late Animation<double> _voiceAnimation;

  // Auto language detection
  String _detectedLanguage = 'en_US';

  static const String _apiKey = 'AIzaSyDBjozxc_umny0CrY4Ho_0sxWRu63EuNg8';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // SharedPreferences key for saving messages
  static const String _messagesKey = 'openchat_messages';

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _typingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );

    _voiceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _voiceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _voiceAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadMessages();
    _initSpeech();

    // Start timer to update timestamps every second for more accurate counting
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild and update all timestamps every second
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    _voiceAnimationController.dispose();
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Detect language from user message
    _detectedLanguage = _detectLanguage(userMessage);

    setState(() {
      _messages.add(
        ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _scrollToBottom();
    await _saveMessages(); // Save after user message

    try {
      final response = await _sendToGemini(userMessage);

      setState(() {
        _messages.add(
          ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Sorry, I encountered an error. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
    await _saveMessages(); // Save after AI response
  }

  Future<String> _sendToGemini(String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': message,
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1000,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] != null && 
          data['candidates'].isNotEmpty && 
          data['candidates'][0]['content'] != null &&
          data['candidates'][0]['content']['parts'] != null &&
          data['candidates'][0]['content']['parts'].isNotEmpty) {
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response received';
      } else {
        return 'No response received';
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to get response: ${response.statusCode} - ${errorData['error']?['message'] ?? response.body}');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getStringList(_messagesKey) ?? [];

      if (messagesJson.isEmpty) {
        // Don't add any message - we'll show the welcome screen
        setState(() {});
      } else {
        // Load saved messages
        for (final messageJson in messagesJson) {
          final messageData = jsonDecode(messageJson);
          _messages.add(
            ChatMessage(
              text: messageData['text'],
              isUser: messageData['isUser'],
              timestamp: DateTime.parse(messageData['timestamp']),
            ),
          );
        }
        setState(() {});
      }
    } catch (e) {
      // If error loading, show welcome screen
      setState(() {});
    }
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages
          .map(
            (message) => jsonEncode({
              'text': message.text,
              'isUser': message.isUser,
              'timestamp': message.timestamp.toIso8601String(),
            }),
          )
          .toList();

      await prefs.setStringList(_messagesKey, messagesJson);
    } catch (e) {
      // Handle save error silently
    }
  }

  Future<void> _clearMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_messagesKey);

      setState(() {
        _messages.clear();
        // Don't add any message - this will show the welcome screen
      });
    } catch (e) {
      // Handle clear error silently
    }
  }

  // Language detection method
  String _detectLanguage(String text) {
    // Simple language detection based on character sets
    if (RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    ).hasMatch(text)) {
      return 'ar_SA'; // Arabic
    } else if (RegExp(
      r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]',
    ).hasMatch(text)) {
      return 'ja_JP'; // Japanese
    } else if (RegExp(r'[\uAC00-\uD7AF]').hasMatch(text)) {
      return 'ko_KR'; // Korean
    } else if (RegExp(r'[\u4E00-\u9FAF]').hasMatch(text)) {
      return 'zh_CN'; // Chinese
    } else if (RegExp(r'[\u0E00-\u0E7F]').hasMatch(text)) {
      return 'th_TH'; // Thai
    } else if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      return 'hi_IN'; // Hindi
    } else if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) {
      return 'bn_BD'; // Bengali
    } else if (RegExp(r'[\u0A00-\u0A7F]').hasMatch(text)) {
      return 'pa_IN'; // Punjabi
    } else if (RegExp(r'[\u0A80-\u0AFF]').hasMatch(text)) {
      return 'gu_IN'; // Gujarati
    } else if (RegExp(r'[\u0B00-\u0B7F]').hasMatch(text)) {
      return 'or_IN'; // Odia
    } else if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(text)) {
      return 'ta_IN'; // Tamil
    } else if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(text)) {
      return 'te_IN'; // Telugu
    } else if (RegExp(r'[\u0C80-\u0CFF]').hasMatch(text)) {
      return 'kn_IN'; // Kannada
    } else if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(text)) {
      return 'ml_IN'; // Malayalam
    } else if (RegExp(r'[\u0D80-\u0DFF]').hasMatch(text)) {
      return 'si_LK'; // Sinhala
    } else if (RegExp(r'[\u0E80-\u0EFF]').hasMatch(text)) {
      return 'lo_LA'; // Lao
    } else if (RegExp(r'[\u1780-\u17FF]').hasMatch(text)) {
      return 'km_KH'; // Khmer
    } else if (RegExp(r'[\u1000-\u109F]').hasMatch(text)) {
      return 'my_MM'; // Myanmar
    } else if (RegExp(r'[\u0F00-\u0FFF]').hasMatch(text)) {
      return 'bo_CN'; // Tibetan
    } else if (RegExp(r'[\u0F40-\u0F6F]').hasMatch(text)) {
      return 'dz_BT'; // Dzongkha
    } else if (RegExp(r'[\u0590-\u05FF]').hasMatch(text)) {
      return 'he_IL'; // Hebrew
    } else if (RegExp(r'[\u0370-\u03FF]').hasMatch(text)) {
      return 'el_GR'; // Greek
    } else if (RegExp(r'[\u0400-\u04FF]').hasMatch(text)) {
      return 'ru_RU'; // Cyrillic (Russian, Bulgarian, etc.)
    } else if (RegExp(r'[\u0530-\u058F]').hasMatch(text)) {
      return 'hy_AM'; // Armenian
    } else if (RegExp(r'[\u10A0-\u10FF]').hasMatch(text)) {
      return 'ka_GE'; // Georgian
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
      return 'fa_IR'; // Persian
    } else if (RegExp(r'[\u0800-\u083F]').hasMatch(text)) {
      return 'ps_AF'; // Pashto
    } else if (RegExp(r'[\u0640-\u064F]').hasMatch(text)) {
      return 'ku_IQ'; // Kurdish
    } else if (RegExp(r'[\u1200-\u137F]').hasMatch(text)) {
      return 'am_ET'; // Amharic
    } else if (RegExp(r'[\u1E00-\u1EFF]').hasMatch(text)) {
      return 'vi_VN'; // Vietnamese
    }

    // Default to English for Latin-based languages
    return 'en_US';
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Clear Chat',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Are you sure you want to clear all messages? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearMessages();
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Color(0xFF8B0000),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Voice recognition methods
  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speech.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          setState(() {
            _isListening = false;
          });
          _voiceAnimationController.stop();
        },
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done' ||
              status == 'notListening' ||
              status == 'stopped') {
            setState(() {
              _isListening = false;
            });
            _voiceAnimationController.stop();
          }
        },
        debugLogging: true, // Enable debug logging for better troubleshooting
      );
      setState(() {});
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
    }
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available'),
          backgroundColor: Color(0xFF8B0000),
        ),
      );
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          print(
            'Speech result: ${result.recognizedWords} (final: ${result.finalResult})',
          );
          setState(() {
            _lastWords = result.recognizedWords;
            if (result.finalResult) {
              _messageController.text = _lastWords;
              // Auto-send after final result with longer delay for better UX
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (_messageController.text.trim().isNotEmpty && mounted) {
                  _sendMessage();
                }
              });
            }
          });
        },
        listenFor: const Duration(seconds: 60), // Increased to 60 seconds
        pauseFor: const Duration(seconds: 5), // Increased pause time
        partialResults: true,
        localeId: _detectedLanguage,
        cancelOnError: false, // Don't cancel on error for better experience
        listenMode: stt
            .ListenMode
            .dictation, // Changed to dictation mode for better accuracy
      );
      setState(() {
        _isListening = true;
      });
      _voiceAnimationController.repeat();
    } catch (e) {
      print('Error starting speech recognition: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFF8B0000),
        ),
      );
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
      _voiceAnimationController.stop();
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: _buildAppBar(isSmallScreen),
      body: _buildBody(isSmallScreen),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isSmallScreen) {
    return AppBar(
      backgroundColor: const Color(0xFF000000),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B0000), Color(0xFFB22222)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'OpenChat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B0000), Color(0xFFB22222)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'AI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
          onPressed: _showClearDialog,
          tooltip: 'Clear Chat',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(bool isSmallScreen) {
    return Column(
      children: [
        Expanded(child: _buildChatList(isSmallScreen)),
        _buildInputSection(isSmallScreen),
      ],
    );
  }

  Widget _buildChatList(bool isSmallScreen) {
    if (_messages.isEmpty && !_isLoading) {
      return _buildWelcomeScreen();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index], isSmallScreen);
      },
    );
  }

  Widget _buildWelcomeScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF000000),
            Color(0xFF1A0000),
            Color(0xFF330000),
            Color(0xFF1A0000),
            Color(0xFF000000),
          ],
          stops: [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo container
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'OpenChat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text(
                    'Your intelligent AI assistant powered by advanced language models. Ask me anything, and I\'ll help you with creative solutions, technical guidance, and meaningful conversations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Features Section Title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text(
                    'Key Features',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Features
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        Icons.auto_awesome,
                        'Advanced AI Technology',
                        'Powered by cutting-edge language models',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        Icons.language,
                        'Multi-Language Support',
                        'Communicate in any language naturally',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        Icons.mic,
                        'Voice Recognition',
                        'Speak and get instant responses',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        Icons.security,
                        'Secure & Private',
                        'Your conversations are protected',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Start chatting hint
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8B0000).withValues(alpha: 0.1),
                        const Color(0xFF8B0000).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: const Color(0xFF8B0000),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Start typing or use voice input to begin your conversation',
                        style: TextStyle(
                          color: Color(0xFF8B0000),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B0000).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B0000).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isSmallScreen) {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/images.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen
                    ? screenSize.width * 0.75
                    : screenSize.width * 0.6,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF1A0000) // Dark red for user
                    : const Color(0xFF0A0A0A), // Black for AI
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                border: Border.all(
                  color: message.isUser
                      ? const Color(0xFF8B0000) // Clear red for user
                      : const Color(
                          0xFF8B0000,
                        ).withValues(alpha: 0.3), // Transparent red for AI
                  width: message.isUser ? 2 : 1, // Thicker border for user
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser
                        ? const Color(0xFF8B0000).withValues(
                            alpha: 0.4,
                          ) // Red shadow for user
                        : Colors.black.withValues(
                            alpha: 0.5,
                          ), // Black shadow for AI
                    blurRadius: message.isUser ? 15 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B0000), Color(0xFFB22222)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(
                20,
              ).copyWith(bottomLeft: const Radius.circular(4)),
              border: Border.all(
                color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingAnimation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B0000).withValues(
                              alpha:
                                  0.3 +
                                  0.7 *
                                      (_typingAnimation.value * 3 - index)
                                          .clamp(0, 1),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF8B0000).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Voice indicator when listening
          if (_isListening)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF4444).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _voiceAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4444),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Transform.scale(
                          scale: 1.0 + 0.3 * _voiceAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFF4444,
                              ).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _stopListening,
                    child: Text(
                      'Listening... Tap to stop',
                      style: TextStyle(
                        color: const Color(0xFFFF4444),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Main input row
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: _isListening
                          ? const Color(0xFFFF4444).withValues(alpha: 0.5)
                          : const Color(0xFF8B0000).withValues(alpha: 0.4),
                      width: _isListening ? 2 : 1,
                    ),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFFF4444,
                              ).withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: const Color(
                                0xFF8B0000,
                              ).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? 'Listening...'
                          : 'Type your message...',
                      hintStyle: TextStyle(
                        color: _isListening
                            ? const Color(0xFFFF4444)
                            : Colors.white.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      suffixIcon: _isListening
                          ? null
                          : IconButton(
                              icon: Icon(
                                Icons.mic,
                                color: const Color(0xFF8B0000),
                                size: 24,
                              ),
                              onPressed: _startListening,
                              tooltip: 'Voice input',
                            ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Send button
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        _isLoading ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 30) {
      return 'Just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      final seconds = difference.inSeconds % 60;
      if (minutes == 1) {
        return seconds == 0 ? '1 minute ago' : '1 minute ${seconds}s ago';
      } else {
        return seconds == 0
            ? '$minutes minutes ago'
            : '$minutes minutes ${seconds}s ago';
      }
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      if (hours == 1) {
        return minutes == 0 ? '1 hour ago' : '1 hour ${minutes}m ago';
      } else {
        return minutes == 0
            ? '$hours hours ago'
            : '$hours hours ${minutes}m ago';
      }
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      if (days == 1) {
        return hours == 0 ? '1 day ago' : '1 day ${hours}h ago';
      } else {
        return hours == 0 ? '$days days ago' : '$days days ${hours}h ago';
      }
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      final days = difference.inDays % 7;
      if (weeks == 1) {
        return days == 0 ? '1 week ago' : '1 week ${days}d ago';
      } else {
        return days == 0 ? '$weeks weeks ago' : '$weeks weeks ${days}d ago';
      }
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      final days = difference.inDays % 30;
      if (months == 1) {
        return days == 0 ? '1 month ago' : '1 month ${days}d ago';
      } else {
        return days == 0 ? '$months months ago' : '$months months ${days}d ago';
      }
    } else {
      final years = (difference.inDays / 365).floor();
      final months = ((difference.inDays % 365) / 30).floor();
      if (years == 1) {
        return months == 0 ? '1 year ago' : '1 year ${months}m ago';
      } else {
        return months == 0 ? '$years years ago' : '$years years ${months}m ago';
      }
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
