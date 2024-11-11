import 'package:bible/presentation/view/user_auth/sign_in/parental_control.dart';
import 'package:bible/presentation/view/user_auth/sign_in/sign_in_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showParentalControlAlert();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showParentalControlAlert() {
    showDialog(
      context: context,
      builder: (context) => ParentalControlNotice(
        onConfirmed: () {
          Navigator.of(context).pop();
          // Proceed with account creation
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const SignInForm(),
            ],
          ),
        ),
      ),
    );
  }
}