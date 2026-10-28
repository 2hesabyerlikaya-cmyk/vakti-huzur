import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'audio_bookmark_tracker_service.dart';
import 'dualar_ve_rabbena.dart';
import 'prayer_location_calendar_service.dart';
import 'quran_api_service.dart';
import 'quran_hadith_data.dart';
import 'share_story_sheet.dart';
import 'translations_and_logo.dart';
import 'widget_ve_kilit_ekrani_servisi.dart';
import 'quiz_sekmesi.dart';
import 'reklam_servisi.dart';
import 'zikirmatik_ve_esmaul_husna.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await reklamServisiniBaslat();
    InterstitialReklamYoneticisi.oncedenYukle();
  } catch (_) {}
  runApp(const IslamiUygulamaApp());
}

class UygulamaScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}



const List<IslamiTema> kTemalar = [
  // 1. Medine Yeşili & Kubbe (Varsayılan Açılış Teması)
  IslamiTema(
    id: 0,
    arkaPlan: Color(0xFF0B2219),
    kartRengi: Color(0xFF153A2B),
    vurguAltin: Color(0xFFD9B650),
    yumusakAltin: Color(0xFFF2E2B6),
    yaziRengi: Color(0xFFF4F8F5),
    ikincilYazi: Color(0xFFB7D4C5),
    karanlikMi: true,
    ikon: Icons.mosque_outlined,
  ),
  // 2. Kâbe Gece & Altın
  IslamiTema(
    id: 1,
    arkaPlan: Color(0xFF0A0A0D),
    kartRengi: Color(0xFF15161B),
    vurguAltin: Color(0xFFE5C158),
    yumusakAltin: Color(0xFFF7E7B4),
    yaziRengi: Color(0xFFFAFAFA),
    ikincilYazi: Color(0xFFB8B8C2),
    karanlikMi: true,
    ikon: Icons.nightlight_outlined,
  ),
  // 3. Bordo Yakut & Altın (#2A121B / #1E0B13 arka plan ve #D4AF37 altın vurgulu)
  IslamiTema(
    id: 2,
    arkaPlan: Color(0xFF1E0B13),
    kartRengi: Color(0xFF2A121B),
    vurguAltin: Color(0xFFD4AF37),
    yumusakAltin: Color(0xFFF3E5AB),
    yaziRengi: Color(0xFFFAF5F7),
    ikincilYazi: Color(0xFFD9B8C4),
    karanlikMi: true,
    ikon: Icons.diamond_outlined,
  ),
  // 4. Klasik Osmanlı Çini Mavisi
  IslamiTema(
    id: 3,
    arkaPlan: Color(0xFF071B26),
    kartRengi: Color(0xFF0F2D3E),
    vurguAltin: Color(0xFF56C8D8),
    yumusakAltin: Color(0xFFE8C97A),
    yaziRengi: Color(0xFFF2F8FA),
    ikincilYazi: Color(0xFFAACAD6),
    karanlikMi: true,
    ikon: Icons.auto_awesome_mosaic_outlined,
  ),
  // 5. Minimalist Nur / Bej
  IslamiTema(
    id: 4,
    arkaPlan: Color(0xFFF6F2E7),
    kartRengi: Color(0xFFFFFFFF),
    vurguAltin: Color(0xFF114232),
    yumusakAltin: Color(0xFF9C7618),
    yaziRengi: Color(0xFF162821),
    ikincilYazi: Color(0xFF546B62),
    karanlikMi: false,
    ikon: Icons.wb_sunny_outlined,
  ),
  // 6. Görsel Tema (Cami & Doğa Fotoğrafları - 34 HD Fotoğraf)
  IslamiTema(
    id: 5,
    arkaPlan: Color(0xFF071612),
    kartRengi: Color(0xCC0D231C),
    vurguAltin: Color(0xFFE5C158),
    yumusakAltin: Color(0xFFF7E7B4),
    yaziRengi: Color(0xFFFAF9F5),
    ikincilYazi: Color(0xFFC8DDD4),
    karanlikMi: true,
    gorselTemaMi: true,
    ikon: Icons.landscape_outlined,
  ),
];

// ============================================================================
// ANA UYGULAMA (GLOBAL TEMA, KALICI TEMA HAFIZASI, CANLI SLIDER VE 3 DİL YÖNETİMİ)
// ============================================================================

class IslamiUygulamaApp extends StatefulWidget {
  const IslamiUygulamaApp({super.key});

  @override
  State<IslamiUygulamaApp> createState() => _IslamiUygulamaAppState();
}

class _IslamiUygulamaAppState extends State<IslamiUygulamaApp> {
  late final ValueNotifier<int> _temaNotifier;
  final ValueNotifier<double> _yaziBoyutuNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<String> _dilNotifier = ValueNotifier<String>('TR');

  @override
  void initState() {
    super.initState();
    // Cihaz hafızasından (localStorage) en son seçilen temayı otomatik oku
    final kayitliTemaIdx =
        KaliciTemaHafizaServisi.kayitliTemaIndeksiniYukle(maxTemaSayisi: kTemalar.length);
    _temaNotifier = ValueNotifier<int>(kayitliTemaIdx);
    _temaNotifier.addListener(_temaDegistigindeKaydet);
  }

  void _temaDegistigindeKaydet() {
    KaliciTemaHafizaServisi.temaIndeksiniKaydet(_temaNotifier.value);
  }

