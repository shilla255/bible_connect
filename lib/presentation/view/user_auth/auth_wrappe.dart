// lib/screens/auth_wrapper.dart
import 'package:bible/presentation/view/user_auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../community/community_page.dart';
import '../pages/homepage/bottom_nav_bar.dart';


class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: user != null && user.emailVerified
          ? const CommunityFeedPage()
          : const SignInScreen(),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: user != null && user.emailVerified ? 3 : 0,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, 'homepage');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, 'biblePage');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, 'audioPage');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, 'community');
              break;
            default:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
              );
          }
        },
      ),
    );
  }
}