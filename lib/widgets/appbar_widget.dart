import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bible/presentation/view/community/profile_screens/profile.dart';
import '../theme/theme_provider.dart';

class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
Widget build(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  final themeNotifier = ref.watch(themeProvider.notifier);

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    padding: const EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 10,
    ),
    decoration: BoxDecoration(
      color: theme.scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu Button with Animated Hover Effect
        Builder(
          builder: (context) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Scaffold.of(context).openDrawer();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.menu,
                      key: ValueKey(theme.brightness),
                      size: 20,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Right Side Actions
        Row(
          children: [
            // Language Dropdown Button
            DropdownButton<Locale>(
              value: context.locale,
              icon: Icon(Icons.language, color: theme.iconTheme.color),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  context.setLocale(newLocale);
                }
              },
              items: [
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text('English', style: theme.textTheme.bodyMedium),
                ),
                DropdownMenuItem(
                  value: const Locale('es'),
                  child: Text('Spanish', style: theme.textTheme.bodyMedium),
                ),
                DropdownMenuItem(
                  value: const Locale('fr'),
                  child: Text('French', style: theme.textTheme.bodyMedium),
                ),
                DropdownMenuItem(
                  value: const Locale('sw'),
                  child: Text('Swahili', style: theme.textTheme.bodyMedium),
                ),
              ],
            ),

            // Theme Toggle Button with Animated Transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: CupertinoButton(
                key: ValueKey(theme.brightness),
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  themeNotifier.toggleTheme();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    theme.brightness == Brightness.dark
                        ? CupertinoIcons.sun_max
                        : CupertinoIcons.moon,
                    size: 20,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
            ),

            // Profile Button with Hover and Transition Effects
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                        const ProfileScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.9, end: 1.0)
                                  .animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              )),
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        CupertinoIcons.person,
                        key: ValueKey(theme.brightness),
                        size: 20,
                        color: theme.iconTheme.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

@override
Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}