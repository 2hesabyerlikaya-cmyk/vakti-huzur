import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  final String mealDe;
  final String mealFr;
  final int cuz;
  final int sayfa;

  const CanliAyetModel({
    required this.ayetNo,
    required this.globalAyetNo,
    required this.arapca,
    required this.mealTr,
    required this.mealEn,
    this.mealDe = '',
    this.mealFr = '',
    required this.cuz,
    required this.sayfa,
  });

  String mealGetir(String dil) {
    if (dil == 'DE' && mealDe.isNotEmpty) return mealDe;
    if (dil == 'FR' && mealFr.isNotEmpty) return mealFr;
    if (dil == 'EN') return mealEn;
    if (dil == 'AR') return arapca;
    return mealTr;
  }

  Map<String, dynamic> toJson() => {
        'ayetNo': ayetNo,
        'globalAyetNo': globalAyetNo,
        'arapca': arapca,
        'mealTr': mealTr,
        'mealEn': mealEn,
        'mealDe': mealDe,
        'mealFr': mealFr,
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
      mealDe: m['mealDe']?.toString() ?? '',
      mealFr: m['mealFr']?.toString() ?? '',
      cuz: (m['cuz'] as num?)?.toInt() ?? 1,
      sayfa: (m['sayfa'] as num?)?.toInt() ?? 1,
    );
  }
}

class DinamikReelsKart {
  final String id;
  final bool ayetMi;
  final String? icerikTuru; // 'ayet', 'hadis', 'esma', 'dua'
  final int? globalAyetNo;
  final String arapcaMetin;
  final String konuTr;
  final String konuEn;
  final String konuDe;
  final String konuFr;
  final String mealTr;
  final String mealEn;
  final String mealDe;
  final String mealFr;
  final String kaynakKisaTr;
  final String kaynakKisaEn;
  final String kaynakKisaDe;
  final String kaynakKisaFr;
  final String dogrulanmisTr;
  final String dogrulanmisEn;
  final String dogrulanmisDe;
  final String dogrulanmisFr;
  final String tefsirTr;
  final String tefsirEn;
  final String tefsirDe;
  final String tefsirFr;
  final List<Color> arkaPlanRenkleri;
  final int desenIndex;
  int begeniSayisi;
  bool begenildi;
  bool kaydedildi;

  DinamikReelsKart({
    required this.id,
    required this.ayetMi,
    this.icerikTuru,
    this.globalAyetNo,
    required this.arapcaMetin,
    required this.konuTr,
    required this.konuEn,
    this.konuDe = '',
    this.konuFr = '',
    required this.mealTr,
    required this.mealEn,
    this.mealDe = '',
    this.mealFr = '',
    required this.kaynakKisaTr,
    required this.kaynakKisaEn,
    this.kaynakKisaDe = '',
    this.kaynakKisaFr = '',
    required this.dogrulanmisTr,
    required this.dogrulanmisEn,
    this.dogrulanmisDe = '',
    this.dogrulanmisFr = '',
    required this.tefsirTr,
    required this.tefsirEn,
    this.tefsirDe = '',
    this.tefsirFr = '',
    required this.arkaPlanRenkleri,
    required this.desenIndex,
    this.begeniSayisi = 0,
    this.begenildi = false,
    this.kaydedildi = false,
  });

  String turBasligi(String dil) {
    final tur = icerikTuru ??
        (id.startsWith('esma_')
            ? 'esma'
            : id.startsWith('dua_')
                ? 'dua'
                : (ayetMi ? 'ayet' : 'hadis'));

    if (tur == 'esma') {
      if (dil == 'DE') return 'Asma-ul Husna';
      if (dil == 'FR') return 'Asma-oul Housna';
      if (dil == 'EN') return 'Asma-ul Husna';
      if (dil == 'AR') return 'أسماء الله الحسنى';
      return 'Esmaü’l Hüsna';
    }
    if (tur == 'dua') {
      if (dil == 'DE') return 'Bittgebet (Dua)';
      if (dil == 'FR') return 'Invocation (Doua)';
      if (dil == 'EN') return 'Dua';
      if (dil == 'AR') return 'دعاء';
      return 'Dua';
    }
    if (tur == 'ayet') {
      if (dil == 'DE') return 'Vers des Tages';
      if (dil == 'FR') return 'Verset du Jour';
      if (dil == 'EN') return 'Verse of the Day';
      if (dil == 'AR') return 'آية اليوم';
      return 'Günün Ayeti';
    }
    if (dil == 'DE') return 'Prophetischer Hadith';
    if (dil == 'FR') return 'Hadith Prophétique';
    if (dil == 'EN') return 'Prophetic Hadith';
    if (dil == 'AR') return 'حديث شريف';
    return 'Hadis-i Şerif';
  }

