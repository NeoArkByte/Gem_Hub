import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:gemhub/shared/widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  String _getFriendlyErrorMessage(String error) {
    final errorStr = error.toLowerCase();

    if (errorStr.contains('invalid login credentials') || 
        errorStr.contains('invalid password') || 
        errorStr.contains('not found')) {
      return 'Invalid email or password. Please check and try again.';
    } else if (errorStr.contains('network') || 
               errorStr.contains('socket') || 
               errorStr.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('email not confirmed')) {
      return 'Please verify your email address before logging in.';
    } else if (errorStr.contains('too many requests')) {
      return 'Too many attempts. Please try again later.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  void _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    final vm = ref.read(authViewModelProvider.notifier);

    final error = vm.validateLogin(email, password);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

   
    try {
      await vm.login(email, password);
    } catch (e) {
      if (mounted) {
        final friendlyMessage = _getFriendlyErrorMessage(e.toString());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    friendlyMessage,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final vm = ref.read(authViewModelProvider.notifier);

    try {
      await vm.signInWithGoogleNative();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google sign-in complete.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final friendlyMessage = _getFriendlyErrorMessage(e.toString());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    friendlyMessage,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.diamond_outlined,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 24),

                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Log in to continue to GemHub',
                  style: TextStyle(color: Colors.grey[500]),
                ),

                const SizedBox(height: 40),

                // EMAIL
                TextField(
                  controller: _emailCtrl,
                  enabled: !isLoading, 
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 16),

                // PASSWORD
                TextField(
                  controller: _passwordCtrl,
                  enabled: !isLoading, 
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // NATIVE GOOGLE OAUTH BUTTON
                isLoading 
                  ? const SizedBox(
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : GoogleSignInButton(
                      label: 'Continue with Google',
                      onPressed: _signInWithGoogle,
                    ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : () {
                        context.go('/signup');
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}