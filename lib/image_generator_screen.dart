import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageGeneratorScreen extends StatefulWidget {
  const ImageGeneratorScreen({super.key});

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<GeneratedImage> _images = [];
  bool _isLoading = false;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;
  Timer? _timeUpdateTimer;

  static const String _apiKey =
      'OMfpYQBueRaHVMMu7QKoqF4uPbO5iuJvTUHpfitMhFNDmHZ2pbSffE7Y';
  static const String _baseUrl = 'https://api.pexels.com/v1/search';

  // SharedPreferences key for saving images
  static const String _imagesKey = 'image_generator_images';

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

    _loadImages();

    // Start timer to update timestamps every second
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
    _promptController.dispose();
    _scrollController.dispose();
    _loadingController.dispose();
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateImage() async {
    if (_promptController.text.trim().isEmpty) return;

    final prompt = _promptController.text.trim();
    _promptController.clear();

    setState(() {
      _images.add(
        GeneratedImage(
          prompt: prompt,
          imageUrl: '',
          timestamp: DateTime.now(),
          isLoading: true,
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();
    await _saveImages();

    try {
      final imageUrl = await _searchPexelsImage(prompt);

      setState(() {
        final lastImage = _images.last;
        _images[_images.length - 1] = GeneratedImage(
          prompt: lastImage.prompt,
          imageUrl: imageUrl,
          timestamp: lastImage.timestamp,
          isLoading: false,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        final lastImage = _images.last;
        _images[_images.length - 1] = GeneratedImage(
          prompt: lastImage.prompt,
          imageUrl: '',
          timestamp: lastImage.timestamp,
          isLoading: false,
          error: "Sorry, I couldn't generate an image. Please try again.",
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
    await _saveImages();
  }

  Future<String> _searchPexelsImage(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?query=${Uri.encodeComponent(query)}&per_page=1'),
      headers: {'Authorization': _apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final photos = data['photos'] as List;

      if (photos.isNotEmpty) {
        final photo = photos.first;
        return photo['src']['large2x'] ??
            photo['src']['large'] ??
            photo['src']['medium'];
      } else {
        throw Exception('No images found for this query');
      }
    } else {
      throw Exception('Failed to get image: ${response.statusCode}');
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

  Future<void> _loadImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagesJson = prefs.getStringList(_imagesKey) ?? [];

      if (imagesJson.isNotEmpty) {
        for (final imageJson in imagesJson) {
          final imageData = jsonDecode(imageJson);
          _images.add(
            GeneratedImage(
              prompt: imageData['prompt'],
              imageUrl: imageData['imageUrl'],
              timestamp: DateTime.parse(imageData['timestamp']),
              isLoading: false,
              error: imageData['error'],
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

  Future<void> _saveImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagesJson = _images
          .map(
            (image) => jsonEncode({
              'prompt': image.prompt,
              'imageUrl': image.imageUrl,
              'timestamp': image.timestamp.toIso8601String(),
              'error': image.error,
            }),
          )
          .toList();

      await prefs.setStringList(_imagesKey, imagesJson);
    } catch (e) {
      // Handle save error silently
    }
  }

  Future<void> _clearImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_imagesKey);

      setState(() {
        _images.clear();
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
            'Clear Images',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Are you sure you want to clear all generated images? This action cannot be undone.',
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
                _clearImages();
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
    final isVerySmallScreen = screenSize.width < 400;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: _buildAppBar(isSmallScreen, isVerySmallScreen),
      body: _buildBody(isSmallScreen, isVerySmallScreen),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isSmallScreen, bool isVerySmallScreen) {
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
            child: const Icon(Icons.image, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Image Generator',
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
          tooltip: 'Clear Images',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      children: [
        Expanded(child: _buildImageList(isSmallScreen, isVerySmallScreen)),
        _buildInputSection(isSmallScreen, isVerySmallScreen),
      ],
    );
  }

  Widget _buildImageList(bool isSmallScreen, bool isVerySmallScreen) {
    if (_images.isEmpty && !_isLoading) {
      return _buildWelcomeScreen();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
      itemCount: _images.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _images.length && _isLoading) {
          return _buildLoadingIndicator();
        }
        return _buildImageCard(_images[index], isSmallScreen, isVerySmallScreen);
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  child: const Icon(Icons.image, color: Colors.white, size: 35),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Image Generator',
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
                    'Transform your ideas into stunning visuals with our AI-powered image generator. Describe what you want to see, and watch your imagination come to life.',
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
                const SizedBox(height: 24),

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
                const SizedBox(height: 12),

                // Features
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        Icons.auto_awesome,
                        'AI-Powered Generation',
                        'Advanced algorithms create unique images',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        Icons.description,
                        'Text-to-Image',
                        'Describe your vision in words',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        Icons.high_quality,
                        'High Quality',
                        'Professional-grade image results',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        Icons.save,
                        'Save & Share',
                        'Keep your creations forever',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Start generating hint
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
                        Icons.edit,
                        color: const Color(0xFF8B0000),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Describe your image and watch it come to life',
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

  Widget _buildImageCard(GeneratedImage image, bool isSmallScreen, bool isVerySmallScreen) {
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
            // Prompt section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A0000),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border.all(color: const Color(0xFF8B0000), width: 2),
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
                      child: Image.asset(
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
                          image.prompt,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(image.timestamp),
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

            // Image section
            if (image.isLoading)
              _buildLoadingImage()
            else if (image.error != null)
              _buildErrorImage(image.error!)
            else
              Column(
                children: [
                  _buildGeneratedImage(image.imageUrl),
                  // Download button below image
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                color: const Color(
                                  0xFF8B0000,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  _downloadImage(image.imageUrl, image.prompt),
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.download,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Download Image',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _loadingAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Generating your image...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This may take a few moments',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage(String error) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4444).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFFF4444), width: 2),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFFFF4444),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedImage(String imageUrl) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: const Color(0xFF8B0000).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: const Color(0xFF0A0A0A),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF8B0000),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF0A0A0A),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      color: Color(0xFFFF4444),
                      size: 50,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Color(0xFFFF4444), fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
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
                      Icons.image,
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
                'Generating your image...',
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

  Widget _buildInputSection(bool isSmallScreen, bool isVerySmallScreen) {
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
      child: Row(
        children: [
          Expanded(
            child: Container(
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
                controller: _promptController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Describe the image you want to generate...',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _generateImage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Generate button
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
                onTap: _isLoading ? null : _generateImage,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _isLoading ? Icons.hourglass_empty : Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadImage(String imageUrl, String prompt) async {
    try {
      if (kIsWeb) {
        // Web-specific download implementation
        _downloadImageWeb(imageUrl, prompt);
      } else {
        // Mobile/Desktop download implementation
        _downloadImageMobile(imageUrl, prompt);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download image: $e'),
            backgroundColor: const Color(0xFFFF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _downloadImageWeb(String imageUrl, String prompt) {
    // Web-specific download using dart:html
    // This will be implemented only for web platform
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download feature available on web platform'),
          backgroundColor: const Color(0xFF8B0000),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _downloadImageMobile(String imageUrl, String prompt) {
    // Mobile/Desktop download implementation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download feature available on mobile/desktop'),
          backgroundColor: const Color(0xFF8B0000),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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

class GeneratedImage {
  final String prompt;
  final String imageUrl;
  final DateTime timestamp;
  final bool isLoading;
  final String? error;

  GeneratedImage({
    required this.prompt,
    required this.imageUrl,
    required this.timestamp,
    required this.isLoading,
    this.error,
  });
}
