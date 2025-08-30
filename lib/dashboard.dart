import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart';
import 'openchat_screen.dart';
import 'image_generator_screen.dart';
import 'code_explainer_screen.dart';
import 'education_screen.dart';
import 'it_services_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const DashboardScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late AnimationController _newsController;
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _newsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    _cardController.forward();
  }

  @override
  void dispose() {
    _newsController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildAppBar(isSmallScreen, isVerySmallScreen),
      body: _buildBody(isSmallScreen, isVerySmallScreen),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isSmallScreen, bool isVerySmallScreen) {
    return AppBar(
      backgroundColor: const Color(0xFF000000),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: isVerySmallScreen ? 28 : 32,
            height: isVerySmallScreen ? 28 : 32,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(isVerySmallScreen ? 6 : 8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isVerySmallScreen ? 6 : 8),
              child: Image.asset(
                'assets/images/images.png',
                width: isVerySmallScreen ? 28 : 32,
                height: isVerySmallScreen ? 28 : 32,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: isVerySmallScreen ? 8 : 12),
          Flexible(
            child: Text(
            'RUNNER CODE',
            style: TextStyle(
              color: Colors.white,
                fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
              fontWeight: FontWeight.w700,
                letterSpacing: isVerySmallScreen ? 0.8 : 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // Delete Account Button
        IconButton(
          icon: Icon(
            Icons.delete_forever, 
            color: Colors.red, 
            size: isVerySmallScreen ? 20 : 24
          ),
          onPressed: _deleteAccount,
          tooltip: 'Delete Account',
        ),
        SizedBox(width: isVerySmallScreen ? 4 : 8),
        // Logout Button
        IconButton(
          icon: Icon(
            Icons.logout, 
            color: Colors.white, 
            size: isVerySmallScreen ? 20 : 24
          ),
          onPressed: _logout,
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildBody(bool isSmallScreen, bool isVerySmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(isSmallScreen, isVerySmallScreen),
          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),
          _buildNewsSection(isSmallScreen, isVerySmallScreen),
          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),
          _buildAboutRunnerCodeSection(isSmallScreen, isVerySmallScreen),
          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),
          _buildFreeCourseSection(isSmallScreen, isVerySmallScreen),
          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),
          _buildFreeWebsiteSection(isSmallScreen, isVerySmallScreen),
          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),
          _buildAIToolsSection(isSmallScreen, isVerySmallScreen),
          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),
          _buildRunnerCodeWebsitesSection(isSmallScreen, isVerySmallScreen),
          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),
          _buildContactUsSection(isSmallScreen, isVerySmallScreen),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(bool isSmallScreen, bool isVerySmallScreen) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 32)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF000000),
                  Color(0xFF1A0000),
                  Color(0xFF330000),
                  Color(0xFF8B0000),
                  Color(0xFFB22222),
                ],
                stops: [0.0, 0.3, 0.6, 0.8, 1.0],
              ),
              borderRadius: BorderRadius.circular(isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                  blurRadius: isVerySmallScreen ? 20 : 30,
                  offset: Offset(0, isVerySmallScreen ? 8 : 12),
                ),
                BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.6),
                  blurRadius: isVerySmallScreen ? 10 : 15,
                  offset: Offset(0, isVerySmallScreen ? 4 : 6),
                ),
              ],
            ),
            child: isVerySmallScreen 
              ? Column(
              children: [
                Container(
                      padding: EdgeInsets.all(isVerySmallScreen ? 12 : 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                    ),
                        borderRadius: BorderRadius.circular(isVerySmallScreen ? 12 : 20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFFFFF).withValues(alpha: 0.3),
                            blurRadius: isVerySmallScreen ? 8 : 15,
                            offset: Offset(0, isVerySmallScreen ? 3 : 6),
                      ),
                    ],
                  ),
                      child: Icon(
                    Icons.person,
                        color: const Color(0xFF8B0000),
                        size: isVerySmallScreen ? 24 : 36,
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 8 : 20),
                    Column(
                      children: [
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isVerySmallScreen ? 14 : 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isVerySmallScreen ? 2 : 4),
                        Text(
                          widget.userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isVerySmallScreen ? 12 : 18,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isVerySmallScreen ? 4 : 8),
                        Text(
                          'Ready to explore the future of AI-powered development',
                          style: TextStyle(
                            color: Colors.white70, 
                            fontSize: isVerySmallScreen ? 10 : 14
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                        ),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFFFFF).withValues(alpha: 0.3),
                            blurRadius: isSmallScreen ? 10 : 15,
                            offset: Offset(0, isSmallScreen ? 4 : 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFF8B0000),
                        size: isSmallScreen ? 30 : 36,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 16 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Colors.white,
                              fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                          SizedBox(height: isSmallScreen ? 3 : 4),
                      Text(
                        widget.userName,
                            style: TextStyle(
                          color: Colors.white,
                              fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Text(
                        'Ready to explore the future of AI-powered development',
                            style: TextStyle(
                              color: Colors.white70, 
                              fontSize: isSmallScreen ? 13 : 14
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsSection(bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                ),
                borderRadius: BorderRadius.circular(isVerySmallScreen ? 6 : 8),
              ),
              child: Icon(
                Icons.newspaper, 
                color: Colors.white, 
                size: isVerySmallScreen ? 14 : 16
              ),
            ),
            SizedBox(width: isVerySmallScreen ? 8 : 12),
            Flexible(
              child: Text(
              'BREAKING NEWS',
              style: TextStyle(
                color: Colors.white,
                  fontSize: isVerySmallScreen ? 14 : 18,
                fontWeight: FontWeight.w800,
                  letterSpacing: isVerySmallScreen ? 1.0 : 1.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isVerySmallScreen ? 8 : 12, 
                vertical: isVerySmallScreen ? 3 : 4
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000),
                borderRadius: BorderRadius.circular(isVerySmallScreen ? 8 : 12),
              ),
              child: Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isVerySmallScreen ? 8 : 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: isVerySmallScreen ? 0.5 : 1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isVerySmallScreen ? 12 : 16),
        Container(
          height: isVerySmallScreen ? 120 : (isSmallScreen ? 140 : 160),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8B0000).withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B0000).withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated background pattern
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _newsController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: NewsBackgroundPainter(_newsController.value),
                    );
                  },
                ),
              ),
              // News content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF8B0000,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.rocket_launch,
                            color: Color(0xFF8B0000),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Runner Code Latest Updates',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B4D8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _newsController,
                        builder: (context, child) {
                          return _buildNewsTicker();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Animated border glow
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _newsController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF8B0000).withValues(
                            alpha: 0.3 + 0.2 * (_newsController.value * 2 % 1),
                          ),
                          width: 1,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsTicker() {
    final newsItems = <Map<String, dynamic>>[
      {
        'icon': '🎓',
        'title': 'Free Programming Course Launched',
        'content':
            'Runner Code launches comprehensive free programming course with 1000+ students enrolled',
        'color': const Color(0xFF00B4D8),
      },
      {
        'icon': '🌐',
        'title': 'Free Website Templates Available',
        'content':
            'Professional website templates now free for download - Dark Joe, Consolution, Minimus & more',
        'color': const Color(0xFF9B5DE5),
      },
      {
        'icon': '💼',
        'title': 'IT Services Expansion',
        'content':
            'Runner Code expands IT services to web development, mobile apps, and desktop applications',
        'color': const Color(0xFFF15BB5),
      },
      {
        'icon': '🤖',
        'title': 'AI Studio Platform Live',
        'content':
            'Advanced AI tools including image generation and code explanation now available',
        'color': const Color(0xFF00F5D4),
      },
      {
        'icon': '📱',
        'title': 'Mobile App Development',
        'content':
            'iOS and Android app development services with Flutter and React Native expertise',
        'color': const Color(0xFFFF6B6B),
      },
      {
        'icon': '🎯',
        'title': '24/7 Support Available',
        'content':
            'Round-the-clock technical support and consultation services now live',
        'color': const Color(0xFF4ECDC4),
      },
      {
        'icon': '🏆',
        'title': 'Certified Education Program',
        'content':
            'Professional programming education with certified diplomas upon completion',
        'color': const Color(0xFF8B0000),
      },
      {
        'icon': '⚡',
        'title': 'Real-time Code Analysis',
        'content':
            'Instant code explanation and debugging with advanced AI assistance',
        'color': const Color(0xFF00D4AA),
      },
    ];

    final currentIndex =
        ((_newsController.value * newsItems.length) % newsItems.length).floor();
    final currentNews = newsItems[currentIndex];

    return Column(
      children: [
        // Current news item
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: currentNews['color'].withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: currentNews['color'].withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                currentNews['icon'] as String,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentNews['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentNews['content'] as String,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Progress indicator
        Row(
          children: List.generate(
            newsItems.length,
            (index) => Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.only(
                  right: index < newsItems.length - 1 ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  color: index == currentIndex
                      ? currentNews['color']
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutRunnerCodeSection(bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Runner Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildAboutCard(
                'Education',
                Icons.school,
                const Color(0xFF8B0000),
                'Professional training and courses in programming, web development, and AI technologies. Learn from industry experts.',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EducationScreen(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildAboutCard(
                'IT Services',
                Icons.computer,
                const Color(0xFFB22222),
                'Complete IT solutions including web development, mobile apps, system integration, and technical consulting.',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ITServicesScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFreeCourseSection(bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Free Course',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildFreeCourseCard(),
      ],
    );
  }

  Widget _buildFreeWebsiteSection(bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Free Website',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildFreeWebsiteCard(),
      ],
    );
  }

  Widget _buildFreeCourseCard() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: InkWell(
            onTap: () => _launchFreeCourse(),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000000),
                    Color(0xFF1A0000),
                    Color(0xFF8B0000),
                    Color(0xFFB22222),
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.6),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.free_breakfast,
                      color: Color(0xFF8B0000),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Free Programming Course',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Free programming courses with recognized certificates. Learn C++, C#, Python, Java, JavaScript, and Cyber Security.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFF0F0F0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: const Color(0xFF8B0000),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFFFFF,
                                    ).withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'FREE',
                                style: TextStyle(
                                  color: Color(0xFF8B0000),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFFFFF,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF8B0000),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _launchFreeCourse() async {
    const url = 'https://runner-code.com/Free%20Course.html';
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the free course link'),
              backgroundColor: Color(0xFF8B0000),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFF8B0000),
          ),
        );
      }
    }
  }

  Widget _buildFreeWebsiteCard() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: InkWell(
            onTap: () => _launchFreeWebsite(),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000000),
                    Color(0xFF1A0000),
                    Color(0xFF8B0000),
                    Color(0xFFB22222),
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.6),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.web,
                      color: Color(0xFF8B0000),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Free Website Builder',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Download free website templates including Dark Joe, Consolution, Minimus, Watch, LaslesVPN, CarRentals, and more.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFF0F0F0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: const Color(0xFF8B0000),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFFFFF,
                                    ).withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'FREE',
                                style: TextStyle(
                                  color: Color(0xFF8B0000),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFFFFF,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF8B0000),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _launchFreeWebsite() async {
    const url = 'https://runner-code.com/Free%20Website.html';
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the free website builder link'),
              backgroundColor: Color(0xFF8B0000),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFF8B0000),
          ),
        );
      }
    }
  }

  Widget _buildAboutCard(
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: EdgeInsets.all(isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 28)),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000000),
                    Color(0xFF1A0000),
                    Color(0xFF8B0000),
                    Color(0xFFB22222),
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                    blurRadius: isVerySmallScreen ? 15 : 25,
                    offset: Offset(0, isVerySmallScreen ? 6 : 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.6),
                    blurRadius: isVerySmallScreen ? 10 : 15,
                    offset: Offset(0, isVerySmallScreen ? 3 : 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.4),
                          blurRadius: isVerySmallScreen ? 12 : 20,
                          offset: Offset(0, isVerySmallScreen ? 5 : 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                          blurRadius: isVerySmallScreen ? 6 : 10,
                          offset: Offset(0, isVerySmallScreen ? 2 : 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon, 
                      color: const Color(0xFF8B0000), 
                      size: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 32)
                  ),
                  ),
                  SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isVerySmallScreen ? 4 : 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIToolsSection(bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Runner Code AI Tools',
          style: TextStyle(
            color: Colors.white,
            fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: isVerySmallScreen ? 12 : 16),
        Column(
          children: [
            _buildAIToolCard(
                'OpenChat',
                Icons.chat_bubble_outline,
                const Color(0xFF8B0000),
                'Advanced AI Chat Assistant',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OpenChatScreen(),
                  ),
                ),
              isVerySmallScreen,
            ),
            SizedBox(height: isVerySmallScreen ? 8 : 16),
            _buildAIToolCard(
                'Image Generator',
                Icons.image,
                const Color(0xFFB22222),
                'Create stunning AI images',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageGeneratorScreen(),
                  ),
                ),
              isVerySmallScreen,
            ),
            SizedBox(height: isVerySmallScreen ? 8 : 16),
            _buildAIToolCard(
                'Code Explainer',
                Icons.code,
                const Color(0xFF8B0000),
                'Understand code instantly',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CodeExplainerScreen(),
                  ),
                ),
              isVerySmallScreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIToolCard(
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
    bool isVerySmallScreen,
  ) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000000),
                    Color(0xFF1A0000),
                    Color(0xFF8B0000),
                    Color(0xFFB22222),
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.6),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: const Color(0xFF8B0000), size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRunnerCodeWebsitesSection(bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Runner Code Websites',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildWebsiteCard(
              'Runner Code',
              'Official Website',
              Icons.home,
              const Color(0xFF8B0000),
              'https://runner-code.com/',
              'Professional programming education, IT services, and high-quality websites.',
            ),
            const SizedBox(height: 16),
            _buildWebsiteCard(
              'Runner Code Studio',
              'Code Editor',
              Icons.code,
              const Color(0xFFB22222),
              'https://studio.runner-code.com/',
              'Write, run, and test code in real-time across multiple programming languages.',
            ),
            const SizedBox(height: 16),
            _buildWebsiteCard(
              'Runner Code AI',
              'AI Tools',
              Icons.psychology,
              const Color(0xFF8B0000),
              'https://ai.runner-code.com/',
              'Smart AI tools for developers, creators, and professionals.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactUsSection(bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Us',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _cardAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimation.value,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF000000),
                      Color(0xFF1A0000),
                      Color(0xFF8B0000),
                      Color(0xFFB22222),
                    ],
                    stops: [0.0, 0.4, 0.7, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.6),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFFFFF,
                                ).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: const Color(
                                  0xFF8B0000,
                                ).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.contact_support,
                            color: Color(0xFF8B0000),
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Get In Touch',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'We\'re here to help 24/7',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Contact methods
                    isVerySmallScreen 
                      ? Column(
                          children: [
                            _buildContactMethod(
                              Icons.email,
                              'Email',
                              'info@runner-code.com',
                              'Send us an email',
                              () => _launchEmail('info@runner-code.com'),
                            ),
                            const SizedBox(height: 12),
                            _buildContactMethod(
                              Icons.phone,
                              'Phone',
                              '+961 79 161 153',
                              'Call us directly',
                              () => _launchPhone('+96179161153'),
                            ),
                            const SizedBox(height: 12),
                            _buildContactMethod(
                              Icons.access_time,
                              'Hours',
                              '24/7 Available',
                              'Always here for you',
                              () {},
                            ),
                            const SizedBox(height: 12),
                            _buildContactMethod(
                              Icons.location_on,
                              'Location',
                              'Lebanon',
                              'Serving globally',
                              () {},
                            ),
                          ],
                        )
                      : Column(
                          children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildContactMethod(
                            Icons.email,
                            'Email',
                            'info@runner-code.com',
                            'Send us an email',
                            () => _launchEmail('info@runner-code.com'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildContactMethod(
                            Icons.phone,
                            'Phone',
                            '+961 79 161 153',
                            'Call us directly',
                            () => _launchPhone('+96179161153'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildContactMethod(
                            Icons.access_time,
                            'Hours',
                            '24/7 Available',
                            'Always here for you',
                            () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildContactMethod(
                            Icons.location_on,
                            'Location',
                            'Lebanon',
                            'Serving globally',
                            () {},
                          ),
                                ),
                              ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Quick contact button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF8B0000),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFFFFFF,
                            ).withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => _showContactDialog(),
                        borderRadius: BorderRadius.circular(16),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.message,
                              color: Color(0xFF8B0000),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Send Quick Message',
                              style: TextStyle(
                                color: Color(0xFF8B0000),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContactMethod(
    IconData icon,
    String title,
    String value,
    String subtitle,
    VoidCallback onTap,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20)),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isVerySmallScreen ? 12 : 16),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isVerySmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(isVerySmallScreen ? 10 : 12),
              ),
              child: Icon(
                icon, 
                color: const Color(0xFF8B0000), 
                size: isVerySmallScreen ? 20 : 24
            ),
            ),
            SizedBox(height: isVerySmallScreen ? 8 : 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isVerySmallScreen ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 2 : 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isVerySmallScreen ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 2 : 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white54,
                fontSize: isVerySmallScreen ? 8 : 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsiteCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String url,
    String description,
  ) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: InkWell(
            onTap: () => _launchWebsite(url),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000000),
                    Color(0xFF1A0000),
                    Color(0xFF8B0000),
                    Color(0xFFB22222),
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.6),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFFFFFF,
                              ).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: const Color(
                                0xFF8B0000,
                              ).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: const Color(0xFF8B0000),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8B0000),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF8B0000),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _launchWebsite(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              backgroundColor: const Color(0xFF8B0000),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFF8B0000),
          ),
        );
      }
    }
  }

  void _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open email client'),
              backgroundColor: const Color(0xFF8B0000),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFF8B0000),
          ),
        );
      }
    }
  }

  void _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open phone dialer'),
              backgroundColor: const Color(0xFF8B0000),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFF8B0000),
          ),
        );
      }
    }
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Contact Us',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'For immediate assistance, please contact us:\n\n'
            '📧 Email: info@runner-code.com\n'
            '📞 Phone: +961 79 161 153\n'
            '⏰ Hours: 24/7 Available\n\n'
            'We\'re here to help you with any questions about our services!',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF8B0000),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchEmail('info@runner-code.com');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send Email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await _databaseHelper.clearSession();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Logged out successfully'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to login screen
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout error: $e'),
            backgroundColor: const Color(0xFF8B0000),
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    // Show confirmation dialog with email and password verification
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final emailController = TextEditingController();
        final passwordController = TextEditingController();
        final formKey = GlobalKey<FormState>();

        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To permanently delete your account, please enter your email and password:',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (value != widget.userEmail) {
                        return 'Email does not match your account';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '⚠️ This action cannot be undone and all your data will be permanently lost.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Verify password
                  bool isValid = await _databaseHelper.validateUser(
                    emailController.text.trim(),
                    passwordController.text,
                  );

                  if (isValid) {
                    Navigator.of(context).pop(true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Incorrect password'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      // Delete user account
      await _databaseHelper.deleteUser(widget.userEmail);

      // Clear session
      await _databaseHelper.clearSession();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account deleted successfully'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to login screen
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: const Color(0xFF8B0000),
          ),
        );
      }
    }
  }
}

// Custom painter for animated news background
class NewsBackgroundPainter extends CustomPainter {
  final double animationValue;

  NewsBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B0000).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Animated circles
    for (int i = 0; i < 5; i++) {
      final x = (size.width * 0.2 * i + animationValue * 100) % size.width;
      final y = size.height * 0.3 + (i * 20);
      final radius = 20 + (i * 5) + (animationValue * 10).toDouble();

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Animated lines
    final linePaint = Paint()
      ..color = const Color(0xFF8B0000).withValues(alpha: 0.03)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final startX = (animationValue * 50 + i * 100) % size.width;
      final endX = startX + 80;
      final y = size.height * 0.7 + (i * 15);

      canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
