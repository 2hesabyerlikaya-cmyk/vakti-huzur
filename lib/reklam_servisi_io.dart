import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'translations_and_logo.dart';

// ============================================================================
// GOOGLE ADMOB ENTEGRASYONU VE HELAL / İSLAMİ AİLE GÜVENLİK FİLTRESİ
// ============================================================================

bool _adMobBaslatildi = false;

Future<void> reklamServisiniBaslat() async {
  if (kIsWeb || _adMobBaslatildi) return;
  try {
    _adMobBaslatildi = true;
    WidgetsFlutterBinding.ensureInitialized();
    await MobileAds.instance.initialize();

    // İSLAMİ AİLE GÜVENLİĞİ FİLTRESİ:
    // - maxAdContentRating: G (Sadece Genel İzleyici / Tüm Aile)
    // - tagForChildDirectedTreatment: yes (COPPA Güvenliği)
    // - tagForUnderAgeOfConsent: yes (Reşit olmayan yaş onayı)
    // Kumar, bahis, flört/dating, iç çamaşırı ve cinsel reklamlar sistem düzeyinde engellenir.
    // ignore: deprecated_member_use
    final RequestConfiguration config = RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.g,
      // ignore: deprecated_member_use
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      // ignore: deprecated_member_use
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
    );
    await MobileAds.instance.updateRequestConfiguration(config);
  } catch (e) {
    debugPrint('AdMob başlatma hatası: $e');
  }
}

AdRequest helalAdRequest() {
  return const AdRequest(
    nonPersonalizedAds: true,
  );
}

class InceBannerReklamWidget extends StatefulWidget {
  final IslamiTema tema;
  const InceBannerReklamWidget({super.key, required this.tema});

  @override
  State<InceBannerReklamWidget> createState() => _InceBannerReklamWidgetState();
}

class _InceBannerReklamWidgetState extends State<InceBannerReklamWidget>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  bool _yuklendi = false;
  Timer? _yenilemeTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _yukle();
    // Google test sunucusu anlık olarak gecikirse 30 saniyede bir yeniden dener
    _yenilemeTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_yuklendi && !KullaniciProfilServisi.premiumAktifMi()) {
        _yukle();
      }
    });
  }

  void _yukle() {
    if (kIsWeb || KullaniciProfilServisi.premiumAktifMi()) return;

    _bannerAd?.dispose();
    _bannerAd = null;

    final String adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: helalAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _yuklendi = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _bannerAd = null;
          if (mounted) setState(() => _yuklendi = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _yenilemeTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ValueListenableBuilder<bool>(
      valueListenable: KullaniciProfilServisi.premiumNotifier,
      builder: (context, premium, _) {
        if (premium) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          color: widget.tema.karanlikMi ? widget.tema.arkaPlan : const Color(0xFF0F3D2E),
          child: _yuklendi && _bannerAd != null
              ? AdWidget(ad: _bannerAd!)
              : Container(
                  width: 320,
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: widget.tema.kartRengi,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.tema.vurguAltin.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: widget.tema.vurguAltin.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: widget.tema.vurguAltin,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google AdMob Reklam Alanı',
                            style: TextStyle(
                              color: widget.tema.yaziRengi,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '✨ Helal & İslami Aile Güvenliği Filtresi Aktif',
                            style: TextStyle(
                              color: widget.tema.vurguAltin,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class InterstitialReklamYoneticisi {
  static InterstitialAd? _interstitialAd;
  static bool _yukleniyor = false;

  static void oncedenYukle() {
    if (kIsWeb || KullaniciProfilServisi.premiumAktifMi() || _interstitialAd != null || _yukleniyor) return;
    _yukleniyor = true;

    final String adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/1033173712'
        : 'ca-app-pub-3940256099942544/4411468910';

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: helalAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _yukleniyor = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _yukleniyor = false;
        },
      ),
    );
  }

  static void goster({VoidCallback? onKapatildi}) {
    if (kIsWeb || KullaniciProfilServisi.premiumAktifMi()) {
      onKapatildi?.call();
      return;
    }

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          onKapatildi?.call();
          oncedenYukle();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          onKapatildi?.call();
          oncedenYukle();
        },
      );
      _interstitialAd!.show();
    } else {
      onKapatildi?.call();
      oncedenYukle();
    }
  }
}
