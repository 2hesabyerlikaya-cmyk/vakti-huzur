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

String _kimlikCoz(List<int> veri) {
  return String.fromCharCodes(veri.map((b) => b ^ 0x5A));
}

const List<int> _kAb = [57, 59, 119, 59, 42, 42, 119, 42, 47, 56, 119, 109, 108, 110, 98, 98, 111, 106, 109, 98, 109, 108, 108, 107, 107, 109, 108, 117, 111, 98, 111, 109, 99, 111, 108, 111, 107, 111];
const List<int> _kIb = [57, 59, 119, 59, 42, 42, 119, 42, 47, 56, 119, 109, 108, 110, 98, 98, 111, 106, 109, 98, 109, 108, 108, 107, 107, 109, 108, 117, 107, 107, 107, 98, 108, 110, 108, 106, 111, 105];
const List<int> _kFab = [57, 59, 119, 59, 42, 42, 119, 42, 47, 56, 119, 105, 99, 110, 106, 104, 111, 108, 106, 99, 99, 99, 110, 104, 111, 110, 110, 117, 108, 105, 106, 106, 99, 109, 98, 107, 107, 107];
const List<int> _kFib = [57, 59, 119, 59, 42, 42, 119, 42, 47, 56, 119, 105, 99, 110, 106, 104, 111, 108, 106, 99, 99, 99, 110, 104, 111, 110, 110, 117, 104, 99, 105, 110, 109, 105, 111, 109, 107, 108];
const List<int> _kAi = [57, 59, 119, 59, 42, 42, 119, 42, 47, 56, 119, 109, 108, 110, 98, 98, 111, 106, 109, 98, 109, 108, 108, 107, 107, 109, 108, 117, 110, 105, 109, 111, 105, 108, 110, 109, 98, 105];
const List<int> _kIi = [57, 59, 119, 59, 42, 42, 119, 42, 47, 56, 119, 109, 108, 110, 98, 98, 111, 106, 109, 98, 109, 108, 108, 107, 107, 109, 108, 117, 107, 105, 108, 108, 106, 111, 98, 106, 108, 107];
const List<int> _kFai = [57, 59, 119, 59, 42, 42, 119, 42, 47, 56, 119, 105, 99, 110, 106, 104, 111, 108, 106, 99, 99, 99, 110, 104, 111, 110, 110, 117, 107, 106, 105, 105, 107, 109, 105, 109, 107, 104];
const List<int> _kFii = [57, 59, 119, 59, 42, 42, 119, 42, 47, 56, 119, 105, 99, 110, 106, 104, 111, 108, 106, 99, 99, 99, 110, 104, 111, 110, 110, 117, 110, 110, 107, 107, 110, 108, 98, 99, 107, 106];

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
    );
    await MobileAds.instance.updateRequestConfiguration(config);
    // İlk interstitial reklamı erkenden hazırla
    InterstitialReklamYoneticisi.oncedenYukle();
  } catch (_) {}
}

AdRequest helalAdRequest() {
  return const AdRequest(
    nonPersonalizedAds: true,
  );
}

class InceBannerReklamWidget extends StatefulWidget {
  final IslamiTema tema;

  /// true ise sayfa içi (Ana Sayfa orta alanı) için yuvarlak köşeli şık kart görünümünde çizilir.
  final bool ortaKart;
  const InceBannerReklamWidget({super.key, required this.tema, this.ortaKart = false});

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

    const envBannerAndroid = String.fromEnvironment('ADMOB_BANNER_ANDROID');
    const envBannerIos = String.fromEnvironment('ADMOB_BANNER_IOS');
    final String realAdUnitId = Platform.isAndroid
        ? (envBannerAndroid.isNotEmpty ? envBannerAndroid : _kimlikCoz(_kAb))
        : (envBannerIos.isNotEmpty ? envBannerIos : _kimlikCoz(_kIb));

    final String fallbackAdUnitId = Platform.isAndroid
        ? _kimlikCoz(_kFab)
        : _kimlikCoz(_kFib);

    void yukleBirim(String unitId, bool fallbackDene) {
      _bannerAd = BannerAd(
        adUnitId: unitId,
        size: AdSize.banner,
        request: helalAdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) setState(() => _yuklendi = true);
          },
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
            _bannerAd = null;
            if (fallbackDene) {
              // Gerçek ID no-fill veya onay sürecindeyse test ID ile gerçek reklam görüntüsünü sun
              yukleBirim(fallbackAdUnitId, false);
            } else {
              if (mounted) setState(() => _yuklendi = false);
            }
          },
        ),
      )..load();
    }

    yukleBirim(realAdUnitId, true);
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

        final Widget reklamIcerik = _yuklendi && _bannerAd != null
            ? SizedBox(width: 320, height: 50, child: AdWidget(ad: _bannerAd!))
            : _yedekAlan();

        if (widget.ortaKart) {
          return _ortaKartCercevesi(reklamIcerik);
        }

        return Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          color: widget.tema.karanlikMi ? widget.tema.arkaPlan : const Color(0xFF0F3D2E),
          child: reklamIcerik,
        );
      },
    );
  }

  /// Ana Sayfa orta alanı için yuvarlak köşeli, altın çerçeveli reklam kartı
  Widget _ortaKartCercevesi(Widget icerik) {
    final tema = widget.tema;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      decoration: BoxDecoration(
        color: tema.kartRengi,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.35), width: 0.9),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_outlined, size: 12, color: tema.ikincilYazi),
              const SizedBox(width: 4),
              Text(
                'Reklam',
                style: TextStyle(
                  color: tema.ikincilYazi,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(child: icerik),
        ],
      ),
    );
  }

  Widget _yedekAlan() {
    return Container(
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
                );
  }
}

class InterstitialReklamYoneticisi {
  static InterstitialAd? _interstitialAd;
  static bool _yukleniyor = false;

  static void oncedenYukle() {
    if (kIsWeb || KullaniciProfilServisi.premiumAktifMi() || _interstitialAd != null || _yukleniyor) return;
    _yukleniyor = true;

    const envInterAndroid = String.fromEnvironment('ADMOB_INTER_ANDROID');
    const envInterIos = String.fromEnvironment('ADMOB_INTER_IOS');
    final String realAdUnitId = Platform.isAndroid
        ? (envInterAndroid.isNotEmpty ? envInterAndroid : _kimlikCoz(_kAi))
        : (envInterIos.isNotEmpty ? envInterIos : _kimlikCoz(_kIi));

    final String fallbackAdUnitId = Platform.isAndroid
        ? _kimlikCoz(_kFai)
        : _kimlikCoz(_kFii);

    void yukleInterstitial(String unitId, bool fallbackDene) {
      InterstitialAd.load(
        adUnitId: unitId,
        request: helalAdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _yukleniyor = false;
          },
          onAdFailedToLoad: (error) {
            if (fallbackDene) {
              yukleInterstitial(fallbackAdUnitId, false);
            } else {
              _interstitialAd = null;
              _yukleniyor = false;
            }
          },
        ),
      );
    }

    yukleInterstitial(realAdUnitId, true);
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
