import 'package:flutter/material.dart';
import 'package:job_market/Screen/Job_market.dart'; // Check your path
import 'package:job_market/Test/admin_screen.dart'; // Check your path

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

  void _handleLogin() {
    String username = _usernameController.text.trim().toLowerCase();
    String password = _passwordController.text.trim();

    // Dummy Authentication Logic
    if (username == 'admin' && password == 'admin123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminJobReviewScreen()),
      );
    } else if (username == 'user' && password == 'user123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JobMarketplaceScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid username or password! Try admin/admin123 or user/user123',
          ),
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
    // 👇 MEKA THAMAI MAGIC EKA! Phone eke mode eka check karanawa
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Mode eka anuwa Main Colors hadagannawa
    Color bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    Color headingColor = isDark ? Colors.white : const Color(0xFF111827);
    Color subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor, // Dynamic Background
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
                  color: headingColor, // Dynamic Text Color
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: subTextColor, // Dynamic Subtext Color
                ),
              ),
              const SizedBox(height: 48),

              // Username Field
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Enter admin or user',
                icon: Icons.person_outline,
                isDark: isDark, // Pass the mode state
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                isPassword: true,
                isDark: isDark, // Pass the mode state
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
                      color: Colors.white, // Always white on Green button
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method ekatath isDark parameter eka add kala
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required bool isDark, // 👇 Added this parameter
  }) {
    // Text field colors dynamic kara
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
            style: TextStyle(color: inputTextColor), // Types text color
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
