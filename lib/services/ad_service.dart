import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Flag to enable/disable ads completely (e.g. if user purchased 'Remove Ads')
  static bool isAdFreeUser = false;

  // =========================================================================
  // AdMob Ad Unit IDs
  // CURRENTLY CONFIGURED WITH OFFICIAL GOOGLE TEST IDS (Safe for development)
  // When ready to publish, replace these with your real AdMob Ad Unit IDs.
  // =========================================================================
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // REPLACE THESE WHEN YOU CREATE YOUR ADMOB ACCOUNT:
  static const String _prodBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  static String get bannerAdUnitId => kDebugMode ? _testBannerId : _testBannerId; // Change to _prodBannerId for production
  static String get interstitialAdUnitId => kDebugMode ? _testInterstitialId : _testInterstitialId;
  static String get rewardedAdUnitId => kDebugMode ? _testRewardedId : _testRewardedId;

  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static int _interstitialActionCounter = 0;

  /// Initializes Google Mobile Ads SDK safely with offline handling
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      loadInterstitialAd();
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob initialization failed (offline or missing config): $e');
    }
  }

  /// Creates and loads a Banner Ad
  static BannerAd createBannerAd({
    required Function(Ad) onAdLoaded,
    required Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    )..load();
  }

  /// Pre-loads an Interstitial Ad
  static void loadInterstitialAd() {
    if (isAdFreeUser) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          debugPrint('Interstitial failed to load: $error');
        },
      ),
    );
  }

  /// Shows an interstitial ad every 3 user calculation actions (non-intrusive frequency)
  static void showInterstitialOnPacedAction() {
    if (isAdFreeUser) return;

    _interstitialActionCounter++;
    if (_interstitialActionCounter % 3 == 0) {
      if (_interstitialAd != null) {
        _interstitialAd!.show();
        _interstitialAd = null;
      } else {
        loadInterstitialAd();
      }
    }
  }

  /// Pre-loads a Rewarded Ad
  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          debugPrint('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  /// Shows a rewarded ad to unlock premium actions (e.g. Export Full Amortization PDF)
  static void showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdUnavailableOrDismissed,
  }) {
    if (isAdFreeUser) {
      onRewardEarned();
      return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onRewardEarned();
        },
      );
      _rewardedAd = null;
    } else {
      // If ad is unavailable (e.g. user is offline), gracefully grant the reward
      // so the user is never blocked or leaves a 1-star review!
      onRewardEarned();
      loadRewardedAd();
    }
  }
}
