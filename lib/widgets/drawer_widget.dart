import 'package:bible/presentation/view/user_auth/auth_wrappe.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/cupertino.dart';

import 'about_us.dart';

class ModernDrawerWidget extends StatefulWidget {
  const ModernDrawerWidget({super.key});

  @override
  ModernDrawerWidgetState createState() => ModernDrawerWidgetState();
}

class ModernDrawerWidgetState extends State<ModernDrawerWidget>
    with SingleTickerProviderStateMixin {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  late AnimationController _animationController;
  int _selectedIndex = 0;

  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      icon: CupertinoIcons.home,
      title: "Home".tr(),
      route: "homepage",
      gradient: [Colors.blue, Colors.lightBlue],
    ),
    DrawerItem(
      icon: CupertinoIcons.book,
      title: "Bible Page".tr(),
      route: "biblePage",
      gradient: [Colors.purple, Colors.deepPurple],
    ),
    DrawerItem(
      icon: CupertinoIcons.person,
      title: "Profile".tr(),
      route: "profile",
      gradient: [Colors.orange, Colors.deepOrange],
    ),
    DrawerItem(
      icon: CupertinoIcons.group,
      title: "Community".tr(),
      route: "community",
      gradient: [Colors.green, Colors.teal],
    ),
    DrawerItem(
      icon: CupertinoIcons.info,
      title: "About".tr(),
      route: "about",
      gradient: [Colors.red, Colors.pink],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2048987392325004/8500083412',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerHeader(context),
                  const SizedBox(height: 8),
                  ...List.generate(
                    _drawerItems.length,
                    (index) => _buildAnimatedDrawerItem(index),
                  ),
                ],
              ),
            ),
            if (_isAdLoaded)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: _bannerAd.size.height.toDouble(),
                  width: _bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                color: Colors.white,
                child: Icon(
                  CupertinoIcons.book_fill,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Holy Bible".tr(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your Daily Scripture Companion".tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDrawerItem(int index) {
    final item = _drawerItems[index];
    final isSelected = _selectedIndex == index;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50)),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset((-30 * (1 - value)), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? LinearGradient(colors: item.gradient)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: item.gradient.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Icon(
              item.icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            title: Text(
              item.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              if (item.route == "community") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthWrapper()),
                );
              } else if (item.route == "about") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                );
              } else {
                Navigator.pushNamed(context, item.route);
              }
            },
          ),
        ),
      ),
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final String route;
  final List<Color> gradient;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.gradient,
  });
}