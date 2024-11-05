
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repository/user_repository.dart';
import '../../../theme/theme_constants.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/textfield_widget.dart';
import '../../../data/models/user.dart' as app_user;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
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

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email or sign in.';
      case 'invalid-email':
        return 'The email address is invalid. Please check and try again.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'weak-password':
        return 'This password is too weak. Please choose a stronger password.';
      default:
        return 'An error occurred during sign up. Please try again.';
    }
  }

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = app_user.CustomUser(
        uid: userCredential.user?.uid ?? '',
        username: username,
        email: email,
        bookmarks: [],
        isVerified: false,
      );

      final userRepository = UserRepository();
      await userRepository.addUser(user);
      await user.saveToFirestore();
      await userCredential.user?.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, 'signIn');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getFirebaseErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: ThemeConstants.standardPadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.back, color: theme.iconTheme.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextFieldWidget(
                  hintText: 'Username',
                  controller: _usernameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: CupertinoIcons.person,
                  validator: _validateUsername,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  hintText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: CupertinoIcons.mail,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: CupertinoIcons.lock,
                  suffixIcon: _obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  onSuffixIconPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  hintText: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: CupertinoIcons.lock,
                  suffixIcon: _obscureConfirmPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  onSuffixIconPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ButtonWidget(
                    text: _isLoading ? 'Signing Up...' : 'Sign Up',
                    onPressed: _isLoading ? null : _signUp,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

    );
  }
}