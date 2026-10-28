import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'js_bridge.dart';
import 'web_shim_io.dart' if (dart.library.js_interop) 'package:web/web.dart' as web;
import 'quran_api_service.dart';
import 'quran_hadith_data.dart';

// ============================================================================
// 1. SESLİ KUR'AN-I KERİM DİNLEME SERVİSİ (ÇOKLU HAFIZ MP3 OYNATICI)
// ============================================================================

/// Seçilebilir hafızlar (cdn.islamic.network edition kodları ve denenecek bitrate sırası)
class HafizModel {
  final String kod;
  final String adTr;
  final String adAr;
  final List<int> bitrateler;

  const HafizModel({
    required this.kod,
    required this.adTr,
    required this.adAr,
    required this.bitrateler,
  });

  String get ad => adTr;
  String get ulke => kod.contains('alafasy')
      ? 'Kuveyt'
      : (kod.contains('abdulbasit') ? 'Mısır' : 'Suudi Arabistan');
}

const List<HafizModel> kHafizlar = [
  HafizModel(
    kod: 'ar.alafasy',
    adTr: 'Mişari Raşid el-Afasi',
    adAr: 'مشاري راشد العفاسي',
    bitrateler: [128, 64],
  ),
  HafizModel(
    kod: 'ar.abdulbasitmurattal',
    adTr: 'Abdulbasit Abdussamed (Murattal)',
    adAr: 'عبد الباسط عبد الصمد (مرتل)',
    bitrateler: [192, 64],
  ),
  HafizModel(
    kod: 'ar.yasseraldossari',
    adTr: 'Yasser Ad-Dossari',
    adAr: 'ياسر الدوسري',
    bitrateler: [128, 64],
  ),
];

class KuranSesOynaticiServisi {
  static web.HTMLAudioElement? _audioElement;
  static const String _hafizStorageKey = 'vakti_huzur_secili_hafiz_v1';

  /// Seçili hafız (kalıcı olarak cihaz hafızasında saklanır)
  static final ValueNotifier<HafizModel> seciliHafiz =
      ValueNotifier<HafizModel>(_kayitliHafiziYukle());

  /// Ses dosyası yüklenemezse sırayla denenecek yedek URL'ler
  static List<String> _yedekUrller = [];

  static HafizModel _kayitliHafiziYukle() {
    try {
      final kod = web.window.localStorage.getItem(_hafizStorageKey);
      if (kod != null) {
        return kHafizlar.firstWhere((h) => h.kod == kod, orElse: () => kHafizlar.first);
      }
    } catch (_) {}
    return kHafizlar.first;
  }

  static void hafizSec(HafizModel hafiz) {
    seciliHafiz.value = hafiz;
    try {
      web.window.localStorage.setItem(_hafizStorageKey, hafiz.kod);
    } catch (_) {}
    tamamenDurdur();
  }

  /// Şu an çalmakta olan globalAyetNo (1..6236)
  static final ValueNotifier<int?> aktifGlobalAyetNo = ValueNotifier<int?>(null);

  /// Reels kartlarında hangi kartın çaldığını takip etmek için
  static final ValueNotifier<String?> aktifKartId = ValueNotifier<String?>(null);

  /// Oynatıcı şu an aktif olarak ses çalıyor mu?
  static final ValueNotifier<bool> caliyorMu = ValueNotifier<bool>(false);

  /// Tüm sureyi sırayla çalma modu aktif mi?
  static final ValueNotifier<bool> sureSiraylaModu = ValueNotifier<bool>(false);

  static List<CanliAyetModel> _siradakiAyetListesi = [];
  static int _siradakiIndex = 0;
  static ValueChanged<int>? _onSureAyetDegisti;

  /// Seçili hafıza göre ana MP3 adresini döndürür
  static String mp3UrlOlustur(int globalAyetNo) {
    return _adayUrller(globalAyetNo).first;
  }

  /// Seçili hafızın tüm bitrate seçenekleri + son çare olarak Mişari Raşid el-Afasi
  static List<String> _adayUrller(int globalAyetNo) {
    final gecerli = globalAyetNo.clamp(1, 6236);
    final h = seciliHafiz.value;
    final liste = <String>[
      for (final br in h.bitrateler)
        'https://cdn.islamic.network/quran/audio/$br/${h.kod}/$gecerli.mp3',
    ];
    if (h.kod != 'ar.alafasy') {
      liste.add('https://cdn.islamic.network/quran/audio/128/ar.alafasy/$gecerli.mp3');
    }
    return liste;
  }

  /// Sure numarası (1..114) ve sure içi ayet numarasından (1..N) globalAyetNo (1..6236) hesaplar
  static int globalAyetNoHesapla(int sureNo, int ayetNo) {
    int toplam = 0;
    for (int i = 0; i < (sureNo - 1).clamp(0, kTum114Sure.length); i++) {
      toplam += kTum114Sure[i].ayetSayisi;
    }
    return (toplam + ayetNo).clamp(1, 6236);
  }

