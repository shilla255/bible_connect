import 'package:bible/presentation/view/user_auth/sign_in/sign_in_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../widgets/button_widget.dart';
import '../../../widgets/textfield_widget.dart';


class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _hasInteractedWithEmail = false;
  bool _hasInteractedWithPassword = false;

  @override
  void initState() {
    super.initState();
    _setupControllerListeners();
  }

  void _setupControllerListeners() {
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_agreedToTerms) {
      _showError('Please agree to the Privacy Policy and Terms & Conditions');
      return;
    }

    setState(() {
      _hasInteractedWithEmail = true;
      _hasInteractedWithPassword = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showError('Please fix the errors in the form');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (mounted) {
        if (userCredential.user != null && userCredential.user!.emailVerified) {
          Navigator.pushReplacementNamed(context, 'authWrapper');
        } else {
          _showError("Please verify your email before signing in.");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(getFirebaseErrorMessage(e));
    } catch (e) {
      if (mounted) _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Calculate responsive dimensions with smaller spacing
    final double verticalSpacing = size.height * 0.012;
    final double fontSize = size.width * 0.035;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Field
          TextFieldWidget(
            hintText: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: CupertinoIcons.mail,
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
            style: TextStyle(fontSize: fontSize),
          ),
          SizedBox(height: verticalSpacing),

          // Password Field
          TextFieldWidget(
            hintText: 'Password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            prefixIcon: CupertinoIcons.lock,
            suffixIcon: _obscurePassword
                ? CupertinoIcons.eye_slash
                : CupertinoIcons.eye,
            onSuffixIconPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            validator: _validatePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _signIn(),
            style: TextStyle(fontSize: fontSize),
          ),
          SizedBox(height: verticalSpacing),

          // Terms and Conditions
          Theme(
            data: theme.copyWith(
              checkboxTheme: CheckboxThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(0, -2),
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: [
                      Text(
                        'I agree to the',
                        style: TextStyle(fontSize: fontSize * 0.85),
                      ),
                      _buildTextButton(
                        'Terms & Conditions',
                            () => openWebView(
                          context,
                          'https://docs.google.com/document/d/11s8KSZ10EghhMwvDSN-Cok4N3KWEafwpDJm06rU9Gp0/edit?usp=sharing',
                          'Terms & Conditions',
                        ),
                        fontSize: fontSize * 0.85,
                      ),
                      Text(
                        'and',
                        style: TextStyle(fontSize: fontSize * 0.85),
                      ),
                      _buildTextButton(
                        'Privacy Policy',
                            () => openWebView(
                          context,
                          'https://docs.google.com/document/d/1JW2-Iu2NWnhDoyx4r8J4kqsYu3SqCB8932Atd2qDEus/edit?usp=sharing',
                          'Privacy Policy',
                        ),
                        fontSize: fontSize * 0.85,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: verticalSpacing * 1.5),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            height: size.height * 0.055,
            child: ButtonWidget(
              text: _isLoading ? 'Signing In...' : 'Sign In',
              onPressed: _isLoading ? null : _signIn,
              isLoading: _isLoading,
            ),
          ),
          SizedBox(height: verticalSpacing),

          // Sign Up Link
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.pushNamed(context, 'signUp'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.height * 0.005,
                ),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: fontSize * 0.9),
                  children: [
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                    ),
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed, {required double fontSize}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}