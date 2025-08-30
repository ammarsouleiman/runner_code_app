import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'email_service.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardController;
  late Animation<double> _heroAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));
    _cardAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _heroController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardController.dispose();
    super.dispose();
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
        icon: Icon(
          Icons.arrow_back, 
          color: Colors.white,
          size: isVerySmallScreen ? 20 : 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
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
              Icons.school, 
              color: Colors.white, 
              size: isVerySmallScreen ? 16 : 20
            ),
          ),
          SizedBox(width: isVerySmallScreen ? 8 : 12),
          Flexible(
            child: Text(
              'Education Services',
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B0000), Color(0xFFB22222)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(bool isSmallScreen, bool isVerySmallScreen) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(isSmallScreen, isVerySmallScreen),
          SizedBox(height: isVerySmallScreen ? 24 : 32),
          _buildServicesSection(isSmallScreen, isVerySmallScreen),
          SizedBox(height: isVerySmallScreen ? 24 : 32),
          _buildFeaturesSection(isSmallScreen),
          SizedBox(height: isVerySmallScreen ? 24 : 32),
          _buildLanguagesSection(isSmallScreen),
          SizedBox(height: isVerySmallScreen ? 24 : 32),
          _buildProcessSection(isSmallScreen),
          SizedBox(height: isVerySmallScreen ? 24 : 32),
          _buildContactSection(isSmallScreen),
          SizedBox(height: isVerySmallScreen ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isSmallScreen, bool isVerySmallScreen) {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _heroAnimation.value)),
          child: Opacity(
            opacity: _heroAnimation.value.clamp(0.0, 1.0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
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
              child: Column(
                children: [
                  // Hero Icon
                  Container(
                    width: isVerySmallScreen ? 60 : (isSmallScreen ? 70 : 80),
                    height: isVerySmallScreen ? 60 : (isSmallScreen ? 70 : 80),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isVerySmallScreen ? 15 : (isSmallScreen ? 18 : 20)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                          blurRadius: isVerySmallScreen ? 15 : 20,
                          offset: Offset(0, isVerySmallScreen ? 6 : 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.school,
                      color: Colors.white,
                      size: isVerySmallScreen ? 28 : (isSmallScreen ? 32 : 40),
                    ),
                  ),
                  SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),

                  // Title
                  Text(
                    'Professional Programming Education',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 28),
                      fontWeight: FontWeight.w800,
                      letterSpacing: isVerySmallScreen ? 0.8 : 1.2,
                    ),
                  ),
                  SizedBox(height: isVerySmallScreen ? 12 : 16),

                  // Subtitle
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
                    child: Text(
                      'Master programming languages and web development with expert-led courses designed for all skill levels. Learn at your own pace with flexible online sessions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 14 : 16),
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),

                  // CTA Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isVerySmallScreen ? 20 : 25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                          blurRadius: isVerySmallScreen ? 12 : 15,
                          offset: Offset(0, isVerySmallScreen ? 4 : 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showDemoDialog(),
                        borderRadius: BorderRadius.circular(isVerySmallScreen ? 20 : 25),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isVerySmallScreen ? 20 : (isSmallScreen ? 28 : 32),
                            vertical: isVerySmallScreen ? 12 : 16,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle,
                                color: Colors.white,
                                size: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
                              ),
                              SizedBox(width: isVerySmallScreen ? 8 : 12),
                              Text(
                                'Book Free Demo Session',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 14 : 16),
                                  fontWeight: FontWeight.w700,
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
          ),
        );
      },
    );
  }

  Widget _buildServicesSection(bool isSmallScreen, bool isVerySmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Educational Services',
            style: TextStyle(
              color: Colors.white,
              fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
              fontWeight: FontWeight.w800,
              letterSpacing: isVerySmallScreen ? 0.5 : 1.0,
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 16 : 20),
          Column(
            children: [
              _buildServiceCard(
                'Online Learning Platform',
                Icons.laptop,
                'Interactive learning sessions via Zoom with real-time coding practice and instant feedback from expert instructors.',
                const Color(0xFF00B4D8),
                isVerySmallScreen,
              ),
              SizedBox(height: isVerySmallScreen ? 12 : 16),
              _buildServiceCard(
                'Flexible Scheduling',
                Icons.schedule,
                'Choose your preferred time slots with minimum 2 sessions per week. Perfect for busy professionals and students.',
                const Color(0xFF9B5DE5),
                isVerySmallScreen,
              ),
              SizedBox(height: isVerySmallScreen ? 12 : 16),
              _buildServiceCard(
                'Expert Instructors',
                Icons.person,
                'Learn from industry professionals with years of experience in software development and teaching.',
                const Color(0xFF00F5D4),
                isVerySmallScreen,
              ),
              SizedBox(height: isVerySmallScreen ? 12 : 16),
              _buildServiceCard(
                'Certified Programs',
                Icons.verified,
                'Receive internationally recognized certificates upon course completion, enhancing your professional portfolio.',
                const Color(0xFFFF6B6B),
                isVerySmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    IconData icon,
    String description,
    Color color,
    bool isVerySmallScreen,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value.clamp(0.0, 1.0),
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
        );
      },
    );
  }

  Widget _buildFeaturesSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Choose Runner Code Education?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.timer,
            'Free Demo Session',
            'Experience our teaching methodology with a complimentary 1-hour demo session before committing.',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.timeline,
            'Flexible Learning Path',
            'Customize your learning journey based on your goals, experience level, and preferred programming languages.',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.group,
            'Small Group Sessions',
            'Learn in intimate groups ensuring personalized attention and better interaction with instructors.',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.assignment,
            'Practical Projects',
            'Build real-world projects to apply your knowledge and create an impressive portfolio.',
          ),
        ],
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
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
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

  Widget _buildLanguagesSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Programming Languages We Teach',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildLanguageChip('Python', Icons.code, const Color(0xFF3776AB)),
              _buildLanguageChip('C++', Icons.code, const Color(0xFF00599C)),
              _buildLanguageChip('C#', Icons.code, const Color(0xFF239120)),
              _buildLanguageChip('Java', Icons.code, const Color(0xFFED8B00)),
              _buildLanguageChip('HTML', Icons.code, const Color(0xFFE34F26)),
              _buildLanguageChip('CSS', Icons.code, const Color(0xFF1572B6)),
              _buildLanguageChip(
                'JavaScript',
                Icons.code,
                const Color(0xFFF7DF1E),
              ),
              _buildLanguageChip('PHP', Icons.code, const Color(0xFF777BB4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String language, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            language,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          _buildProcessStep(
            1,
            'Book Free Demo',
            'Schedule your complimentary 1-hour demo session to experience our teaching style.',
            Icons.calendar_today,
          ),
          const SizedBox(height: 16),
          _buildProcessStep(
            2,
            'Choose Your Path',
            'Select your preferred programming language and learning schedule (minimum 2 sessions/week).',
            Icons.route,
          ),
          const SizedBox(height: 16),
          _buildProcessStep(
            3,
            'Start Learning',
            'Begin your journey with expert instructors in interactive online sessions.',
            Icons.play_circle,
          ),
          const SizedBox(height: 16),
          _buildProcessStep(
            4,
            'Get Certified',
            'Complete your course and receive an internationally recognized certificate.',
            Icons.verified,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep(
    int step,
    String title,
    String description,
    IconData icon,
  ) {
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B0000), Color(0xFFB22222)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFF8B0000), size: 24),
        ],
      ),
    );
  }

  Widget _buildContactSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B0000).withValues(alpha: 0.1),
            const Color(0xFF8B0000).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B0000).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Ready to Start Your Programming Journey?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Join thousands of students who have transformed their careers with Runner Code Education.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildContactButton(
                'Book Demo',
                Icons.calendar_today,
                () => _showDemoDialog(),
              ),
              const SizedBox(width: 16),
              _buildContactButton(
                'Contact Us',
                Icons.message,
                () => _showContactDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(String text, IconData icon, VoidCallback onTap) {
    return Container(
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDemoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const DemoBookingWidget(),
          ),
        );
      },
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Contact Runner Code Education',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get in touch with us to start your programming journey:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _buildContactInfo(Icons.email, 'Email', 'info@runner-code.com'),
              const SizedBox(height: 8),
              _buildContactInfo(Icons.phone, 'Phone', '+961 79 161 153'),
              const SizedBox(height: 8),
              _buildContactInfo(Icons.schedule, 'Hours', 'Open 24 hours'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
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

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8B0000), size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}

