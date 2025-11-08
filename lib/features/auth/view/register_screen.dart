import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymbros/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../../core/widgets/dialogs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister(BuildContext context) async {
    print("[RegisterScreen] Register button pressed.");
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    viewModel.resetErrorState();

    if (_formKey.currentState!.validate()) {
      print("[RegisterScreen] Form valid, calling ViewModel...");
      bool success = await viewModel.createUserWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && mounted) {
        print("[RegisterScreen] Registration success. Signing out via ViewModel...");
        
        // Gunakan signOut dari ViewModel, bukan FirebaseAuth langsung
        await viewModel.signOut();
        print("[RegisterScreen] User signed out successfully after registration.");

        // Tampilkan dialog sukses
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                backgroundColor: AppColors.background,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'Registration Successful!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onPrimary),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please log in with your new account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.onPrimary),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      if (mounted) {
                        // Navigasi ke login screen
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } else {
      print("[RegisterScreen] Form invalid.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.state == AuthState.Error && viewModel.errorMessage.isNotEmpty) {
            showErrorPopup(context, 'Registration Failed', viewModel.errorMessage);
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
                        const SizedBox(height: 28),
                      ],
                    ),
                    Text(
                      'Account register',
                      style: TextStyle(color: AppColors.onPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
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
                          return 'Please enter a valid email';
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
                          return 'Password minimum 6 character';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: TextStyle(color: AppColors.onPrimary),
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_reset_outlined, color: AppColors.onSecondary),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password cannot be empty';
                        }
                        if (value != _passwordController.text) {
                          return 'Password doesn\'t match';
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
                      onPressed: viewModel.state == AuthState.Loading ? null : () => _handleRegister(context),
                      child: viewModel.state == AuthState.Loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Register'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: viewModel.state == AuthState.Loading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account?',
                              style: GoogleFonts.outfit(
                                color: AppColors.onPrimary,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: ' Login here',
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