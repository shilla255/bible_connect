import 'package:bible/presentation/view/pages/video/video_model.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/cupertino.dart';
import 'remote_config_service.dart';
import 'video_player.dart';

class ChannelSelectionPage extends StatefulWidget {
  const ChannelSelectionPage({super.key});

  @override
  State<ChannelSelectionPage> createState() => _ChannelSelectionPageState();
}

class _ChannelSelectionPageState extends State<ChannelSelectionPage>
    with SingleTickerProviderStateMixin {
  InterstitialAd? _interstitialAd;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  List<Channel> _channels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _loadNativeAd();
    _fetchRemoteConfig();
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

  Future<void> _fetchRemoteConfig() async {
    try {
      final remoteConfigService = RemoteConfigService();
      final channels = await remoteConfigService.fetchChannels();

      setState(() {
        _channels = channels;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to fetch Remote Config: $e');
      setState(() {
        _isLoading = false; // Stop loader even if there's an error
      });
    }
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
      adUnitId: 'ca-app-pub-2048987392325004/4424332953',
      factoryId: 'adFactory',
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

  void _showInterstitialAd(String url) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _navigateToVideoPlayer(url);
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _navigateToVideoPlayer(url);
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      _navigateToVideoPlayer(url);
    }
  }

  void _navigateToVideoPlayer(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoStreamWidget(streamUrl: url),
      ),
    );
  }

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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Column(
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
                                  fontSize: 24,
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
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Grid of channels
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: _channels.length,
                        itemBuilder: (context, index) {
                          final channel = _channels[index];
                          return GestureDetector(
                            onTap: () => _showInterstitialAd(channel.url),
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
                              child: Center(
                                child: Text(
                                  channel.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Native Ad Container
                    if (_isNativeAdLoaded && _nativeAd != null)
                      Container(
                        height: 80,
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