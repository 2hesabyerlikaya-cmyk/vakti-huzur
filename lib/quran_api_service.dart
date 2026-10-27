import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'web_shim_io.dart' if (dart.library.js_interop) 'package:web/web.dart' as web;
import 'quran_hadith_data.dart';

// ============================================================================
// CANLI KUR'AN AYET MODELİ & DİNAMİK REELS KART MODELİ
// ============================================================================

class CanliAyetModel {
  final int ayetNo;
  final int globalAyetNo;
  final String arapca;
  final String mealTr;
  final String mealEn;
  final int cuz;
  final int sayfa;

  const CanliAyetModel({
    required this.ayetNo,
    required this.globalAyetNo,
    required this.arapca,
    required this.mealTr,
    required this.mealEn,
    required this.cuz,
    required this.sayfa,
  });

  Map<String, dynamic> toJson() => {
        'ayetNo': ayetNo,
        'globalAyetNo': globalAyetNo,
        'arapca': arapca,
        'mealTr': mealTr,
        'mealEn': mealEn,
        'cuz': cuz,
        'sayfa': sayfa,
      };

  factory CanliAyetModel.fromJson(Map<String, dynamic> m) {
    return CanliAyetModel(
      ayetNo: (m['ayetNo'] as num?)?.toInt() ?? 1,
      globalAyetNo: (m['globalAyetNo'] as num?)?.toInt() ?? 1,
      arapca: m['arapca']?.toString() ?? '',
      mealTr: m['mealTr']?.toString() ?? '',
      mealEn: m['mealEn']?.toString() ?? '',
      cuz: (m['cuz'] as num?)?.toInt() ?? 1,
      sayfa: (m['sayfa'] as num?)?.toInt() ?? 1,
    );
  }
}

class DinamikReelsKart {
  final String id;
  final bool ayetMi;
  final int? globalAyetNo;
  final String arapcaMetin;
  final String konuTr;
  final String konuEn;
  final String mealTr;
  final String mealEn;
  final String kaynakKisaTr;
  final String kaynakKisaEn;
  final String dogrulanmisTr;
  final String dogrulanmisEn;
  final String tefsirTr;
  final String tefsirEn;
  final List<Color> arkaPlanRenkleri;
  final int desenIndex;
  int begeniSayisi;
  bool begenildi;
  bool kaydedildi;

  DinamikReelsKart({
    required this.id,
    required this.ayetMi,
    this.globalAyetNo,
    required this.arapcaMetin,
    required this.konuTr,
    required this.konuEn,
    required this.mealTr,
    required this.mealEn,
    required this.kaynakKisaTr,
    required this.kaynakKisaEn,
    required this.dogrulanmisTr,
    required this.dogrulanmisEn,
    required this.tefsirTr,
    required this.tefsirEn,
    required this.arkaPlanRenkleri,
    required this.desenIndex,
    this.begeniSayisi = 0,
    this.begenildi = false,
    this.kaydedildi = false,
  });

  String turBasligi(String dil) {
    if (dil == 'EN') return ayetMi ? 'Holy Qur’an Verse' : 'Prophetic Hadith';
    if (dil == 'AR') return ayetMi ? 'آية كريمة' : 'حديث شريف';
    return ayetMi ? 'Ayet-i Kerime' : 'Hadis-i Şerif';
  }

  String konu(String dil) => dil == 'EN' ? konuEn : konuTr;
  String meal(String dil) => dil == 'EN' ? mealEn : (dil == 'AR' ? arapcaMetin : mealTr);
  String kaynakKisa(String dil) => dil == 'EN' ? kaynakKisaEn : kaynakKisaTr;
  String dogrulanmis(String dil) => dil == 'EN' ? dogrulanmisEn : dogrulanmisTr;
  String tefsir(String dil) => dil == 'EN' ? tefsirEn : tefsirTr;
}

// ============================================================================
// KUR'AN-I KERİM CANLI API SERVİSİ (ALQURAN.CLOUD - 114 SURE & 6236 AYET)
// ============================================================================

class KuranApiServisi {
  static final Map<int, List<CanliAyetModel>> _sureOnbellek = {};

  /// 1. Fâtiha Suresi hariç diğer surelerin 1. ayetinin başındaki Besmele'yi temizler
  static String besmeleTemizle(String arapcaMetin, int sureNo, int ayetNo) {
    final t = arapcaMetin.trim();
    if (sureNo == 1 || sureNo == 9 || ayetNo != 1) return t;

    const besmeleKaliplari = [
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيمِ',
      'بسم الله الرحمن الرحيم',
    ];

    for (final b in besmeleKaliplari) {
      if (t.startsWith(b)) {
        final kalan = t.substring(b.length).trim();
        if (kalan.isNotEmpty) return kalan;
      }
    }

    // Unicode hareke farklılıklarına karşı ilk 4 kelime "بِسْمِ ... الرَّحِيمِ" ise kırp
    final kelimeler = t.split(RegExp(r'\s+'));
    if (kelimeler.length > 4 &&
        (kelimeler[0].contains('بِسْمِ') || kelimeler[0].contains('بسم')) &&
        (kelimeler[3].contains('حِيم') || kelimeler[3].contains('حيم'))) {
      return kelimeler.sublist(4).join(' ').trim();
    }

    return t;
  }

