import 'package:bible/presentation/view/user_auth/sign_in/google_signin_service.dart';
import 'package:bible/presentation/view/user_auth/sign_in/sign_in_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  final GoogleSignInService _googleSignInService = GoogleSignInService();

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
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Calculate responsive dimensions with optimized spacing
    final double iconSize = size.height * 0.05;
    final double verticalSpacing = size.height * 0.015;
    final double horizontalPadding = size.width * 0.04;

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
              children: [
                // Top spacing
                SizedBox(height: size.height * 0.02),

                // Icon and Welcome Text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(iconSize * 0.2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                        child: Icon(
                          CupertinoIcons.person_circle_fill,
                          size: iconSize,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: verticalSpacing),
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.055,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: verticalSpacing * 0.3),
                      Text(
                        'Sign in to continue',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.032,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: verticalSpacing * 1.5),

                // Sign-In Form
                Expanded(
                  flex: 5,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Card(
                      elevation: 6,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: const SignInForm(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing),

                // Divider and Google Sign-In Button
                Expanded(
                  flex: 2,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDivider(theme),
                        SizedBox(height: verticalSpacing),
                        _buildGoogleSignInButton(theme, size),
                      ],
                    ),
                  ),
                ),

                // Bottom spacing
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(ThemeData theme, Size size) {
    final buttonHeight = size.height * 0.07;

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading
              ? null
              : () async {
            setState(() => _isLoading = true);
            await _googleSignInService.signInWithGoogle(context);
            setState(() => _isLoading = false);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  SizedBox(
                    width: buttonHeight * 0.4,
                    height: buttonHeight * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                else
                  Image.asset('assets/images/google.png', height: buttonHeight * 0.4),
                SizedBox(width: size.width * 0.02),
                Text(
                  _isLoading ? 'Signing in...' : 'Continue with Google',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}