class DemoBookingWidget extends StatefulWidget {
  const DemoBookingWidget({super.key});

  @override
  State<DemoBookingWidget> createState() => _DemoBookingWidgetState();
}

class _DemoBookingWidgetState extends State<DemoBookingWidget> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay? _selectedTime;

  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Book Free Demo Session',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Section
            const Text(
              'Select Date',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar<String>(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Colors.white70),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF8B0000),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF666666),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white70),
                  weekendStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Time Selection
            const Text(
              'Select Time',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.access_time,
                  color: Color(0xFF8B0000),
                ),
                title: Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'Select Time',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white70,
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF8B0000),
                            surface: Color(0xFF2A2A2A),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // Contact Information
            const Text(
              'Contact Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField('Full Name', _nameController, Icons.person),
            const SizedBox(height: 16),
            _buildTextField('Country', _countryController, Icons.public),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', _phoneController, Icons.phone),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController, Icons.email),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Book Demo Session',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: const Color(0xFF8B0000)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  void _submitBooking() async {
    if (_nameController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select date/time'),
          backgroundColor: Color(0xFF8B0000),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Send email using Formspree directly
      final success = await EmailService.sendDemoBookingEmail(
        name: _nameController.text,
        country: _countryController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        date: '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
        time: _selectedTime!.format(context),
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ Booking request sent successfully! We will contact you soon.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Booking request prepared! Please check your email client.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open Email',
              textColor: Colors.white,
              onPressed: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'info@runner-code.com',
                  query: Uri.encodeQueryComponent(
                    'subject=Demo Session Booking - ${_nameController.text}&body='
                    'Demo Session Booking Request\n\n'
                    'Date: ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}\n'
                    'Time: ${_selectedTime!.format(context)}\n\n'
                    'Contact Information:\n'
                    'Name: ${_nameController.text}\n'
                    'Country: ${_countryController.text}\n'
                    'Phone: ${_phoneController.text}\n'
                    'Email: ${_emailController.text}\n\n'
                    'Please confirm this booking and send meeting details to the student.',
                  ),
                );

                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
            ),
          ),
        );
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
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