  /// Seçilen surenin (1..114) tüm ayetlerini canlı olarak çeker
  static Future<List<CanliAyetModel>> sureAyetleriniGetir(int sureNo) async {
    if (_sureOnbellek.containsKey(sureNo)) {
      return _sureOnbellek[sureNo]!;
    }

    final url = Uri.parse(
      'https://api.alquran.cloud/v1/surah/$sureNo/editions/quran-uthmani,tr.diyanet,en.sahih',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final dataList = decoded['data'] as List<dynamic>;
        if (dataList.length >= 3) {
          final arAyahs = (dataList[0] as Map<String, dynamic>)['ayahs'] as List<dynamic>;
          final trAyahs = (dataList[1] as Map<String, dynamic>)['ayahs'] as List<dynamic>;
          final enAyahs = (dataList[2] as Map<String, dynamic>)['ayahs'] as List<dynamic>;

          final List<CanliAyetModel> sonuc = [];
          for (int i = 0; i < arAyahs.length; i++) {
            final ar = arAyahs[i] as Map<String, dynamic>;
            final tr = i < trAyahs.length ? trAyahs[i] as Map<String, dynamic> : ar;
            final en = i < enAyahs.length ? enAyahs[i] as Map<String, dynamic> : ar;
            final ayetNo = (ar['numberInSurah'] as num).toInt();
            final hamArapca = (ar['text'] as String).trim();

            sonuc.add(
              CanliAyetModel(
                ayetNo: ayetNo,
                globalAyetNo: (ar['number'] as num).toInt(),
                arapca: besmeleTemizle(hamArapca, sureNo, ayetNo),
                mealTr: (tr['text'] as String).trim(),
                mealEn: (en['text'] as String).trim(),
                cuz: (ar['juz'] as num?)?.toInt() ?? 1,
                sayfa: (ar['page'] as num?)?.toInt() ?? 1,
              ),
            );
          }

          _sureOnbellek[sureNo] = sonuc;
          // Çevrimdışı (internetsiz) okuma için cihaz hafızasına (localStorage) otomatik kaydet
          try {
            web.window.localStorage.setItem(
              'nur_huzur_sure_cache_v1_$sureNo',
              jsonEncode(sonuc.map((a) => a.toJson()).toList()),
            );
          } catch (_) {}
          return sonuc;
        }
      }
    } catch (_) {}

    // İnternet yoksa önce cihaz hafızasına (localStorage) kaydedilmiş sure verisini oku
    try {
      final kayitliRaw = web.window.localStorage.getItem('nur_huzur_sure_cache_v1_$sureNo');
      if (kayitliRaw != null && kayitliRaw.isNotEmpty) {
        final decodedList = jsonDecode(kayitliRaw) as List<dynamic>;
        final kayitliAyetler = decodedList
            .map((e) => CanliAyetModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (kayitliAyetler.isNotEmpty) {
          _sureOnbellek[sureNo] = kayitliAyetler;
          return kayitliAyetler;
        }
      }
    } catch (_) {}

    return _yedekSureAyetleri(sureNo);
  }