  static void _audioHazirla() {
    if (_audioElement != null) return;
    final audio = web.HTMLAudioElement();
    audio.preload = 'auto';

    audio.onended = ((web.Event _) {
      if (sureSiraylaModu.value && _siradakiIndex + 1 < _siradakiAyetListesi.length) {
        _siradakiIndex++;
        final yeniAyet = _siradakiAyetListesi[_siradakiIndex];
        _onSureAyetDegisti?.call(yeniAyet.ayetNo);
        _dogrudanMp3Cal(yeniAyet.globalAyetNo, kartId: null);
      } else {
        caliyorMu.value = false;
        sureSiraylaModu.value = false;
        aktifGlobalAyetNo.value = null;
        aktifKartId.value = null;
      }
    }).toJS;

    audio.onerror = ((web.Event _) {
      // Seçili hafızın dosyası bulunamazsa sıradaki bitrate / yedek hafızı dene
      if (_yedekUrller.isNotEmpty) {
        final sonraki = _yedekUrller.removeAt(0);
        _audioElement!.src = sonraki;
        _audioElement!.play();
        return;
      }
      caliyorMu.value = false;
    }).toJS;

    _audioElement = audio;
  }

  static void _dogrudanMp3Cal(int globalAyetNo, {String? kartId}) {
    _audioHazirla();
    try {
      web.window.speechSynthesis.cancel();
    } catch (_) {}

    final adaylar = _adayUrller(globalAyetNo);
    _yedekUrller = adaylar.sublist(1);
    _audioElement!.src = adaylar.first;
    aktifGlobalAyetNo.value = globalAyetNo;
    aktifKartId.value = kartId;
    caliyorMu.value = true;
    _audioElement!.play();
  }

  /// Tek bir ayeti (Reels kartında veya Sure listesinde) oynatır veya duraklatır
  static void tekAyetOynatDuraklat({
    required int globalAyetNo,
    String? kartId,
  }) {
    _audioHazirla();

    // Aynı ayet zaten çalıyorsa duraklat / devam ettir
    if (aktifGlobalAyetNo.value == globalAyetNo &&
        (kartId == null || aktifKartId.value == kartId)) {
      if (caliyorMu.value) {
        _audioElement?.pause();
        caliyorMu.value = false;
      } else {
        _audioElement?.play();
        caliyorMu.value = true;
      }
      return;
    }

    sureSiraylaModu.value = false;
    _siradakiAyetListesi = [];
    _dogrudanMp3Cal(globalAyetNo, kartId: kartId);
  }

  /// Reels kartındaki Hadis-i Şerif için Web Speech API ile Arapça/Türkçe seslendirme
  static void hadisSeslendirDuraklat({
    required String kartId,
    required String arapcaMetin,
    required String mealMetin,
  }) {
    _audioHazirla();
    _audioElement?.pause();
    sureSiraylaModu.value = false;
    aktifGlobalAyetNo.value = null;

    if (aktifKartId.value == kartId && caliyorMu.value) {
      try {
        web.window.speechSynthesis.cancel();
      } catch (_) {}
      caliyorMu.value = false;
      aktifKartId.value = null;
      return;
    }

    try {
      web.window.speechSynthesis.cancel();
      final utter = web.SpeechSynthesisUtterance(arapcaMetin);
      utter.lang = 'ar-SA';
      utter.rate = 0.88;
      utter.onend = ((web.Event _) {
        caliyorMu.value = false;
        aktifKartId.value = null;
      }).toJS;
      utter.onerror = ((web.Event _) {
        caliyorMu.value = false;
        aktifKartId.value = null;
      }).toJS;
      aktifKartId.value = kartId;
      caliyorMu.value = true;
      web.window.speechSynthesis.speak(utter);
    } catch (_) {
      caliyorMu.value = false;
      aktifKartId.value = null;
    }
  }

  /// Sure okuma ekranında tüm sureyi baştan sona sırayla okur
  static void sureSiraylaOynatBaslat({
    required List<CanliAyetModel> ayetler,
    int baslangicIndex = 0,
    ValueChanged<int>? onAyetDegisti,
  }) {
    if (ayetler.isEmpty) return;
    _audioHazirla();

    _siradakiAyetListesi = ayetler;
    _siradakiIndex = baslangicIndex.clamp(0, ayetler.length - 1);
    _onSureAyetDegisti = onAyetDegisti;
    sureSiraylaModu.value = true;

    final ilkAyet = _siradakiAyetListesi[_siradakiIndex];
    _onSureAyetDegisti?.call(ilkAyet.ayetNo);
    _dogrudanMp3Cal(ilkAyet.globalAyetNo, kartId: null);
  }

  static void sonrakiAyeteGec() {
    if (_siradakiAyetListesi.isEmpty) return;
    if (_siradakiIndex + 1 < _siradakiAyetListesi.length) {
      _siradakiIndex++;
      sureSiraylaModu.value = true;
      final ayet = _siradakiAyetListesi[_siradakiIndex];
      _onSureAyetDegisti?.call(ayet.ayetNo);
      _dogrudanMp3Cal(ayet.globalAyetNo, kartId: null);
    }
  }