  String konu(String dil) {
    if (dil == 'DE') return konuDe.isNotEmpty ? konuDe : konuEn;
    if (dil == 'FR') return konuFr.isNotEmpty ? konuFr : konuEn;
    return dil == 'EN' ? konuEn : konuTr;
  }

  String meal(String dil) {
    if (dil == 'DE') return mealDe.isNotEmpty ? mealDe : mealEn;
    if (dil == 'FR') return mealFr.isNotEmpty ? mealFr : mealEn;
    return dil == 'EN' ? mealEn : (dil == 'AR' ? arapcaMetin : mealTr);
  }

  String kaynakKisa(String dil) {
    if (dil == 'DE') return kaynakKisaDe.isNotEmpty ? kaynakKisaDe : kaynakKisaEn;
    if (dil == 'FR') return kaynakKisaFr.isNotEmpty ? kaynakKisaFr : kaynakKisaEn;
    return dil == 'EN' ? kaynakKisaEn : kaynakKisaTr;
  }

  String dogrulanmis(String dil) {
    if (dil == 'DE') return dogrulanmisDe.isNotEmpty ? dogrulanmisDe : dogrulanmisEn;
    if (dil == 'FR') return dogrulanmisFr.isNotEmpty ? dogrulanmisFr : dogrulanmisEn;
    return dil == 'EN' ? dogrulanmisEn : dogrulanmisTr;
  }

  String tefsir(String dil) {
    if (dil == 'DE') return tefsirDe.isNotEmpty ? tefsirDe : tefsirEn;
    if (dil == 'FR') return tefsirFr.isNotEmpty ? tefsirFr : tefsirEn;
    return dil == 'EN' ? tefsirEn : tefsirTr;
  }
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