  /// 6236 Kur'an ayeti içinden globalAyetNo (1..6236) ile canlı Reels kartı oluşturur (Başlangıç beğenisi: 0)
  static Future<DinamikReelsKart?> canliAyetReelsKartiGetir(int globalAyetNo, int siraIndex) async {
    final gecerliNo = ((globalAyetNo - 1) % 6236) + 1;
    final url = Uri.parse(
      'https://api.alquran.cloud/v1/ayah/$gecerliNo/editions/quran-uthmani,tr.diyanet,en.sahih',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 9));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final dataList = decoded['data'] as List<dynamic>;
        if (dataList.length >= 3) {
          final ar = dataList[0] as Map<String, dynamic>;
          final tr = dataList[1] as Map<String, dynamic>;
          final en = dataList[2] as Map<String, dynamic>;

          final surahObj = ar['surah'] as Map<String, dynamic>;
          final sureNo = (surahObj['number'] as num).toInt();
          final ayetNo = (ar['numberInSurah'] as num).toInt();
          final cuzNo = (ar['juz'] as num?)?.toInt() ?? 1;
          final sayfaNo = (ar['page'] as num?)?.toInt() ?? 1;

          final sureMeta = kTum114Sure[(sureNo - 1).clamp(0, kTum114Sure.length - 1)];
          final paletIdx = siraIndex % kReelsArkaPlanPaletleri.length;
          final temizArapca = besmeleTemizle((ar['text'] as String).trim(), sureNo, ayetNo);

          return DinamikReelsKart(
            id: 'ayah_${gecerliNo}_$siraIndex',
            ayetMi: true,
            globalAyetNo: gecerliNo,
            arapcaMetin: temizArapca,
            konuTr: '${sureMeta.adTr} Suresi (${sureMeta.anlamTr}) • $cuzNo. Cüz',
            konuEn: 'Surah ${sureMeta.adEn} (${sureMeta.anlamEn}) • Juz $cuzNo',
            mealTr: '“${(tr['text'] as String).trim()}”',
            mealEn: '“${(en['text'] as String).trim()}”',
            kaynakKisaTr: '${sureMeta.adTr} Suresi, $ayetNo. Ayet',
            kaynakKisaEn: 'Surah ${sureMeta.adEn}, Verse $ayetNo',
            dogrulanmisTr:
                'Doğrulanmış Kaynak: T.C. Diyanet İşleri Başkanlığı Kur’an-ı Kerim Meali • ${sureMeta.adTr} $sureNo/$ayetNo (Sayfa: $sayfaNo)',
            dogrulanmisEn:
                'Verified Source: Presidency of Religious Affairs & Sahih Int. • ${sureMeta.adEn} $sureNo:$ayetNo (Page: $sayfaNo)',
            tefsirTr:
                '${sureMeta.yer} olan ${sureMeta.adTr} Suresi’nin $ayetNo. ayet-i kerimesidir ($cuzNo. Cüz, $sayfaNo. Sayfa).',
            tefsirEn:
                'Verse $ayetNo of Surah ${sureMeta.adEn} (${sureMeta.yer}, Juz $cuzNo, Page $sayfaNo).',
            arkaPlanRenkleri: kReelsArkaPlanPaletleri[paletIdx],
            desenIndex: paletIdx,
            begeniSayisi: 0,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// Sahih Hadis havuzundan dinamik Reels kartı üretir (Başlangıç beğenisi: 0)
  static DinamikReelsKart sahihHadisReelsKartiOlustur(int hadisIndex, int siraIndex) {
    final h = kSahihHadisHavuzu[hadisIndex % kSahihHadisHavuzu.length];
    final paletIdx = siraIndex % kReelsArkaPlanPaletleri.length;

    return DinamikReelsKart(
      id: 'hadith_${hadisIndex}_$siraIndex',
      ayetMi: false,
      arapcaMetin: h['arapca']!,
      konuTr: h['konuTr']!,
      konuEn: h['konuEn']!,
      mealTr: h['mealTr']!,
      mealEn: h['mealEn']!,
      kaynakKisaTr: h['kaynakKisa']!,
      kaynakKisaEn: h['kaynakKisa']!,
      dogrulanmisTr: h['dogrulanmis']!,
      dogrulanmisEn: h['dogrulanmis']!,
      tefsirTr: h['tefsirTr']!,
      tefsirEn: h['tefsirEn']!,
      arkaPlanRenkleri: kReelsArkaPlanPaletleri[paletIdx],
      desenIndex: paletIdx,
      begeniSayisi: 0,
    );
  }

  static List<CanliAyetModel> _yedekSureAyetleri(int sureNo) {
    final meta = kTum114Sure[(sureNo - 1).clamp(0, kTum114Sure.length - 1)];
    if (sureNo == 1) {
      return const [
        CanliAyetModel(
          ayetNo: 1,
          globalAyetNo: 1,
          arapca: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          mealTr: 'Rahmân ve Rahîm olan Allah’ın adıyla.',
          mealEn: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          cuz: 1,
          sayfa: 1,
        ),
        CanliAyetModel(
          ayetNo: 2,
          globalAyetNo: 2,
          arapca: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          mealTr: 'Hamd, âlemlerin Rabbi olan Allah’a mahsustur.',
          mealEn: 'All praise is due to Allah, Lord of the worlds.',
          cuz: 1,
          sayfa: 1,
        ),
      ];
    }
    return [
      CanliAyetModel(
        ayetNo: 1,
        globalAyetNo: sureNo,
        arapca: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        mealTr: '${meta.adTr} Suresi (${meta.ayetSayisi} Ayet)',
        mealEn: 'Surah ${meta.adEn} (${meta.ayetSayisi} Verses)',
        cuz: 1,
        sayfa: 1,
      ),
    ];
  }
}
