import 'package:flutter/material.dart';
import '../../common/services/auth_repository.dart';
import '../../common/theme/app_theme.dart';
import '../../common/widgets/glass_container.dart';
import '../../common/widgets/glass_text_field.dart';
import '../../common/widgets/primary_button.dart';
import '../../common/widgets/agent_orb.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final user = await _authRepository.registerWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (user != null && mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppTheme.spacingXXL),
                    // Agent Orb Placeholder
                    const Center(
                      child: AgentOrb(state: AgentOrbState.idle, size: 100),
                    ),
                    const SizedBox(height: AppTheme.spacingXL),
                    // Title
                    Text(
                      'Create Account',
                      style: AppTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Sign up to get started',
                      style: AppTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXXL),
                    // Email Field
                    GlassTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
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
                    const SizedBox(height: AppTheme.spacingM),
                    // Password Field
                    GlassTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    // Confirm Password Field
                    GlassTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixTap: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
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
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      GlassContainer(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        child: Text(
                          _errorMessage!,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.spacingXL),
                    // Register Button
                    PrimaryButton(
                      label: 'Register',
                      onPressed: _isLoading ? null : _register,
                      isLoading: _isLoading,
                      icon: Icons.person_add,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    // Sign In Link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          'Already have an account? Sign In',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.accentPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXXL),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
