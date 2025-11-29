
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'core/Ads/ads_config.dart';
import 'package:device_preview/device_preview.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfigs.adMobsAd) {
    // Initialize AdMob
    try {
      // Add small delay to ensure Android WebView is fully initialized
      await Future.delayed(const Duration(milliseconds: 500));

      final initializationStatus = await MobileAds.instance.initialize();

      // Configure test devices
      RequestConfiguration requestConfiguration = RequestConfiguration(
        testDeviceIds: [
          'a7bf72cb-c1fb-44aa-a636-d0792058c21b',
        ],
      );
      MobileAds.instance.updateRequestConfiguration(requestConfiguration);

      // Set request agent for better ad delivery
      if (Platform.isAndroid) {
        MobileAds.instance.setAppVolume(1.0);
        MobileAds.instance.setAppMuted(false);

      }

    } catch (e) {
      return Future.error('Error seeking audio: $e');
    }
  } else {

    // Fallback to AdMob initialization
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final initializationStatus = await MobileAds.instance.initialize();

      RequestConfiguration requestConfiguration = RequestConfiguration(
        // testDeviceIds: ['a7bf72cb-c1fb-44aa-a636-d0792058c21b'],
      );
      MobileAds.instance.updateRequestConfiguration(requestConfiguration);

      if (Platform.isAndroid) {
        MobileAds.instance.setAppVolume(1.0);
        MobileAds.instance.setAppMuted(false);
      }
    } catch (e) {
      return Future.error('Error seeking audio: $e');
    }
    try {
      await AppLovinMAX.initialize(AppConfigs.appLovinSdkKey);
    } catch (e) {
      return Future.error('Error seeking audio: $e');
    }
  }
  runApp(const MyApp());

}