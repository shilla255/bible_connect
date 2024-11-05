import 'package:bible/presentation/view/pages/video/video_model.dart';
import 'package:bible/presentation/view/pages/video/video_player.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/cupertino.dart';

class ChannelSelectionPage extends StatefulWidget {
  const ChannelSelectionPage({super.key});

  @override
  _ChannelSelectionPageState createState() => _ChannelSelectionPageState();
}

class _ChannelSelectionPageState extends State<ChannelSelectionPage>
    with SingleTickerProviderStateMixin {
  InterstitialAd? _interstitialAd;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _loadNativeAd();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-2048987392325004/8910242996',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      // Use a different factoryId that matches what's registered in MainActivity.kt/AppDelegate.swift
      adUnitId: 'ca-app-pub-2048987392325004/4424332953',
      factoryId: 'adFactory', // Change this to match your native ad factory ID
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Native ad failed to load: $error');
        },
      ),
    )..load();
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _navigateToVideoPlayer();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _navigateToVideoPlayer();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      _navigateToVideoPlayer();
    }
  }

  void _navigateToVideoPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoStreamWidget(streamUrl: _selectedChannelUrl),
      ),
    );
  }

  String _selectedChannelUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.deepPurple.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and title
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Choose Your Channel',
                          style: TextStyle(
                            fontSize: 24, // Reduced font size to prevent overflow
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(2, 2),
                                blurRadius: 3.0,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis, // Handle text overflow
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Grid of channels
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: channels.length,
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    return ChannelCard(
                      channel: channel,
                      onTap: () {
                        _selectedChannelUrl = channel.url;
                        _showInterstitialAd();
                      },
                    );
                  },
                ),
              ),
              // Native Ad Container
              if (_isNativeAdLoaded && _nativeAd != null)
                Container(
                  height: 80, // Reduced height to prevent overflow
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AdWidget(ad: _nativeAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }
}

// Separate widget for channel card to improve code organization
class ChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  channel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Slightly reduced font size
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2, // Limit number of lines
                  overflow: TextOverflow.ellipsis, // Handle text overflow
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}