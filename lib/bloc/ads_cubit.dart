import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsCubit extends Cubit<bool> {
  static AdsCubit of(BuildContext context) =>
      BlocProvider.of<AdsCubit>(context);

  int interactionCount = 0;
  int interactionsBeforeInterstitialShown = 2;

  AdsCubit(super.initialState);
  BannerAd? banner;
  InterstitialAd? _interstitialAd;

  void init() {    
    _initBanner();
    _initInterstitial();
  }

  void _initBanner() {
    String adUnit = kReleaseMode ? "ca-app-pub-4439621725258210/1144765207" : "ca-app-pub-3940256099942544/6300978111";
    banner = BannerAd(
      adUnitId: adUnit,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
          onAdLoaded: (_) => emit(true),
        ),
    )..load();
  }

  void _initInterstitial() {
    String adUnit = kReleaseMode ? "ca-app-pub-4439621725258210/1839835553" : "ca-app-pub-3940256099942544/1033173712";
  
    InterstitialAd.load(
        adUnitId: adUnit,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (_) {},
        ));
  }

  void showInterstitial() {
    if (_interstitialAd != null) {

      // dont show ads every time
      interactionCount++;
      if (interactionCount <= interactionsBeforeInterstitialShown) return; 
      interactionCount = 0;
      
      // shop and reload interstitial
      _interstitialAd!.show();
      _initInterstitial();
    }
  }
}
