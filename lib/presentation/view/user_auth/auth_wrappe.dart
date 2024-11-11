// lib/screens/auth_wrapper.dart
import 'package:bible/presentation/view/user_auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../community/community_page.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: user != null && user.emailVerified
          ? const CommunityFeedPage()
          : const SignInScreen(),
    );
  }
}