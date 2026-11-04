import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'js_bridge.dart';
import 'prayer_location_calendar_service.dart';
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
  /// Global ayet numarasından (1..6236) (sureNo, ayetNo) çiftini bulur
  static (int sureNo, int ayetNo) globaldenSureVeAyet(int globalAyetNo) {
    int kalan = globalAyetNo.clamp(1, 6236);
    for (int i = 0; i < kTum114Sure.length; i++) {
      final sure = kTum114Sure[i];
      if (kalan <= sure.ayetSayisi) {
        return (sure.no, kalan);
      }
      kalan -= sure.ayetSayisi;
    }
    return (114, 6);
  }

  /// Seçili hafıza göre sure bazlı doğrudan MP3 URL'si
  static String sureMp3Url(int sureNo, {HafizModel? hafiz}) {
    final h = hafiz ?? seciliHafiz.value;
    final sure3 = sureNo.toString().padLeft(3, '0');
    if (h.kod == 'ar.yasseraldossari') {
      return 'https://server11.mp3quran.net/yasser/$sure3.mp3';
    } else if (h.kod == 'ar.abdulbasitmurattal') {
      return 'https://server7.mp3quran.net/basit/Almusshaf-Al-Murattal/$sure3.mp3';
    } else {
      return 'https://server8.mp3quran.net/afs/$sure3.mp3';
    }
  }

  /// Seçili hafızın tüm doğrudan ve yedek ses adresleri
  static List<String> _adayUrller(int globalAyetNo) {
    final gecerli = globalAyetNo.clamp(1, 6236);
    final h = seciliHafiz.value;
    final (sureNo, ayetNo) = globaldenSureVeAyet(gecerli);
    final sure3 = sureNo.toString().padLeft(3, '0');
    final ayet3 = ayetNo.toString().padLeft(3, '0');

    final liste = <String>[];

    if (h.kod == 'ar.yasseraldossari') {
      // 1. EveryAyah Yasser Ad-Dossari doğrudan ve kesintisiz çalışan 128kbps CDN
      liste.add('https://everyayah.com/data/Yasser_Ad-Dossari_128kbps/$sure3$ayet3.mp3');
      // 2. Mp3Quran Yasser Ad-Dossari doğrudan çalışan sure sunucusu
      if (ayetNo == 1) {
        liste.add('https://server11.mp3quran.net/yasser/$sure3.mp3');
      }
      // 3. AlQuran Cloud CDN
      for (final br in h.bitrateler) {
        liste.add('https://cdn.islamic.network/quran/audio/$br/${h.kod}/$gecerli.mp3');
      }
    } else if (h.kod == 'ar.abdulbasitmurattal') {
      // 1. EveryAyah Abdulbasit Murattal
      liste.add('https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/$sure3$ayet3.mp3');
      liste.add('https://everyayah.com/data/Abdul_Basit_Murattal_64kbps/$sure3$ayet3.mp3');
      // 2. AlQuran Cloud CDN
      for (final br in h.bitrateler) {
        liste.add('https://cdn.islamic.network/quran/audio/$br/${h.kod}/$gecerli.mp3');
      }
    } else {
      // Mişari Raşid el-Afasi
      for (final br in h.bitrateler) {
        liste.add('https://cdn.islamic.network/quran/audio/$br/${h.kod}/$gecerli.mp3');
      }
      liste.add('https://everyayah.com/data/Alafasy_128kbps/$sure3$ayet3.mp3');
    }

    // Ortak güvenilir yedek: Mişari Raşid el-Afasi
    if (h.kod != 'ar.alafasy') {
      liste.add('https://everyayah.com/data/Alafasy_128kbps/$sure3$ayet3.mp3');
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
// 6. CANLI KIBLE PUSULASI SENSÖRÜ (MASAÜSTÜ MODLU SENSÖR FÜZYONU) VE TİTREŞİM KÖPRÜSÜ
// ============================================================================

class CanliPusulaSensorServisi {
  /// Mobil cihaz yönelim sensöründen canlı pusula açısını (0..360) okur.
  /// Sensör verisi yoksa -1 döner.
  static double cihazPusulaAcisiOku() {
    return cihazPusulaAcisiOkuBridge();
  }

  /// Cihazın native sensöründen gelen açının zaten Coğrafi Kuzey (True North) olup olmadığını döndürür.
  static bool nativeTrueNorthMu() {
    return pusulaNativeTrueNorthMuBridge();
  }

  /// Cihazın masaya düz (yatay) konulup konulmadığını döndürür.
  static bool masaustuModundaMi() {
    return pusulaMasaustuModundaMiBridge();
  }

  /// Cihazın ileri/geri eğim açısını (Pitch) derece cinsinden döndürür.
  static double egimPitchOku() {
    return pusulaEgimPitchOkuBridge();
  }

  /// Cihazın sağa/sola eğim açısını (Roll) derece cinsinden döndürür.
  static double egimRollOku() {
    return pusulaEgimRollOkuBridge();
  }

  /// Anlık manyetik alan şiddetini (µT) döndürür (normal Dünya alanı: 25-65 µT).
  static double manyetikAlanSiddetiOku() {
    return pusulaManyetikAlanSiddetiOkuBridge();
  }

  /// Cihazın manyetik sensör kalibrasyonuna (8 hareketi) ihtiyacı olup olmadığını döndürür.
  static bool kalibrasyonGerekliMi() {
    return pusulaKalibrasyonGerekliMiBridge();
  }

  /// iOS 13+ cihazlarda pusula sensörü iznini ister
  static void sensorIzniIste() {
    pusulaSensorIzniIsteBridge();
  }

  /// Kıble tam hizalandığında (±2°) çift ve belirgin titreşim verir
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
// 7. GERÇEK ANDROID & iOS EZAN SESLİ YEREL BİLDİRİM ALTYAPISI (flutter_local_notifications + timezone)
// ============================================================================

class BildirimAyarlariModel {
  static const List<String> vakitAnahtarlari = [
    'imsak',
    'gunes',
    'ogle',
    'ikindi',
    'aksam',
    'yatsi',
  ];

  final Map<String, bool> tamVaktinde;
  final Map<String, bool> vakitCikmadanOnce;
  final Map<String, String> vakitSesModu; // 'ezan', 'kisa', 'sessiz'
  final String genelSesModu; // 'ezan' (Tam Ezan Sesi), 'kisa' (Kısa Uyarı Sesi), 'sessiz' (Sessiz)
  final bool gununAyetiBildirimi;

  const BildirimAyarlariModel({
    required this.tamVaktinde,
    required this.vakitCikmadanOnce,
    required this.vakitSesModu,
    this.genelSesModu = 'ezan',
    this.gununAyetiBildirimi = true,
  });

  factory BildirimAyarlariModel.varsayilan() {
    return const BildirimAyarlariModel(
      tamVaktinde: {
        'imsak': true,
        'gunes': true,
        'ogle': true,
        'ikindi': true,
        'aksam': true,
        'yatsi': true,
      },
      vakitCikmadanOnce: {
        'imsak': true,
        'gunes': false,
        'ogle': true,
        'ikindi': true,
        'aksam': true,
        'yatsi': true,
      },
      vakitSesModu: {
        'imsak': 'ezan',
        'gunes': 'kisa',
        'ogle': 'ezan',
        'ikindi': 'ezan',
        'aksam': 'ezan',
        'yatsi': 'ezan',
      },
      genelSesModu: 'ezan',
      gununAyetiBildirimi: true,
    );
  }

  bool vakitTamAktifMi(String key) => tamVaktinde[key] ?? true;
  bool vakitCikmadanAktifMi(String key) => vakitCikmadanOnce[key] ?? true;
  String vakitSesModuGetir(String key) => vakitSesModu[key] ?? genelSesModu;

  BildirimAyarlariModel vakitGuncelle({
    required String vakitKey,
    bool? tamVaktindeDeger,
    bool? vakitCikmadanDeger,
    String? sesModuDeger,
  }) {
    final yeniTam = Map<String, bool>.from(tamVaktinde);
    final yeniCikmadan = Map<String, bool>.from(vakitCikmadanOnce);
    final yeniSes = Map<String, String>.from(vakitSesModu);
    if (tamVaktindeDeger != null) {
      yeniTam[vakitKey] = tamVaktindeDeger;
    }
    if (vakitCikmadanDeger != null) {
      yeniCikmadan[vakitKey] = vakitCikmadanDeger;
    }
    if (sesModuDeger != null) {
      yeniSes[vakitKey] = sesModuDeger;
    }
    return BildirimAyarlariModel(
      tamVaktinde: yeniTam,
      vakitCikmadanOnce: yeniCikmadan,
      vakitSesModu: yeniSes,
      genelSesModu: genelSesModu,
      gununAyetiBildirimi: gununAyetiBildirimi,
    );
  }

  BildirimAyarlariModel tumVakitlerinSesModunuDegistir(String yeniGenelSes) {
    final yeniSes = <String, String>{
      for (final k in vakitAnahtarlari) k: yeniGenelSes,
    };
    return BildirimAyarlariModel(
      tamVaktinde: Map<String, bool>.from(tamVaktinde),
      vakitCikmadanOnce: Map<String, bool>.from(vakitCikmadanOnce),
      vakitSesModu: yeniSes,
      genelSesModu: yeniGenelSes,
      gununAyetiBildirimi: gununAyetiBildirimi,
    );
  }

  BildirimAyarlariModel copyWith({
    Map<String, bool>? tamVaktinde,
    Map<String, bool>? vakitCikmadanOnce,
    Map<String, String>? vakitSesModu,
    String? genelSesModu,
    bool? gununAyetiBildirimi,
  }) {
    return BildirimAyarlariModel(
      tamVaktinde: tamVaktinde ?? Map<String, bool>.from(this.tamVaktinde),
      vakitCikmadanOnce: vakitCikmadanOnce ?? Map<String, bool>.from(this.vakitCikmadanOnce),
      vakitSesModu: vakitSesModu ?? Map<String, String>.from(this.vakitSesModu),
      genelSesModu: genelSesModu ?? this.genelSesModu,
      gununAyetiBildirimi: gununAyetiBildirimi ?? this.gununAyetiBildirimi,
    );
  }

  Map<String, dynamic> toJson() => {
        'tamVaktinde': tamVaktinde,
        'vakitCikmadanOnce': vakitCikmadanOnce,
        'vakitSesModu': vakitSesModu,
        'genelSesModu': genelSesModu,
        'gununAyetiBildirimi': gununAyetiBildirimi,
      };

  factory BildirimAyarlariModel.fromJson(Map<String, dynamic> m) {
    final def = BildirimAyarlariModel.varsayilan();
    final tam = Map<String, bool>.from(def.tamVaktinde);
    final cikmadan = Map<String, bool>.from(def.vakitCikmadanOnce);
    final ses = Map<String, String>.from(def.vakitSesModu);
    final genelSes = (m['genelSesModu'] as String?) ?? 'ezan';

    if (m['tamVaktinde'] is Map) {
      final rawTam = m['tamVaktinde'] as Map;
      for (final k in vakitAnahtarlari) {
        if (rawTam.containsKey(k)) {
          tam[k] = rawTam[k] == true;
        }
      }
    }

    if (m['vakitCikmadanOnce'] is Map) {
      final rawCik = m['vakitCikmadanOnce'] as Map;
      for (final k in vakitAnahtarlari) {
        if (rawCik.containsKey(k)) {
          cikmadan[k] = rawCik[k] == true;
        }
      }
    }

    if (m['vakitSesModu'] is Map) {
      final rawSes = m['vakitSesModu'] as Map;
      for (final k in vakitAnahtarlari) {
        final v = rawSes[k]?.toString();
        if (v == 'ezan' || v == 'kisa' || v == 'sessiz') {
          ses[k] = v!;
        }
      }
    } else {
      for (final k in vakitAnahtarlari) {
        ses[k] = genelSes;
      }
    }

    return BildirimAyarlariModel(
      tamVaktinde: tam,
      vakitCikmadanOnce: cikmadan,
      vakitSesModu: ses,
      genelSesModu: genelSes,
      gununAyetiBildirimi: m['gununAyetiBildirimi'] != false,
    );
  }
}

class BildirimAyarlariServisi {
  static const String _storageKey = 'nur_huzur_bildirim_ayarlari_v3';

  // 3 Farklı Ses Kanalı (Android 8.0+ kanal sesleri oluşturulduktan sonra değiştirilemediği için her ses moduna özel kanal):
  // 1. Tam Ezan Sesi Kanalı -> android/app/src/main/res/raw/adhan.mp3
  static const String _kanalTamEzanId = 'vakti_huzur_tam_ezan_sesli_v3';
  // 2. Kısa Uyarı Sesi Kanalı -> android/app/src/main/res/raw/adhan_short.wav
  static const String _kanalKisaUyariId = 'vakti_huzur_kisa_uyari_sesli_v3';
  // 3. Sessiz Bildirim Kanalı -> playSound: false
  static const String _kanalSessizId = 'vakti_huzur_sessiz_bildirim_v3';
  // 4. Vakit Çıkmadan Önce Hatırlatıcı Kanalı -> adhan_short.wav
  static const String _kanalCikmadanId = 'vakti_huzur_vakit_cikmadan_v3';

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _baslatildi = false;
  static bool _tzHazir = false;
  static final ValueNotifier<bool> izinDurumuNotifier = ValueNotifier<bool>(false);

  static final ValueNotifier<BildirimAyarlariModel> ayarlarNotifier =
      ValueNotifier<BildirimAyarlariModel>(_yukle());

  static BildirimAyarlariModel _yukle() {
    try {
      final raw = web.window.localStorage.getItem(_storageKey) ??
          web.window.localStorage.getItem('nur_huzur_bildirim_ayarlari_v2') ??
          web.window.localStorage.getItem('nur_huzur_bildirim_ayarlari_v1');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return BildirimAyarlariModel.fromJson(decoded);
      }
    } catch (_) {}
    return BildirimAyarlariModel.varsayilan();
  }

  static void _timezoneHazirla() {
    if (_tzHazir) return;
    _tzHazir = true;
    try {
      tz_data.initializeTimeZones();
      final offsetHours = DateTime.now().timeZoneOffset.inHours;
      if (offsetHours == 3) {
        tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      } else {
        for (final loc in tz.timeZoneDatabase.locations.values) {
          if (loc.currentTimeZone.offset.inMilliseconds ==
              DateTime.now().timeZoneOffset.inMilliseconds) {
            tz.setLocalLocation(loc);
            break;
          }
        }
      }
    } catch (_) {}
  }

  static NotificationDetails _sesModunaGoreDetayOlustur(String sesModu, {bool cikmadanMi = false}) {
    if (cikmadanMi) {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          _kanalCikmadanId,
          'Vakit Çıkmadan Önce Hatırlatıcı',
          channelDescription: 'Namaz vakti çıkmadan önce kısa uyarı sesiyle hatırlatma bildirimi gönderir.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('adhan_short'),
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'adhan_short.wav',
        ),
      );
    }

    if (sesModu == 'sessiz') {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          _kanalSessizId,
          'Namaz Vakti Bildirimleri (Sessiz)',
          channelDescription: 'Namaz vakti girdiğinde ses çalmadan sessiz bildirim gönderir.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: false,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        ),
      );
    }

    if (sesModu == 'kisa') {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          _kanalKisaUyariId,
          'Namaz Vakti Kısa Uyarı Sesi',
          channelDescription: 'Namaz vakti girdiğinde huzurlu kısa uyarı sesiyle bildirim gönderir.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('adhan_short'),
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'adhan_short.wav',
        ),
      );
    }

    // Varsayılan: 'ezan' -> Tam Ezan Sesi (raw/adhan.mp3 & iOS adhan.mp3)
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _kanalTamEzanId,
        'Sesli Ezan Okuma (Tam Ezan Bildirimi)',
        channelDescription: 'Diyanet namaz vakti girdiğinde gerçek ezan sesiyle (adhan.mp3) bildirim gönderir.',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'adhan.mp3',
      ),
    );
  }

  static Future<bool> baslatVeIzinIste({bool alarmIzniDeIste = false}) async {
    if (kIsWeb) return true;
    try {
      _timezoneHazirla();

      if (!_baslatildi) {
        const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosSettings = DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        const initSettings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );
        await _plugin.initialize(settings: initSettings);
        _baslatildi = true;
      }

      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        // 1. Tam Ezan Sesi Kanalı (raw/adhan.mp3)
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _kanalTamEzanId,
            'Sesli Ezan Okuma (Tam Ezan Bildirimi)',
            description: 'Namaz vakitleri girdiğinde gerçek ezan sesiyle (adhan) bildirim gönderir.',
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan'),
            audioAttributesUsage: AudioAttributesUsage.alarm,
            enableVibration: true,
            showBadge: true,
          ),
        );
        // 2. Kısa Uyarı Sesi Kanalı (raw/adhan_short.wav)
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _kanalKisaUyariId,
            'Namaz Vakti Kısa Uyarı Sesi',
            description: 'Namaz vakitleri girdiğinde kısa huzurlu uyarı sesiyle bildirim gönderir.',
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan_short'),
            enableVibration: true,
            showBadge: true,
          ),
        );
        // 3. Sessiz Bildirim Kanalı
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _kanalSessizId,
            'Namaz Vakti Bildirimleri (Sessiz)',
            description: 'Namaz vakitleri girdiğinde sessiz bildirim gönderir.',
            importance: Importance.high,
            playSound: false,
            enableVibration: true,
            showBadge: true,
          ),
        );
        // 4. Vakit Çıkmadan Önce Kanalı
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _kanalCikmadanId,
            'Vakit Çıkmadan Önce Hatırlatıcı',
            description: 'Namaz vakti çıkmadan önce hatırlatma bildirimi gönderir.',
            importance: Importance.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan_short'),
            enableVibration: true,
            showBadge: true,
          ),
        );

        final izinVerildi = await androidPlugin.requestNotificationsPermission();
        if (alarmIzniDeIste) {
          try {
            await androidPlugin.requestExactAlarmsPermission();
          } catch (_) {}
        }
        final aktifMi = await androidPlugin.areNotificationsEnabled() ?? (izinVerildi ?? true);
        izinDurumuNotifier.value = aktifMi;
        return aktifMi;
      }

      final iosPlugin =
          _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final iosIzin = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        izinDurumuNotifier.value = iosIzin ?? true;
        return iosIzin ?? true;
      }

      izinDurumuNotifier.value = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> gunlukBildirimleriZamanla({
    CanliNamazVakitleriModel? vakitModel,
    String dil = 'TR',
  }) async {
    if (kIsWeb) return;
    try {
      await baslatVeIzinIste();
      await _plugin.cancelAll();

      final model = vakitModel ?? NamazVeKonumServisi.hafizadakiSonVakitleriGetir();
      if (model == null) return;

      final ayar = ayarlarNotifier.value;
      final konum = model.konumAdi;

      final vakitVerileri = <Map<String, String>>[
        {'key': 'imsak', 'adTr': 'İmsak', 'adEn': 'Fajr (Imsak)', 'saat': model.imsak},
        {'key': 'gunes', 'adTr': 'Güneş', 'adEn': 'Sunrise', 'saat': model.gunes},
        {'key': 'ogle', 'adTr': 'Öğle', 'adEn': 'Dhuhr', 'saat': model.ogle},
        {'key': 'ikindi', 'adTr': 'İkindi', 'adEn': 'Asr', 'saat': model.ikindi},
        {'key': 'aksam', 'adTr': 'Akşam', 'adEn': 'Maghrib', 'saat': model.aksam},
        {'key': 'yatsi', 'adTr': 'Yatsı', 'adEn': 'Isha', 'saat': model.yatsi},
      ];

      (int, int)? saatParcala(String s) {
        final temiz = s.split(' ').first.trim();
        final p = temiz.split(':');
        if (p.length >= 2) {
          final h = int.tryParse(p[0]);
          final m = int.tryParse(p[1]);
          if (h != null && m != null) return (h.clamp(0, 23), m.clamp(0, 59));
        }
        return null;
      }

      tz.TZDateTime gelecekZamanOlustur(int saat, int dakika) {
        final simdi = tz.TZDateTime.now(tz.local);
        var hedef = tz.TZDateTime(tz.local, simdi.year, simdi.month, simdi.day, saat, dakika);
        if (hedef.isBefore(simdi)) {
          hedef = hedef.add(const Duration(days: 1));
        }
        return hedef;
      }

      final cikmadanDetay = _sesModunaGoreDetayOlustur('kisa', cikmadanMi: true);

      Future<void> guvenliZamanla({
        required int id,
        required String baslik,
        required String icerik,
        required tz.TZDateTime zaman,
        required NotificationDetails detay,
      }) async {
        try {
          await _plugin.zonedSchedule(
            id: id,
            title: baslik,
            body: icerik,
            scheduledDate: zaman,
            notificationDetails: detay,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        } catch (_) {
          try {
            await _plugin.zonedSchedule(
              id: id,
              title: baslik,
              body: icerik,
              scheduledDate: zaman,
              notificationDetails: detay,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.time,
            );
          } catch (_) {}
        }
      }

      for (int i = 0; i < vakitVerileri.length; i++) {
        final v = vakitVerileri[i];
        final key = v['key']!;
        final ad = dil == 'EN' ? v['adEn']! : v['adTr']!;
        final saatStr = v['saat']!;
        final hm = saatParcala(saatStr);
        if (hm == null) continue;

        // 1. TAM VAKTİNDE BİLDİRİMİ (ID: 100..105) — Vaktin ses moduna ('ezan', 'kisa', 'sessiz') göre!
        if (ayar.vakitTamAktifMi(key)) {
          final sesModu = ayar.vakitSesModuGetir(key);
          final tamDetay = _sesModunaGoreDetayOlustur(sesModu);
          final zaman = gelecekZamanOlustur(hm.$1, hm.$2);
          final ezanEtiketi = sesModu == 'ezan' ? '🔊 ' : '';
          final baslik = dil == 'EN'
              ? '$ezanEtiketi🕌 $konum • $ad Time ($saatStr)'
              : '$ezanEtiketi🕌 $konum • $ad Vakti Girdi ($saatStr)';
          final icerik = dil == 'EN'
              ? '$ad time has entered for $konum. Hayya alas-salah!'
              : '$konum için $ad vakti girdi ($saatStr). Hayye ale’s-salâh, Hayye ale’l-felâh!';
          await guvenliZamanla(
            id: 100 + i,
            baslik: baslik,
            icerik: icerik,
            zaman: zaman,
            detay: tamDetay,
          );
        }

        // 2. VAKİT ÇIKMADAN ÖNCE BİLDİRİMİ (Sonraki vakitten 25 dakika önce — ID: 200..205)
        if (ayar.vakitCikmadanAktifMi(key)) {
          final sonrakiV = vakitVerileri[(i + 1) % vakitVerileri.length];
          final sonrakiHm = saatParcala(sonrakiV['saat']!);
          if (sonrakiHm != null) {
            final simdi = tz.TZDateTime.now(tz.local);
            var sonrakiZaman = tz.TZDateTime(
              tz.local,
              simdi.year,
              simdi.month,
              simdi.day,
              sonrakiHm.$1,
              sonrakiHm.$2,
            );
            var uyariZaman = sonrakiZaman.subtract(const Duration(minutes: 25));
            if (uyariZaman.isBefore(simdi)) {
              uyariZaman = uyariZaman.add(const Duration(days: 1));
            }
            final sonrakiAd = dil == 'EN' ? sonrakiV['adEn']! : sonrakiV['adTr']!;
            final baslik = dil == 'EN'
                ? '⏳ $konum • $ad Time Ending Soon'
                : '⏳ $konum • $ad Vakti Çıkmak Üzere';
            final icerik = dil == 'EN'
                ? '25 minutes remaining until $sonrakiAd (${sonrakiV['saat']}). Remember to complete your $ad prayer.'
                : '$sonrakiAd vaktine (${sonrakiV['saat']}) 25 dakika kaldı. $ad vaktini çıkmadan eda etmeyi unutmayın.';
            await guvenliZamanla(
              id: 200 + i,
              baslik: baslik,
              icerik: icerik,
              zaman: uyariZaman,
              detay: cikmadanDetay,
            );
          }
        }
      }

      // 3. GÜNÜN AYETİ & HADİSİ BİLDİRİMİ (Her gün 10:00 — ID: 300)
      if (ayar.gununAyetiBildirimi) {
        final ayetZaman = gelecekZamanOlustur(10, 0);
        await guvenliZamanla(
          id: 300,
          baslik: dil == 'EN'
              ? '✨ Vakt-i Huzur • Verse & Hadith of the Day'
              : '✨ Vakt-i Huzur • Günün Ayeti ve Hadis-i Şerifi',
          icerik: dil == 'EN'
              ? '“Verily, in the remembrance of Allah do hearts find rest.” (Surah Ar-Ra’d, 28)'
              : '“Biliniz ki, kalpler ancak Allah’ı anmakla (zikirle) huzur bulur.” (Ra’d Suresi, 28. Ayet)',
          zaman: ayetZaman,
          detay: _sesModunaGoreDetayOlustur('kisa'),
        );
      }
    } catch (_) {}
  }

  /// Kullanıcının seçtiği ses moduyla ('ezan', 'kisa', 'sessiz') anında gerçek sistem bildirimi düşürür ve ezan okur.
  static Future<bool> anindaGercekSistemBildirimiGonder({
    required String baslik,
    required String icerik,
    String? sesModu,
  }) async {
    final aktifSesModu = sesModu ?? ayarlarNotifier.value.genelSesModu;
    CanliPusulaSensorServisi.kibleDogrulandiTitresim();
    try {
      bildirimSesiCalBridge(baslik, icerik, sesModu: aktifSesModu);
    } catch (_) {}

    if (kIsWeb) return true;

    try {
      final izinTamam = await baslatVeIzinIste(alarmIzniDeIste: true);
      final detay = _sesModunaGoreDetayOlustur(aktifSesModu);
      await _plugin.show(
        id: 999,
        title: baslik,
        body: icerik,
        notificationDetails: detay,
      );
      return izinTamam;
    } catch (_) {
      return false;
    }
  }

  static void guncelle(
    BildirimAyarlariModel yeni, {
    CanliNamazVakitleriModel? vakitModel,
    String dil = 'TR',
  }) {
    ayarlarNotifier.value = yeni;
    try {
      web.window.localStorage.setItem(_storageKey, jsonEncode(yeni.toJson()));
    } catch (_) {}
    gunlukBildirimleriZamanla(vakitModel: vakitModel, dil: dil);
  }

  static String _sesModuEtiketi(String mod, String dil) {
    if (dil == 'EN') {
      if (mod == 'ezan') return '🔊 Full Adhan';
      if (mod == 'kisa') return '🔔 Short Tone';
      return '🔕 Silent';
    }
    if (mod == 'ezan') return '🔊 Tam Ezan Sesi';
    if (mod == 'kisa') return '🔔 Kısa Uyarı Sesi';
    return '🔕 Sessiz';
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
    String siradakiVakitSaat = '18:04',
  }) {
    baslatVeIzinIste();

    final kayitliVakit = NamazVeKonumServisi.hafizadakiSonVakitleriGetir();
    final aktifKonum = kayitliVakit?.konumAdi ?? konumAdi;

    final vakitSatirlari = [
      {
        'key': 'imsak',
        'ad': dil == 'EN' ? 'Fajr (Imsak)' : dil == 'AR' ? 'الفجر (الإمساك)' : 'İmsak',
        'saat': kayitliVakit?.imsak ?? '06:05',
        'ikon': Icons.nightlight_outlined,
      },
      {
        'key': 'gunes',
        'ad': dil == 'EN' ? 'Sunrise' : dil == 'AR' ? 'الشروق' : 'Güneş',
        'saat': kayitliVakit?.gunes ?? '07:31',
        'ikon': Icons.wb_twilight_rounded,
      },
      {
        'key': 'ogle',
        'ad': dil == 'EN' ? 'Dhuhr' : dil == 'AR' ? 'الظهر' : 'Öğle',
        'saat': kayitliVakit?.ogle ?? '12:53',
        'ikon': Icons.wb_sunny_outlined,
      },
      {
        'key': 'ikindi',
        'ad': dil == 'EN' ? 'Asr' : dil == 'AR' ? 'العصر' : 'İkindi',
        'saat': kayitliVakit?.ikindi ?? '15:38',
        'ikon': Icons.sunny_snowing,
      },
      {
        'key': 'aksam',
        'ad': dil == 'EN' ? 'Maghrib' : dil == 'AR' ? 'المغرب' : 'Akşam',
        'saat': kayitliVakit?.aksam ?? '18:04',
        'ikon': Icons.nights_stay_outlined,
      },
      {
        'key': 'yatsi',
        'ad': dil == 'EN' ? 'Isha' : dil == 'AR' ? 'العشاء' : 'Yatsı',
        'saat': kayitliVakit?.yatsi ?? '19:25',
        'ikon': Icons.bedtime_outlined,
      },
    ];

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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.90,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: vurguAltin.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: vurguAltin.withValues(alpha: 0.5)),
                            ),
                            child: Icon(
                              Icons.volume_up_rounded,
                              color: vurguAltin,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dil == 'EN'
                                      ? 'Adhan Sound & Notification Settings'
                                      : 'Ezan Sesli Bildirim Ayarları',
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: yaziRengi,
                                  ),
                                ),
                                Text(
                                  '$aktifKonum • 🔊 Bildirimde Ezan Oku (Sesli Ezan)',
                                  style: TextStyle(color: vurguAltin, fontSize: 11.5, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              bildirimSesiDurdurBridge();
                              Navigator.pop(ctx);
                            },
                            icon: Icon(Icons.close_rounded, color: ikincilYazi),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // GENEL EZAN SESİ SEÇİM KUTUSU: (🔊 Tam Ezan Sesi | 🔔 Kısa Uyarı Sesi | 🔕 Sessiz)
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: arkaPlan.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: vurguAltin.withValues(alpha: 0.45)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.campaign_rounded, color: vurguAltin, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    dil == 'EN'
                                        ? '🔊 Play Adhan on Notification (Sound Mode):'
                                        : '🔊 Bildirimde Ezan Oku (Genel Ses Seçimi):',
                                    style: TextStyle(
                                      color: yumusakAltin,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    bildirimSesiCalBridge(
                                      'Vakt-i Huzur Ezan Sesi',
                                      'Ezan sesi önizlemesi',
                                      sesModu: ayar.genelSesModu == 'sessiz' ? 'ezan' : ayar.genelSesModu,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: vurguAltin.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: vurguAltin),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.play_arrow_rounded, size: 14, color: vurguAltin),
                                        const SizedBox(width: 3),
                                        Text(
                                          dil == 'EN' ? 'Listen' : 'Ezanı Dinle',
                                          style: TextStyle(
                                            color: vurguAltin,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                for (final mod in ['ezan', 'kisa', 'sessiz'])
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          final yeniAyar = ayar.tumVakitlerinSesModunuDegistir(mod);
                                          guncelle(yeniAyar, vakitModel: kayitliVakit, dil: dil);
                                          if (mod != 'sessiz') {
                                            bildirimSesiCalBridge(
                                              'Vakt-i Huzur',
                                              'Ses Önizleme',
                                              sesModu: mod,
                                            );
                                          } else {
                                            bildirimSesiDurdurBridge();
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                          decoration: BoxDecoration(
                                            color: ayar.genelSesModu == mod
                                                ? vurguAltin
                                                : kartRengi,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: ayar.genelSesModu == mod
                                                  ? vurguAltin
                                                  : vurguAltin.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Text(
                                            _sesModuEtiketi(mod, dil),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: ayar.genelSesModu == mod
                                                  ? arkaPlan
                                                  : yaziRengi,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tablo Üst Başlığı: Vakit & Ses Modu | Tam Vaktinde | Çıkmadan Önce
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: vurguAltin.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: vurguAltin.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Text(
                                dil == 'EN' ? 'Prayer & Sound Mode' : 'Vakit & Ses Seçimi',
                                style: TextStyle(
                                  color: vurguAltin,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                dil == 'EN' ? 'On Time' : 'Vaktinde',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: vurguAltin,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                dil == 'EN' ? 'Before End' : 'Çıkmadan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: vurguAltin,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // 6 Vakit Listesi (Her vakit için ayrı ses modu değiştirme özelliğiyle)
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            ...vakitSatirlari.map((v) {
                              final key = v['key'] as String;
                              final ad = v['ad'] as String;
                              final saat = v['saat'] as String;
                              final ikon = v['ikon'] as IconData;
                              final tamAktif = ayar.vakitTamAktifMi(key);
                              final cikmadanAktif = ayar.vakitCikmadanAktifMi(key);
                              final vSes = ayar.vakitSesModuGetir(key);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: arkaPlan.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: (tamAktif || cikmadanAktif)
                                        ? vurguAltin.withValues(alpha: 0.35)
                                        : vurguAltin.withValues(alpha: 0.14),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Row(
                                        children: [
                                          Icon(ikon, color: vurguAltin, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      ad,
                                                      style: TextStyle(
                                                        color: yaziRengi,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      saat,
                                                      style: TextStyle(
                                                        color: vurguAltin,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 11.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                // Vakit bazlı ses modu seçici chip (Tıklandıkça Tam Ezan -> Kısa Uyarı -> Sessiz değişir)
                                                InkWell(
                                                  borderRadius: BorderRadius.circular(6),
                                                  onTap: () {
                                                    HapticFeedback.selectionClick();
                                                    final siradakiMod = vSes == 'ezan'
                                                        ? 'kisa'
                                                        : (vSes == 'kisa' ? 'sessiz' : 'ezan');
                                                    guncelle(
                                                      ayar.vakitGuncelle(
                                                        vakitKey: key,
                                                        sesModuDeger: siradakiMod,
                                                      ),
                                                      vakitModel: kayitliVakit,
                                                      dil: dil,
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: vSes == 'ezan'
                                                          ? vurguAltin.withValues(alpha: 0.22)
                                                          : kartRengi,
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(
                                                        color: vurguAltin.withValues(alpha: 0.45),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      _sesModuEtiketi(vSes, dil),
                                                      style: TextStyle(
                                                        color: vSes == 'ezan'
                                                            ? yumusakAltin
                                                            : ikincilYazi,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Switch.adaptive(
                                          value: tamAktif,
                                          activeThumbColor: vurguAltin,
                                          activeTrackColor: vurguAltin.withValues(alpha: 0.35),
                                          onChanged: (val) {
                                            HapticFeedback.lightImpact();
                                            guncelle(
                                              ayar.vakitGuncelle(
                                                vakitKey: key,
                                                tamVaktindeDeger: val,
                                              ),
                                              vakitModel: kayitliVakit,
                                              dil: dil,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Switch.adaptive(
                                          value: cikmadanAktif,
                                          activeThumbColor: vurguAltin,
                                          activeTrackColor: vurguAltin.withValues(alpha: 0.35),
                                          onChanged: (val) {
                                            HapticFeedback.lightImpact();
                                            guncelle(
                                              ayar.vakitGuncelle(
                                                vakitKey: key,
                                                vakitCikmadanDeger: val,
                                              ),
                                              vakitModel: kayitliVakit,
                                              dil: dil,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Günün Ayeti Bildirimi Anahtarı
                            Container(
                              margin: const EdgeInsets.only(top: 2, bottom: 8),
                              decoration: BoxDecoration(
                                color: arkaPlan.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: vurguAltin.withValues(alpha: 0.28)),
                              ),
                              child: SwitchListTile(
                                dense: true,
                                activeThumbColor: vurguAltin,
                                secondary: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: vurguAltin,
                                  size: 20,
                                ),
                                title: Text(
                                  dil == 'EN'
                                      ? 'Daily Verse & Hadith Notification'
                                      : 'Günün Ayeti & Hadisi Bildirimi',
                                  style: TextStyle(
                                    color: yaziRengi,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  dil == 'EN'
                                      ? 'Daily inspiring Qur’an verse and Sahih Hadith at 10:00'
                                      : 'Her gün saat 10:00’da seçkin bir ayet ve hadis bildirimi',
                                  style: TextStyle(color: ikincilYazi, fontSize: 11),
                                ),
                                value: ayar.gununAyetiBildirimi,
                                onChanged: (val) {
                                  HapticFeedback.lightImpact();
                                  guncelle(
                                    ayar.copyWith(gununAyetiBildirimi: val),
                                    vakitModel: kayitliVakit,
                                    dil: dil,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // EZAN SESLİ BİLDİRİMİ TEST ET BUTONU
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: vurguAltin,
                          foregroundColor: arkaPlan,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final kontrolBaslik = dil == 'EN'
                              ? '🔊🕌 Vakt-i Huzur • $aktifKonum $siradakiVakitAdi ($siradakiVakitSaat)'
                              : '🔊🕌 Vakt-i Huzur • $aktifKonum $siradakiVakitAdi Vakti ($siradakiVakitSaat)';
                          final kontrolIcerik = dil == 'EN'
                              ? 'Adhan notification sound (${_sesModuEtiketi(ayar.genelSesModu, dil)}) verified!'
                              : 'Ezan sesli bildirim (${_sesModuEtiketi(ayar.genelSesModu, dil)}) doğrulandı! Hayye ale’s-salâh!';

                          await anindaGercekSistemBildirimiGonder(
                            baslik: kontrolBaslik,
                            icerik: kontrolIcerik,
                            sesModu: ayar.genelSesModu,
                          );
                          await gunlukBildirimleriZamanla(
                            vakitModel: kayitliVakit,
                            dil: dil,
                          );

                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: kartRengi,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: vurguAltin, width: 1.4),
                              ),
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    color: vurguAltin,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      dil == 'EN'
                                          ? 'Adhan notification sent & daily prayer alarms scheduled!'
                                          : 'Sesli Ezan bildirimi gönderildi ve tüm vakitler zamanlandı!',
                                      style: TextStyle(
                                        color: yaziRengi,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.volume_up_rounded, size: 19),
                        label: Text(
                          dil == 'EN'
                              ? '🔊 Test Adhan Notification & Schedule Alarms'
                              : '🔊 Sesli Ezan Bildirimini Test Et ve Kaydet',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}



