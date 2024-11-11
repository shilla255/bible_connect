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
          Navigator.pushReplacementNamed(context, 'authWrapper');
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
            content: Text(getFirebaseErrorMessage(e)),
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      onPressed: () => openWebView(
                          context,
                          'https://docs.google.com/document/d/11s8KSZ10EghhMwvDSN-Cok4N3KWEafwpDJm06rU9Gp0/edit?usp=sharing',
                          'Terms & Conditions'
                      ),
                      child: const Text('Terms & Conditions'),
                    ),
                    const Text(' and '),
                    TextButton(
                      onPressed: () => openWebView(
                          context,
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
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}