  static void oncekiAyeteGec() {
    if (_siradakiAyetListesi.isEmpty) return;
    if (_siradakiIndex - 1 >= 0) {
      _siradakiIndex--;
      sureSiraylaModu.value = true;
      final ayet = _siradakiAyetListesi[_siradakiIndex];
      _onSureAyetDegisti?.call(ayet.ayetNo);
      _dogrudanMp3Cal(ayet.globalAyetNo, kartId: null);
    }
  }

  static void tamamenDurdur() {
    try {
      _audioElement?.pause();
      web.window.speechSynthesis.cancel();
    } catch (_) {}
    caliyorMu.value = false;
    sureSiraylaModu.value = false;
    aktifGlobalAyetNo.value = null;
    aktifKartId.value = null;
  }
}

// ============================================================================
// 2. KALDIĞIM YERDEN DEVAM ET (KUR'AN-I KERİM AYRACI SERVİSİ)
// ============================================================================

class KuranAyracModel {
  final int sureNo;
  final int ayetNo;
  final bool mushafModuMu;

  const KuranAyracModel({
    required this.sureNo,
    required this.ayetNo,
    this.mushafModuMu = false,
  });

  SureMeta get sureMeta => kTum114Sure[(sureNo - 1).clamp(0, kTum114Sure.length - 1)];

  Map<String, dynamic> toJson() => {
        'sureNo': sureNo,
        'ayetNo': ayetNo,
        'mushafModuMu': mushafModuMu,
      };

  factory KuranAyracModel.fromJson(Map<String, dynamic> map) {
    return KuranAyracModel(
      sureNo: (map['sureNo'] as num?)?.toInt() ?? 36,
      ayetNo: (map['ayetNo'] as num?)?.toInt() ?? 1,
      mushafModuMu: map['mushafModuMu'] == true,
    );
  }
}

class KuranAyracServisi {
  static const String _storageKey = 'nur_huzur_kuran_ayrac_v1';

  static final ValueNotifier<KuranAyracModel> ayracNotifier =
      ValueNotifier<KuranAyracModel>(_baslangicYukle());

  static KuranAyracModel _baslangicYukle() {
    try {
      final raw = web.window.localStorage.getItem(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return KuranAyracModel.fromJson(decoded);
      }
    } catch (_) {}
    // Varsayılan başlangıç ayracı: Yâsîn Suresi, 1. Ayet
    return const KuranAyracModel(sureNo: 36, ayetNo: 1, mushafModuMu: false);
  }

  static void ayracKaydet({
    required int sureNo,
    required int ayetNo,
    bool mushafModuMu = false,
  }) {
    final yeni = KuranAyracModel(
      sureNo: sureNo,
      ayetNo: ayetNo,
      mushafModuMu: mushafModuMu,
    );
    ayracNotifier.value = yeni;
    try {
      web.window.localStorage.setItem(_storageKey, jsonEncode(yeni.toJson()));
    } catch (_) {}
  }

  static bool ayracliMi(int sureNo, int ayetNo) {
    final a = ayracNotifier.value;
    return a.sureNo == sureNo && a.ayetNo == ayetNo;
  }
}

// ============================================================================
// 3. GÜNLÜK 5 VAKİT NAMAZ TAKİP ÇİZELGESİ SERVİSİ VE KARTI
// ============================================================================

class GunlukNamazTakipServisi {
  static String get _bugunAnahtar {
    final s = DateTime.now();
    return 'nur_huzur_namaz_takip_${s.year}_${s.month}_${s.day}';
  }

  static Map<String, bool> bugunDurumunuGetir() {
    final varsayilan = <String, bool>{
      'sabah': false,
      'ogle': false,
      'ikindi': false,
      'aksam': false,
      'yatsi': false,
    };
    try {
      final raw = web.window.localStorage.getItem(_bugunAnahtar);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final k in varsayilan.keys) {
          if (decoded[k] == true) varsayilan[k] = true;
        }
      }
    } catch (_) {}
    return varsayilan;
  }

  static void vakitDurumuKaydet(Map<String, bool> durum) {
    try {
      web.window.localStorage.setItem(_bugunAnahtar, jsonEncode(durum));
    } catch (_) {}
  }
}

class GunlukNamazTakipKarti extends StatefulWidget {
  final Color arkaPlan;
  final Color kartRengi;
  final Color vurguAltin;
  final Color yumusakAltin;
  final Color yaziRengi;
  final Color ikincilYazi;
  final String dil;

  const GunlukNamazTakipKarti({
    super.key,
    required this.arkaPlan,
    required this.kartRengi,
    required this.vurguAltin,
    required this.yumusakAltin,
    required this.yaziRengi,
    required this.ikincilYazi,
    required this.dil,
  });

  @override
  State<GunlukNamazTakipKarti> createState() => _GunlukNamazTakipKartiState();
}

class _GunlukNamazTakipKartiState extends State<GunlukNamazTakipKarti> {
  late Map<String, bool> _durum;

  @override
  void initState() {
    super.initState();
    _durum = GunlukNamazTakipServisi.bugunDurumunuGetir();
  }

  void _vakitDegistir(String anahtar) {
    setState(() {
      _durum[anahtar] = !(_durum[anahtar] ?? false);
    });
    GunlukNamazTakipServisi.vakitDurumuKaydet(_durum);
  }

