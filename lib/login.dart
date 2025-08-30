import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _focusNodeEmail = FocusNode();
  final _focusNodePassword = FocusNode();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    final session = await _databaseHelper.getSavedSession();
    if (session != null) {
      setState(() {
        _emailController.text = session['email'] ?? '';
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Validate user credentials
        bool isValid = await _databaseHelper.validateUser(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (isValid) {
          // Get user data
          final userData = await _databaseHelper.getUserByEmail(
            _emailController.text.trim(),
          );

          // Save session (always save session for logged in users)
          await _databaseHelper.saveUserSession(
            _emailController.text.trim(),
            _rememberMe,
          );

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Login successful!'),
                backgroundColor: const Color(0xFF1A1A1A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            // Navigate to Dashboard
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  userEmail: _emailController.text.trim(),
                  userName: userData?['name'] ?? 'User',
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Invalid email or password'),
                backgroundColor: const Color(0xFFB22222),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: const Color(0xFFB22222),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;

    return Scaffold(
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? double.infinity : 450,
                  minHeight: screenSize.height - 100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Header Section
                    _buildHeaderSection(isSmallScreen, isVerySmallScreen),
                    SizedBox(height: isVerySmallScreen ? 20 : (isSmallScreen ? 30 : 50)),

                    // Login Form
                    _buildLoginForm(isSmallScreen, isVerySmallScreen),
                    SizedBox(height: isVerySmallScreen ? 15 : (isSmallScreen ? 20 : 30)),

                    // Additional Options
                    _buildAdditionalOptions(isSmallScreen, isVerySmallScreen),
                    SizedBox(height: isVerySmallScreen ? 20 : (isSmallScreen ? 30 : 40)),

                    // Social Login
                    _buildSocialLogin(isSmallScreen, isVerySmallScreen),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      children: [
        // Professional Logo
        Container(
          width: isVerySmallScreen ? 60 : (isSmallScreen ? 80 : 100),
          height: isVerySmallScreen ? 60 : (isSmallScreen ? 80 : 100),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isVerySmallScreen ? 15 : 20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                blurRadius: isVerySmallScreen ? 10 : 15,
                offset: Offset(0, isVerySmallScreen ? 5 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isVerySmallScreen ? 15 : 20),
            child: Image.asset(
              'assets/images/images.png',
              width: isVerySmallScreen ? 60 : (isSmallScreen ? 80 : 100),
              height: isVerySmallScreen ? 60 : (isSmallScreen ? 80 : 100),
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 24 : 32)),

        // App Name
        Text(
          'RUNNER CODE',
          style: TextStyle(
            color: Colors.white,
            fontSize: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 32),
            fontWeight: FontWeight.w700,
            letterSpacing: isVerySmallScreen ? 1.0 : 1.5,
            shadows: [
              Shadow(
                color: const Color(0xFF8B0000).withValues(alpha: 0.5),
                blurRadius: isVerySmallScreen ? 8 : 10,
                offset: Offset(0, isVerySmallScreen ? 3 : 4),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),

        // Welcome Text
        Text(
          'Welcome!',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isSmallScreen, bool isVerySmallScreen) {
    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 16 : (isSmallScreen ? 24 : 32)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isVerySmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: isVerySmallScreen ? 15 : 20,
            offset: Offset(0, isVerySmallScreen ? 8 : 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              focusNode: _focusNodeEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 14 : 16),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: isVerySmallScreen ? 12 : 14,
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: const Color(0xFF8B0000),
                  size: isVerySmallScreen ? 18 : 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isVerySmallScreen ? 10 : 12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isVerySmallScreen ? 10 : 12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isVerySmallScreen ? 10 : 12),
                  borderSide: BorderSide(
                    color: const Color(0xFF8B0000),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isVerySmallScreen ? 12 : 16,
                  vertical: isVerySmallScreen ? 12 : 16,
                ),
              ),
              validator: _validateEmail,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(_focusNodePassword);
              },
            ),
            SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 25)),

            // Password Field
            TextFormField(
              controller: _passwordController,
              focusNode: _focusNodePassword,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 14 : 16),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: isVerySmallScreen ? 12 : 14,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: const Color(0xFF8B0000),
                  size: isVerySmallScreen ? 18 : 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade600,
                    size: isVerySmallScreen ? 18 : 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isVerySmallScreen ? 10 : 12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isVerySmallScreen ? 10 : 12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isVerySmallScreen ? 10 : 12),
                  borderSide: BorderSide(
                    color: const Color(0xFF8B0000),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isVerySmallScreen ? 12 : 16,
                  vertical: isVerySmallScreen ? 12 : 16,
                ),
              ),
              validator: _validatePassword,
              onEditingComplete: _submitForm,
            ),
            SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),

            // Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF8B0000),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Flexible(
                        child: Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: const Color(0xFF8B0000),
                      fontWeight: FontWeight.w600,
                      fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isVerySmallScreen ? 20 : (isSmallScreen ? 25 : 30)),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: isVerySmallScreen ? 45 : 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isVerySmallScreen ? 10 : 12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: isVerySmallScreen ? 18 : 20,
                        height: isVerySmallScreen ? 18 : 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions(bool isSmallScreen, bool isVerySmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            "Don't have an account? ",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: isVerySmallScreen ? 12 : 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isVerySmallScreen ? 12 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin(bool isSmallScreen, bool isVerySmallScreen) {
    return Container(); // Remove social login for cleaner design
  }
}