  /// Seçilen surenin (1..114) tüm ayetlerini önce yerel çevrimdışı assets içinden yükler,
  /// internet varsa veya güncellenmesi gerekirse API'den senkronize eder.
  static Future<List<CanliAyetModel>> sureAyetleriniGetir(int sureNo) async {
    if (_sureOnbellek.containsKey(sureNo)) {
      return _sureOnbellek[sureNo]!;
    }

    // 1. ÖNCE ÇEVRİMDIŞI (İNTERNETSİZ) YEREL ASSET'LERDEN YÜKLE
    try {
      final byteData = await rootBundle.load('assets/quran/$sureNo.json');
      final assetJson = utf8.decode(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      if (assetJson.isNotEmpty) {
        final decodedList = jsonDecode(assetJson) as List<dynamic>;
        final List<CanliAyetModel> yerelAyetler = [];
        for (final item in decodedList) {
          final m = item as Map<String, dynamic>;
          final ayetNo = (m['ayetNo'] as num?)?.toInt() ?? 1;
          final hamArapca = m['arapca']?.toString() ?? '';
          yerelAyetler.add(
            CanliAyetModel(
              ayetNo: ayetNo,
              globalAyetNo: (m['globalAyetNo'] as num?)?.toInt() ?? 1,
              arapca: besmeleTemizle(hamArapca, sureNo, ayetNo),
              mealTr: m['mealTr']?.toString() ?? '',
              mealEn: m['mealEn']?.toString() ?? '',
              mealDe: m['mealDe']?.toString() ?? '',
              mealFr: m['mealFr']?.toString() ?? '',
              cuz: (m['cuz'] as num?)?.toInt() ?? 1,
              sayfa: (m['sayfa'] as num?)?.toInt() ?? 1,
            ),
          );
        }
        if (yerelAyetler.isNotEmpty) {
          _sureOnbellek[sureNo] = yerelAyetler;
          return yerelAyetler;
        }
      }
    } catch (_) {}

    // 2. Cihaz hafızasındaki (localStorage) önbelleği kontrol et
    try {
      final kayitliRaw = web.window.localStorage.getItem('nur_huzur_sure_cache_v2_$sureNo');
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

    // 3. Çevrimiçi API üzerinden çek (Arapça + Türkçe Diyanet + İngilizce Sahih + Almanca Bubenheim + Fransızca Hamidullah)
    final url = Uri.parse(
      'https://api.alquran.cloud/v1/surah/$sureNo/editions/quran-uthmani,tr.diyanet,en.sahih,de.bubenheim,fr.hamidullah',
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
          final deAyahs = dataList.length > 3
              ? ((dataList[3] as Map<String, dynamic>)['ayahs'] as List<dynamic>)
              : enAyahs;
          final frAyahs = dataList.length > 4
              ? ((dataList[4] as Map<String, dynamic>)['ayahs'] as List<dynamic>)
              : enAyahs;

          final List<CanliAyetModel> sonuc = [];
          for (int i = 0; i < arAyahs.length; i++) {
            final ar = arAyahs[i] as Map<String, dynamic>;
            final tr = i < trAyahs.length ? trAyahs[i] as Map<String, dynamic> : ar;
            final en = i < enAyahs.length ? enAyahs[i] as Map<String, dynamic> : ar;
            final de = i < deAyahs.length ? deAyahs[i] as Map<String, dynamic> : en;
            final fr = i < frAyahs.length ? frAyahs[i] as Map<String, dynamic> : en;
            final ayetNo = (ar['numberInSurah'] as num).toInt();
            final hamArapca = (ar['text'] as String).trim();

            sonuc.add(
              CanliAyetModel(
                ayetNo: ayetNo,
                globalAyetNo: (ar['number'] as num).toInt(),
                arapca: besmeleTemizle(hamArapca, sureNo, ayetNo),
                mealTr: (tr['text'] as String).trim(),
                mealEn: (en['text'] as String).trim(),
                mealDe: (de['text'] as String).trim(),
                mealFr: (fr['text'] as String).trim(),
                cuz: (ar['juz'] as num?)?.toInt() ?? 1,
                sayfa: (ar['page'] as num?)?.toInt() ?? 1,
              ),
            );
          }

          _sureOnbellek[sureNo] = sonuc;
          try {
            web.window.localStorage.setItem(
              'nur_huzur_sure_cache_v2_$sureNo',
              jsonEncode(sonuc.map((a) => a.toJson()).toList()),
            );
          } catch (_) {}
          return sonuc;
        }
      }
    } catch (_) {}

    return _yedekSureAyetleri(sureNo);
  }

