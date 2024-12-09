
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
  bool _hasInteractedWithFields = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

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

  String? _validateFields(String? value, String fieldName) {
    if (!_hasInteractedWithFields) return null;

    if (value?.isEmpty ?? true) {
      return '$fieldName is required';
    }

    switch (fieldName) {
      case 'Email':
        final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
        return emailRegex.hasMatch(value!) ? null : 'Invalid email format';
      case 'Password':
        return value!.length < 6 ? 'Password too short' : null;
      case 'Confirm Password':
        return value != _passwordController.text ? 'Passwords don\'t match' : null;
      default:
        return null;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    setState(() => _hasInteractedWithFields = true);

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showErrorSnackBar('Please check your input');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Create user account
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create custom user object
      final user = app_user.CustomUser(
        uid: userCredential.user?.uid ?? '',
        username: username,
        email: email,
        bookmarks: [],
        isVerified: false,
      );

      // Save user data
      await Future.wait([
        UserRepository().addUser(user),
        user.saveToFirestore(),
        userCredential.user?.sendEmailVerification() ?? Future.value(),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(CupertinoIcons.mail, color: Colors.white),
                SizedBox(width: 8),
                Text('Verification email sent!'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacementNamed(context, 'signIn');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = switch (e.code) {
        'email-already-in-use' => 'This email is already registered',
        'invalid-email' => 'Invalid email format',
        'weak-password' => 'Password is too weak',
        _ => 'Sign up failed: ${e.message}',
      };
      if (mounted) _showErrorSnackBar(errorMessage);
    } catch (e) {
      if (mounted) _showErrorSnackBar('An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Responsive spacing calculations
    final double verticalSpacing = size.height * 0.02;
    final double horizontalPadding = size.width * 0.05;
    final double inputHeight = size.height * 0.065;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.back, color: theme.iconTheme.color),
                  onPressed: () => Navigator.pop(context),
                ),

                // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(top: verticalSpacing),
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                // Form
                Expanded(
  child: SlideTransition(
    position: _slideAnimation,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: verticalSpacing),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextFieldWidget(
              hintText: 'Username',
              controller: _usernameController,
              keyboardType: TextInputType.name,
              prefixIcon: CupertinoIcons.person,
              validator: (v) => _validateFields(v, 'Username'),
              textInputAction: TextInputAction.next,
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
            TextFieldWidget(
              hintText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: CupertinoIcons.mail,
              validator: (v) => _validateFields(v, 'Email'),
              textInputAction: TextInputAction.next,
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
            TextFieldWidget(
              hintText: 'Password',
              controller: _passwordController,
              obscureText: _obscurePassword,
              prefixIcon: CupertinoIcons.lock,
              suffixIcon: _obscurePassword
                  ? CupertinoIcons.eye_slash
                  : CupertinoIcons.eye,
              onSuffixIconPressed: () => setState(() =>
                  _obscurePassword = !_obscurePassword),
              validator: (v) => _validateFields(v, 'Password'),
              textInputAction: TextInputAction.next,
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
            TextFieldWidget(
              hintText: 'Confirm Password',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              prefixIcon: CupertinoIcons.lock,
              suffixIcon: _obscureConfirmPassword
                  ? CupertinoIcons.eye_slash
                  : CupertinoIcons.eye,
              onSuffixIconPressed: () => setState(() =>
                  _obscureConfirmPassword = !_obscureConfirmPassword),
              validator: (v) => _validateFields(v, 'Confirm Password'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _signUp(),
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
            SizedBox(
              width: double.infinity,
              height: inputHeight,
              child: ButtonWidget(
                text: _isLoading ? 'Creating Account...' : 'Sign Up',
                onPressed: _isLoading ? null : _signUp,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),

                // Sign In Link
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: verticalSpacing),
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pushReplacementNamed(context, 'signIn'),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: size.width * 0.035),
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            TextSpan(
                              text: 'Sign In',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}