  String _vakitBasligi(String key, String dil) {
    if (dil == 'EN') {
      switch (key) {
        case 'sabah':
          return 'Fajr';
        case 'ogle':
          return 'Dhuhr';
        case 'ikindi':
          return 'Asr';
        case 'aksam':
          return 'Maghrib';
        case 'yatsi':
          return 'Isha';
      }
    } else if (dil == 'AR') {
      switch (key) {
        case 'sabah':
          return 'الفجر';
        case 'ogle':
          return 'الظهر';
        case 'ikindi':
          return 'العصر';
        case 'aksam':
          return 'المغرب';
        case 'yatsi':
          return 'العشاء';
      }
    }
    switch (key) {
      case 'sabah':
        return 'Sabah';
      case 'ogle':
        return 'Öğle';
      case 'ikindi':
        return 'İkindi';
      case 'aksam':
        return 'Akşam';
      case 'yatsi':
        return 'Yatsı';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dil = widget.dil;
    final kilinanSayisi = _durum.values.where((v) => v).length;
    final yuzde = ((kilinanSayisi / 5) * 100).round();

    final baslik = dil == 'EN'
        ? 'My Daily Prayer Tracker'
        : dil == 'AR'
            ? 'جدول متابعة الصلوات اليومية'
            : 'Günlük Namaz Takibim';

    final durumMetni = dil == 'EN'
        ? '%$yuzde - $kilinanSayisi/5 Prayers Completed'
        : dil == 'AR'
            ? '%$yuzde - تم أداء $kilinanSayisi/5 صلوات'
            : '%$yuzde - $kilinanSayisi/5 Vakit Eda Edildi';

    const anahtarlar = ['sabah', 'ogle', 'ikindi', 'aksam', 'yatsi'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.kartRengi,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kilinanSayisi == 5
              ? const Color(0xFF2E9E6B)
              : widget.vurguAltin.withValues(alpha: 0.45),
          width: kilinanSayisi == 5 ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      kilinanSayisi == 5
                          ? Icons.verified_rounded
                          : Icons.fact_check_outlined,
                      color: widget.vurguAltin,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        baslik,
                        style: TextStyle(
                          fontFamily: 'Lora',
                          color: widget.vurguAltin,
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
                  color: kilinanSayisi == 5
                      ? const Color(0xFF1F6E4A).withValues(alpha: 0.35)
                      : widget.vurguAltin.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.vurguAltin.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  durumMetni,
                  style: TextStyle(
                    color: widget.vurguAltin,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // İlerleme Çubuğu
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: kilinanSayisi / 5.0,
              minHeight: 7,
              backgroundColor: widget.arkaPlan.withValues(alpha: 0.55),
              valueColor: AlwaysStoppedAnimation<Color>(widget.vurguAltin),
            ),
          ),
          const SizedBox(height: 16),

          // 5 Vakit Yuvarlak Tik / Check Kutuları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: anahtarlar.map((k) {
              final edaEdildi = _durum[k] ?? false;
              return GestureDetector(
                onTap: () => _vakitDegistir(k),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: edaEdildi
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF1E6F50),
                                  widget.vurguAltin,
                                ],
                              )
                            : null,
                        color: edaEdildi
                            ? null
                            : widget.arkaPlan.withValues(alpha: 0.45),
                        border: Border.all(
                          color: edaEdildi
                              ? widget.vurguAltin
                              : widget.vurguAltin.withValues(alpha: 0.35),
                          width: edaEdildi ? 1.8 : 1.1,
                        ),
                        boxShadow: edaEdildi
                            ? [
                                BoxShadow(
                                  color: widget.vurguAltin.withValues(alpha: 0.28),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        edaEdildi
                            ? Icons.check_rounded
                            : Icons.circle_outlined,
                        color: edaEdildi
                            ? Colors.white
                            : widget.ikincilYazi.withValues(alpha: 0.5),
                        size: edaEdildi ? 24 : 18,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _vakitBasligi(k, dil),
                      style: TextStyle(
                        color: edaEdildi ? widget.vurguAltin : widget.yaziRengi,
                        fontWeight: edaEdildi ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. KALICI TEMA HAFIZA SERVİSİ (LOCALSTORAGE PERSISTENT THEME)
// ============================================================================

class KaliciTemaHafizaServisi {
  static const String _temaStorageKey = 'nur_huzur_secili_tema_idx_v1';

  /// Cihaz hafızasından (localStorage) son seçilen tema indeksini (0..5) okur.
  /// Kayıt yoksa varsayılan olarak 0 (Medine Yeşili & Kubbe) döner.
  static int kayitliTemaIndeksiniYukle({int maxTemaSayisi = 6}) {
    try {
      final raw = web.window.localStorage.getItem(_temaStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final parsed = int.tryParse(raw.trim());
        if (parsed != null && parsed >= 0 && parsed < maxTemaSayisi) {
          return parsed;
        }
      }
    } catch (_) {}
    return 0;
  }

  /// Kullanıcı tema değiştirdiğinde seçilen tema indeksini anında cihaz hafızasına kaydeder.
  static void temaIndeksiniKaydet(int temaIdx) {
    try {
      web.window.localStorage.setItem(_temaStorageKey, temaIdx.toString());
    } catch (_) {}
  }
}

// ============================================================================
// 5. KAZA NAMAZI TAKİP ÇETELESİ SERVİSİ VE KARTI (6 VAKİT + TOPLU SAYI GİRİŞİ)
// ============================================================================

class KazaNamaziServisi {
  static const String _storageKey = 'nur_huzur_kaza_namazi_cetele_v1';

  static const List<String> vakitAnahtarlari = [
    'sabah',
    'ogle',
    'ikindi',
    'aksam',
    'yatsi',
    'vitir',
  ];

  static final ValueNotifier<Map<String, int>> ceteleNotifier =
      ValueNotifier<Map<String, int>>(_baslangicYukle());

  static Map<String, int> _baslangicYukle() {
    final varsayilan = <String, int>{
      for (final k in vakitAnahtarlari) k: 0,
    };
    try {
      final raw = web.window.localStorage.getItem(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final k in vakitAnahtarlari) {
          varsayilan[k] = ((decoded[k] as num?)?.toInt() ?? 0).clamp(0, 999999);
        }
      }
    } catch (_) {}
    return varsayilan;
  }

  static void _kaydet(Map<String, int> veri) {
    ceteleNotifier.value = Map<String, int>.from(veri);
    try {
      web.window.localStorage.setItem(_storageKey, jsonEncode(veri));
    } catch (_) {}
  }

  static void degerDegistir(String vakitKey, int fark) {
    final guncel = Map<String, int>.from(ceteleNotifier.value);
    final mevcut = guncel[vakitKey] ?? 0;
    guncel[vakitKey] = (mevcut + fark).clamp(0, 999999);
    _kaydet(guncel);
  }

  static void dogrudanDegerAta(String vakitKey, int yeniDeger) {
    final guncel = Map<String, int>.from(ceteleNotifier.value);
    guncel[vakitKey] = yeniDeger.clamp(0, 999999);
    _kaydet(guncel);
  }
}

class KazaNamaziTakipKarti extends StatelessWidget {
  final Color arkaPlan;
  final Color kartRengi;
  final Color vurguAltin;
  final Color yumusakAltin;
  final Color yaziRengi;
  final Color ikincilYazi;
  final String dil;

  const KazaNamaziTakipKarti({
    super.key,
    required this.arkaPlan,
    required this.kartRengi,
    required this.vurguAltin,
    required this.yumusakAltin,
    required this.yaziRengi,
    required this.ikincilYazi,
    required this.dil,
  });

  String _vakitAdi(String key) {
    switch (key) {
      case 'sabah':
        return dil == 'EN' ? 'Fajr (Sabah)' : dil == 'AR' ? 'الفجر' : 'Sabah';
      case 'ogle':
        return dil == 'EN' ? 'Dhuhr (Öğle)' : dil == 'AR' ? 'الظهر' : 'Öğle';
      case 'ikindi':
        return dil == 'EN' ? 'Asr (İkindi)' : dil == 'AR' ? 'العصر' : 'İkindi';
      case 'aksam':
        return dil == 'EN' ? 'Maghrib (Akşam)' : dil == 'AR' ? 'المغرب' : 'Akşam';
      case 'yatsi':
        return dil == 'EN' ? 'Isha (Yatsı)' : dil == 'AR' ? 'العشاء' : 'Yatsı';
      case 'vitir':
        return dil == 'EN' ? 'Witr (Vitir)' : dil == 'AR' ? 'الوتر' : 'Vitir';
      default:
        return key;
    }
  }

  IconData _vakitIkonu(String key) {
    switch (key) {
      case 'sabah':
        return Icons.wb_twilight_rounded;
      case 'ogle':
        return Icons.wb_sunny_rounded;
      case 'ikindi':
        return Icons.sunny_snowing;
      case 'aksam':
        return Icons.nights_stay_outlined;
      case 'yatsi':
        return Icons.bedtime_rounded;
      case 'vitir':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.mosque_outlined;
    }
  }

  void _hizliSayiDuzenlemeDialogAc(BuildContext context, String vakitKey, int mevcutSayi) {
    final ctrl = TextEditingController(text: mevcutSayi.toString());
    final vakitBaslik = _vakitAdi(vakitKey);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: kartRengi,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: vurguAltin.withValues(alpha: 0.65), width: 1.4),
          ),
          title: Row(
            children: [
              Icon(Icons.edit_calendar_rounded, color: vurguAltin, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dil == 'EN'
                      ? '$vakitBaslik Missed Prayer Count'
                      : dil == 'AR'
                          ? 'عدد قضاء صلاة $vakitBaslik'
                          : '$vakitBaslik Kaza Sayısını Düzenle',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    color: yaziRengi,
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dil == 'EN'
                    ? 'Enter total missed prayer count directly (e.g. 100 or 365):'
                    : dil == 'AR'
                        ? 'أدخل إجمالي عدد الصلوات الفائتة مباشرة (مثلاً ١٠٠ أو ٣٦٥):'
                        : 'Toplu kaza namazı sayısını doğrudan yazabilir veya hızlı butonları kullanabilirsiniz (Örn: 100 veya 365):',
                style: TextStyle(color: ikincilYazi, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: vurguAltin,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: arkaPlan.withValues(alpha: 0.55),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: vurguAltin.withValues(alpha: 0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: vurguAltin.withValues(alpha: 0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: vurguAltin, width: 1.6),
                  ),
                ),
                onSubmitted: (val) {
                  final yeni = int.tryParse(val.trim()) ?? 0;
                  KazaNamaziServisi.dogrudanDegerAta(vakitKey, yeni);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  for (final ekle in [30, 100, 365])
                    ActionChip(
                      label: Text(
                        '+$ekle',
                        style: TextStyle(
                          color: vurguAltin,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: arkaPlan.withValues(alpha: 0.55),
                      side: BorderSide(color: vurguAltin.withValues(alpha: 0.35)),
                      onPressed: () {
                        final simdiki = int.tryParse(ctrl.text.trim()) ?? 0;
                        ctrl.text = (simdiki + ekle).toString();
                      },
                    ),
                  ActionChip(
                    label: Text(
                      dil == 'EN' ? 'Reset (0)' : dil == 'AR' ? 'تصفير (٠)' : 'Sıfırla (0)',
                      style: TextStyle(color: ikincilYazi, fontSize: 12),
                    ),
                    backgroundColor: arkaPlan.withValues(alpha: 0.4),
                    side: BorderSide(color: vurguAltin.withValues(alpha: 0.25)),
                    onPressed: () => ctrl.text = '0',
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                dil == 'EN' ? 'Cancel' : dil == 'AR' ? 'إلغاء' : 'İptal',
                style: TextStyle(color: ikincilYazi),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: vurguAltin,
                foregroundColor: arkaPlan,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                final yeni = int.tryParse(ctrl.text.trim()) ?? 0;
                KazaNamaziServisi.dogrudanDegerAta(vakitKey, yeni);
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                dil == 'EN' ? 'Save' : dil == 'AR' ? 'حفظ' : 'Kaydet',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: KazaNamaziServisi.ceteleNotifier,
      builder: (context, cetele, _) {
        final toplamKaza = cetele.values.fold<int>(0, (a, b) => a + b);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kartRengi,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: vurguAltin.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.history_edu_rounded, color: vurguAltin, size: 21),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            dil == 'EN'
                                ? 'Missed Prayers Tracker (Qada)'
                                : dil == 'AR'
                                    ? 'جدول متابعة الصلوات الفائتة (القضاء)'
                                    : 'Kaza Namazlarım (Çetele)',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              color: vurguAltin,
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
                      color: vurguAltin.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: vurguAltin.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      dil == 'EN'
                          ? 'Total: $toplamKaza'
                          : dil == 'AR'
                              ? 'المجموع: $toplamKaza'
                              : 'Toplam: $toplamKaza',
                      style: TextStyle(
                        color: vurguAltin,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                dil == 'EN'
                    ? 'Tap any number to enter a bulk count (e.g. 100 or 365) or use +/- buttons.'
                    : dil == 'AR'
                        ? 'اضغط على الرقم لإدخال عدد كبير مباشرة أو استخدم أزرار (+/-).'
                        : 'Toplu sayı girmek için rakamın üzerine dokunun veya (+/-) butonlarıyla güncelleyin.',
                style: TextStyle(color: ikincilYazi, fontSize: 11.5),
              ),
              const SizedBox(height: 12),

              ...KazaNamaziServisi.vakitAnahtarlari.map((key) {
                final sayi = cetele[key] ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: arkaPlan.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: vurguAltin.withValues(alpha: 0.22)),
                  ),
                  child: Row(
                    children: [
                      Icon(_vakitIkonu(key), color: vurguAltin, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _vakitAdi(key),
                          style: TextStyle(
                            color: yaziRengi,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Azaltma (-) Butonu (Kaza kılındıkça düşürmek için)
                      InkWell(
                        borderRadius: BorderRadius.circular(9),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          KazaNamaziServisi.degerDegistir(key, -1);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: kartRengi,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: vurguAltin.withValues(alpha: 0.35)),
                          ),
                          child: Icon(Icons.remove_rounded, color: yaziRengi, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tıklanabilir Kaza Sayısı Kutusu (Doğrudan Rakam Yazma)
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _hizliSayiDuzenlemeDialogAc(context, key, sayi),
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 66),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: vurguAltin.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: vurguAltin.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$sayi',
                                style: TextStyle(
                                  color: vurguAltin,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.edit_outlined,
                                size: 12,
                                color: vurguAltin.withValues(alpha: 0.75),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Artırma (+) Butonu
                      InkWell(
                        borderRadius: BorderRadius.circular(9),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          KazaNamaziServisi.degerDegistir(key, 1);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: vurguAltin,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(Icons.add_rounded, color: arkaPlan, size: 18),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// 6. CANLI KIBLE PUSULASI SENSÖRÜ VE MOBİL TİTREŞİM KÖPRÜSÜ
// ============================================================================

class CanliPusulaSensorServisi {
  /// Mobil cihaz yönelim sensöründen canlı pusula açısını (0..360) okur.
  /// Sensör verisi yoksa -1 döner.
  static double cihazPusulaAcisiOku() {
    return cihazPusulaAcisiOkuBridge();
  }

  /// iOS 13+ cihazlarda pusula sensörü iznini ister
  static void sensorIzniIste() {
    pusulaSensorIzniIsteBridge();
  }

  /// Kıble tam hizalandığında (±3°) çift ve belirgin titreşim verir
  static void kibleDogrulandiTitresim() {
    HapticFeedback.heavyImpact();
    cihazTitretBridge(90);
    Future.delayed(const Duration(milliseconds: 160), () {
      HapticFeedback.heavyImpact();
      cihazTitretBridge(90);
    });
  }
}

// ============================================================================
// 7. NAMAZ VAKTİ VE GÜNLÜK AYET BİLDİRİM PANELİ (KALICI + SESLİ/GÖRSEL TEST)
// ============================================================================

class BildirimAyarlariModel {
  final bool ezanVaktindeBildir;
  final bool onBesDkOnceHatirlat;
  final bool gununAyetiBildirimi;

  const BildirimAyarlariModel({
    this.ezanVaktindeBildir = true,
    this.onBesDkOnceHatirlat = true,
    this.gununAyetiBildirimi = true,
  });

  BildirimAyarlariModel copyWith({
    bool? ezanVaktindeBildir,
    bool? onBesDkOnceHatirlat,
    bool? gununAyetiBildirimi,
  }) {
    return BildirimAyarlariModel(
      ezanVaktindeBildir: ezanVaktindeBildir ?? this.ezanVaktindeBildir,
      onBesDkOnceHatirlat: onBesDkOnceHatirlat ?? this.onBesDkOnceHatirlat,
      gununAyetiBildirimi: gununAyetiBildirimi ?? this.gununAyetiBildirimi,
    );
  }

  Map<String, dynamic> toJson() => {
        'ezanVaktindeBildir': ezanVaktindeBildir,
        'onBesDkOnceHatirlat': onBesDkOnceHatirlat,
        'gununAyetiBildirimi': gununAyetiBildirimi,
      };

  factory BildirimAyarlariModel.fromJson(Map<String, dynamic> m) {
    return BildirimAyarlariModel(
      ezanVaktindeBildir: m['ezanVaktindeBildir'] != false,
      onBesDkOnceHatirlat: m['onBesDkOnceHatirlat'] != false,
      gununAyetiBildirimi: m['gununAyetiBildirimi'] != false,
    );
  }
}

class BildirimAyarlariServisi {
  static const String _storageKey = 'nur_huzur_bildirim_ayarlari_v1';

  static final ValueNotifier<BildirimAyarlariModel> ayarlarNotifier =
      ValueNotifier<BildirimAyarlariModel>(_yukle());

  static BildirimAyarlariModel _yukle() {
    try {
      final raw = web.window.localStorage.getItem(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return BildirimAyarlariModel.fromJson(decoded);
      }
    } catch (_) {}
    return const BildirimAyarlariModel();
  }

  static void guncelle(BildirimAyarlariModel yeni) {
    ayarlarNotifier.value = yeni;
    try {
      web.window.localStorage.setItem(_storageKey, jsonEncode(yeni.toJson()));
    } catch (_) {}
  }

  static void panelGoster(
    BuildContext context, {
    required Color arkaPlan,
    required Color kartRengi,
    required Color vurguAltin,
    required Color yumusakAltin,
    required Color yaziRengi,
    required Color ikincilYazi,
    required String dil,
    String konumAdi = 'İstanbul',
    String siradakiVakitAdi = 'Akşam',
    String siradakiVakitSaat = '18:24',
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kartRengi,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return ValueListenableBuilder<BildirimAyarlariModel>(
          valueListenable: ayarlarNotifier,
          builder: (context, ayar, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: vurguAltin.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: vurguAltin.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: vurguAltin.withValues(alpha: 0.5)),
                          ),
                          child: Icon(Icons.notifications_active_rounded, color: vurguAltin, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dil == 'EN'
                                    ? 'Vakt-i Huzur • Notification Settings'
                                    : dil == 'AR'
                                        ? 'Vakt-i Huzur • إعدادات التنبيهات'
                                        : 'Vakt-i Huzur • Bildirim Ayarları',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.bold,
                                  color: yaziRengi,
                                ),
                              ),
                              Text(
                                dil == 'EN'
                                    ? 'Diyanet Adhan Times & Spiritual Reminders'
                                    : dil == 'AR'
                                        ? 'مواقيت الأذان والتذكيرات اليومية'
                                        : 'Diyanet Ezan Vakitleri & Manevi Hatırlatmalar',
                                style: TextStyle(color: ikincilYazi, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 1. Ezan Vaktinde Bildir
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: arkaPlan.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: vurguAltin.withValues(alpha: 0.28)),
                      ),
                      child: SwitchListTile(
                        dense: true,
                        activeThumbColor: vurguAltin,
                        secondary: Icon(Icons.mosque_rounded, color: vurguAltin, size: 20),
                        title: Text(
                          dil == 'EN'
                              ? 'Notify at Adhan Time'
                              : dil == 'AR'
                                  ? 'التنبيه عند دخول وقت الأذان'
                                  : 'Ezan Vaktinde Bildir',
                          style: TextStyle(
                            color: yaziRengi,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        subtitle: Text(
                          dil == 'EN'
                              ? 'Exact Diyanet prayer time alert for $konumAdi'
                              : dil == 'AR'
                                  ? 'تنبيه عند دخول وقت الصلاة حسب الشؤون الدينية'
                                  : '$konumAdi için vakit girdiğinde anında sesli/görsel bildirim',
                          style: TextStyle(color: ikincilYazi, fontSize: 11.5),
                        ),
                        value: ayar.ezanVaktindeBildir,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          guncelle(ayar.copyWith(ezanVaktindeBildir: val));
                        },
                      ),
                    ),

                    // 2. Vakitten 15 Dk Önce Hatırlat
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: arkaPlan.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: vurguAltin.withValues(alpha: 0.28)),
                      ),
                      child: SwitchListTile(
                        dense: true,
                        activeThumbColor: vurguAltin,
                        secondary: Icon(Icons.alarm_rounded, color: vurguAltin, size: 20),
                        title: Text(
                          dil == 'EN'
                              ? 'Remind 15 Minutes Before Prayer'
                              : dil == 'AR'
                                  ? 'التذكير قبل الوقت بـ ١٥ دقيقة'
                                  : 'Vakitten 15 Dk Önce Hatırlat',
                          style: TextStyle(
                            color: yaziRengi,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        subtitle: Text(
                          dil == 'EN'
                              ? 'Preparation & Wudu reminder before next prayer'
                              : dil == 'AR'
                                  ? 'تذكير للوضوء والاستعداد قبل دخول الوقت'
                                  : 'Abdest ve namaz hazırlığı için vakitten 15 dakika önce uyar',
                          style: TextStyle(color: ikincilYazi, fontSize: 11.5),
                        ),
                        value: ayar.onBesDkOnceHatirlat,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          guncelle(ayar.copyWith(onBesDkOnceHatirlat: val));
                        },
                      ),
                    ),

                    // 3. Günün Ayeti Bildirimi
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: arkaPlan.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: vurguAltin.withValues(alpha: 0.28)),
                      ),
                      child: SwitchListTile(
                        dense: true,
                        activeThumbColor: vurguAltin,
                        secondary: Icon(Icons.auto_awesome_rounded, color: vurguAltin, size: 20),
                        title: Text(
                          dil == 'EN'
                              ? 'Verse of the Day Notification'
                              : dil == 'AR'
                                  ? 'تنبيه آية وحديث اليوم'
                                  : 'Günün Ayeti Bildirimi',
                          style: TextStyle(
                            color: yaziRengi,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        subtitle: Text(
                          dil == 'EN'
                              ? 'Daily inspiring Qur’an verse and Sahih Hadith'
                              : dil == 'AR'
                                  ? 'آية كريمة وحديث شريف كل صباح'
                                  : 'Her gün seçkin bir Kur’an-ı Kerim ayeti ve Sahih Hadis bildirimi',
                          style: TextStyle(color: ikincilYazi, fontSize: 11.5),
                        ),
                        value: ayar.gununAyetiBildirimi,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          guncelle(ayar.copyWith(gununAyetiBildirimi: val));
                        },
                      ),
                    ),

                    // ÖRNEK BİLDİRİMİ TEST ET BUTONU (SESLİ + GÖRSEL + TİTREŞİMLİ)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vurguAltin,
                        foregroundColor: arkaPlan,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        CanliPusulaSensorServisi.kibleDogrulandiTitresim();
                        final testBaslik = dil == 'EN'
                            ? '🕌 Vakt-i Huzur • $konumAdi $siradakiVakitAdi Adhan ($siradakiVakitSaat)'
                            : dil == 'AR'
                                ? '🕌 Vakt-i Huzur • $konumAdi أذان $siradakiVakitAdi ($siradakiVakitSaat)'
                                : '🕌 Vakt-i Huzur • $konumAdi $siradakiVakitAdi Vakti ($siradakiVakitSaat)';
                        final testIcerik = dil == 'EN'
                            ? '“Verily, in the remembrance of Allah do hearts find rest.” (Ar-Ra’d, 28)'
                            : dil == 'AR'
                                ? '«أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ» (سورة الرعد، ٢٨)'
                                : '“Kalpler ancak Allah’ı zikretmekle huzur bulur.” (Ra’d Suresi, 28. Ayet)';

                        try {
                          bildirimSesiCalBridge(testBaslik, testIcerik);
                        } catch (_) {}

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: kartRengi,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: vurguAltin, width: 1.4),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.notifications_active_rounded, color: vurguAltin, size: 19),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        testBaslik,
                                        style: TextStyle(
                                          color: vurguAltin,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  testIcerik,
                                  style: TextStyle(
                                    color: yaziRengi,
                                    fontSize: 12.5,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                      label: Text(
                        dil == 'EN'
                            ? 'Test Sample Notification (Audio & Visual)'
                            : dil == 'AR'
                                ? 'تجربة التنبيه الصوتي والمرئي'
                                : 'Örnek Bildirimi Test Et',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}



