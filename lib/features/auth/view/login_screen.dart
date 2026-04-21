import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👇 Added
import 'package:job_market/data/datasources/local/database_helper.dart'; // 👇 Added

import 'package:job_market/features/marketplace/view/Job_market.dart'; // Check your path
import 'package:job_market/features/jobs/view/admin_screen.dart'; // Check your path
import 'package:job_market/features/auth/view/sign_up_screen.dart'; // 👇 Added for Sign Up

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final Color primaryGreen = const Color(0xFF10C971);

  // 👇 REAL DATABASE LOGIN LOGIC 👇
  void _handleLogin() async {
    // Changed to async
    String username = _usernameController.text.trim().toLowerCase();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 1. ADMIN CHECK EKA
    if (username == 'admin' && password == 'admin123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_user_id', 'ADMIN');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminJobReviewScreen()),
        );
      }
      return;
    }

    // 2. NORMAL USER CHECK EKA (Database eken)
    var user = await DatabaseHelper().loginUser(username, password);

    if (user != null) {
      // User hitiyoth eyage ID eka save karanawa
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_user_id', user['id'].toString());

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JobMarketplaceScreen()),
        );
      }
    } else {
      // Invalid nam error eka denawa
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    Color headingColor = isDark ? Colors.white : const Color(0xFF111827);
    Color subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo/Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.diamond_outlined,
                    color: primaryGreen,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Welcome Text
              Text(
                'Welcome to\nGemCost Jobs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: subTextColor),
              ),
              const SizedBox(height: 48),

              // Username Field
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Enter your username',
                icon: Icons.person_outline,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                isPassword: true,
                isDark: isDark,
              ),

              const SizedBox(height: 12),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // 👇 SIGN UP LINK EKA ADD KALA 👇
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(color: subTextColor),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required bool isDark,
  }) {
    Color labelColor = isDark ? Colors.grey[300]! : const Color(0xFF374151);
    Color fieldBgColor = isDark ? const Color(0xFF1F2937) : Colors.grey[50]!;
    Color borderColor = isDark ? const Color(0xFF374151) : Colors.grey[200]!;
    Color inputTextColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: fieldBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            style: TextStyle(color: inputTextColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
