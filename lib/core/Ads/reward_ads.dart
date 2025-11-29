import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_halper.dart';


/// Manager class for handling Rewarded Ads
class RewardedAdManager {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;

  /// Check if ad is ready to show
  bool get isAdReady => _isAdLoaded && _rewardedAd != null;

  /// Load a rewarded ad
  Future<void> loadRewardedAd({
    Function? onAdLoaded,
    Function(String)? onAdFailedToLoad,
  }) async {
    if (_isAdLoading) {
      return;
    }

    if (_isAdLoaded) {
      return;
    }

    _isAdLoading = true;

    await RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          _isAdLoading = false;

          // Set full screen content callback
          _setFullScreenContentCallback();

          if (onAdLoaded != null) {
            onAdLoaded();
          }
        },
        onAdFailedToLoad: (LoadAdError error) {

          _rewardedAd = null;
          _isAdLoaded = false;
          _isAdLoading = false;

          // Handle specific error codes
          if (error.code == 0) {
            // Retry after delay for error code 0 (WebView issues)
            Future.delayed(const Duration(seconds: 5), () {
              loadRewardedAd(onAdFailedToLoad: onAdFailedToLoad);
            });
          }

          if (onAdFailedToLoad != null) {
            onAdFailedToLoad(error.message);
          }
        },
      ),
    );
  }

  /// Set full screen content callback for the loaded ad
  void _setFullScreenContentCallback() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;

        // Preload next ad
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
      },
      onAdImpression: (RewardedAd ad) {
      },
    );
  }

  /// Show the rewarded ad
  Future<void> showRewardedAd({
    required Function(int amount, String type) onUserEarnedReward,
    Function? onAdDismissed,
  }) async {
    if (!_isAdLoaded || _rewardedAd == null) {
      return;
    }

    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {

        onUserEarnedReward(reward.amount.toInt(), reward.type);
      },
    );
  }

  /// Dispose the rewarded ad
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
    _isAdLoading = false;
  }
}
