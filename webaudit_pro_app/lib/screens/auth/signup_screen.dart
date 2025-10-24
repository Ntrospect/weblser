import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback? onSwitchToLogin;

  const SignupScreen({Key? key, this.onSwitchToLogin}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      setState(() => _isLoading = true);

      final authService = context.read<AuthService>();
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      setState(() => _isLoading = false);

      // Check if signup was successful
      if (authService.isAuthenticated && mounted) {
        // Navigation will be handled by AuthWrapper
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isPasswordStrong(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: isDesktop ? 400 : double.infinity,
              child: Consumer<AuthService>(
                builder: (context, authService, _) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/websler_pro.png',
                                width: 240,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Join WebAudit Pro today',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Error message
                        if (authService.authState.hasError)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              authService.authState.errorMessage ?? 'An error occurred',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        if (authService.authState.hasError) const SizedBox(height: 16),

                        // Full name field
                        TextFormField(
                          controller: _fullNameController,
                          enabled: !_isLoading,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Full Name (Optional)',
                            labelStyle: const TextStyle(color: Colors.black87),
                            hintText: 'John Doe',
                            hintStyle: const TextStyle(color: Colors.black45),
                            prefixIcon: const Icon(Icons.person_outlined),
                            prefixIconColor: Colors.black54,
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isLoading,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: const TextStyle(color: Colors.black87),
                            hintText: 'you@example.com',
                            hintStyle: const TextStyle(color: Colors.black45),
                            prefixIcon: const Icon(Icons.email_outlined),
                            prefixIconColor: Colors.black54,
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          enabled: !_isLoading,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.black87),
                            hintText: 'At least 8 characters',
                            hintStyle: const TextStyle(color: Colors.black45),
                            prefixIcon: const Icon(Icons.lock_outlined),
                            prefixIconColor: Colors.black54,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() => _showPassword = !_showPassword);
                              },
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: !_showPassword,
                          onChanged: (value) => setState(() {}),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Password strength indicator
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            _isPasswordStrong(_passwordController.text)
                                ? '✅ Strong password'
                                : '⚠️ Consider using uppercase letters and numbers',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isPasswordStrong(_passwordController.text)
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm password field
                        TextFormField(
                          controller: _confirmPasswordController,
                          enabled: !_isLoading,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: const TextStyle(color: Colors.black87),
                            hintText: 'Re-enter your password',
                            hintStyle: const TextStyle(color: Colors.black45),
                            prefixIcon: const Icon(Icons.lock_outlined),
                            prefixIconColor: Colors.black54,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() => _showConfirmPassword = !_showConfirmPassword);
                              },
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: !_showConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Terms and conditions checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() => _acceptTerms = value ?? false);
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _acceptTerms = !_acceptTerms);
                                },
                                child: const Text(
                                  'I agree to the Terms & Conditions',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sign up button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignup,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blue.shade600,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),

                        // Login link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(fontSize: 13),
                              ),
                              TextButton(
                                onPressed: widget.onSwitchToLogin,
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