// Sign Up Screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _focusNodeName = FocusNode();
  final _focusNodeEmail = FocusNode();
  final _focusNodePassword = FocusNode();
  final _focusNodeConfirmPassword = FocusNode();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _focusNodeName.dispose();
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please agree to the terms and conditions'),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        print('Starting sign up process...');

        // Check if email already exists
        bool emailExists = await _databaseHelper.emailExists(
          _emailController.text.trim(),
        );

        print('Email exists check result: $emailExists');

        if (emailExists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Email already exists. Please use a different email.',
                ),
                backgroundColor: const Color(0xFFB22222),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
          return;
        }

        // Insert new user
        int userId = await _databaseHelper.insertUser(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        print('User inserted with ID: $userId');

        // List all users for debugging
        await _databaseHelper.getAllUsers();

        // Automatically log in the user after successful signup
        await _databaseHelper.saveUserSession(
          _emailController.text.trim(),
          false, // Don't remember me by default for auto-login
        );

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Account created successfully! You are now logged in.',
              ),
              backgroundColor: const Color(0xFF4CAF50), // Green color
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate directly to dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userEmail: _emailController.text.trim(),
                userName: _nameController.text.trim(),
              ),
            ),
          );
        }
      } catch (e) {
        print('Error in sign up: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: const Color(0xFFB22222),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF000000),
              const Color(0xFF1A1A1A),
              const Color(0xFF8B0000),
              const Color(0xFFB22222),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? double.infinity : 400,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Section
                    _buildHeaderSection(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 30 : 40),

                    // Sign Up Form
                    _buildSignUpForm(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 25 : 30),

                    // Terms and Conditions
                    _buildTermsSection(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 25 : 30),

                    // Sign Up Button
                    _buildSignUpButton(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 25 : 30),

                    // Login Link
                    _buildLoginLink(isSmallScreen),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 80 : 100,
          height: isSmallScreen ? 80 : 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/images.png',
              width: isSmallScreen ? 80 : 100,
              height: isSmallScreen ? 80 : 100,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 24 : 32),
        Text(
          'RUNNER CODE',
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: const Color(0xFF8B0000).withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          'Create account',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Name Field
            _buildFormField(
              controller: _nameController,
              focusNode: _focusNodeName,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: _validateName,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_focusNodeEmail),
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Email Field
            _buildFormField(
              controller: _emailController,
              focusNode: _focusNodeEmail,
              label: 'Email Address',
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_focusNodePassword),
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Password Field
            _buildPasswordField(
              controller: _passwordController,
              focusNode: _focusNodePassword,
              label: 'Password',
              hint: 'Enter your password',
              isPasswordVisible: _isPasswordVisible,
              onVisibilityChanged: (value) =>
                  setState(() => _isPasswordVisible = value),
              validator: _validatePassword,
              onEditingComplete: () => FocusScope.of(
                context,
              ).requestFocus(_focusNodeConfirmPassword),
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Confirm Password Field
            _buildPasswordField(
              controller: _confirmPasswordController,
              focusNode: _focusNodeConfirmPassword,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              isPasswordVisible: _isConfirmPasswordVisible,
              onVisibilityChanged: (value) =>
                  setState(() => _isConfirmPasswordVisible = value),
              validator: _validateConfirmPassword,
              onEditingComplete: _submitForm,
              isSmallScreen: isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required VoidCallback onEditingComplete,
    required bool isSmallScreen,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF8B0000), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF8B0000), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
      onEditingComplete: onEditingComplete,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required bool isPasswordVisible,
    required Function(bool) onVisibilityChanged,
    required String? Function(String?) validator,
    required VoidCallback onEditingComplete,
    required bool isSmallScreen,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: !isPasswordVisible,
      textInputAction: TextInputAction.done,
      style: TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: const Color(0xFF8B0000),
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade600,
            size: 20,
          ),
          onPressed: () => onVisibilityChanged(!isPasswordVisible),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF8B0000), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
      onEditingComplete: onEditingComplete,
    );
  }

  Widget _buildTermsSection(bool isSmallScreen) {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: const Color(0xFF8B0000),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.white70,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B0000),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                'Create Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildLoginLink(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
