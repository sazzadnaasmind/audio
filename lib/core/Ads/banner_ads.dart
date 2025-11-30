import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_halper.dart';

/// Manager class for handling Banner Ads
class BannerAdManager {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;

  /// Check if ad is ready to show
  bool get isAdReady => _isAdLoaded && _bannerAd != null;

  /// Get the banner ad widget
  BannerAd? get bannerAd => _bannerAd;

  /// Load a banner ad
  Future<void> loadBannerAd({
    AdSize adSize = AdSize.banner,
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

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _isAdLoaded = true;
          _isAdLoading = false;

          if (onAdLoaded != null) {
            onAdLoaded();
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          _bannerAd = null;
          _isAdLoaded = false;
          _isAdLoading = false;

          // Handle specific error codes
          if (error.code == 0) {
            // Retry after delay for error code 0 (WebView issues)
            Future.delayed(const Duration(seconds: 5), () {
              loadBannerAd(
                adSize: adSize,
                onAdFailedToLoad: onAdFailedToLoad,
              );
            });
          }

          if (onAdFailedToLoad != null) {
            onAdFailedToLoad(error.message);
          }
        },
        onAdOpened: (Ad ad) {
          // Ad opened
        },
        onAdClosed: (Ad ad) {
          // Ad closed
        },
        onAdImpression: (Ad ad) {
          // Ad impression
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// Dispose the banner ad
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;
    _isAdLoading = false;
  }
}

