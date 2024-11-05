

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../theme/theme_constants.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/textfield_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _hasInteractedWithEmail = false;
  bool _hasInteractedWithPassword = false;

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

    _emailController.addListener(() {
      if (!_hasInteractedWithEmail && _emailController.text.isNotEmpty) {
        setState(() => _hasInteractedWithEmail = true);
      }
    });

    _passwordController.addListener(() {
      if (!_hasInteractedWithPassword && _passwordController.text.isNotEmpty) {
        setState(() => _hasInteractedWithPassword = true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (!_hasInteractedWithEmail) return null;

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
    if (!_hasInteractedWithPassword) return null;

    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void _openWebView(String url, String title) {
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: WebViewWidget(controller: controller),
        ),
      ),
    );
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email. Please check your email or sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is invalid. Please check and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return 'An error occurred during sign in. Please try again.';
    }
  }

  Future<void> _signIn() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Privacy Policy and Terms & Conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _hasInteractedWithEmail = true;
      _hasInteractedWithPassword = true;
    });

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
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        if (userCredential.user != null && userCredential.user!.emailVerified) {
          Navigator.pushReplacementNamed(context, 'community');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please verify your email before signing in."),
              backgroundColor: Colors.orange,
            ),
          );
        }
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
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                    ),
                    Expanded(
                      child: Wrap(
                        children: [
                          const Text('I agree to the '),
                          TextButton(
                            onPressed: () => _openWebView(
                                'https://docs.google.com/document/d/11s8KSZ10EghhMwvDSN-Cok4N3KWEafwpDJm06rU9Gp0/edit?usp=sharing',
                                'Terms & Conditions'
                            ),
                            child: const Text('Terms & Conditions'),
                          ),
                          const Text(' and '),
                          TextButton(
                            onPressed: () => _openWebView(
                                'https://docs.google.com/document/d/1JW2-Iu2NWnhDoyx4r8J4kqsYu3SqCB8932Atd2qDEus/edit?usp=sharing',
                                'Privacy Policy'
                            ),
                            child: const Text('Privacy Policy'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ButtonWidget(
                    text: _isLoading ? 'Signing In...' : 'Sign In',
                    onPressed: _isLoading ? null : _signIn,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pushNamed(context, 'signUp'),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                            ),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        // Handle forgot password navigation here
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Forgot Password?',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                          ],
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