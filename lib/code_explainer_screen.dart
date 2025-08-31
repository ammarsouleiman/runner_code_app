import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CodeExplainerScreen extends StatefulWidget {
  const CodeExplainerScreen({super.key});

  @override
  State<CodeExplainerScreen> createState() => _CodeExplainerScreenState();
}

class _CodeExplainerScreenState extends State<CodeExplainerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  static const String _apiKey =
      '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';
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // SharedPreferences key for saving messages
  static const String _messagesKey = 'code_explainer_messages';

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _scrollToBottom();
    await _saveMessages();

    try {
      final response = await _sendToOpenRouter(userMessage);

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
            text: "Sorry, I couldn't process your request. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
    await _saveMessages();
  }

  Future<String> _sendToOpenRouter(String message) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://runner-code-app.com',
        'X-Title': 'Code Explainer App',
      },
      body: jsonEncode({
        'model': 'openai/gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful code explainer assistant. You help users understand code by providing clear, detailed explanations. Always respond in a helpful and educational manner.',
          },
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get response: ${response.statusCode}');
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

      if (messagesJson.isNotEmpty) {
        for (final messageJson in messagesJson) {
          final messageData = jsonDecode(messageJson);
          _messages.add(
            ChatMessage(
              text: messageData['text'],
              isUser: messageData['isUser'],
              timestamp: DateTime.parse(messageData['timestamp']),
              isError: messageData['isError'] ?? false,
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
              'isError': message.isError,
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
      });
    } catch (e) {
      // Handle clear error silently
    }
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
            child: const Icon(Icons.code, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Code Explainer',
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
        Expanded(child: _buildMessageList(isSmallScreen)),
        _buildInputSection(isSmallScreen),
      ],
    );
  }

  Widget _buildMessageList(bool isSmallScreen) {
    if (_messages.isEmpty && !_isLoading) {
      return _buildWelcomeScreen();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildLoadingIndicator();
        }
        return _buildMessageCard(_messages[index], isSmallScreen);
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.code, color: Colors.white, size: 25),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Code Explainer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Get clear explanations for any code. Ask questions about programming concepts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),

            // Features
            _buildFeatureItem(
              Icons.psychology,
              'Smart Analysis',
              'Advanced AI understands code',
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              Icons.lightbulb,
              'Clear Explanations',
              'Easy-to-understand breakdowns',
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              Icons.bug_report,
              'Debug Help',
              'Identify and fix issues',
            ),
            const SizedBox(height: 20),

            // Start chatting hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B0000).withValues(alpha: 0.1),
                    const Color(0xFF8B0000).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat, color: const Color(0xFF8B0000), size: 14),
                  const SizedBox(width: 6),
                  const Text(
                    'Ask me anything about code!',
                    style: TextStyle(
                      color: Color(0xFF8B0000),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF8B0000).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF8B0000).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(ChatMessage message, bool isSmallScreen) {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isSmallScreen
              ? screenSize.width * 0.9
              : screenSize.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF8B0000).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF1A0000)
                    : const Color(0xFF0A0A0A),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: message.isError
                      ? const Color(0xFFFF4444)
                      : const Color(0xFF8B0000),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: message.isUser
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B0000),
                                    Color(0xFFB22222),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
                            )
                          : Image.asset(
                              'assets/images/images.png',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.isUser ? 'You' : 'Code Explainer',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Message content
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isError
                      ? const Color(0xFFFF4444)
                      : Colors.white,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF8B0000).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _loadingAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.code,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Analyzing your code...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
          // Main input row
          Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 50,
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B0000).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText:
                          'Ask about code, debugging, or programming concepts...',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    minLines: 1,
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
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
