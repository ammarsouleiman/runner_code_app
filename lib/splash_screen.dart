import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'login.dart';
import 'dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      // Add a small delay to show splash screen
      await Future.delayed(const Duration(milliseconds: 1500));

      // Check for saved session
      final session = await _databaseHelper.getSavedSession();

      if (mounted) {
        if (session != null) {
          // User has an active session, navigate to dashboard
          final userData = await _databaseHelper.getUserByEmail(
            session['email'],
          );
          if (userData != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  userEmail: userData['email'],
                  userName: userData['name'],
                ),
              ),
            );
          } else {
            // User data not found, clear session and go to login
            await _databaseHelper.clearSession();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          // No active session, go to login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      print('Error checking session: $e');
      if (mounted) {
        // On error, go to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;
    
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000000),
              Color(0xFF1A1A1A),
              Color(0xFF8B0000),
              Color(0xFFB22222),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: isVerySmallScreen ? 80 : (isSmallScreen ? 100 : 120),
                    height: isVerySmallScreen ? 80 : (isSmallScreen ? 100 : 120),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                          blurRadius: isSmallScreen ? 15 : 20,
                          offset: Offset(0, isSmallScreen ? 8 : 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 30),
                      child: Image.asset(
                        'assets/images/images.png',
                        width: isVerySmallScreen ? 80 : (isSmallScreen ? 100 : 120),
                        height: isVerySmallScreen ? 80 : (isSmallScreen ? 100 : 120),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 30 : 40),

                  // App Name
                  Text(
                    'RUNNER CODE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isVerySmallScreen ? 24 : (isSmallScreen ? 28 : 36),
                      fontWeight: FontWeight.w800,
                      letterSpacing: isSmallScreen ? 1.5 : 2.0,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF8B0000),
                          blurRadius: isSmallScreen ? 10 : 15,
                          offset: Offset(0, isSmallScreen ? 3 : 5),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 15 : 20),

                  // Loading indicator
                  SizedBox(
                    width: isSmallScreen ? 30 : 40,
                    height: isSmallScreen ? 30 : 40,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: isSmallScreen ? 2.5 : 3,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // Loading text
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