  /// 6236 Kur'an ayeti içinden globalAyetNo (1..6236) ile canlı Reels kartı oluşturur (Başlangıç beğenisi: 0)
  static Future<DinamikReelsKart?> canliAyetReelsKartiGetir(int globalAyetNo, int siraIndex) async {
    final gecerliNo = ((globalAyetNo - 1) % 6236) + 1;
    final url = Uri.parse(
      'https://api.alquran.cloud/v1/ayah/$gecerliNo/editions/quran-uthmani,tr.diyanet,en.sahih,de.bubenheim,fr.hamidullah',
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
          final de = dataList.length > 3 ? dataList[3] as Map<String, dynamic> : en;
          final fr = dataList.length > 4 ? dataList[4] as Map<String, dynamic> : en;

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
            konuDe: 'Sure ${sureMeta.adEn} • Dschuz $cuzNo',
            konuFr: 'Sourate ${sureMeta.adEn} • Juz $cuzNo',
            mealTr: '“${(tr['text'] as String).trim()}”',
            mealEn: '“${(en['text'] as String).trim()}”',
            mealDe: '„${(de['text'] as String).trim()}“',
            mealFr: '« ${(fr['text'] as String).trim()} »',
            kaynakKisaTr: '${sureMeta.adTr} Suresi, $ayetNo. Ayet',
            kaynakKisaEn: 'Surah ${sureMeta.adEn}, Verse $ayetNo',
            kaynakKisaDe: 'Sure ${sureMeta.adEn}, Vers $ayetNo',
            kaynakKisaFr: 'Sourate ${sureMeta.adEn}, Verset $ayetNo',
            dogrulanmisTr:
                'Doğrulanmış Kaynak: T.C. Diyanet İşleri Başkanlığı Kur’an-ı Kerim Meali • ${sureMeta.adTr} $sureNo/$ayetNo (Sayfa: $sayfaNo)',
            dogrulanmisEn:
                'Verified Source: Presidency of Religious Affairs & Sahih Int. • ${sureMeta.adEn} $sureNo:$ayetNo (Page: $sayfaNo)',
            dogrulanmisDe:
                'Verifizierte Quelle: Bubenheim & Elyas Koranübersetzung • Sure ${sureMeta.adEn} $sureNo:$ayetNo (Seite: $sayfaNo)',
            dogrulanmisFr:
                'Source vérifiée : Traduction du Coran par Muhammad Hamidullah • Sourate ${sureMeta.adEn} $sureNo:$ayetNo (Page : $sayfaNo)',
            tefsirTr:
                '${sureMeta.yer} olan ${sureMeta.adTr} Suresi’nin $ayetNo. ayet-i kerimesidir ($cuzNo. Cüz, $sayfaNo. Sayfa).',
            tefsirEn:
                'Verse $ayetNo of Surah ${sureMeta.adEn} (${sureMeta.yer}, Juz $cuzNo, Page $sayfaNo).',
            tefsirDe:
                'Vers $ayetNo der Sure ${sureMeta.adEn} (Dschuz $cuzNo, Seite $sayfaNo).',
            tefsirFr:
                'Verset $ayetNo de la Sourate ${sureMeta.adEn} (Juz $cuzNo, Page $sayfaNo).',
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
    final idx = hadisIndex % kSahihHadisHavuzu.length;
    final h = kSahihHadisHavuzu[idx];
    final paletIdx = siraIndex % kReelsArkaPlanPaletleri.length;

    return DinamikReelsKart(
      id: 'hadith_${hadisIndex}_$siraIndex',
      ayetMi: false,
      arapcaMetin: h['arapca']!,
      konuTr: h['konuTr']!,
      konuEn: h['konuEn']!,
      konuDe: hadisKonuGetir(idx, 'DE'),
      konuFr: hadisKonuGetir(idx, 'FR'),
      mealTr: h['mealTr']!,
      mealEn: h['mealEn']!,
      mealDe: hadisMealGetir(idx, 'DE'),
      mealFr: hadisMealGetir(idx, 'FR'),
      kaynakKisaTr: h['kaynakKisa']!,
      kaynakKisaEn: h['kaynakKisa']!,
      kaynakKisaDe: h['kaynakKisa']!,
      kaynakKisaFr: h['kaynakKisa']!,
      dogrulanmisTr: h['dogrulanmis']!,
      dogrulanmisEn: hadisDogrulanmisGetir(idx, 'EN'),
      dogrulanmisDe: hadisDogrulanmisGetir(idx, 'DE'),
      dogrulanmisFr: hadisDogrulanmisGetir(idx, 'FR'),
      tefsirTr: h['tefsirTr']!,
      tefsirEn: h['tefsirEn']!,
      tefsirDe: hadisTefsirGetir(idx, 'DE'),
      tefsirFr: hadisTefsirGetir(idx, 'FR'),
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
          mealDe: 'Im Namen Allahs, des Allerbarmers, des Barmherzigen.',
          mealFr: 'Au nom d’Allah, le Tout Miséricordieux, le Très Miséricordieux.',
          cuz: 1,
          sayfa: 1,
        ),
        CanliAyetModel(
          ayetNo: 2,
          globalAyetNo: 2,
          arapca: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          mealTr: 'Hamd, âlemlerin Rabbi olan Allah’a mahsustur.',
          mealEn: 'All praise is due to Allah, Lord of the worlds.',
          mealDe: 'Alles Lob gebührt Allah, dem Herrn der Welten.',
          mealFr: 'Louange à Allah, Seigneur de l’univers.',
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
        mealDe: 'Sure ${meta.adEn} (${meta.ayetSayisi} Verse)',
        mealFr: 'Sourate ${meta.adEn} (${meta.ayetSayisi} Versets)',
        cuz: 1,
        sayfa: 1,
      ),
    ];
  }
}