  @override
  void dispose() {
    _temaNotifier.removeListener(_temaDegistigindeKaydet);
    _temaNotifier.dispose();
    _yaziBoyutuNotifier.dispose();
    _dilNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _temaNotifier,
      builder: (context, temaIdx, _) {
        final tema = kTemalar[temaIdx];
        return ValueListenableBuilder<String>(
          valueListenable: _dilNotifier,
          builder: (context, dil, _) {
            return ValueListenableBuilder<double>(
              valueListenable: _yaziBoyutuNotifier,
              builder: (context, yaziCarpani, _) {
                return MaterialApp(
                  title: Ceviri.m(dil, 'app_title'),
                  debugShowCheckedModeBanner: false,
                  scrollBehavior: UygulamaScrollBehavior(),
                  theme: ThemeData(
                    useMaterial3: true,
                    brightness: tema.karanlikMi ? Brightness.dark : Brightness.light,
                    fontFamily: 'Plus Jakarta Sans',
                    scaffoldBackgroundColor: tema.arkaPlan,
                    cardColor: tema.kartRengi,
                    colorScheme: ColorScheme(
                      brightness: tema.karanlikMi ? Brightness.dark : Brightness.light,
                      primary: tema.vurguAltin,
                      onPrimary: tema.arkaPlan,
                      secondary: tema.yumusakAltin,
                      onSecondary: tema.arkaPlan,
                      error: Colors.redAccent,
                      onError: Colors.white,
                      surface: tema.kartRengi,
                      onSurface: tema.yaziRengi,
                    ),
                    appBarTheme: AppBarTheme(
                      backgroundColor: tema.arkaPlan,
                      foregroundColor: tema.yumusakAltin,
                      elevation: 0,
                      centerTitle: true,
                    ),
                  ),
                  builder: (context, child) {
                    return Directionality(
                      textDirection: dil == 'AR' ? TextDirection.rtl : TextDirection.ltr,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(yaziCarpani),
                        ),
                        child: child!,
                      ),
                    );
                  },
                  home: VaktiHuzurAcilisKapisi(
                    child: AnaIskeletEkrani(
                      temaNotifier: _temaNotifier,
                      yaziBoyutuNotifier: _yaziBoyutuNotifier,
                      dilNotifier: _dilNotifier,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// YEREL AÇILIŞ EKRANI (SPLASH SCREEN - 1.5 SANİYE ZÜMRÜT & ALTIN GEÇİŞ)
// ============================================================================

class VaktiHuzurAcilisKapisi extends StatefulWidget {
  final Widget child;

  const VaktiHuzurAcilisKapisi({
    super.key,
    required this.child,
  });

  @override
  State<VaktiHuzurAcilisKapisi> createState() => _VaktiHuzurAcilisKapisiState();
}

class _VaktiHuzurAcilisKapisiState extends State<VaktiHuzurAcilisKapisi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _olcekAnim;
  late final Animation<double> _opaklikAnim;
  bool _gecisBasladi = false;
  bool _splashBitti = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _olcekAnim = Tween<double>(begin: 0.84, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _opaklikAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();

    // 1.5 saniye boyunca açılış ekranını göster, ardından zarif geçişle ana ekrana aç
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _gecisBasladi = true);
      Future.delayed(const Duration(milliseconds: 420), () {
        if (!mounted) return;
        setState(() => _splashBitti = true);
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_splashBitti)
          IgnorePointer(
            ignoring: _gecisBasladi,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              opacity: _gecisBasladi ? 0.0 : 1.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                scale: _gecisBasladi ? 1.06 : 1.0,
                child: Scaffold(
                  backgroundColor: const Color(0xFF091A13),
                  body: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.0, -0.15),
                        radius: 1.15,
                        colors: [
                          Color(0xFF133829),
                          Color(0xFF0B2219),
                          Color(0xFF06130E),
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // İslami Geometrik Desen Arka Planı
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ReelsIslamiDesenPainter(
                              desenTipi: 0,
                              altinRenk: const Color(0xFFD9B650),
                            ),
                          ),
                        ),
                        // Merkez: Altın Vakt-i Huzur Logosu ve Başlığı
                        FadeTransition(
                          opacity: _opaklikAnim,
                          child: ScaleTransition(
                            scale: _olcekAnim,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFD9B650).withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: const Color(0xFFD9B650).withValues(alpha: 0.45),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFD9B650).withValues(alpha: 0.25),
                                        blurRadius: 32,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const ModernIslamiLogo(
                                    boyut: 88,
                                    altinRenk: Color(0xFFD9B650),
                                    arkaPlanRenk: Color(0xFF0A291E),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Vakt-i Huzur',
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF2E2B6),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 1,
                                      color: const Color(0xFFD9B650).withValues(alpha: 0.5),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Icon(
                                        Icons.auto_awesome,
                                        size: 14,
                                        color: Color(0xFFD9B650),
                                      ),
                                    ),
                                    Container(
                                      width: 36,
                                      height: 1,
                                      color: const Color(0xFFD9B650).withValues(alpha: 0.5),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Kur’an-ı Kerim • Namaz Vakitleri • Sahih Hadis',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFB7D4C5),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: 110,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      minHeight: 3,
                                      backgroundColor:
                                          const Color(0xFFD9B650).withValues(alpha: 0.18),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFD9B650),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// ANA İSKELET EKRANI
// ============================================================================

class AnaIskeletEkrani extends StatefulWidget {
  final ValueNotifier<int> temaNotifier;
  final ValueNotifier<double> yaziBoyutuNotifier;
  final ValueNotifier<String> dilNotifier;

  const AnaIskeletEkrani({
    super.key,
    required this.temaNotifier,
    required this.yaziBoyutuNotifier,
    required this.dilNotifier,
  });

  @override
  State<AnaIskeletEkrani> createState() => _AnaIskeletEkraniState();
}

class _AnaIskeletEkraniState extends State<AnaIskeletEkrani> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _seciliSekmeIndex = 0;

  // Sonsuz (Infinite) Reels Akış Listesi - Her açılışta tamamen rastgele (Random)
  final List<DinamikReelsKart> _sonsuzReelsListesi = [];
  late final math.Random _rng;
  late final List<int> _karisikHadisIndeksleri;
  late final int _rastgeleArkaPlanOffset;
  int _ureticiSayac = 0;
  int _hadisSayac = 0;
  bool _yeniKartYukleniyor = false;

  @override
  void initState() {
    super.initState();
    _rng = math.Random(DateTime.now().microsecondsSinceEpoch);
    _rastgeleArkaPlanOffset = _rng.nextInt(997) + 1;
    _karisikHadisIndeksleri =
        List<int>.generate(kSahihHadisHavuzu.length, (i) => i)..shuffle(_rng);
    _baslangicReelsOlustur();
  }

  int _sonrakiKarisikHadisIndex() {
    final idx = _karisikHadisIndeksleri[_hadisSayac % _karisikHadisIndeksleri.length];
    _hadisSayac++;
    return idx;
  }

  void _baslangicReelsOlustur() {
    // Başlangıçta tamamen karıştırılmış Sahih Hadis havuzundan rastgele kartlar ekle
    // ve paralel olarak 1..6236 arasından rastgele Kur'an ayetlerini çek
    for (int i = 0; i < 4; i++) {
      final rastgeleStilSira = _rastgeleArkaPlanOffset + (_ureticiSayac++);
      _sonsuzReelsListesi.add(
        KuranApiServisi.sahihHadisReelsKartiOlustur(
          _sonrakiKarisikHadisIndex(),
          rastgeleStilSira,
        ),
      );
    }
    _sonrakiReelsBatchYukle(adet: 6, ilkAcilisMi: true);
  }

  Future<void> _sonrakiReelsBatchYukle({int adet = 4, bool ilkAcilisMi = false}) async {
    if (_yeniKartYukleniyor) return;
    _yeniKartYukleniyor = true;

    for (int i = 0; i < adet; i++) {
      final sira = _rastgeleArkaPlanOffset + (_ureticiSayac++);
      // 1 ile 6236 arasında tamamen rastgele Kur'an-ı Kerim ayeti çek
      final int hedefAyetNo = _rng.nextInt(6236) + 1;

      final canliAyetKart =
          await KuranApiServisi.canliAyetReelsKartiGetir(hedefAyetNo, sira);
      if (mounted) {
        setState(() {
          if (canliAyetKart != null) {
            if (ilkAcilisMi && i == 0 && _rng.nextBool()) {
              // İlk açılışta %50 ihtimalle en başa (0. indekse) rastgele Kur'an ayetini koy
              _sonsuzReelsListesi.insert(0, canliAyetKart);
            } else {
              _sonsuzReelsListesi.add(canliAyetKart);
            }
          }
          // Yanına karıştırılmış havuzdan 1 adet rastgele Sahih Hadis ekle
          final hadisStilSira = _rastgeleArkaPlanOffset + (_ureticiSayac++);
          _sonsuzReelsListesi.add(
            KuranApiServisi.sahihHadisReelsKartiOlustur(
              _sonrakiKarisikHadisIndex(),
              hadisStilSira,
            ),
          );
        });
      }
    }

    _yeniKartYukleniyor = false;
  }

  void _drawerAc() => _scaffoldKey.currentState?.openDrawer();

  void _kaydedilenleriGoster(IslamiTema tema, String dil) {
    final kaydedilenler = _sonsuzReelsListesi.where((e) => e.kaydedildi).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: tema.kartRengi,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bookmarks_rounded, color: tema.vurguAltin),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${Ceviri.m(dil, 'drawer_saved')} (${kaydedilenler.length})',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: tema.yaziRengi,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (kaydedilenler.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      Ceviri.m(dil, 'saved_empty'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tema.ikincilYazi, fontSize: 13.5),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: kaydedilenler.length,
                    itemBuilder: (context, idx) {
                      final item = kaydedilenler[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.auto_awesome, color: tema.vurguAltin),
                        title: Text(
                          item.kaynakKisa(dil),
                          style: TextStyle(
                            color: tema.vurguAltin,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          item.meal(dil),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: tema.yaziRengi),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _diniGunlerTakvimiGoster(IslamiTema tema, String dil) {
    final gunler = DiyanetDiniGunlerServisi.diniGunleriHesapla(sadeceYaklasanlar: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: tema.kartRengi,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.76,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_available_rounded, color: tema.vurguAltin),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Ceviri.m(dil, 'calendar_title'),
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: tema.yaziRengi,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dil == 'EN'
                      ? 'Presidency of Religious Affairs Official Hijri & Gregorian Calendar'
                      : dil == 'AR'
                          ? 'التقويم الرسمي لرئاسة الشؤون الدينية (هجري / ميلادي)'
                          : 'T.C. Diyanet İşleri Başkanlığı Resmi Hicrî / Milâdî Takvimi',
                  style: TextStyle(color: tema.ikincilYazi, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: gunler.length,
                    separatorBuilder: (_, _) => Divider(
                      color: tema.vurguAltin.withValues(alpha: 0.18),
                      height: 1,
                    ),
                    itemBuilder: (context, i) {
                      final g = gunler[i];
                      final gectiMi = g.kalanGun < 0;
                      final bugunMu = g.kalanGun == 0;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: CircleAvatar(
                          radius: 17,
                          backgroundColor: gectiMi
                              ? tema.ikincilYazi.withValues(alpha: 0.15)
                              : tema.vurguAltin.withValues(alpha: 0.18),
                          child: Icon(
                            bugunMu
                                ? Icons.auto_awesome_rounded
                                : gectiMi
                                    ? Icons.history_rounded
                                    : Icons. nights_stay_rounded,
                            size: 17,
                            color: gectiMi ? tema.ikincilYazi : tema.vurguAltin,
                          ),
                        ),
                        title: Text(
                          g.ad(dil),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: gectiMi
                                ? tema.ikincilYazi
                                : tema.yaziRengi,
                          ),
                        ),
                        subtitle: Text(
                          '${g.hicriTarih}  •  ${g.formatliMiladiTarih(dil)}',
                          style: TextStyle(color: tema.ikincilYazi, fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: bugunMu
                                ? tema.vurguAltin
                                : gectiMi
                                    ? tema.arkaPlan.withValues(alpha: 0.5)
                                    : tema.vurguAltin.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: gectiMi
                                  ? tema.ikincilYazi.withValues(alpha: 0.3)
                                  : tema.vurguAltin.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            g.kalanGunEtiketi(dil),
                            style: TextStyle(
                              color: bugunMu
                                  ? tema.arkaPlan
                                  : gectiMi
                                      ? tema.ikincilYazi
                                      : tema.vurguAltin,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = kTemalar[widget.temaNotifier.value];
    final dil = widget.dilNotifier.value;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _SolUstAyarlarDrawer(
        temaNotifier: widget.temaNotifier,
        yaziBoyutuNotifier: widget.yaziBoyutuNotifier,
        dilNotifier: widget.dilNotifier,
        onKaydedilenlerAc: () => _kaydedilenleriGoster(tema, dil),
        onDiniGunlerAc: () => _diniGunlerTakvimiGoster(tema, dil),
      ),
      body: IndexedStack(
        index: _seciliSekmeIndex,
        children: [
          AkisReelsSekmesi(
            icerikler: _sonsuzReelsListesi,
            tema: tema,
            dil: dil,
            onMenuAc: _drawerAc,
            onDahaFazlaYukle: () => _sonrakiReelsBatchYukle(adet: 3),
            onDurumGuncelle: () => setState(() {}),
          ),
          AnaSayfaSekmesi(
            tema: tema,
            dil: dil,
            onMenuAc: _drawerAc,
            begenilenler: _sonsuzReelsListesi.where((e) => e.begenildi).toList(),
          ),
          GunlukIslamiQuizSekmesi(
            tema: tema,
            dil: dil,
            onMenuAc: _drawerAc,
          ),
          KutuphaneSekmesi(
            tema: tema,
            dil: dil,
            onMenuAc: _drawerAc,
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sadece Ana Sayfa (1) ve Kütüphane (3) ekranlarında Helal Banner Reklam
          if (_seciliSekmeIndex == 1 || _seciliSekmeIndex == 3)
            InceBannerReklamWidget(tema: tema),
          Container(
            decoration: BoxDecoration(
              color: tema.karanlikMi ? tema.arkaPlan : const Color(0xFF0F3D2E),
          border: Border(
            top: BorderSide(
              color: tema.vurguAltin.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _seciliSekmeIndex,
            onTap: (idx) => setState(() => _seciliSekmeIndex = idx),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFFD4AF37),
            unselectedItemColor: const Color(0xFFA2BDB2),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11.5),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.amp_stories_outlined, size: 22),
                activeIcon: const Icon(Icons.auto_awesome_motion_rounded, size: 22),
                label: Ceviri.m(dil, 'tab_reels'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.mosque_outlined, size: 22),
                activeIcon: const Icon(Icons.mosque_rounded, size: 22),
                label: Ceviri.m(dil, 'tab_home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.quiz_outlined, size: 22),
                activeIcon: const Icon(Icons.quiz_rounded, size: 22),
                label: Ceviri.m(dil, 'tab_quiz'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu_book_outlined, size: 22),
                activeIcon: const Icon(Icons.menu_book_rounded, size: 22),
                label: Ceviri.m(dil, 'tab_library'),
              ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }
}

// ============================================================================
// SOL ÜST MENÜ (DRAWER)
// ============================================================================

class _SolUstAyarlarDrawer extends StatelessWidget {
  final ValueNotifier<int> temaNotifier;
  final ValueNotifier<double> yaziBoyutuNotifier;
  final ValueNotifier<String> dilNotifier;
  final VoidCallback onKaydedilenlerAc;
  final VoidCallback onDiniGunlerAc;

  const _SolUstAyarlarDrawer({
    required this.temaNotifier,
    required this.yaziBoyutuNotifier,
    required this.dilNotifier,
    required this.onKaydedilenlerAc,
    required this.onDiniGunlerAc,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: temaNotifier,
      builder: (context, seciliTemaIdx, _) {
        final tema = kTemalar[seciliTemaIdx];
        return ValueListenableBuilder<String>(
          valueListenable: dilNotifier,
          builder: (context, seciliDil, _) {
            return ValueListenableBuilder<double>(
              valueListenable: yaziBoyutuNotifier,
              builder: (context, yaziCarpani, _) {
                return Drawer(
                  width: 335,
                  backgroundColor: tema.arkaPlan,
                  child: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: tema.kartRengi,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              ModernIslamiLogo(
                                boyut: 40,
                                altinRenk: tema.vurguAltin,
                                arkaPlanRenk: tema.arkaPlan,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  Ceviri.m(seciliDil, 'app_title'),
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: tema.yaziRengi,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 1. ARKA PLAN TEMASI SEÇİMİ (KOMPAKT & SADE)
                        Text(
                          Ceviri.m(seciliDil, 'drawer_theme_title'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: tema.vurguAltin,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...kTemalar.map((t) {
                          final secili = t.id == seciliTemaIdx;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              color: secili
                                  ? tema.vurguAltin.withValues(alpha: 0.16)
                                  : tema.kartRengi,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: secili
                                    ? tema.vurguAltin
                                    : tema.vurguAltin.withValues(alpha: 0.2),
                                width: secili ? 1.4 : 0.8,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              visualDensity: const VisualDensity(horizontal: 0, vertical: -3),
                              minVerticalPadding: 0,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              onTap: () => temaNotifier.value = t.id,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: t.arkaPlan,
                                child: Icon(t.ikon, size: 15, color: t.vurguAltin),
                              ),
                              title: Text(
                                Ceviri.m(seciliDil, 'theme_${t.id}_name'),
                                style: TextStyle(
                                  fontSize: 12.8,
                                  fontWeight: FontWeight.bold,
                                  color: tema.yaziRengi,
                                ),
                              ),
                              trailing: secili
                                  ? Icon(Icons.check_circle_rounded, color: tema.vurguAltin, size: 18)
                                  : null,
                            ),
                          );
                        }),
                        const SizedBox(height: 16),

                        // 2. CANLI YAZI BOYUTU AYARI (SLIDER)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                Ceviri.m(seciliDil, 'drawer_font_title'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: tema.vurguAltin,
                                ),
                              ),
                            ),
                            Text(
                              '%${(yaziCarpani * 100).round()}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tema.vurguAltin,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: tema.kartRengi,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  yaziBoyutuNotifier.value =
                                      (yaziCarpani - 0.05).clamp(0.80, 1.45);
                                },
                                icon: Text(
                                  'A-',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: tema.ikincilYazi,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: yaziCarpani,
                                  min: 0.80,
                                  max: 1.45,
                                  divisions: 13,
                                  activeColor: tema.vurguAltin,
                                  label: '%${(yaziCarpani * 100).round()}',
                                  onChanged: (val) => yaziBoyutuNotifier.value = val,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  yaziBoyutuNotifier.value =
                                      (yaziCarpani + 0.05).clamp(0.80, 1.45);
                                },
                                icon: Text(
                                  'A+',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: tema.vurguAltin,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. AKTİF 3 DİL SEÇİMİ (TR / EN / AR)
                        Text(
                          Ceviri.m(seciliDil, 'drawer_lang_title'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: tema.vurguAltin,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final d in [
                              {'kod': 'TR', 'ad': 'Türkçe'},
                              {'kod': 'EN', 'ad': 'English'},
                              {'kod': 'AR', 'ad': 'العربية'},
                            ])
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: ChoiceChip(
                                    label: Center(
                                      child: Text(
                                        d['ad']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: seciliDil == d['kod']
                                              ? tema.arkaPlan
                                              : tema.yaziRengi,
                                        ),
                                      ),
                                    ),
                                    selected: seciliDil == d['kod'],
                                    selectedColor: tema.vurguAltin,
                                    backgroundColor: tema.kartRengi,
                                    showCheckmark: false,
                                    onSelected: (_) => dilNotifier.value = d['kod']!,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: tema.vurguAltin.withValues(alpha: 0.2)),

                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                          leading: Icon(Icons.touch_app_rounded, color: tema.vurguAltin),
                          title: Text(
                            seciliDil == 'EN'
                                ? 'Digital Tasbih & Dhikr Counter'
                                : seciliDil == 'AR'
                                    ? 'المسبحة الإلكترونية والأذكار'
                                    : 'Dijital Zikirmatik & Tesbihat',
                            style: TextStyle(
                              color: tema.yaziRengi,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: tema.ikincilYazi),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ZikirmatikTamEkran(
                                  arkaPlan: tema.arkaPlan,
                                  kartRengi: tema.kartRengi,
                                  vurguAltin: tema.vurguAltin,
                                  yumusakAltin: tema.yumusakAltin,
                                  yaziRengi: tema.yaziRengi,
                                  ikincilYazi: tema.ikincilYazi,
                                  dil: seciliDil,
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                          leading: Icon(Icons.auto_awesome_rounded, color: tema.vurguAltin),
                          title: Text(
                            seciliDil == 'EN'
                                ? '99 Names of Allah (Asma-ul Husna)'
                                : seciliDil == 'AR'
                                    ? 'أسماء الله الحسنى (٩٩)'
                                    : '99 Esmaü’l Hüsna',
                            style: TextStyle(
                              color: tema.yaziRengi,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: tema.ikincilYazi),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EsmaulHusnaTamEkran(
                                  arkaPlan: tema.arkaPlan,
                                  kartRengi: tema.kartRengi,
                                  vurguAltin: tema.vurguAltin,
                                  yumusakAltin: tema.yumusakAltin,
                                  yaziRengi: tema.yaziRengi,
                                  ikincilYazi: tema.ikincilYazi,
                                  dil: seciliDil,
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                          leading: Icon(Icons.bookmark_added_rounded, color: tema.vurguAltin),
                          title: Text(
                            Ceviri.m(seciliDil, 'drawer_saved'),
                            style: TextStyle(
                              color: tema.yaziRengi,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: tema.ikincilYazi),
                          onTap: () {
                            Navigator.pop(context);
                            onKaydedilenlerAc();
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                          leading: Icon(Icons.notifications_active_outlined, color: tema.vurguAltin),
                          title: Text(
                            seciliDil == 'EN'
                                ? 'Notification Settings'
                                : seciliDil == 'AR'
                                    ? 'إعدادات التنبيهات'
                                    : 'Bildirim Ayarları',
                            style: TextStyle(
                              color: tema.yaziRengi,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: tema.ikincilYazi),
                          onTap: () {
                            Navigator.pop(context);
                            BildirimAyarlariServisi.panelGoster(
                              context,
                              arkaPlan: tema.arkaPlan,
                              kartRengi: tema.kartRengi,
                              vurguAltin: tema.vurguAltin,
                              yumusakAltin: tema.yumusakAltin,
                              yaziRengi: tema.yaziRengi,
                              ikincilYazi: tema.ikincilYazi,
                              dil: seciliDil,
                            );
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                          leading: Icon(Icons.widgets_rounded, color: tema.vurguAltin),
                          title: Text(
                            seciliDil == 'EN'
                                ? 'Lock Screen & Home Widgets'
                                : seciliDil == 'AR'
                                    ? 'إعدادات الويدجت وشاشة القفل'
                                    : 'Kilit Ekranı & Widget Ayarları',
                            style: TextStyle(
                              color: tema.yaziRengi,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: tema.ikincilYazi),
                          onTap: () {
                            Navigator.pop(context);
                            VaktiHuzurWidgetServisi.panelGoster(
                              context,
                              arkaPlan: tema.arkaPlan,
                              kartRengi: tema.kartRengi,
                              vurguAltin: tema.vurguAltin,
                              yumusakAltin: tema.yumusakAltin,
                              yaziRengi: tema.yaziRengi,
                              ikincilYazi: tema.ikincilYazi,
                              dil: seciliDil,
                            );
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                          leading: Icon(Icons.record_voice_over_rounded, color: tema.vurguAltin),
                          title: Text(
                            seciliDil == 'EN'
                                ? 'Quran Reciter Selection'
                                : seciliDil == 'AR'
                                    ? 'اختيار القارئ'
                                    : 'Kuran Tilaveti Hafız Seçimi',
                            style: TextStyle(
                              color: tema.yaziRengi,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          subtitle: ValueListenableBuilder<HafizModel>(
                            valueListenable: KuranSesOynaticiServisi.seciliHafiz,
                            builder: (context, h, _) => Text(
                              h.ad,
                              style: TextStyle(color: tema.ikincilYazi, fontSize: 11),
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: tema.ikincilYazi),
                          onTap: () {
                            Navigator.pop(context);
                            _hafizSeciciSheetGoster(context, tema: tema, dil: seciliDil);
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                          leading: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4AF37)),
                          title: Text(
                            seciliDil == 'EN'
                                ? 'Ad-Free Package & Support'
                                : seciliDil == 'AR'
                                    ? 'الباقة الخالية من الإعلانات ودعم التطبيق'
                                    : 'Reklamsız Paket & Destek Ol',
                            style: TextStyle(
                              color: tema.yaziRengi,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6)),
                            ),
                            child: const Text(
                              'DESTEK',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _premiumVeDestekSheetGoster(context, tema: tema, dil: seciliDil);
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                          leading: Icon(Icons.calendar_month_rounded, color: tema.vurguAltin),
                          title: Text(
                            Ceviri.m(seciliDil, 'drawer_calendar'),
                            style: TextStyle(
                              color: tema.yaziRengi,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: tema.ikincilYazi),
                          onTap: () {
                            Navigator.pop(context);
                            onDiniGunlerAc();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

void _hafizSeciciSheetGoster(BuildContext context, {required IslamiTema tema, required String dil}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: tema.arkaPlan,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.4)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: tema.vurguAltin.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.record_voice_over_rounded, color: tema.vurguAltin),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dil == 'EN'
                        ? 'Select Quran Reciter'
                        : dil == 'AR'
                            ? 'اختيار قارئ القرآن الكريم'
                            : 'Kur’an-ı Kerim Hafız Seçimi',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: tema.yaziRengi,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<HafizModel>(
              valueListenable: KuranSesOynaticiServisi.seciliHafiz,
              builder: (context, secili, _) {
                return Column(
                  children: kHafizlar.map((h) {
                    final aktif = h.kod == secili.kod;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: aktif
                            ? tema.vurguAltin.withValues(alpha: 0.16)
                            : tema.kartRengi,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: aktif
                              ? tema.vurguAltin
                              : tema.vurguAltin.withValues(alpha: 0.2),
                          width: aktif ? 1.4 : 0.8,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: tema.vurguAltin.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.mic_rounded,
                            color: tema.vurguAltin,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          h.ad,
                          style: TextStyle(
                            color: tema.yaziRengi,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        subtitle: Text(
                          '${h.ulke} • 128 kbps HD Kalite',
                          style: TextStyle(
                            color: tema.ikincilYazi,
                            fontSize: 11.5,
                          ),
                        ),
                        trailing: aktif
                            ? Icon(Icons.check_circle_rounded, color: tema.vurguAltin)
                            : null,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          KuranSesOynaticiServisi.hafizSec(h);
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void _premiumVeDestekSheetGoster(BuildContext context, {required IslamiTema tema, required String dil}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _PremiumVeDestekIcerik(tema: tema, dil: dil),
  );
}

class _PremiumVeDestekIcerik extends StatefulWidget {
  final IslamiTema tema;
  final String dil;

  const _PremiumVeDestekIcerik({required this.tema, required this.dil});

  @override
  State<_PremiumVeDestekIcerik> createState() => _PremiumVeDestekIcerikState();
}

class _PremiumVeDestekIcerikState extends State<_PremiumVeDestekIcerik> {
  int _seciliPaketIdx = 1;

  final List<Map<String, dynamic>> _secenekler = [
    {
      'baslik': 'Aylık Reklamsız',
      'fiyat': '29,99 TL / ay',
      'rozet': null,
    },
    {
      'baslik': 'Yıllık Reklamsız (%45 Tasarruf)',
      'fiyat': '199,99 TL / yıl',
      'rozet': 'EN POPÜLER',
    },
    {
      'baslik': 'Ömür Boyu Sınırsız',
      'fiyat': '399,99 TL (Tek Seferlik)',
      'rozet': 'ÖMÜR BOYU',
    },
  ];

  void _destekOlOnayla() {
    HapticFeedback.heavyImpact();
    KullaniciProfilServisi.premiumAyarla(true);
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.tema.kartRengi,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: widget.tema.vurguAltin, width: 1.2),
        ),
        title: Row(
          children: [
            Icon(Icons.volunteer_activism_rounded, color: widget.tema.vurguAltin, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.dil == 'EN' ? 'Thank You!' : 'Allah Kabul Eylesin!',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: widget.tema.yaziRengi,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          widget.dil == 'EN'
              ? 'Thank you for supporting Vakt-i Huzur! May Allah bless your good deeds and grant peace to your life.'
              : 'Vakt-i Huzur uygulamamızın gelişimine verdiğiniz destek ve dualarınız için teşekkür ederiz. Rabbimiz hayırlarınızı kat kat kabul eylesin.',
          style: TextStyle(color: widget.tema.yaziRengi.withValues(alpha: 0.9), fontSize: 13, height: 1.45),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.tema.vurguAltin),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              widget.dil == 'EN' ? 'Close' : 'Âmin, Kapat',
              style: TextStyle(color: widget.tema.arkaPlan, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _onayla() {
    HapticFeedback.heavyImpact();
    KullaniciProfilServisi.premiumAyarla(true);
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.tema.kartRengi,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: widget.tema.vurguAltin, width: 1.2),
        ),
        title: Row(
          children: [
            Icon(Icons.volunteer_activism_rounded, color: widget.tema.vurguAltin, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.dil == 'EN' ? 'Thank You!' : 'Allah Kabul Eylesin!',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: widget.tema.yaziRengi,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          widget.dil == 'EN'
              ? 'Thank you for supporting Vakt-i Huzur! May Allah bless your good deeds and grant peace to your life.'
              : 'Vakt-i Huzur uygulamamıza ve manevi hizmetlerimize verdiğiniz destek ve dualarınız için teşekkür ederiz. Rabbimiz hayırlarınızı kat kat kabul eylesin.',
          style: TextStyle(color: widget.tema.yaziRengi.withValues(alpha: 0.9), fontSize: 13, height: 1.45),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.tema.vurguAltin),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              widget.dil == 'EN' ? 'Close' : 'Âmin, Kapat',
              style: TextStyle(color: widget.tema.arkaPlan, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = widget.tema;
    final dil = widget.dil;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: tema.arkaPlan,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.4)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: tema.vurguAltin.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4AF37), size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dil == 'EN' ? 'Ad-Free Package & Support' : 'Reklamsız Paket & Destek Ol',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: tema.yaziRengi,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: tema.ikincilYazi),
                ),
              ],
            ),
            Text(
              dil == 'EN'
                  ? 'Enjoy seamless, ad-free spiritual tranquility and contribute to Islamic education & apps.'
                  : 'Tamamen reklamsız, kesintisiz manevi huzur yaşayın ve İslami ilim-rehberlik hizmetimize katkı sağlayın.',
              style: TextStyle(color: tema.ikincilYazi, fontSize: 12),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: _secenekler.length,
                itemBuilder: (context, idx) {
                  final item = _secenekler[idx];
                  final secili = _seciliPaketIdx == idx;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: secili ? tema.vurguAltin.withValues(alpha: 0.16) : tema.kartRengi,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: secili ? tema.vurguAltin : tema.vurguAltin.withValues(alpha: 0.22),
                        width: secili ? 1.6 : 0.8,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _seciliPaketIdx = idx);
                      },
                      leading: Icon(
                        secili ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        color: secili ? tema.vurguAltin : tema.ikincilYazi,
                        size: 20,
                      ),
                      title: Text(
                        item['baslik'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: tema.yaziRengi,
                        ),
                      ),
                      subtitle: Text(
                        item['fiyat'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: tema.vurguAltin,
                        ),
                      ),
                      trailing: item['rozet'] != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: tema.vurguAltin.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                item['rozet'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: tema.vurguAltin,
                                ),
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: tema.vurguAltin,
                foregroundColor: tema.arkaPlan,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _onayla,
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(
                dil == 'EN' ? 'Confirm & Go Ad-Free' : 'Seçimi Onayla & Reklamsız Kullan',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 14),
            // SADELEŞTİRİLMİŞ DESTEK OL BÖLÜMÜ
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tema.kartRengi,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: tema.vurguAltin.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: tema.vurguAltin.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.volunteer_activism_rounded, color: tema.vurguAltin, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          dil == 'EN'
                              ? 'Support the App'
                              : dil == 'AR'
                                  ? 'دعم التطبيق'
                                  : 'Uygulamaya Destek Ol',
                          style: TextStyle(
                            color: tema.yaziRengi,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dil == 'EN'
                        ? 'You can support the ongoing development of the app.'
                        : dil == 'AR'
                            ? 'يمكنك التبرع لدعم وتطوير هذا التطبيق.'
                            : 'Uygulamanın gelişimi için destekte bulunabilirsiniz.',
                    style: TextStyle(color: tema.ikincilYazi, fontSize: 12, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tema.vurguAltin,
                      side: BorderSide(color: tema.vurguAltin, width: 1.3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _destekOlOnayla,
                    icon: const Icon(Icons.favorite_rounded, size: 16),
                    label: Text(
                      dil == 'EN' ? 'Support Now' : dil == 'AR' ? 'تبرع الآن' : 'Destekte Bulun',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 1. SEKME: SONSUZ (INFINITE) REELS AYET & HADİS AKIŞI + 12 FARKLI ARKA PLAN
// ============================================================================

class AkisReelsSekmesi extends StatefulWidget {
  final List<DinamikReelsKart> icerikler;
  final IslamiTema tema;
  final String dil;
  final VoidCallback onMenuAc;
  final VoidCallback onDahaFazlaYukle;
  final VoidCallback onDurumGuncelle;

  const AkisReelsSekmesi({
    super.key,
    required this.icerikler,
    required this.tema,
    required this.dil,
    required this.onMenuAc,
    required this.onDahaFazlaYukle,
    required this.onDurumGuncelle,
  });

  @override
  State<AkisReelsSekmesi> createState() => _AkisReelsSekmesiState();
}

class _AkisReelsSekmesiState extends State<AkisReelsSekmesi> {
  final PageController _pageController = PageController();
  DateTime _sonTekerlekZamani = DateTime.fromMillisecondsSinceEpoch(0);
  final int _rastgeleFotoOffset =
      math.Random(DateTime.now().microsecondsSinceEpoch)
          .nextInt(kGorselTemaFotograflari.length);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _fareTekerlegiKaydir(PointerScrollEvent event) {
    final simdi = DateTime.now();
    if (simdi.difference(_sonTekerlekZamani).inMilliseconds < 400) return;
    if (event.scrollDelta.dy > 12) {
      _sonTekerlekZamani = simdi;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else if (event.scrollDelta.dy < -12) {
      _sonTekerlekZamani = simdi;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _paylas(DinamikReelsKart item) {
    PaylasimStoryBottomSheet.goster(context, item, widget.dil);
  }

  void _begeniYap(DinamikReelsKart item) {
    final kayitliIsim = KullaniciProfilServisi.rumuzGetir();
    if (kayitliIsim == null || kayitliIsim.isEmpty) {
      _rumuzGirisiDialogGoster(onOnay: (yeniRumuz) {
        KullaniciProfilServisi.rumuzKaydet(yeniRumuz);
        HapticFeedback.mediumImpact();
        setState(() {
          item.begenildi = true;
          item.begeniSayisi++;
        });
        widget.onDurumGuncelle();
      });
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        item.begenildi = !item.begenildi;
        item.begeniSayisi = item.begenildi
            ? item.begeniSayisi + 1
            : (item.begeniSayisi > 0 ? item.begeniSayisi - 1 : 0);
      });
      widget.onDurumGuncelle();
    }
  }

  void _rumuzGirisiDialogGoster({required ValueChanged<String> onOnay}) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.tema.kartRengi,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: widget.tema.vurguAltin, width: 1.2),
        ),
        title: Row(
          children: [
            Icon(Icons.person_pin_rounded, color: widget.tema.vurguAltin, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.dil == 'EN' ? 'Add Your Name / Handle' : 'Adınızı / Rumuzunuzu Girin',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.tema.yaziRengi,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dil == 'EN'
                  ? 'No password or sign-up needed. Enter your name to appear as "Ahmet Y. and 120 others liked this".'
                  : 'Şifre veya üyelik gerekmez. Beğendiğiniz ayet ve hadislerde "Ahmet Y. ve 120 kişi beğendi" şeklinde görünmesi için adınızı veya rumuzunuzu giriniz.',
              style: TextStyle(color: widget.tema.ikincilYazi, fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              style: TextStyle(color: widget.tema.yaziRengi, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: widget.dil == 'EN' ? 'Your Name (e.g. Ahmet Y.)' : 'Adınız / Rumuz (Örn: Ahmet Y.)',
                hintStyle: TextStyle(color: widget.tema.ikincilYazi.withValues(alpha: 0.6)),
                filled: true,
                fillColor: widget.tema.arkaPlan,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.tema.vurguAltin.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.tema.vurguAltin, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              widget.dil == 'EN' ? 'Cancel' : 'Vazgeç',
              style: TextStyle(color: widget.tema.ikincilYazi),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.tema.vurguAltin),
            onPressed: () {
              final girilen = ctrl.text.trim();
              if (girilen.isNotEmpty) {
                Navigator.pop(ctx);
                onOnay(girilen);
              }
            },
            child: Text(
              widget.dil == 'EN' ? 'Save & Like' : 'Kaydet ve Beğen',
              style: TextStyle(color: widget.tema.arkaPlan, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color goldAccent = Color(0xFFD4AF37);
    const Color softGold = Color(0xFFF3E5AB);
    final dil = widget.dil;

    return Listener(
      onPointerSignal: (signal) {
        if (signal is PointerScrollEvent) _fareTekerlegiKaydir(signal);
      },
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              // Kullanıcı son 4 karta yaklaştığında otomatik olarak yeni Kur'an ayetleri ve hadisler çek!
              if (index >= widget.icerikler.length - 4) {
                widget.onDahaFazlaYukle();
              }
            },
            itemCount: widget.icerikler.length,
            itemBuilder: (context, index) {
              final item = widget.icerikler[index];
              final fotoUrl = kGorselTemaFotograflari[
                  (index + _rastgeleFotoOffset) % kGorselTemaFotograflari.length];

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.arkaPlanRenkleri,
                  ),
                ),
                child: Stack(
                  children: [
                    // 6. Tema ("Görsel Tema") seçiliyse 12 farklı Cami/Doğa fotoğrafı dönüşümlü gösterilir
                    if (widget.tema.gorselTemaMi) ...[
                      Positioned.fill(
                        child: Image.network(
                          fotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.62),
                                Colors.black.withValues(alpha: 0.72),
                                Colors.black.withValues(alpha: 0.85),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // 32 Renk Paleti + 8 Farklı İslami Geometrik / Kubbe / Şemse Arka Plan Motifi
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ReelsIslamiDesenPainter(
                          desenTipi: item.desenIndex,
                          altinRenk: goldAccent,
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 660),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 58, 66, 12),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: goldAccent.withValues(alpha: 0.16),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: goldAccent.withValues(alpha: 0.55),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      item.ayetMi
                                                          ? Icons.menu_book_rounded
                                                          : Icons.auto_awesome_rounded,
                                                      color: goldAccent,
                                                      size: 13,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      item.turBasligi(dil),
                                                      style: const TextStyle(
                                                        color: softGold,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Flexible(
                                                child: Text(
                                                  item.konu(dil),
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.8),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Ana Ayet / Hadis Kartı
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 22,
                                              vertical: 20,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.28),
                                              borderRadius: BorderRadius.circular(22),
                                              border: Border.all(
                                                color: goldAccent.withValues(alpha: 0.35),
                                                width: 0.9,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  item.arapcaMetin,
                                                  textAlign: TextAlign.center,
                                                  textDirection: TextDirection.rtl,
                                                  style: const TextStyle(
                                                    fontFamily: 'Amiri',
                                                    fontSize: 27,
                                                    height: 1.75,
                                                    color: softGold,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 14),
                                                Text(
                                                  item.meal(dil),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontFamily: 'Lora',
                                                    fontSize: 16,
                                                    height: 1.5,
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                                const SizedBox(height: 14),
                                                Text(
                                                  '— ${item.kaynakKisa(dil)} —',
                                                  style: const TextStyle(
                                                    color: goldAccent,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          // Kısa Tefsir Kutusu
                                          Container(
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.05),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: goldAccent.withValues(alpha: 0.22),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.auto_stories_outlined,
                                                      color: goldAccent,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      Ceviri.m(dil, 'short_tafsir'),
                                                      style: const TextStyle(
                                                        color: goldAccent,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  item.tefsir(dil),
                                                  style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.88),
                                                    fontSize: 13,
                                                    height: 1.45,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          // Doğrulanmış Kaynak Rozeti
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0A291E).withValues(alpha: 0.78),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: goldAccent.withValues(alpha: 0.38),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.verified_user_outlined,
                                                  color: goldAccent,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    item.dogrulanmis(dil),
                                                    style: TextStyle(
                                                      color: softGold.withValues(alpha: 0.92),
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // İsimli Beğeni Alanı ("Ahmet Y. ve 120 kişi beğendi")
                                          Builder(
                                            builder: (context) {
                                              final rumuz = KullaniciProfilServisi.rumuzGetir();
                                              String begeniSatiri;
                                              if (item.begenildi) {
                                                final ad = rumuz ?? (dil == 'EN' ? 'You' : 'Siz');
                                                final digerleri = item.begeniSayisi > 1 ? item.begeniSayisi - 1 : 0;
                                                begeniSatiri = digerleri > 0
                                                    ? (dil == 'EN'
                                                        ? '$ad and $digerleri others liked this'
                                                        : '$ad ve $digerleri kişi beğendi')
                                                    : (dil == 'EN' ? '$ad liked this' : '$ad beğendi');
                                              } else {
                                                final ornekIsim = item.id.hashCode.abs() % 2 == 0 ? 'Ahmet Y.' : 'Hilal K.';
                                                final digerleri = item.begeniSayisi > 1 ? item.begeniSayisi - 1 : item.begeniSayisi;
                                                begeniSatiri = item.begeniSayisi > 0
                                                    ? (dil == 'EN'
                                                        ? '$ornekIsim and $digerleri others liked this'
                                                        : '$ornekIsim ve $digerleri kişi beğendi')
                                                    : (dil == 'EN' ? 'Be the first to like' : 'İlk beğenen siz olun');
                                              }

                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(10),
                                                  onTap: () => _begeniYap(item),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF0A291E).withValues(alpha: 0.72),
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: item.begenildi
                                                            ? const Color(0xFFE57373).withValues(alpha: 0.75)
                                                            : goldAccent.withValues(alpha: 0.28),
                                                        width: 0.8,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          item.begenildi ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                          color: item.begenildi ? const Color(0xFFE57373) : softGold,
                                                          size: 14,
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Flexible(
                                                          child: Text(
                                                            begeniSatiri,
                                                            style: TextStyle(
                                                              color: item.begenildi ? const Color(0xFFFFCDD2) : softGold.withValues(alpha: 0.92),
                                                              fontSize: 11,
                                                              fontWeight: item.begenildi ? FontWeight.bold : FontWeight.w500,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      size: 15,
                                      color: softGold.withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      Ceviri.m(dil, 'swipe_hint'),
                                      style: TextStyle(
                                        color: softGold.withValues(alpha: 0.6),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Sağ Kenar Zarif Cam Butonlar (Dinle, Beğen, Kaydet, Paylaş)
                    Positioned(
                      right: 14,
                      bottom: 44,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. SESLİ DİNLE BUTONU (Mişari Raşid el-Afasi MP3 / Seslendirme)
                          ValueListenableBuilder<bool>(
                            valueListenable: KuranSesOynaticiServisi.caliyorMu,
                            builder: (context, caliyor, _) {
                              return ValueListenableBuilder<String?>(
                                valueListenable: KuranSesOynaticiServisi.aktifKartId,
                                builder: (context, aktifId, _) {
                                  final buKartCaliyor = caliyor && aktifId == item.id;
                                  final etiket = buKartCaliyor
                                      ? (dil == 'EN'
                                          ? 'Playing'
                                          : dil == 'AR'
                                              ? 'يُتلى'
                                              : 'Okunuyor')
                                      : (dil == 'EN'
                                          ? 'Listen'
                                          : dil == 'AR'
                                              ? 'استمع'
                                              : 'Dinle');
                                  return _ZarifCamButon(
                                    icon: buKartCaliyor
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.volume_up_rounded,
                                    etiket: etiket,
                                    aktif: buKartCaliyor,
                                    aktifRenk: goldAccent,
                                    onTap: () {
                                      if (item.ayetMi && item.globalAyetNo != null) {
                                        KuranSesOynaticiServisi.tekAyetOynatDuraklat(
                                          globalAyetNo: item.globalAyetNo!,
                                          kartId: item.id,
                                        );
                                      } else {
                                        KuranSesOynaticiServisi.hadisSeslendirDuraklat(
                                          kartId: item.id,
                                          arapcaMetin: item.arapcaMetin,
                                          mealMetin: item.meal(dil),
                                        );
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _ZarifCamButon(
                            icon: item.begenildi
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            etiket: '${item.begeniSayisi}',
                            aktif: item.begenildi,
                            aktifRenk: const Color(0xFFE57373),
                            onTap: () => _begeniYap(item),
                          ),
                          const SizedBox(height: 14),
                          _ZarifCamButon(
                            icon: item.kaydedildi
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            etiket: item.kaydedildi
                                ? Ceviri.m(dil, 'saved')
                                : Ceviri.m(dil, 'save'),
                            aktif: item.kaydedildi,
                            aktifRenk: goldAccent,
                            onTap: () {
                              setState(() => item.kaydedildi = !item.kaydedildi);
                              widget.onDurumGuncelle();
                            },
                          ),
                          const SizedBox(height: 14),
                          _ZarifCamButon(
                            icon: Icons.ios_share_rounded,
                            etiket: Ceviri.m(dil, 'share'),
                            aktif: false,
                            onTap: () => _paylas(item),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Üst Bar: Sol Üst Hamburger Menü + Modern İslami Uygulama Logosu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onMenuAc,
                    icon: const Icon(Icons.menu_rounded, color: softGold, size: 24),
                  ),
                  const SizedBox(width: 6),
                  const ModernIslamiLogo(boyut: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      Ceviri.m(dil, 'flow_title'),
                      style: const TextStyle(
                        fontFamily: 'Lora',
                        color: softGold,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZarifCamButon extends StatelessWidget {
  final IconData icon;
  final String etiket;
  final bool aktif;
  final Color aktifRenk;
  final VoidCallback onTap;

  const _ZarifCamButon({
    required this.icon,
    required this.etiket,
    required this.aktif,
    this.aktifRenk = const Color(0xFFD4AF37),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: aktif
                        ? aktifRenk.withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  icon,
                  color: aktif ? aktifRenk : Colors.white.withValues(alpha: 0.9),
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            etiket,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. SEKME: ANA SAYFA
// ============================================================================

class AnaSayfaSekmesi extends StatefulWidget {
  final IslamiTema tema;
  final String dil;
  final VoidCallback onMenuAc;
  final List<DinamikReelsKart> begenilenler;

  const AnaSayfaSekmesi({
    super.key,
    required this.tema,
    required this.dil,
    required this.onMenuAc,
    required this.begenilenler,
  });

  @override
  State<AnaSayfaSekmesi> createState() => _AnaSayfaSekmesiState();
}

class _AnaSayfaSekmesiState extends State<AnaSayfaSekmesi> {
  late Timer _timer;
  Timer? _sensorTimer;
  DateTime _simdi = DateTime.now();
  double _pusulaAcisi = 0.0;
  bool _oncekiKibleDogrulandi = true;
  bool _canliSensorAktif = true;
  bool _konumYukleniyor = false;

  CanliNamazVakitleriModel _vakitModel = CanliNamazVakitleriModel(
    konumAdi: 'İstanbul',
    enlem: 41.0082,
    boylam: 28.9784,
    imsak: '05:48',
    gunes: '07:14',
    ogle: '12:56',
    ikindi: '15:52',
    aksam: '18:24',
    yatsi: '19:44',
    hicriTarihTr: '14 Cemâziyelevvel 1448',
    hicriTarihEn: '14 Jumada al-Ula 1448 AH',
    hicriTarihAr: '١٤ جمادى الأولى ١٤٤٨ هـ',
    miladiTarihTr: '27 Ekim 2026 Salı',
    miladiTarihEn: 'Tuesday, 27 October 2026',
    miladiTarihAr: 'الثلاثاء 27 أكتوبر 2026 م',
    kibleAcisiDerece: NamazVeKonumServisi.kibleAcisiHesapla(41.0082, 28.9784),
    kabeMesafeKm: NamazVeKonumServisi.kabeMesafeHesaplaKm(41.0082, 28.9784),
  );

  @override
  void initState() {
    super.initState();
    // Çevrimdışı (internetsiz) açılış için önce cihaz hafızasındaki (localStorage) son vakitleri yükle
    final kayitliVakit = NamazVeKonumServisi.hafizadakiSonVakitleriGetir();
    if (kayitliVakit != null) {
      _vakitModel = kayitliVakit;
    }
    _sehirVakitleriniYukle(_vakitModel.konumAdi);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _simdi = DateTime.now());
    });

    // Mobil cihaz yönelim sensörü dinleyicisi (Canlı Kıble Pusulası)
    _sensorTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted || !_canliSensorAktif) return;
      final cihazYonu = CanliPusulaSensorServisi.cihazPusulaAcisiOku();
      if (cihazYonu >= 0) {
        double fark = (_vakitModel.kibleAcisiDerece - cihazYonu) % 360.0;
        if (fark > 180.0) fark -= 360.0;
        if (fark < -180.0) fark += 360.0;
        if ((fark - _pusulaAcisi).abs() >= 0.8) {
          _pusulaAcisiniAyarla(fark, manuelMi: false);
        }
      }
    });
  }

  void _pusulaAcisiniAyarla(double yeniAci, {bool manuelMi = true}) {
    final sinirli = yeniAci.clamp(-180.0, 180.0);
    final simdiDogrulandi = sinirli.abs() <= 3.0;
    if (simdiDogrulandi && !_oncekiKibleDogrulandi) {
      CanliPusulaSensorServisi.kibleDogrulandiTitresim();
    } else if (manuelMi) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      if (manuelMi) _canliSensorAktif = false;
      _pusulaAcisi = sinirli;
      _oncekiKibleDogrulandi = simdiDogrulandi;
    });
  }

  Future<void> _sehirVakitleriniYukle(String sehirSorgu) async {
    setState(() => _konumYukleniyor = true);
    final yeniModel = await NamazVeKonumServisi.sehirAramasiIleVakitleriGetir(sehirSorgu);
    if (mounted) {
      setState(() {
        _vakitModel = yeniModel;
        _pusulaAcisi = 0.0;
        _konumYukleniyor = false;
      });
      _widgetOtomatikSenkronizeEt();
    }
  }

  void _widgetOtomatikSenkronizeEt() {
    try {
      final sonraki = _sonrakiVaktiHesapla();
      final siradakiKey = sonraki['key'] as String;
      final kalanSure = sonraki['kalan'] as Duration;
      final saat = kalanSure.inHours.toString().padLeft(2, '0');
      final dk = (kalanSure.inMinutes % 60).toString().padLeft(2, '0');
      VaktiHuzurWidgetServisi.widgetVerileriniSenkronizeEt(
        vakitModel: _vakitModel,
        siradakiVakitAdi: Ceviri.m(widget.dil, siradakiKey),
        kalanSureMetni: '${saat}s ${dk}dk',
        dil: widget.dil,
      );
    } catch (_) {}
  }

  Future<void> _gpsKonumunuBulVeYukle() async {
    setState(() => _konumYukleniyor = true);
    final yeniModel = await NamazVeKonumServisi.gpsKonumundanVakitleriGetir();
    if (mounted) {
      setState(() {
        _vakitModel = yeniModel;
        _pusulaAcisi = 0.0;
        _konumYukleniyor = false;
      });
      _widgetOtomatikSenkronizeEt();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: widget.tema.kartRengi,
          behavior: SnackBarBehavior.floating,
          content: Text(
            '📍 ${yeniModel.konumAdi} (${yeniModel.enlem.toStringAsFixed(3)}°, ${yeniModel.boylam.toStringAsFixed(3)}°) — Diyanet vakitleri ve Kıble açısı (${yeniModel.kibleAcisiDerece.toStringAsFixed(1)}°) güncellendi.',
            style: TextStyle(color: widget.tema.yaziRengi, fontSize: 12.5),
          ),
        ),
      );
    }
  }

  void _sehirAramaPenceresiAc() {
    final tema = widget.tema;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KonumVeSehirSeciciSheet(
        arkaPlan: tema.arkaPlan,
        kartRengi: tema.kartRengi,
        vurguAltin: tema.vurguAltin,
        yaziRengi: tema.yaziRengi,
        ikincilYazi: tema.ikincilYazi,
        dil: widget.dil,
        onSehirSecildi: _sehirVakitleriniYukle,
        onGpsKonumBul: _gpsKonumunuBulVeYukle,
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _sensorTimer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get _canliVakitListesi {
    List<int> parcala(String s) {
      final p = s.split(':');
      if (p.length >= 2) {
        return [int.tryParse(p[0]) ?? 0, int.tryParse(p[1]) ?? 0];
      }
      return [0, 0];
    }

    final im = parcala(_vakitModel.imsak);
    final gu = parcala(_vakitModel.gunes);
    final og = parcala(_vakitModel.ogle);
    final ik = parcala(_vakitModel.ikindi);
    final ak = parcala(_vakitModel.aksam);
    final ya = parcala(_vakitModel.yatsi);

    return [
      {'key': 'imsak', 'saat': _vakitModel.imsak, 'saatInt': im[0], 'dakikaInt': im[1], 'ikon': Icons.nightlight_outlined},
      {'key': 'gunes', 'saat': _vakitModel.gunes, 'saatInt': gu[0], 'dakikaInt': gu[1], 'ikon': Icons.wb_twilight_rounded},
      {'key': 'ogle', 'saat': _vakitModel.ogle, 'saatInt': og[0], 'dakikaInt': og[1], 'ikon': Icons.wb_sunny_outlined},
      {'key': 'ikindi', 'saat': _vakitModel.ikindi, 'saatInt': ik[0], 'dakikaInt': ik[1], 'ikon': Icons.sunny_snowing},
      {'key': 'aksam', 'saat': _vakitModel.aksam, 'saatInt': ak[0], 'dakikaInt': ak[1], 'ikon': Icons.nights_stay_outlined},
      {'key': 'yatsi', 'saat': _vakitModel.yatsi, 'saatInt': ya[0], 'dakikaInt': ya[1], 'ikon': Icons.bedtime_outlined},
    ];
  }

  Map<String, dynamic> _sonrakiVaktiHesapla() {
    final vakitler = _canliVakitListesi;
    for (int i = 0; i < vakitler.length; i++) {
      final v = vakitler[i];
      final z = DateTime(_simdi.year, _simdi.month, _simdi.day, v['saatInt'] as int, v['dakikaInt'] as int);
      if (z.isAfter(_simdi)) {
        return {'index': i, 'key': v['key'], 'saat': v['saat'], 'kalan': z.difference(_simdi)};
      }
    }
    final yarin = DateTime(_simdi.year, _simdi.month, _simdi.day + 1, vakitler[0]['saatInt'] as int, vakitler[0]['dakikaInt'] as int);
    return {'index': 0, 'key': vakitler[0]['key'], 'saat': vakitler[0]['saat'], 'kalan': yarin.difference(_simdi)};
  }

  String _sureFormatla(Duration d) {
    final s = d.inHours.toString().padLeft(2, '0');
    final dk = (d.inMinutes % 60).toString().padLeft(2, '0');
    final sn = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$s : $dk : $sn';
  }

  @override
  Widget build(BuildContext context) {
    final tema = widget.tema;
    final dil = widget.dil;
    final vakitler = _canliVakitListesi;
    final sonraki = _sonrakiVaktiHesapla();
    final int sonrakiIdx = sonraki['index'] as int;
    final String sonrakiAd = Ceviri.m(dil, sonraki['key'] as String);
    final double kibleDerece = _vakitModel.kibleAcisiDerece;
    final yaklasanDiniGunler =
        DiyanetDiniGunlerServisi.diniGunleriHesapla(sadeceYaklasanlar: true).take(6).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: tema.vurguAltin),
          onPressed: widget.onMenuAc,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModernIslamiLogo(
              boyut: 32,
              altinRenk: tema.vurguAltin,
              arkaPlanRenk: tema.arkaPlan,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                Ceviri.m(dil, 'app_title'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  color: tema.yaziRengi,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // GPS Konumumu Bul Butonu
          IconButton(
            tooltip: dil == 'EN'
                ? 'Find My Location (GPS)'
                : dil == 'AR'
                    ? 'تحديد موقعي'
                    : 'Konumumu Bul (GPS)',
            onPressed: _konumYukleniyor ? null : _gpsKonumunuBulVeYukle,
            icon: _konumYukleniyor
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tema.vurguAltin,
                    ),
                  )
                : Icon(Icons.my_location_rounded, color: tema.vurguAltin, size: 20),
          ),
          // Şehir / İlçe Arama ve Seçme Butonu
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _sehirAramaPenceresiAc,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: tema.kartRengi,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _vakitModel.gpsKaynakliMi
                          ? Icons.gps_fixed_rounded
                          : Icons.location_on_outlined,
                      color: tema.vurguAltin,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 115),
                      child: Text(
                        _vakitModel.konumAdi,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tema.yaziRengi,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.search_rounded, color: tema.vurguAltin, size: 15),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (tema.gorselTemaMi) ...[
            Positioned.fill(
              child: Image.network(
                kAnaSayfaKabeGorselUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.black.withValues(alpha: 0.84),
                    ],
                  ),
                ),
              ),
            ),
          ],
          SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                  // 0. SON OKUDUĞUN YERE DÖN (KUR'AN-I KERİM AYRACI) KARTI
                  ValueListenableBuilder<KuranAyracModel>(
                    valueListenable: KuranAyracServisi.ayracNotifier,
                    builder: (context, ayrac, _) {
                      final sure = ayrac.sureMeta;
                      final sureBaslik = dil == 'EN'
                          ? 'Surah ${sure.adEn}, Verse ${ayrac.ayetNo}'
                          : dil == 'AR'
                              ? 'سورة ${sure.arapca}، الآية ${ayrac.ayetNo}'
                              : '${sure.adTr} Suresi, ${ayrac.ayetNo}. Ayet';
                      final ustEtiket = dil == 'EN'
                          ? 'CONTINUE READING QUR’AN (BOOKMARK)'
                          : dil == 'AR'
                              ? 'متابعة القراءة من الفاصلة المرجعية'
                              : 'SON OKUDUĞUN YERE DÖN (KUR’AN AYRACI)';
                      final devamMetni = dil == 'EN'
                          ? 'Continue →'
                          : dil == 'AR'
                              ? 'متابعة ←'
                              : 'Devam Et →';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              tema.kartRengi,
                              tema.vurguAltin.withValues(alpha: 0.16),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: tema.vurguAltin.withValues(alpha: 0.55),
                            width: 1.2,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SureDetayOkumaEkrani(
                                  sureMeta: sure,
                                  tema: tema,
                                  dil: dil,
                                  baslangicAyetNo: ayrac.ayetNo,
                                  baslangicMushafModu: ayrac.mushafModuMu,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: tema.vurguAltin.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: tema.vurguAltin.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.bookmark_added_rounded,
                                    color: tema.vurguAltin,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ustEtiket,
                                        style: TextStyle(
                                          color: tema.vurguAltin,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        sureBaslik,
                                        style: TextStyle(
                                          fontFamily: 'Lora',
                                          color: tema.yaziRengi,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: tema.vurguAltin,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    devamMetni,
                                    style: TextStyle(
                                      color: tema.arkaPlan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: tema.kartRengi,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.45), width: 1.2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _vakitModel.tarihBanner(dil),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tema.ikincilYazi,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            ActionChip(
                              avatar: Icon(Icons.my_location_rounded, size: 15, color: tema.vurguAltin),
                              label: Text(
                                dil == 'EN'
                                    ? 'Find My Location (GPS)'
                                    : dil == 'AR'
                                        ? 'موقعي عبر GPS'
                                        : 'Konumumu Bul (GPS)',
                                style: TextStyle(fontSize: 11.5, color: tema.yaziRengi),
                              ),
                              backgroundColor: tema.arkaPlan.withValues(alpha: 0.55),
                              side: BorderSide(color: tema.vurguAltin.withValues(alpha: 0.35)),
                              onPressed: _konumYukleniyor ? null : _gpsKonumunuBulVeYukle,
                            ),
                            ActionChip(
                              avatar: Icon(Icons.travel_explore_rounded, size: 15, color: tema.vurguAltin),
                              label: Text(
                                dil == 'EN'
                                    ? 'Search City / District'
                                    : dil == 'AR'
                                        ? 'ابحث عن مدينة'
                                        : 'Şehir / İlçe Ara (81 İl & Dünya)',
                                style: TextStyle(fontSize: 11.5, color: tema.yaziRengi),
                              ),
                              backgroundColor: tema.arkaPlan.withValues(alpha: 0.55),
                              side: BorderSide(color: tema.vurguAltin.withValues(alpha: 0.35)),
                              onPressed: _sehirAramaPenceresiAc,
                            ),
                            ActionChip(
                              avatar: Icon(
                                Icons.notifications_active_rounded,
                                size: 15,
                                color: tema.vurguAltin,
                              ),
                              label: Text(
                                dil == 'EN'
                                    ? 'Notifications'
                                    : dil == 'AR'
                                        ? 'التنبيهات'
                                        : 'Bildirim Ayarları',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: tema.yaziRengi,
                                ),
                              ),
                              backgroundColor: tema.vurguAltin.withValues(alpha: 0.16),
                              side: BorderSide(color: tema.vurguAltin.withValues(alpha: 0.55)),
                              onPressed: () {
                                BildirimAyarlariServisi.panelGoster(
                                  context,
                                  arkaPlan: tema.arkaPlan,
                                  kartRengi: tema.kartRengi,
                                  vurguAltin: tema.vurguAltin,
                                  yumusakAltin: tema.yumusakAltin,
                                  yaziRengi: tema.yaziRengi,
                                  ikincilYazi: tema.ikincilYazi,
                                  dil: dil,
                                  konumAdi: _vakitModel.konumAdi,
                                  siradakiVakitAdi: sonrakiAd,
                                  siradakiVakitSaat: sonraki['saat'] as String,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dil == 'TR'
                              ? '$sonrakiAd ${Ceviri.m(dil, 'remaining_time')}'
                              : '${Ceviri.m(dil, 'remaining_time')} $sonrakiAd',
                          style: TextStyle(color: tema.yaziRengi, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _sureFormatla(sonraki['kalan'] as Duration),
                          style: TextStyle(
                            color: tema.vurguAltin,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$sonrakiAd ${Ceviri.m(dil, 'adhan_label')}: ${sonraki['saat']}  •  ${_vakitModel.konumAdi} (${Ceviri.m(dil, 'diyanet_cal')})',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tema.ikincilYazi, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  ...List.generate(vakitler.length, (i) {
                    final v = vakitler[i];
                    final aktif = i == sonrakiIdx;
                    final vakitAdi = Ceviri.m(dil, v['key'] as String);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: aktif ? tema.vurguAltin.withValues(alpha: 0.14) : tema.kartRengi,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: aktif ? tema.vurguAltin : tema.vurguAltin.withValues(alpha: 0.2),
                          width: aktif ? 1.3 : 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(v['ikon'] as IconData, color: tema.vurguAltin, size: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              vakitAdi,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: aktif ? FontWeight.bold : FontWeight.w500,
                                color: tema.yaziRengi,
                              ),
                            ),
                          ),
                          if (aktif)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: tema.vurguAltin,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                Ceviri.m(dil, 'next_badge'),
                                style: TextStyle(
                                  color: tema.arkaPlan,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Text(
                            v['saat'] as String,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: aktif ? tema.vurguAltin : tema.yaziRengi,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // GÜNLÜK 5 VAKİT NAMAZ TAKİP ÇİZELGESİ KARTI
                  GunlukNamazTakipKarti(
                    arkaPlan: tema.arkaPlan,
                    kartRengi: tema.kartRengi,
                    vurguAltin: tema.vurguAltin,
                    yumusakAltin: tema.yumusakAltin,
                    yaziRengi: tema.yaziRengi,
                    ikincilYazi: tema.ikincilYazi,
                    dil: dil,
                  ),
                  const SizedBox(height: 16),

                  // KAZA NAMAZI TAKİP ÇETELESİ KARTI (6 VAKİT + TOPLU SAYI GİRİŞİ)
                  KazaNamaziTakipKarti(
                    arkaPlan: tema.arkaPlan,
                    kartRengi: tema.kartRengi,
                    vurguAltin: tema.vurguAltin,
                    yumusakAltin: tema.yumusakAltin,
                    yaziRengi: tema.yaziRengi,
                    ikincilYazi: tema.ikincilYazi,
                    dil: dil,
                  ),
                  const SizedBox(height: 16),

                  // HIZLI ERİŞİM: DİJİTAL ZİKİRMATİK & 99 ESMAÜ'L HÜSNA KARTLARI
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ZikirmatikTamEkran(
                                  arkaPlan: tema.arkaPlan,
                                  kartRengi: tema.kartRengi,
                                  vurguAltin: tema.vurguAltin,
                                  yumusakAltin: tema.yumusakAltin,
                                  yaziRengi: tema.yaziRengi,
                                  ikincilYazi: tema.ikincilYazi,
                                  dil: dil,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: tema.kartRengi,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.45)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.touch_app_rounded, color: tema.vurguAltin, size: 22),
                                    Icon(Icons.arrow_forward_ios_rounded, color: tema.vurguAltin, size: 13),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  dil == 'EN'
                                      ? 'Digital Tasbih'
                                      : dil == 'AR'
                                          ? 'المسبحة الإلكترونية'
                                          : 'Dijital Zikirmatik',
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    color: tema.yaziRengi,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                ValueListenableBuilder<int>(
                                  valueListenable: ZikirmatikHafizaServisi.toplamZikirNotifier,
                                  builder: (context, toplam, _) {
                                    return Text(
                                      dil == 'EN'
                                          ? 'Tasbihat • Total: $toplam'
                                          : dil == 'AR'
                                              ? 'التسبيحات • الإجمالي: $toplam'
                                              : 'Tesbihat • Toplam: $toplam',
                                      style: TextStyle(color: tema.vurguAltin, fontSize: 11.5),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EsmaulHusnaTamEkran(
                                  arkaPlan: tema.arkaPlan,
                                  kartRengi: tema.kartRengi,
                                  vurguAltin: tema.vurguAltin,
                                  yumusakAltin: tema.yumusakAltin,
                                  yaziRengi: tema.yaziRengi,
                                  ikincilYazi: tema.ikincilYazi,
                                  dil: dil,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: tema.kartRengi,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.45)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, color: tema.vurguAltin, size: 22),
                                    Icon(Icons.arrow_forward_ios_rounded, color: tema.vurguAltin, size: 13),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  dil == 'EN'
                                      ? '99 Asma-ul Husna'
                                      : dil == 'AR'
                                          ? 'أسماء الله الحسنى'
                                          : '99 Esmaü’l Hüsna',
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    color: tema.yaziRengi,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  dil == 'EN'
                                      ? '99 Names & Dhikr Counts'
                                      : dil == 'AR'
                                          ? '٩٩ اسماً مع الأذكار'
                                          : '99 İsm-i Şerif & Zikirleri',
                                  style: TextStyle(color: tema.vurguAltin, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // KİLİT EKRANI & ANA EKRAN WİDGET AYARLARI KARTI (SAMSUNG/ANDROID & iPHONE)
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      final sonraki = _sonrakiVaktiHesapla();
                      final siradakiKey = sonraki['key'] as String;
                      final kalan = sonraki['kalan'] as Duration;
                      final s = kalan.inHours.toString().padLeft(2, '0');
                      final d = (kalan.inMinutes % 60).toString().padLeft(2, '0');
                      VaktiHuzurWidgetServisi.panelGoster(
                        context,
                        arkaPlan: tema.arkaPlan,
                        kartRengi: tema.kartRengi,
                        vurguAltin: tema.vurguAltin,
                        yumusakAltin: tema.yumusakAltin,
                        yaziRengi: tema.yaziRengi,
                        ikincilYazi: tema.ikincilYazi,
                        dil: dil,
                        vakitModel: _vakitModel,
                        siradakiVakitAdi: Ceviri.m(dil, siradakiKey),
                        kalanSureMetni: '${s}s ${d}dk',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tema.kartRengi,
                            tema.vurguAltin.withValues(alpha: 0.14),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: tema.vurguAltin.withValues(alpha: 0.5),
                          width: 1.1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: tema.vurguAltin.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.widgets_rounded,
                              color: tema.vurguAltin,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dil == 'EN'
                                      ? 'Lock Screen & Home Widgets'
                                      : dil == 'AR'
                                          ? 'إعدادات الويدجت وشاشة القفل'
                                          : 'Kilit Ekranı & Ana Ekran Widget’ları',
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    color: tema.yaziRengi,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dil == 'EN'
                                      ? 'Samsung / Android & iPhone Prayer Times & Daily Verse Widgets'
                                      : 'Samsung / Android & iPhone Namaz Vakti ve Günün Ayeti Widget’ı',
                                  style: TextStyle(
                                    color: tema.vurguAltin,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: tema.vurguAltin,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Günün Duası
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: tema.kartRengi,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.volunteer_activism_outlined, color: tema.vurguAltin, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              Ceviri.m(dil, 'dua_title'),
                              style: TextStyle(
                                fontFamily: 'Lora',
                                color: tema.vurguAltin,
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 24,
                            height: 1.7,
                            color: tema.yumusakAltin,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          Ceviri.m(dil, 'dua_meaning'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 14.5,
                            fontStyle: FontStyle.italic,
                            color: tema.yaziRengi,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Ceviri.m(dil, 'dua_source'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tema.ikincilYazi, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. KONUMA GÖRE GERÇEK KIBLE PUSULASI (CANLI SENSÖR + AÇI KAYDIRICISI + ±3° DOĞRULAMA)
                  Builder(
                    builder: (context) {
                      final bool kibleDogrulandi = _pusulaAcisi.abs() <= 3.0;
                      const Color dogrulamaYesilAltin = Color(0xFF2ECC71);
                      final Color aktifPusulaRengi =
                          kibleDogrulandi ? dogrulamaYesilAltin : tema.vurguAltin;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: tema.kartRengi,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kibleDogrulandi
                                ? dogrulamaYesilAltin.withValues(alpha: 0.85)
                                : tema.vurguAltin.withValues(alpha: 0.45),
                            width: kibleDogrulandi ? 1.8 : 1.0,
                          ),
                          boxShadow: kibleDogrulandi
                              ? [
                                  BoxShadow(
                                    color: dogrulamaYesilAltin.withValues(alpha: 0.22),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.explore_outlined, color: aktifPusulaRengi, size: 22),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          Ceviri.m(dil, 'qibla_title'),
                                          style: TextStyle(
                                            fontFamily: 'Lora',
                                            color: aktifPusulaRengi,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: aktifPusulaRengi.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_vakitModel.konumAdi}: ${kibleDerece.toStringAsFixed(1)}°',
                                    style: TextStyle(
                                      color: aktifPusulaRengi,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dil == 'EN'
                                  ? 'Coordinates: ${_vakitModel.enlem.toStringAsFixed(3)}°N, ${_vakitModel.boylam.toStringAsFixed(3)}°E  •  Distance to Kaaba: ${_vakitModel.kabeMesafeKm.round()} km'
                                  : dil == 'AR'
                                      ? 'الإحداثيات: ${_vakitModel.enlem.toStringAsFixed(2)}°، ${_vakitModel.boylam.toStringAsFixed(2)}°  •  المسافة للكعبة: ${_vakitModel.kabeMesafeKm.round()} كم'
                                      : 'Koordinat: ${_vakitModel.enlem.toStringAsFixed(3)}°K, ${_vakitModel.boylam.toStringAsFixed(3)}°D  •  Kâbe’ye Mesafe: ${_vakitModel.kabeMesafeKm.round()} km',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: tema.ikincilYazi, fontSize: 11.5),
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanUpdate: (details) {
                                final center = const Offset(96, 96);
                                final localPos = details.localPosition - center;
                                if (localPos.distance > 12) {
                                  final touchAngleDeg =
                                      math.atan2(localPos.dx, -localPos.dy) * (180.0 / math.pi);
                                  double yeniSapma = (touchAngleDeg - kibleDerece) % 360.0;
                                  if (yeniSapma > 180.0) yeniSapma -= 360.0;
                                  if (yeniSapma < -180.0) yeniSapma += 360.0;
                                  _pusulaAcisiniAyarla(yeniSapma, manuelMi: true);
                                }
                              },
                              child: Container(
                                width: 192,
                                height: 192,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: kibleDogrulandi
                                      ? [
                                          BoxShadow(
                                            color: dogrulamaYesilAltin.withValues(alpha: 0.32),
                                            blurRadius: 24,
                                            spreadRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: kibleDerece + _pusulaAcisi),
                                  duration: const Duration(milliseconds: 220),
                                  builder: (context, aci, _) {
                                    return CustomPaint(
                                      painter: _KiblePusulasiPainter(
                                        kibleAcisiDerece: aci,
                                        altinRenk: aktifPusulaRengi,
                                        kibleDogrulandi: kibleDogrulandi,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // KIBLE YÖNÜ DOĞRULANDI (±3°) DURUM ROZETİ
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: kibleDogrulandi
                                    ? dogrulamaYesilAltin.withValues(alpha: 0.18)
                                    : tema.arkaPlan.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: kibleDogrulandi
                                      ? dogrulamaYesilAltin
                                      : tema.vurguAltin.withValues(alpha: 0.3),
                                  width: kibleDogrulandi ? 1.4 : 0.9,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    kibleDogrulandi
                                        ? Icons.verified_rounded
                                        : Icons.compass_calibration_rounded,
                                    color: aktifPusulaRengi,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      kibleDogrulandi
                                          ? (dil == 'EN'
                                              ? 'Qibla Direction Verified (±${_pusulaAcisi.abs().toStringAsFixed(1)}°)'
                                              : dil == 'AR'
                                                  ? 'تم التحقق من اتجاه القبلة (±${_pusulaAcisi.abs().toStringAsFixed(1)}°)'
                                                  : 'Kıble Yönü Doğrulandı (Sapma: ${_pusulaAcisi.toStringAsFixed(0)}°)')
                                          : (dil == 'EN'
                                              ? 'Turn ${(_pusulaAcisi > 0 ? "Left" : "Right")} by ${_pusulaAcisi.abs().toStringAsFixed(0)}° to align with Qibla'
                                              : dil == 'AR'
                                                  ? 'قم بالمحاذاة بمقدار ${_pusulaAcisi.abs().toStringAsFixed(0)}° نحو القبلة'
                                                  : 'Kıble için ${_pusulaAcisi.abs().toStringAsFixed(0)}° ${_pusulaAcisi > 0 ? "Sola" : "Sağa"} Hizalayın'),
                                      style: TextStyle(
                                        color: kibleDogrulandi ? dogrulamaYesilAltin : tema.yaziRengi,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // MASAÜSTÜ VE HASSAS TEST İÇİN CANLI AÇI KAYDIRICISI (SLIDER: -180° .. +180°)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                children: [
                                  Text(
                                    '-180°',
                                    style: TextStyle(color: tema.ikincilYazi, fontSize: 11),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _pusulaAcisi.clamp(-180.0, 180.0),
                                      min: -180.0,
                                      max: 180.0,
                                      divisions: 120,
                                      activeColor: aktifPusulaRengi,
                                      label: '${_pusulaAcisi.round()}°',
                                      onChanged: (val) => _pusulaAcisiniAyarla(val, manuelMi: true),
                                    ),
                                  ),
                                  Text(
                                    '+180°',
                                    style: TextStyle(color: tema.ikincilYazi, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _pusulaAcisiniAyarla(_pusulaAcisi - 15, manuelMi: true),
                                  icon: const Icon(Icons.rotate_left_rounded, size: 17),
                                  label: Text(
                                    Ceviri.m(dil, 'turn_left'),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: aktifPusulaRengi,
                                    foregroundColor: tema.arkaPlan,
                                  ),
                                  onPressed: () {
                                    CanliPusulaSensorServisi.sensorIzniIste();
                                    _canliSensorAktif = true;
                                    _oncekiKibleDogrulandi = false;
                                    _pusulaAcisiniAyarla(0.0, manuelMi: false);
                                  },
                                  icon: const Icon(Icons.my_location_rounded, size: 16),
                                  label: Text(
                                    Ceviri.m(dil, 'align_qibla'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _pusulaAcisiniAyarla(_pusulaAcisi + 15, manuelMi: true),
                                  icon: const Icon(Icons.rotate_right_rounded, size: 17),
                                  label: Text(
                                    Ceviri.m(dil, 'turn_right'),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. DİYANET TAKVİMİNE UYGUN GERÇEK DİNİ GÜNLER VE BAYRAMLAR KARTI
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: tema.kartRengi,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.45)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, color: tema.vurguAltin, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                Ceviri.m(dil, 'calendar_title'),
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  color: tema.vurguAltin,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...yaklasanDiniGunler.map((g) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: tema.arkaPlan.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.22)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        g.ad(dil),
                                        style: TextStyle(
                                          color: tema.yaziRengi,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${g.hicriTarih}  •  ${g.formatliMiladiTarih(dil)}',
                                        style: TextStyle(color: tema.ikincilYazi, fontSize: 11.5),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: tema.vurguAltin.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.45)),
                                  ),
                                  child: Text(
                                    g.kalanGunEtiketi(dil),
                                    style: TextStyle(
                                      color: tema.vurguAltin,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

              // 5. BEĞENİLEN AYET & HADİSLER VİTRİN KARTI
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tema.kartRengi,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.45)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFFE57373),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Ceviri.m(dil, 'liked_showcase_title'),
                              style: TextStyle(
                                fontFamily: 'Lora',
                                color: tema.vurguAltin,
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: tema.vurguAltin.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.begenilenler.length}',
                            style: TextStyle(
                              color: tema.vurguAltin,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.begenilenler.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          Ceviri.m(dil, 'liked_empty'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tema.ikincilYazi,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      )
                    else
                      ...widget.begenilenler.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: tema.arkaPlan.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: tema.vurguAltin.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.kaynakKisa(dil),
                                      style: TextStyle(
                                        color: tema.vurguAltin,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    tooltip: Ceviri.m(dil, 'share'),
                                    onPressed: () =>
                                        PaylasimStoryBottomSheet.goster(context, item, dil),
                                    icon: Icon(
                                      Icons.ios_share_rounded,
                                      size: 17,
                                      color: tema.vurguAltin,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                item.arapcaMetin,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 21,
                                  height: 1.65,
                                  color: tema.yumusakAltin,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.meal(dil),
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 13.5,
                                  fontStyle: FontStyle.italic,
                                  color: tema.yaziRengi,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
          ),
        ],
      ),
    );
  }
}

class _KiblePusulasiPainter extends CustomPainter {
  final double kibleAcisiDerece;
  final Color altinRenk;
  final bool kibleDogrulandi;

  _KiblePusulasiPainter({
    required this.kibleAcisiDerece,
    required this.altinRenk,
    this.kibleDogrulandi = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    if (kibleDogrulandi) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = altinRenk.withValues(alpha: 0.14)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = altinRenk.withValues(alpha: kibleDogrulandi ? 0.85 : 0.45)
        ..strokeWidth = kibleDogrulandi ? 2.8 : 2.0
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      center,
      radius - 14,
      Paint()
        ..color = altinRenk.withValues(alpha: 0.18)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    for (int i = 0; i < 36; i++) {
      final rad = (i * 10) * math.pi / 180;
      final anaYon = i % 9 == 0;
      final p1 = Offset(
        center.dx + (radius - (anaYon ? 12 : 6)) * math.cos(rad),
        center.dy + (radius - (anaYon ? 12 : 6)) * math.sin(rad),
      );
      final p2 = Offset(
        center.dx + radius * math.cos(rad),
        center.dy + radius * math.sin(rad),
      );
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = altinRenk.withValues(alpha: anaYon ? 0.85 : 0.35)
          ..strokeWidth = anaYon ? 2 : 1,
      );
    }

    final kibleRad = (kibleAcisiDerece - 90) * math.pi / 180;
    final ucNokta = Offset(
      center.dx + (radius - 22) * math.cos(kibleRad),
      center.dy + (radius - 22) * math.sin(kibleRad),
    );

    canvas.drawLine(
      center,
      ucNokta,
      Paint()
        ..color = altinRenk
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawRect(
      Rect.fromCenter(center: ucNokta, width: 14, height: 14),
      Paint()..color = const Color(0xFF111111),
    );
    canvas.drawRect(
      Rect.fromCenter(center: ucNokta, width: 14, height: 14),
      Paint()
        ..color = altinRenk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(center, 5, Paint()..color = altinRenk);
  }

  @override
  bool shouldRepaint(covariant _KiblePusulasiPainter oldDelegate) =>
      oldDelegate.kibleAcisiDerece != kibleAcisiDerece ||
      oldDelegate.kibleDogrulandi != kibleDogrulandi ||
      oldDelegate.altinRenk != altinRenk;
}

// ============================================================================
// 3. SEKME: KÜTÜPHANE (114 SURENİN TAMAMI + ARAMA ÇUBUĞU + HADİS KÜLLİYATI)
// ============================================================================

class KutuphaneSekmesi extends StatefulWidget {
  final IslamiTema tema;
  final String dil;
  final VoidCallback onMenuAc;

  const KutuphaneSekmesi({
    super.key,
    required this.tema,
    required this.dil,
    required this.onMenuAc,
  });

  @override
  State<KutuphaneSekmesi> createState() => _KutuphaneSekmesiState();
}

class _KutuphaneSekmesiState extends State<KutuphaneSekmesi> {
  String _aramaMetni = '';

  @override
  Widget build(BuildContext context) {
    final tema = widget.tema;
    final dil = widget.dil;

    final filtrelenmisSureler = kTum114Sure.where((s) {
      if (_aramaMetni.trim().isEmpty) return true;
      final q = _aramaMetni.toLowerCase();
      return s.no.toString().contains(q) ||
          s.adTr.toLowerCase().contains(q) ||
          s.adEn.toLowerCase().contains(q) ||
          s.anlamTr.toLowerCase().contains(q) ||
          s.anlamEn.toLowerCase().contains(q) ||
          s.arapca.contains(q);
    }).toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu_rounded, color: tema.vurguAltin),
            onPressed: widget.onMenuAc,
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernIslamiLogo(
                boyut: 30,
                altinRenk: tema.vurguAltin,
                arkaPlanRenk: tema.arkaPlan,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  Ceviri.m(dil, 'lib_title'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.bold,
                    color: tema.yaziRengi,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: tema.vurguAltin,
                  side: BorderSide(color: tema.vurguAltin.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZikirmatikTamEkran(
                        arkaPlan: tema.arkaPlan,
                        kartRengi: tema.kartRengi,
                        vurguAltin: tema.vurguAltin,
                        yumusakAltin: tema.yumusakAltin,
                        yaziRengi: tema.yaziRengi,
                        ikincilYazi: tema.ikincilYazi,
                        dil: dil,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.touch_app_rounded, size: 16),
                label: Text(
                  dil == 'EN' ? 'Tasbih' : dil == 'AR' ? 'المسبحة' : 'Zikirmatik',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            indicatorColor: tema.vurguAltin,
            labelColor: tema.vurguAltin,
            unselectedLabelColor: tema.ikincilYazi,
            tabs: [
              Tab(text: '${Ceviri.m(dil, 'tab_quran')} (114)'),
              Tab(
                text: dil == 'EN'
                    ? '99 Names of Allah'
                    : dil == 'AR'
                        ? 'أسماء الله (٩٩)'
                        : '99 Esmaü’l Hüsna',
              ),
              Tab(
                text: dil == 'EN'
                    ? 'Duas & Rabbana'
                    : dil == 'AR'
                        ? 'الأدعية وربنا'
                        : 'Dualar & Rabbena',
              ),
              Tab(text: '${Ceviri.m(dil, 'tab_hadith')} (${kSahihHadisHavuzu.length})'),
            ],
          ),
        ),
        body: Stack(
          children: [
            if (tema.gorselTemaMi) ...[
              Positioned.fill(
                child: Image.network(
                  kKutuphaneMescidiNebeviGorselUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.74),
                        Colors.black.withValues(alpha: 0.86),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 740),
                  child: TabBarView(
                    children: [
                // 1. KUR'AN-I KERİM: 114 SURENİN TAMAMI & ARAMA ÇUBUĞU
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: TextField(
                        onChanged: (val) => setState(() => _aramaMetni = val),
                        style: TextStyle(color: tema.yaziRengi, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: Ceviri.m(dil, 'search_surah'),
                          hintStyle: TextStyle(color: tema.ikincilYazi, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded, color: tema.vurguAltin),
                          filled: true,
                          fillColor: tema.kartRengi,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: tema.vurguAltin.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: tema.vurguAltin.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        itemCount: filtrelenmisSureler.length,
                        itemBuilder: (context, idx) {
                          final sure = filtrelenmisSureler[idx];
                          final sureAdi = dil == 'EN'
                              ? 'Surah ${sure.adEn}'
                              : dil == 'AR'
                                  ? 'سورة ${sure.arapca}'
                                  : '${sure.adTr} Suresi';
                          final sureAnlami = dil == 'EN' ? sure.anlamEn : sure.anlamTr;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: tema.vurguAltin.withValues(alpha: 0.24)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SureDetayOkumaEkrani(
                                      sureMeta: sure,
                                      tema: tema,
                                      dil: dil,
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: tema.vurguAltin.withValues(alpha: 0.16),
                                child: Text(
                                  '${sure.no}',
                                  style: TextStyle(
                                    color: tema.vurguAltin,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              title: Text(
                                sureAdi,
                                style: TextStyle(fontWeight: FontWeight.bold, color: tema.yaziRengi),
                              ),
                              subtitle: Text(
                                '$sureAnlami • ${sure.yer} • ${sure.ayetSayisi} ${Ceviri.m(dil, 'verse_unit')}',
                                style: TextStyle(fontSize: 12, color: tema.ikincilYazi),
                              ),
                              trailing: Text(
                                sure.arapca,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 22,
                                  color: tema.yumusakAltin,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // 2. 99 ESMAÜ'L HÜSNA SEKMESİ (TÜM 99 İSİM + ZİKİR ÇEK + DİNLE + PAYLAŞ)
                EsmaulHusnaListeWidget(
                  arkaPlan: tema.arkaPlan,
                  kartRengi: tema.kartRengi,
                  vurguAltin: tema.vurguAltin,
                  yumusakAltin: tema.yumusakAltin,
                  yaziRengi: tema.yaziRengi,
                  ikincilYazi: tema.ikincilYazi,
                  dil: dil,
                ),

                // 3. GÜNLÜK DUALAR & RABBENA DUALARI SEKMESİ (KATEGORİLİ + SESLİ DİNLE + STORY PAYLAŞ)
                DualarVeRabbenaListeWidget(
                  arkaPlan: tema.arkaPlan,
                  kartRengi: tema.kartRengi,
                  vurguAltin: tema.vurguAltin,
                  yumusakAltin: tema.yumusakAltin,
                  yaziRengi: tema.yaziRengi,
                  ikincilYazi: tema.ikincilYazi,
                  dil: dil,
                ),

                // 4. HADİS KÜLLİYATI SEKMESİ (TÜM SAHİH HADİS HAVUZU)
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kSahihHadisHavuzu.length,
                  itemBuilder: (context, idx) {
                    final h = kSahihHadisHavuzu[idx];
                    final konu = dil == 'EN' ? h['konuEn']! : h['konuTr']!;
                    final meal = dil == 'EN' ? h['mealEn']! : h['mealTr']!;
                    final tefsir = dil == 'EN' ? h['tefsirEn']! : h['tefsirTr']!;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: tema.vurguAltin.withValues(alpha: 0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${idx + 1}. $konu',
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: tema.vurguAltin,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              h['arapca']!,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 24,
                                height: 1.7,
                                color: tema.yumusakAltin,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              meal,
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 14.5,
                                fontStyle: FontStyle.italic,
                                color: tema.yaziRengi,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tefsir,
                              style: TextStyle(fontSize: 12.5, color: tema.ikincilYazi),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.verified_outlined, size: 14, color: tema.vurguAltin),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    h['dogrulanmis']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: tema.vurguAltin,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CANLI SURE OKUMA EKRANI (TÜM AYETLER: MEALLİ LİSTE & ARAPÇA MUSHAF SAYFASI)
// ============================================================================

class SureDetayOkumaEkrani extends StatefulWidget {
  final SureMeta sureMeta;
  final IslamiTema tema;
  final String dil;
  final int? baslangicAyetNo;
  final bool baslangicMushafModu;

  const SureDetayOkumaEkrani({
    super.key,
    required this.sureMeta,
    required this.tema,
    required this.dil,
    this.baslangicAyetNo,
    this.baslangicMushafModu = false,
  });

  @override
  State<SureDetayOkumaEkrani> createState() => _SureDetayOkumaEkraniState();
}

class _SureDetayOkumaEkraniState extends State<SureDetayOkumaEkrani> {
  late bool _mushafGorunumu;
  late Future<List<CanliAyetModel>> _ayetlerFuture;
  final ScrollController _listeScrollCtrl = ScrollController();
  int? _vurgulananAyetNo;
  bool _ilkKaydirmaYapildi = false;

  @override
  void initState() {
    super.initState();
    _mushafGorunumu = widget.baslangicMushafModu;
    _vurgulananAyetNo = widget.baslangicAyetNo;
    _ayetlerFuture = KuranApiServisi.sureAyetleriniGetir(widget.sureMeta.no);
  }

  @override
  void dispose() {
    _listeScrollCtrl.dispose();
    super.dispose();
  }

  void _ayracKaydetBildir(int ayetNo) {
    KuranAyracServisi.ayracKaydet(
      sureNo: widget.sureMeta.no,
      ayetNo: ayetNo,
      mushafModuMu: _mushafGorunumu,
    );
    setState(() => _vurgulananAyetNo = ayetNo);
    final dil = widget.dil;
    final mesaj = dil == 'EN'
        ? '🔖 Bookmark saved: Surah ${widget.sureMeta.adEn}, Verse $ayetNo'
        : dil == 'AR'
            ? '🔖 تم حفظ الفاصلة: سورة ${widget.sureMeta.arapca}، الآية $ayetNo'
            : '🔖 Kur’an ayracı kaydedildi: ${widget.sureMeta.adTr} Suresi, $ayetNo. Ayet (Ana Sayfadan devam edebilirsiniz)';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: widget.tema.kartRengi,
        behavior: SnackBarBehavior.floating,
        content: Text(mesaj, style: TextStyle(color: widget.tema.yaziRengi, fontSize: 12.5)),
      ),
    );
  }

  void _ayeteKaydir(int ayetNo, int toplamAyet) {
    if (!_listeScrollCtrl.hasClients || _mushafGorunumu) return;
    final hedefIdx = (ayetNo - 1).clamp(0, toplamAyet - 1);
    final tahminiYukseklik = hedefIdx * 235.0;
    _listeScrollCtrl.animateTo(
      tahminiYukseklik.clamp(0.0, _listeScrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  String _arapcaRakam(int sayi) {
    const rakamlar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return sayi.toString().split('').map((c) => rakamlar[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final tema = widget.tema;
    final sure = widget.sureMeta;
    final dil = widget.dil;
    final baslik = dil == 'EN'
        ? 'Surah ${sure.adEn}'
        : dil == 'AR'
            ? 'سورة ${sure.arapca}'
            : '${sure.adTr} Suresi';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${sure.no}. $baslik (${sure.ayetSayisi} ${Ceviri.m(dil, 'verse_unit')})',
          style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: dil == 'EN'
                ? 'Bookmark this Surah'
                : dil == 'AR'
                    ? 'حفظ علامة مرجعية'
                    : 'Bu Sureye Ayraç Koy',
            onPressed: () => _ayracKaydetBildir(_vurgulananAyetNo ?? 1),
            icon: Icon(Icons.bookmark_add_rounded, color: tema.vurguAltin),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: false,
                      icon: const Icon(Icons.view_agenda_outlined, size: 18),
                      label: Text(Ceviri.m(dil, 'mode_list')),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: Text(Ceviri.m(dil, 'mode_mushaf')),
                    ),
                  ],
                  selected: {_mushafGorunumu},
                  onSelectionChanged: (secim) => setState(() => _mushafGorunumu = secim.first),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<CanliAyetModel>>(
                  future: _ayetlerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: tema.vurguAltin),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                Ceviri.m(dil, 'loading_surah'),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: tema.ikincilYazi, fontSize: 13.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final ayetler = snapshot.data ?? [];
                    if (!_ilkKaydirmaYapildi &&
                        widget.baslangicAyetNo != null &&
                        widget.baslangicAyetNo! > 1 &&
                        ayetler.isNotEmpty) {
                      _ilkKaydirmaYapildi = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _ayeteKaydir(widget.baslangicAyetNo!, ayetler.length);
                      });
                    }
                    return Column(
                      children: [
                        // TÜM SUREYİ SIRAYLA DİNLE (MİŞARİ RAŞİD EL-AFASİ MP3 OYNATICI ÇUBUĞU)
                        _buildSureSesOynaticiCubugu(sure, ayetler, tema, dil),
                        Expanded(
                          child: _mushafGorunumu
                              ? _buildArapcaMushafSayfasi(sure, ayetler, dil)
                              : _buildMealliListeGorunumu(sure, ayetler, tema, dil),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSureSesOynaticiCubugu(
    SureMeta sure,
    List<CanliAyetModel> ayetler,
    IslamiTema tema,
    String dil,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: KuranSesOynaticiServisi.caliyorMu,
      builder: (context, caliyor, _) {
        return ValueListenableBuilder<int?>(
          valueListenable: KuranSesOynaticiServisi.aktifGlobalAyetNo,
          builder: (context, aktifGlobalNo, _) {
            int? okunanAyetNo;
            if (aktifGlobalNo != null) {
              for (final a in ayetler) {
                if (a.globalAyetNo == aktifGlobalNo) {
                  okunanAyetNo = a.ayetNo;
                  break;
                }
              }
            }
            final buSureOkunuyor = okunanAyetNo != null;

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: tema.kartRengi,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: buSureOkunuyor && caliyor
                      ? tema.vurguAltin
                      : tema.vurguAltin.withValues(alpha: 0.35),
                  width: buSureOkunuyor && caliyor ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    buSureOkunuyor && caliyor
                        ? Icons.graphic_eq_rounded
                        : Icons.headphones_rounded,
                    color: tema.vurguAltin,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<HafizModel>(
                          valueListenable: KuranSesOynaticiServisi.seciliHafiz,
                          builder: (context, hafiz, _) {
                            return InkWell(
                              onTap: () => _hafizSeciciSheetGoster(context, tema: tema, dil: dil),
                              borderRadius: BorderRadius.circular(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          dil == 'EN'
                                              ? 'Reciter: ${hafiz.ad}'
                                              : dil == 'AR'
                                                  ? 'القارئ: ${hafiz.ad}'
                                                  : 'Hafız: ${hafiz.ad}',
                                          style: TextStyle(
                                            color: tema.yaziRengi,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.tune_rounded, size: 14, color: tema.vurguAltin),
                                    ],
                                  ),
                                  Text(
                                    buSureOkunuyor
                                        ? (dil == 'EN'
                                            ? 'Now Reciting: Verse $okunanAyetNo / ${ayetler.length}'
                                            : dil == 'AR'
                                                ? 'يُتلى الآن: الآية $okunanAyetNo من ${ayetler.length}'
                                                : 'Şu an okunan: $okunanAyetNo. Ayet / ${ayetler.length}')
                                        : (dil == 'EN'
                                            ? 'Sequential recitation • Tap to change reciter'
                                            : dil == 'AR'
                                                ? 'تلاوة متسلسلة • انقر لتغيير القارئ'
                                                : 'Sırayla okur • Hafızı değiştirmek için dokunun'),
                                    style: TextStyle(color: tema.ikincilYazi, fontSize: 11),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (buSureOkunuyor) ...[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Önceki Ayet',
                      onPressed: KuranSesOynaticiServisi.oncekiAyeteGec,
                      icon: Icon(Icons.skip_previous_rounded, color: tema.vurguAltin, size: 22),
                    ),
                  ],
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: tema.vurguAltin,
                      foregroundColor: tema.arkaPlan,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (buSureOkunuyor && caliyor && aktifGlobalNo != null) {
                        KuranSesOynaticiServisi.tekAyetOynatDuraklat(
                          globalAyetNo: aktifGlobalNo,
                        );
                      } else {
                        final baslangicIdx = okunanAyetNo != null
                            ? (okunanAyetNo - 1).clamp(0, ayetler.length - 1)
                            : 0;
                        KuranSesOynaticiServisi.sureSiraylaOynatBaslat(
                          ayetler: ayetler,
                          baslangicIndex: baslangicIdx,
                          onAyetDegisti: (yeniAyetNo) {
                            if (mounted) {
                              setState(() => _vurgulananAyetNo = yeniAyetNo);
                              _ayeteKaydir(yeniAyetNo, ayetler.length);
                            }
                          },
                        );
                      }
                    },
                    icon: Icon(
                      buSureOkunuyor && caliyor
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 18,
                    ),
                    label: Text(
                      buSureOkunuyor && caliyor
                          ? (dil == 'EN' ? 'Pause' : dil == 'AR' ? 'إيقاف' : 'Duraklat')
                          : (dil == 'EN' ? 'Play All' : dil == 'AR' ? 'تشغيل' : 'Dinle'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  if (buSureOkunuyor) ...[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Sonraki Ayet',
                      onPressed: KuranSesOynaticiServisi.sonrakiAyeteGec,
                      icon: Icon(Icons.skip_next_rounded, color: tema.vurguAltin, size: 22),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Durdur',
                      onPressed: KuranSesOynaticiServisi.tamamenDurdur,
                      icon: Icon(Icons.stop_circle_outlined, color: tema.ikincilYazi, size: 20),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArapcaMushafSayfasi(
    SureMeta sure,
    List<CanliAyetModel> ayetler,
    String dil,
  ) {
    const Color mushafKagit = Color(0xFFFBF5E6);
    const Color tezhipAltin = Color(0xFFB5892E);
    const Color tezhipZumrut = Color(0xFF144233);
    const Color murekkepSiyah = Color(0xFF1A1612);

    return ValueListenableBuilder<int?>(
      valueListenable: KuranSesOynaticiServisi.aktifGlobalAyetNo,
      builder: (context, aktifGlobalNo, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: mushafKagit,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tezhipAltin, width: 3),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(color: tezhipZumrut, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: tezhipZumrut,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: tezhipAltin, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${sure.yer} • ${ayetler.length} Âyet',
                          style: const TextStyle(color: Color(0xFFF3E5AB), fontSize: 12),
                        ),
                        Text(
                          'سُورَةُ ${sure.arapca}',
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFFF3E5AB),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => _ayracKaydetBildir(_vurgulananAyetNo ?? 1),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_add_rounded, color: Color(0xFFF3E5AB), size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Ayraç Koy',
                                style: TextStyle(
                                  color: Color(0xFFF3E5AB),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (sure.no != 1 && sure.no != 9) ...[
                    const Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 28,
                        color: tezhipZumrut,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          for (final ayet in ayetler) ...[
                            TextSpan(
                              text: '${ayet.arapca} ',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 28,
                                height: 2.05,
                                color: murekkepSiyah,
                                backgroundColor: aktifGlobalNo == ayet.globalAyetNo
                                    ? tezhipAltin.withValues(alpha: 0.28)
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' ﴿${_arapcaRakam(ayet.ayetNo)}﴾ ',
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 22,
                                color: tezhipAltin,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: tezhipAltin),
                  Text(
                    '${Ceviri.m(dil, 'mushaf_footer')} • T.C. Diyanet İşleri Başkanlığı (${sure.adTr} Suresi, 1-${ayetler.length})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: tezhipZumrut,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealliListeGorunumu(
    SureMeta sure,
    List<CanliAyetModel> ayetler,
    IslamiTema tema,
    String dil,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: KuranSesOynaticiServisi.caliyorMu,
      builder: (context, caliyor, _) {
        return ValueListenableBuilder<int?>(
          valueListenable: KuranSesOynaticiServisi.aktifGlobalAyetNo,
          builder: (context, aktifGlobalNo, _) {
            return ValueListenableBuilder<KuranAyracModel>(
              valueListenable: KuranAyracServisi.ayracNotifier,
              builder: (context, kayitliAyrac, _) {
                return ListView.builder(
                  controller: _listeScrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: ayetler.length,
                  itemBuilder: (context, i) {
                    final ayet = ayetler[i];
                    final meal = dil == 'EN' ? ayet.mealEn : ayet.mealTr;
                    final buAyetOkunuyor = aktifGlobalNo == ayet.globalAyetNo;
                    final buAyetAyracli =
                        kayitliAyrac.sureNo == sure.no && kayitliAyrac.ayetNo == ayet.ayetNo;
                    final vurgulu = buAyetOkunuyor ||
                        buAyetAyracli ||
                        _vurgulananAyetNo == ayet.ayetNo;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: buAyetOkunuyor
                            ? tema.vurguAltin.withValues(alpha: 0.14)
                            : tema.kartRengi,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: buAyetOkunuyor
                              ? tema.vurguAltin
                              : vurgulu
                                  ? tema.vurguAltin.withValues(alpha: 0.85)
                                  : tema.vurguAltin.withValues(alpha: 0.3),
                          width: buAyetOkunuyor ? 2.0 : (vurgulu ? 1.5 : 1.0),
                        ),
                        boxShadow: buAyetOkunuyor
                            ? [
                                BoxShadow(
                                  color: tema.vurguAltin.withValues(alpha: 0.22),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${sure.no}:${ayet.ayetNo}  •  Cüz ${ayet.cuz}  •  Sayfa ${ayet.sayfa}',
                                  style: TextStyle(
                                    color: tema.vurguAltin,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              // Tekil Ayeti Dinle Butonu
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: dil == 'EN'
                                    ? 'Listen to Verse'
                                    : dil == 'AR'
                                        ? 'استمع للآية'
                                        : 'Ayeti Dinle (Mişari el-Afasi)',
                                onPressed: () {
                                  KuranSesOynaticiServisi.tekAyetOynatDuraklat(
                                    globalAyetNo: ayet.globalAyetNo,
                                  );
                                },
                                icon: Icon(
                                  buAyetOkunuyor && caliyor
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_fill_rounded,
                                  color: tema.vurguAltin,
                                  size: 24,
                                ),
                              ),
                              // Ayraç Koy (Kaldığım Yer) Butonu
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: dil == 'EN'
                                    ? 'Save Bookmark Here'
                                    : dil == 'AR'
                                        ? 'حفظ الفاصلة هنا'
                                        : 'Ayraç Koy (Kaldığım Yer Olarak Kaydet)',
                                onPressed: () => _ayracKaydetBildir(ayet.ayetNo),
                                icon: Icon(
                                  buAyetAyracli
                                      ? Icons.bookmark_added_rounded
                                      : Icons.bookmark_add_outlined,
                                  color: buAyetAyracli ? tema.vurguAltin : tema.ikincilYazi,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '﴿${_arapcaRakam(ayet.ayetNo)}﴾',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 20,
                                  color: tema.vurguAltin,
                                ),
                              ),
                            ],
                          ),
                          if (i == 0 && sure.no != 1 && sure.no != 9) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: tema.vurguAltin.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 24,
                                  color: tema.vurguAltin,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            ayet.arapca,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 27,
                              height: 1.8,
                              color: tema.yumusakAltin,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            meal,
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 15.5,
                              height: 1.5,
                              color: tema.yaziRengi,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.verified_outlined, size: 13.5, color: tema.vurguAltin),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  dil == 'EN'
                                      ? 'Verified Source: Presidency of Religious Affairs & Sahih Int. • ${sure.adEn} ${sure.no}:${ayet.ayetNo}'
                                      : 'Doğrulanmış Kaynak: T.C. Diyanet İşleri Başkanlığı Kur’an-ı Kerim Meali • ${sure.adTr} ${sure.no}/${ayet.ayetNo}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: tema.vurguAltin,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
