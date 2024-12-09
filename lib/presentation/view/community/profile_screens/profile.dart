import 'package:bible/presentation/view/community/profile_screens/profile_menu_items.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../theme/theme_provider.dart';
import 'bookmarks.dart';
import 'help_screen.dart';
import '../../../../data/models/user.dart' as custom;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  custom.CustomUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchUser();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _user = custom.CustomUser.fromMap(userDoc.data()!);
        });
      }
    } else {
      setState(() {
        _user = custom.CustomUser(
          uid: "guest",
          username: "Guest",
          email: "guest@example.com",
        );
      });
    }
  }

  void _openWebView(String url, String title) {
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title.tr()),
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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout").tr(),
        content: const Text("Are you sure you want to logout?").tr(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel").tr(),
          ),
          FilledButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            child: const Text("Logout").tr(),
          ),
        ],
      ),
    );
  }

  // lib/presentation/view/community/profile_screens/profile.dart

@override
Widget build(BuildContext context) {
  ref.watch(themeProvider);

  return Scaffold(
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
      slivers: [
        SliverAppBar.large(
          floating: false,
          pinned: true,
          backgroundColor: Colors.deepPurple,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.white),
            ).tr(),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade500,
                  ],
                ),
              ),
            ),
          ),
          actions: [
            // Add language changing button here
            IconButton(
              icon: const Icon(Icons.language, color: Colors.white),
              onPressed: () {
                // Show language selection dialog or menu
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Change Language").tr(),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text("English").tr(),
                          onTap: () {
                            context.setLocale(const Locale('en'));
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("Spanish").tr(),
                          onTap: () {
                            context.setLocale(const Locale('es'));
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("French").tr(),
                          onTap: () {
                            context.setLocale(const Locale('fr'));
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("Swahili").tr(),
                          onTap: () {
                            context.setLocale(const Locale('sw'));
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Hero(
                tag: "profile-avatar",
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple.shade300,
                    child: Text(
                      _user?.username.isNotEmpty ?? false
                          ? _user!.username[0].toUpperCase()
                          : "",
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _user?.username ?? "",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ProfileMenuItem(
                        icon: Icons.bookmark_rounded,
                        title: "Bookmarks".tr(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookmarksScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ProfileMenuItem(
                        icon: Icons.description_rounded,
                        title: "Terms and Conditions".tr(),
                        onTap: () {
                          _openWebView(
                              "https://docs.google.com/document/d/11s8KSZ10EghhMwvDSN-Cok4N3KWEafwpDJm06rU9Gp0/edit?usp=sharing",
                              "Terms & Conditions"
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ProfileMenuItem(
                        icon: Icons.privacy_tip_rounded,
                        title: "Privacy Policy".tr(),
                        onTap: () {
                          _openWebView(
                              "https://docs.google.com/document/d/1JW2-Iu2NWnhDoyx4r8J4kqsYu3SqCB8932Atd2qDEus/edit?usp=sharing",
                              "Privacy Policy"
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ProfileMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: "Help & Support".tr(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HelpRequestForm(currentUser: _user!),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ProfileMenuItem(
                        icon: Icons.logout_rounded,
                        title: "Logout".tr(),
                        textColor: Colors.red,
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    ),
  );
}
}