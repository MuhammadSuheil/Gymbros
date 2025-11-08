import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../../core/widgets/dialogs.dart';
import 'package:gymbros/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) async {
    print("[LoginScreen] Login button pressed.");
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    viewModel.resetErrorState();

    if (_formKey.currentState!.validate()) {
      bool success = await viewModel.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (success) {
        print("[LoginScreen] Login success, waiting for AuthWrapper to navigate...");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.state == AuthState.Error && viewModel.errorMessage.isNotEmpty) {
            showErrorPopup(context, 'Login Failed', viewModel.errorMessage);
            viewModel.resetErrorState();
          }
        });
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    Column(
                      children: [
                        Image.asset('assets/images/notxt.png', height: 60),
                        Image.asset('assets/images/gymbrostxt.png', height: 120),
                        const SizedBox(height: 24),
                      ],
                    ),
                    SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome to ',
                            style: GoogleFonts.outfit(
                              color: AppColors.onPrimary,
                              fontSize: 20,
                            ),
                          ),
                          TextSpan(
                            text: ' GymBros',
                            style: GoogleFonts.outfit(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      style: TextStyle(color: AppColors.onPrimary),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.onSecondary),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: TextStyle(color: AppColors.onPrimary),
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.onSecondary),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(700, 50),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: viewModel.state == AuthState.Loading ? null : () => _handleLogin(context),
                      child: viewModel.state == AuthState.Loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: viewModel.state == AuthState.Loading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Don\'t have an account?',
                              style: GoogleFonts.outfit(
                                color: AppColors.onPrimary,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: ' Register here',
                              style: GoogleFonts.outfit(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}