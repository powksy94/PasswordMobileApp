import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const _adUnitId = 'ca-app-pub-9495964118235971/7300635049';

  static InterstitialAd? _ad;

  static Future<void> load() async {
    await InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded:       (ad) => _ad = ad,
        onAdFailedToLoad: (_)  => _ad = null,
      ),
    );
  }

  static Future<void> showIfReady() async {
    if (_ad == null) return;
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); _ad = null; },
      onAdFailedToShowFullScreenContent: (ad, _) { ad.dispose(); _ad = null; },
    );
    await _ad!.show();
    _ad = null;
  }
}
