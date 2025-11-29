import 'dart:io';

import 'ads_config.dart';

class AdHelper {
  static bool get useAdMob => AppConfigs.adMobsAd;
  static bool get useAppLovin => !AppConfigs.adMobsAd;

  // Set to true for testing, false for production
  static const bool useTesting = true;

  static String get bannerAdUnitId {
    if (useAdMob) {
      // AdMob Banner Ads
      if (Platform.isAndroid) {
        return useTesting ? AppConfigs.adMobsBannerIdTest : AppConfigs.adMobsBannerId;
      } else if (Platform.isIOS) {
        return useTesting ? AppConfigs.adMobsBannerIdTestIOS : AppConfigs.adMobsBannerIdIOS;
      }
    } else {
      // AppLovin Banner Ads
      if (Platform.isAndroid) {
        return useTesting ? AppConfigs.appLovinBannerIdAndroid : AppConfigs.appLovinBannerIdAndroidProduction;
      } else if (Platform.isIOS) {
        return AppConfigs.appLovinBannerIdIOSProduction; // Production ID
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (useAdMob) {
      // AdMob Rewarded Ads
      if (Platform.isAndroid) {
        return useTesting ? AppConfigs.adMobsRewardsIdTest : AppConfigs.adMobsRewardsId;
      } else if (Platform.isIOS) {
        return useTesting ? AppConfigs.adMobsRewardsIdTestIOS : AppConfigs.adMobsRewardsIdIOS;
      }
    } else {
      // AppLovin Rewarded Ads
      if (Platform.isAndroid) {
        return useTesting ? AppConfigs.appLovinRewardedIdAndroid : AppConfigs.appLovinRewardedIdAndroidProduction;
      } else if (Platform.isIOS) {
        return AppConfigs.appLovinRewardedIdIOSProduction; // Production ID
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Get ad network name for logging
  static String get adNetworkName => useAdMob ? 'AdMob' : 'AppLovin';
}