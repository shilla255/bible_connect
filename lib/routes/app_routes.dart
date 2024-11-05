import 'package:bible/presentation/view/community/community_page.dart';
import 'package:bible/presentation/view/pages/audio_page/audio_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:bible/presentation/view/screens/splash_screen.dart';
import 'package:bible/presentation/view/pages/home_page.dart';
import 'package:bible/presentation/view/pages/bible_page.dart';
import 'package:bible/presentation/view/pages/book_page.dart';
import 'package:bible/presentation/view/user_auth/sign_in_screen.dart';
import '../presentation/view/user_auth/auth_wrappe.dart';
import '../presentation/view/user_auth/sign_up.dart';
import 'package:bible/presentation/view/community/profile_screens/profile.dart'; // Import ProfileScreen


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case 'homepage':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case 'biblePage':
        return MaterialPageRoute(builder: (_) => const BiblePage());
      case 'audioPage':
        return MaterialPageRoute(builder: (_) => const AudioBibleWrapper());
      case 'user_auth':
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case 'community':
        return MaterialPageRoute(builder: (_) => const CommunityFeedPage());
      case 'bookPage':
        final bibleId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => BooksPage(bibleId: bibleId));
      case 'signIn':
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case 'signUp':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case 'profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case 'authWrapper': // Add authWrapper route
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}