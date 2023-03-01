import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsCubit extends Cubit<bool> {
  static AdsCubit of(BuildContext context) =>
      BlocProvider.of<AdsCubit>(context);

  final bool releaseMode;
  int showInterstitialCount = 0;
  late int interstitialRate;
  late bool interstitialOnResume;

  AdsCubit(super.initialState, {this.releaseMode = false});
  BannerAd? banner;
  InterstitialAd? _interstitialAd;

  Future<void> init() async {
    try {
      await FirebaseRemoteConfig.instance.fetchAndActivate();
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: "remote_config_fetch_exception");
    }
    
    interstitialRate = FirebaseRemoteConfig.instance.getInt("interstitial_rate");
    interstitialOnResume = FirebaseRemoteConfig.instance.getBool("interstitial_on_resume");

    if (FirebaseRemoteConfig.instance.getBool("banner")) {
        _initBanner();
    }
    if (FirebaseRemoteConfig.instance.getBool("interstitial")) {
      _initInterstitial();
    }
    
  }

  Future<void> _initBanner() async {
    String adUnit = releaseMode ? "ca-app-pub-7519220681088057/4344383854" : "ca-app-pub-3940256099942544/6300978111";
    banner = BannerAd(
      adUnitId: adUnit,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
          onAdLoaded: (_) => emit(true),
          onAdClicked: (_) =>
              FirebaseAnalytics.instance.logEvent(name: "banner_clicked"),
          onAdImpression: (_) =>
              FirebaseAnalytics.instance.logEvent(name: "banner_impression"),
        ),
    )..load();
  }

  Future<void> _initInterstitial() async {
    String adUnit = releaseMode ? "ca-app-pub-7519220681088057/8210474967" : "ca-app-pub-3940256099942544/1033173712";
  
    InterstitialAd.load(
        adUnitId: adUnit,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            FirebaseAnalytics.instance.logEvent(name: "loaded_interstitial");
          },
          onAdFailedToLoad: print,
        ));
  }

  Future<void> showInterstitial({bool appResumed = false}) async {
    // dont show interstitial on app resume
    if (appResumed && !interstitialOnResume) return;

    if (_interstitialAd != null) {

      // dont show ads every time
      showInterstitialCount++;
      if (showInterstitialCount % interstitialRate != 0) return; 
      showInterstitialCount = 0;
      
      // shop and reload interstitial
      _interstitialAd!.show();
      FirebaseAnalytics.instance.logEvent(name: "show_interstitial");
      _initInterstitial();

    }
  }
}
