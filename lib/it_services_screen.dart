import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'email_service.dart';

class ITServicesScreen extends StatefulWidget {
  const ITServicesScreen({super.key});

  @override
  State<ITServicesScreen> createState() => _ITServicesScreenState();
}

class _ITServicesScreenState extends State<ITServicesScreen>
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
            child: const Icon(Icons.computer, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'IT Services',
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

  Widget _buildBody(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(isSmallScreen),
          const SizedBox(height: 32),
          _buildServicesSection(isSmallScreen),
          const SizedBox(height: 32),
          _buildFeaturesSection(isSmallScreen),
          const SizedBox(height: 32),
          _buildTechnologiesSection(isSmallScreen),
          const SizedBox(height: 32),
          _buildProcessSection(isSmallScreen),
          const SizedBox(height: 32),
          _buildContactSection(isSmallScreen),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _heroAnimation.value)),
          child: Opacity(
            opacity: _heroAnimation.value.clamp(0.0, 1.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.computer,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Professional IT Solutions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Text(
                      'Transform your business with cutting-edge technology solutions. From web development to mobile apps, we deliver innovative digital solutions that drive growth.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CTA Button
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
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showConsultationDialog(),
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.rocket_launch,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Get Free Consultation',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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

  Widget _buildServicesSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our IT Services',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isSmallScreen ? 1 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _buildServiceCard(
                'Web Development',
                Icons.web,
                'Custom websites and web applications built with modern technologies and responsive design for optimal user experience.',
                const Color(0xFF00B4D8),
              ),
              _buildServiceCard(
                'Desktop Applications',
                Icons.desktop_windows,
                'Professional desktop software solutions for Windows, macOS, and Linux platforms with intuitive user interfaces.',
                const Color(0xFF9B5DE5),
              ),
              _buildServiceCard(
                'Mobile Development',
                Icons.phone_android,
                'Native and cross-platform mobile applications for iOS and Android with cutting-edge features and performance.',
                const Color(0xFF00F5D4),
              ),
              _buildServiceCard(
                'UI/UX Design',
                Icons.design_services,
                'User-centered design solutions that enhance user experience and drive engagement across all platforms.',
                const Color(0xFFFF6B6B),
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
  ) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value.clamp(0.0, 1.0),
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
                  child: Icon(icon, color: const Color(0xFF8B0000), size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
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
            'Why Choose Runner Code IT Services?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.rocket_launch,
            'Free Consultation',
            'Get expert advice and project planning with our complimentary consultation session.',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.timeline,
            'Agile Development',
            'Iterative development process ensuring your project evolves with your business needs.',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.security,
            'Quality Assurance',
            'Rigorous testing and quality control to deliver reliable and secure solutions.',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.support_agent,
            '24/7 Support',
            'Round-the-clock technical support and maintenance for all our delivered solutions.',
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

  Widget _buildTechnologiesSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Technologies We Use',
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
              // Web Development Technologies
              _buildTechnologyChip(
                'HTML5',
                Icons.code,
                const Color(0xFFE34F26),
              ),
              _buildTechnologyChip('CSS3', Icons.code, const Color(0xFF1572B6)),
              _buildTechnologyChip(
                'JavaScript',
                Icons.code,
                const Color(0xFFF7DF1E),
              ),
              _buildTechnologyChip('PHP', Icons.code, const Color(0xFF777BB4)),
              _buildTechnologyChip(
                'React',
                Icons.code,
                const Color(0xFF61DAFB),
              ),
              _buildTechnologyChip(
                'Angular',
                Icons.code,
                const Color(0xFFDD0031),
              ),
              _buildTechnologyChip(
                'Vue.js',
                Icons.code,
                const Color(0xFF4FC08D),
              ),
              _buildTechnologyChip(
                'Node.js',
                Icons.code,
                const Color(0xFF339933),
              ),
              _buildTechnologyChip(
                'Laravel',
                Icons.code,
                const Color(0xFFFF2D20),
              ),
              _buildTechnologyChip(
                'Django',
                Icons.code,
                const Color(0xFF092E20),
              ),

              // Desktop Applications
              _buildTechnologyChip('C#', Icons.code, const Color(0xFF239120)),
              _buildTechnologyChip('C++', Icons.code, const Color(0xFF00599C)),
              _buildTechnologyChip('Java', Icons.code, const Color(0xFFED8B00)),
              _buildTechnologyChip(
                'Python',
                Icons.code,
                const Color(0xFF3776AB),
              ),
              _buildTechnologyChip('.NET', Icons.code, const Color(0xFF512BD4)),
              _buildTechnologyChip('WPF', Icons.code, const Color(0xFF0078D4)),

              // Mobile Development
              _buildTechnologyChip(
                'Flutter',
                Icons.code,
                const Color(0xFF02569B),
              ),
              _buildTechnologyChip(
                'React Native',
                Icons.code,
                const Color(0xFF61DAFB),
              ),
              _buildTechnologyChip(
                'Swift',
                Icons.code,
                const Color(0xFFFA7343),
              ),
              _buildTechnologyChip(
                'Kotlin',
                Icons.code,
                const Color(0xFF7F52FF),
              ),
              _buildTechnologyChip(
                'Xamarin',
                Icons.code,
                const Color(0xFF3498DB),
              ),

              // Database & Backend
              _buildTechnologyChip(
                'MySQL',
                Icons.storage,
                const Color(0xFF4479A1),
              ),
              _buildTechnologyChip(
                'PostgreSQL',
                Icons.storage,
                const Color(0xFF336791),
              ),
              _buildTechnologyChip(
                'MongoDB',
                Icons.storage,
                const Color(0xFF47A248),
              ),
              _buildTechnologyChip(
                'Firebase',
                Icons.storage,
                const Color(0xFFFFCA28),
              ),

              // Cloud & DevOps
              _buildTechnologyChip('AWS', Icons.cloud, const Color(0xFF232F3E)),
              _buildTechnologyChip(
                'Azure',
                Icons.cloud,
                const Color(0xFF0078D4),
              ),
              _buildTechnologyChip(
                'Docker',
                Icons.cloud,
                const Color(0xFF2496ED),
              ),
              _buildTechnologyChip('Git', Icons.code, const Color(0xFFF05032)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologyChip(String technology, IconData icon, Color color) {
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
            technology,
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
            'Our Development Process',
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
            'Consultation',
            'Understand your requirements and business goals through detailed consultation.',
            Icons.people,
          ),
          const SizedBox(height: 16),
          _buildProcessStep(
            2,
            'Planning & Design',
            'Create comprehensive project plans and design mockups for your approval.',
            Icons.design_services,
          ),
          const SizedBox(height: 16),
          _buildProcessStep(
            3,
            'Development',
            'Build your solution using modern technologies and best practices.',
            Icons.code,
          ),
          const SizedBox(height: 16),
          _buildProcessStep(
            4,
            'Testing & Launch',
            'Thorough testing and quality assurance before launching your solution.',
            Icons.rocket_launch,
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
            'Ready to Transform Your Business?',
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
            'Join hundreds of businesses that have successfully digitized their operations with Runner Code IT Services.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildContactButton(
                'Get Consultation',
                Icons.rocket_launch,
                () => _showConsultationDialog(),
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

  void _showConsultationDialog() {
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
            child: const ConsultationWidget(),
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
            'Contact Runner Code IT Services',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get in touch with us to discuss your IT project:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _buildContactInfo(Icons.email, 'Email', 'info@runner-code.com'),
              const SizedBox(height: 8),
              _buildContactInfo(Icons.phone, 'Phone', '+961 79 161 153'),
              const SizedBox(height: 8),
              _buildContactInfo(Icons.schedule, 'Hours', '24/7'),
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

class ConsultationWidget extends StatefulWidget {
  const ConsultationWidget({super.key});

  @override
  State<ConsultationWidget> createState() => _ConsultationWidgetState();
}

class _ConsultationWidgetState extends State<ConsultationWidget> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay? _selectedTime;

  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _projectController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Get Free Consultation',
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
              'Project Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField('Full Name', _nameController, Icons.person),
            const SizedBox(height: 16),
            _buildTextField('Company Name', _companyController, Icons.business),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', _phoneController, Icons.phone),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController, Icons.email),
            const SizedBox(height: 16),
            _buildTextField(
              'Project Description',
              _projectController,
              Icons.description,
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitConsultation,
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
                        'Request Consultation',
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
        maxLines: label == 'Project Description' ? 3 : 1,
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

  void _submitConsultation() async {
    if (_nameController.text.isEmpty ||
        _companyController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _projectController.text.isEmpty ||
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
      // Send consultation request via Formspree
      final success = await EmailService.sendConsultationRequest(
        name: _nameController.text,
        company: _companyController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        project: _projectController.text,
        date: '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
        time: _selectedTime!.format(context),
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ Consultation request sent successfully! We will contact you soon.',
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
              'Consultation request prepared! Please check your email client.',
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
                    'subject=IT Consultation Request - ${_nameController.text}&body='
                    'IT Consultation Request\n\n'
                    'Date: ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}\n'
                    'Time: ${_selectedTime!.format(context)}\n\n'
                    'Contact Information:\n'
                    'Name: ${_nameController.text}\n'
                    'Company: ${_companyController.text}\n'
                    'Phone: ${_phoneController.text}\n'
                    'Email: ${_emailController.text}\n\n'
                    'Project Description:\n${_projectController.text}\n\n'
                    'Please contact this client to discuss their IT project requirements.',
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
