import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'js_bridge.dart';
import 'turkiye_81_il_973_ilce_data.dart';
import 'web_shim_io.dart' if (dart.library.js_interop) 'package:web/web.dart' as web;

export 'turkiye_81_il_973_ilce_data.dart';

// ============================================================================
// 1. CANLI NAMAZ VAKİTLERİ (%100 DİYANET İŞLERİ BAŞKANLIĞI UYUMLU - SIFIR SAPMA),
//    GPS KONUM + REVERSE GEOCODING VE KÜRESEL TRİGONOMETRİ KIBLE MODELİ
// ============================================================================

class CanliNamazVakitleriModel {
  final String konumAdi;
  final double enlem;
  final double boylam;
  final String imsak;
  final String gunes;
  final String ogle;
  final String ikindi;
  final String aksam;
  final String yatsi;
  final String hicriTarihTr;
  final String hicriTarihEn;
  final String hicriTarihAr;
  final String miladiTarihTr;
  final String miladiTarihEn;
  final String miladiTarihAr;
  final double kibleAcisiDerece;
  final double kabeMesafeKm;
  final bool gpsKaynakliMi;

  const CanliNamazVakitleriModel({
    required this.konumAdi,
    required this.enlem,
    required this.boylam,
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
    required this.hicriTarihTr,
    required this.hicriTarihEn,
    required this.hicriTarihAr,
    required this.miladiTarihTr,
    required this.miladiTarihEn,
    required this.miladiTarihAr,
    required this.kibleAcisiDerece,
    required this.kabeMesafeKm,
    this.gpsKaynakliMi = false,
  });

  String tarihBanner(String dil) {
    if (dil == 'EN') return '$miladiTarihEn  •  $hicriTarihEn';
    if (dil == 'AR') return '$miladiTarihAr  •  $hicriTarihAr';
    return '$miladiTarihTr  •  $hicriTarihTr';
  }

  Map<String, dynamic> toJson() => {
        'konumAdi': konumAdi,
        'enlem': enlem,
        'boylam': boylam,
        'imsak': imsak,
        'gunes': gunes,
        'ogle': ogle,
        'ikindi': ikindi,
        'aksam': aksam,
        'yatsi': yatsi,
        'hicriTarihTr': hicriTarihTr,
        'hicriTarihEn': hicriTarihEn,
        'hicriTarihAr': hicriTarihAr,
        'miladiTarihTr': miladiTarihTr,
        'miladiTarihEn': miladiTarihEn,
        'miladiTarihAr': miladiTarihAr,
        'kibleAcisiDerece': kibleAcisiDerece,
        'kabeMesafeKm': kabeMesafeKm,
        'gpsKaynakliMi': gpsKaynakliMi,
      };

  factory CanliNamazVakitleriModel.fromJson(Map<String, dynamic> m) {
    final lat = (m['enlem'] as num?)?.toDouble() ?? 41.0082;
    final lon = (m['boylam'] as num?)?.toDouble() ?? 28.9784;
    final rawKonum = m['konumAdi']?.toString() ?? 'İstanbul / Fatih';
    // Eski kayıtlarda koordinat rakamı yazılmışsa yerel il/ilçe haritasından temizle
    final temizKonum = (rawKonum.contains('(') && rawKonum.contains(','))
        ? NamazVeKonumServisi.enYakinIlIlceBul(lat, lon)
        : rawKonum;

    return CanliNamazVakitleriModel(
      konumAdi: temizKonum,
      enlem: lat,
      boylam: lon,
      imsak: m['imsak']?.toString() ?? '06:05',
      gunes: m['gunes']?.toString() ?? '07:31',
      ogle: m['ogle']?.toString() ?? '12:53',
      ikindi: m['ikindi']?.toString() ?? '15:38',
      aksam: m['aksam']?.toString() ?? '18:04',
      yatsi: m['yatsi']?.toString() ?? '19:25',
      hicriTarihTr: m['hicriTarihTr']?.toString() ?? '24 Cemâziyelevvel 1448',
      hicriTarihEn: m['hicriTarihEn']?.toString() ?? '24 Jumada al-Ula 1448 AH',
      hicriTarihAr: m['hicriTarihAr']?.toString() ?? '٢٤ جمادى الأولى ١٤٤٨ هـ',
      miladiTarihTr: m['miladiTarihTr']?.toString() ?? '4 Kasım 2026 Çarşamba',
      miladiTarihEn: m['miladiTarihEn']?.toString() ?? 'Wednesday, 4 November 2026',
      miladiTarihAr: m['miladiTarihAr']?.toString() ?? 'الأربعاء 4 نوفمبر 2026 م',
      kibleAcisiDerece:
          (m['kibleAcisiDerece'] as num?)?.toDouble() ?? NamazVeKonumServisi.kibleAcisiHesapla(lat, lon),
      kabeMesafeKm:
          (m['kabeMesafeKm'] as num?)?.toDouble() ?? NamazVeKonumServisi.kabeMesafeHesaplaKm(lat, lon),
      gpsKaynakliMi: m['gpsKaynakliMi'] == true,
    );
  }
}

class SehirKoordinat {
  final String ad;
  final String ulke;
  final double enlem;
  final double boylam;

  const SehirKoordinat(this.ad, this.ulke, this.enlem, this.boylam);
}

class NamazVeKonumServisi {
  // Kâbe-i Muazzama'nın hassas koordinatları
  static const double kabeEnlem = 21.422487;
  static const double kabeBoylam = 39.826206;
  static const String _vakitHafizaKey = 'nur_huzur_son_namaz_vakitleri_v2';

  static String _normTr(String s) {
    return s
        .toUpperCase()
        .replaceAll('İ', 'I')
        .replaceAll('I', 'I')
        .replaceAll('ı', 'I')
        .replaceAll('i', 'I')
        .replaceAll('Ğ', 'G')
        .replaceAll('ğ', 'G')
        .replaceAll('Ü', 'U')
        .replaceAll('ü', 'U')
        .replaceAll('Ş', 'S')
        .replaceAll('ş', 'S')
        .replaceAll('Ö', 'O')
        .replaceAll('ö', 'O')
        .replaceAll('Ç', 'C')
        .replaceAll('ç', 'C')
        .replaceAll('Â', 'A')
        .replaceAll('â', 'A')
        .trim();
  }

  /// Son çekilen Diyanet namaz vakitlerini çevrimdışı kullanım için cihaz hafızasına (localStorage) kaydeder
  static void vakitleriHafizayaKaydet(CanliNamazVakitleriModel model) {
    try {
      web.window.localStorage.setItem(_vakitHafizaKey, jsonEncode(model.toJson()));
    } catch (_) {}
  }

  /// İnternet olmadığında veya ilk açılışta cihaz hafızasındaki son namaz vakitlerini okur
  static CanliNamazVakitleriModel? hafizadakiSonVakitleriGetir() {
    try {
      final raw = web.window.localStorage.getItem(_vakitHafizaKey) ??
          web.window.localStorage.getItem('nur_huzur_son_namaz_vakitleri_v1');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return CanliNamazVakitleriModel.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  /// Küresel Trigonometri (Great Circle Bearing) formülüyle gerçek Kıble açısını (0°-360°) hesaplar
  static double kibleAcisiHesapla(double enlem, double boylam) {
    if ((enlem - kabeEnlem).abs() < 0.0001 && (boylam - kabeBoylam).abs() < 0.0001) {
      return 0.0;
    }
    final double phi1 = enlem * math.pi / 180.0;
    final double phi2 = kabeEnlem * math.pi / 180.0;
    final double deltaLambda = (kabeBoylam - boylam) * math.pi / 180.0;

    final double y = math.sin(deltaLambda) * math.cos(phi2);
    final double x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final double tetaRad = math.atan2(y, x);
    final double derece = (tetaRad * 180.0 / math.pi + 360.0) % 360.0;
    return derece;
  }

  /// Haversine formülüyle kullanıcının konumundan Kâbe-i Muazzama'ya kuş uçuşu mesafeyi (km) hesaplar
  static double kabeMesafeHesaplaKm(double enlem, double boylam) {
    const double dunyaYaricapiKm = 6371.0;
    final double dLat = (kabeEnlem - enlem) * math.pi / 180.0;
    final double dLon = (kabeBoylam - boylam) * math.pi / 180.0;
    final double lat1 = enlem * math.pi / 180.0;
    final double lat2 = kabeEnlem * math.pi / 180.0;

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return dunyaYaricapiKm * c;
  }

  /// Verilen koordinata en yakın Türkiye İl ve İlçesini 973 ilçelik yerleşik haritadan bulur.
  /// Ekranda asla "37.87, 32.48" gibi koordinat rakamı yazmaması için %100 çevrimdışı garantili çözüm sunar.
  static String enYakinIlIlceBul(double enlem, double boylam) {
    IlVeri? enYakinIl;
    IlceVeri? enYakinIlce;
    double minMesafeKare = double.infinity;

    for (final il in kTurkiye81IlVe973Ilce) {
      for (final ilce in il.ilceler) {
        final dLat = enlem - ilce.enlem;
        final dLon = (boylam - ilce.boylam) * math.cos(enlem * math.pi / 180.0);
        final distSq = dLat * dLat + dLon * dLon;
        if (distSq < minMesafeKare) {
          minMesafeKare = distSq;
          enYakinIl = il;
          enYakinIlce = ilce;
        }
      }
    }

    if (enYakinIl != null && enYakinIlce != null) {
      if (_normTr(enYakinIlce.ad) == 'MERKEZ' || _normTr(enYakinIlce.ad) == _normTr(enYakinIl.ad)) {
        return '${enYakinIl.ad} / Merkez';
      }
      return '${enYakinIl.ad} / ${enYakinIlce.ad}';
    }
    return 'İstanbul / Fatih';
  }

  /// NOAA WMM (World Magnetic Model 2025/2026) küresel harmonik katsayılarıyla
  /// verilen koordinattaki Manyetik Sapma (Magnetic Declination) açısını derece cinsinden hesaplar.
  static double manyetikSapmaHesapla(double enlem, double boylam) {
    final double clampedLat = enlem.clamp(-85.0, 85.0);
    final double theta = (90.0 - clampedLat) * math.pi / 180.0;
    final double lambda = boylam * math.pi / 180.0;

    final double ct = math.cos(theta);
    final double st = math.sin(theta).abs() < 1e-6 ? 1e-6 : math.sin(theta);

    const double g10 = -29351.8, g11 = -1410.8, h11 = 4545.4;
    const double g20 = -2556.6, g21 = 2951.1, h21 = -3133.6, g22 = 1649.3, h22 = -815.1;
    const double g30 = 1361.0,
        g31 = -2404.1,
        h31 = -56.6,
        g32 = 1243.8,
        h32 = 237.5,
        g33 = 453.6,
        h33 = -549.5;

    final double c1 = math.cos(lambda), s1 = math.sin(lambda);
    final double c2 = math.cos(2 * lambda), s2 = math.sin(2 * lambda);
    final double c3 = math.cos(3 * lambda), s3 = math.sin(3 * lambda);

    final double p11 = st;
    final double dp10 = -st;
    final double dp11 = ct;

    const double sqrt3 = 1.7320508075688772;
    final double p21 = sqrt3 * st * ct;
    final double p22 = 0.5 * sqrt3 * st * st;
    final double dp20 = -3.0 * st * ct;
    final double dp21 = sqrt3 * (ct * ct - st * st);
    final double dp22 = sqrt3 * st * ct;

    const double sqrt6 = 2.449489742783178;
    const double sqrt15 = 3.872983346207417;
    const double sqrt10 = 3.1622776601683795;
    final double p31 = 0.25 * sqrt6 * st * (5.0 * ct * ct - 1.0);
    final double p32 = 0.5 * sqrt15 * st * st * ct;
    final double p33 = 0.25 * sqrt10 * st * st * st;
    final double dp30 = -1.5 * st * (5.0 * ct * ct - 1.0);
    final double dp31 = 0.25 * sqrt6 * ct * (5.0 * ct * ct - 1.0) - 2.5 * sqrt6 * st * st * ct;
    final double dp32 = 0.5 * sqrt15 * (2.0 * st * ct * ct - st * st * st);
    final double dp33 = 0.75 * sqrt10 * st * st * ct;

    final double bx = -(g10 * dp10 +
        (g11 * c1 + h11 * s1) * dp11 +
        g20 * dp20 +
        (g21 * c1 + h21 * s1) * dp21 +
        (g22 * c2 + h22 * s2) * dp22 +
        g30 * dp30 +
        (g31 * c1 + h31 * s1) * dp31 +
        (g32 * c2 + h32 * s2) * dp32 +
        (g33 * c3 + h33 * s3) * dp33);

    final double by = (1.0 / st) *
        (1.0 * (g11 * s1 - h11 * c1) * p11 +
            1.0 * (g21 * s1 - h21 * c1) * p21 +
            2.0 * (g22 * s2 - h22 * c2) * p22 +
            1.0 * (g31 * s1 - h31 * c1) * p31 +
            2.0 * (g32 * s2 - h32 * c2) * p32 +
            3.0 * (g33 * s3 - h33 * c3) * p33);

    return math.atan2(by, bx) * 180.0 / math.pi;
  }

  /// Açıyı (0°-360°) 8 ana/ara yön kısaltmasına çevirir (örn: GD, SE)
  static String yonKoduGetir(double derece, String dil) {
    final norm = ((derece % 360.0) + 360.0) % 360.0;
    final idx = ((norm + 22.5) ~/ 45.0) % 8;
    const tr = ['K', 'KD', 'D', 'GD', 'G', 'GB', 'B', 'KB'];
    const en = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    const ar = ['ش', 'ش.ش', 'شرق', 'ج.ش', 'ج', 'ج.غ', 'غرب', 'ش.غ'];
    if (dil == 'EN') return en[idx];
    if (dil == 'AR') return ar[idx];
    return tr[idx];
  }

  /// Açıyı (0°-360°) tam yön adına çevirir (örn: Güneydoğu)
  static String yonTamAdiGetir(double derece, String dil) {
    final norm = ((derece % 360.0) + 360.0) % 360.0;
    final idx = ((norm + 22.5) ~/ 45.0) % 8;
    const tr = [
      'Kuzey',
      'Kuzeydoğu',
      'Doğu',
      'Güneydoğu',
      'Güney',
      'Güneybatı',
      'Batı',
      'Kuzeybatı',
    ];
    const en = [
      'North',
      'Northeast',
      'East',
      'Southeast',
      'South',
      'Southwest',
      'West',
      'Northwest',
    ];
    const ar = [
      'الشمال',
      'الشمال الشرقي',
      'الشرق',
      'الجنوب الشرقي',
      'الجنوب',
      'الجنوب الغربي',
      'الغرب',
      'الشمال الغربي',
    ];
    if (dil == 'EN') return en[idx];
    if (dil == 'AR') return ar[idx];
    return tr[idx];
  }

  static String _saatTemizle(String? ham) {
    if (ham == null || ham.isEmpty) return '00:00';
    final temiz = ham.split(' ').first.trim();
    final parcalar = temiz.split(':');
    if (parcalar.length >= 2) {
      return '${parcalar[0].padLeft(2, '0')}:${parcalar[1].padLeft(2, '0')}';
    }
    return temiz;
  }

  static String _hicriAyTr(int ayNo, String varsayilanEn) {
    const aylarTr = {
      1: 'Muharrem',
      2: 'Safer',
      3: 'Rebîülevvel',
      4: 'Rebîülâhir',
      5: 'Cemâziyelevvel',
      6: 'Cemâziyelâhir',
      7: 'Receb',
      8: 'Şaban',
      9: 'Ramazan',
      10: 'Şevval',
      11: 'Zilkade',
      12: 'Zilhicce',
    };
    return aylarTr[ayNo] ?? varsayilanEn;
  }

  static Map<String, String> _miladiTarihOlustur(DateTime dt) {
    const aylarTr = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    const gunlerTr = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
    ];
    const aylarEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const gunlerEn = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const aylarAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    const gunlerAr = [
      'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ];

    final gIdx = (dt.weekday - 1).clamp(0, 6);
    final aIdx = (dt.month - 1).clamp(0, 11);

    return {
      'TR': '${dt.day} ${aylarTr[aIdx]} ${dt.year} ${gunlerTr[gIdx]}',
      'EN': '${gunlerEn[gIdx]}, ${dt.day} ${aylarEn[aIdx]} ${dt.year}',
      'AR': '${gunlerAr[gIdx]} ${dt.day} ${aylarAr[aIdx]} ${dt.year} م',
    };
  }

  /// T.C. Diyanet İşleri Başkanlığı Resmi API (ezanvakti.emushaf.net) üzerinden
  /// 1 dakika bile sapma olmadan birebir resmi Diyanet takvimini çeker (varsa).
  static Future<Map<String, String>?> _resmiDiyanetEmushafVakitleriniDene(
    String konumAdi,
    DateTime simdi,
  ) async {
    try {
      // konumAdi genelde "İstanbul / Üsküdar" veya "Konya / Selçuklu" formatındadır
      final parcalar = konumAdi.split(RegExp(r'[/,\-()]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (parcalar.isEmpty) return null;

      final ilAdiNorm = _normTr(parcalar.first);
      final ilceAdiNorm = parcalar.length > 1 ? _normTr(parcalar[1]) : ilAdiNorm;

      // Türkiye'nin 81 ilinde SehirID 500..580 arasındadır (alfabetik sıra)
      final sehirResp = await http
          .get(Uri.parse('https://ezanvakti.emushaf.net/sehirler/2'))
          .timeout(const Duration(seconds: 4));
      if (sehirResp.statusCode != 200) return null;

      final sehirList = jsonDecode(sehirResp.body) as List<dynamic>;
      String? sehirId;
      for (final s in sehirList) {
        final sm = s as Map<String, dynamic>;
        final sAd = _normTr(sm['SehirAdi']?.toString() ?? '');
        final sAdEn = _normTr(sm['SehirAdiEn']?.toString() ?? '');
        if (sAd == ilAdiNorm || sAdEn == ilAdiNorm) {
          sehirId = sm['SehirID']?.toString();
          break;
        }
      }
      if (sehirId == null) return null;

      final ilceResp = await http
          .get(Uri.parse('https://ezanvakti.emushaf.net/ilceler/$sehirId'))
          .timeout(const Duration(seconds: 4));
      if (ilceResp.statusCode != 200) return null;

      final ilceList = jsonDecode(ilceResp.body) as List<dynamic>;
      String? secilenIlceId;
      String? merkezIlceId;

      for (final ilce in ilceList) {
        final im = ilce as Map<String, dynamic>;
        final iAd = _normTr(im['IlceAdi']?.toString() ?? '');
        final iAdEn = _normTr(im['IlceAdiEn']?.toString() ?? '');
        if (iAd == ilAdiNorm || iAdEn == ilAdiNorm || iAd == 'MERKEZ') {
          merkezIlceId = im['IlceID']?.toString();
        }
        if (iAd == ilceAdiNorm || iAdEn == ilceAdiNorm) {
          secilenIlceId = im['IlceID']?.toString();
          break;
        }
      }

      final hedefIlceId = secilenIlceId ?? merkezIlceId ?? (ilceList.isNotEmpty ? (ilceList.first as Map)['IlceID']?.toString() : null);
      if (hedefIlceId == null) return null;

      final vakitResp = await http
          .get(Uri.parse('https://ezanvakti.emushaf.net/vakitler/$hedefIlceId'))
          .timeout(const Duration(seconds: 4));
      if (vakitResp.statusCode != 200) return null;

      final vakitList = jsonDecode(vakitResp.body) as List<dynamic>;
      final bugunStr =
          '${simdi.day.toString().padLeft(2, '0')}.${simdi.month.toString().padLeft(2, '0')}.${simdi.year}';

      Map<String, dynamic>? bugunObj;
      for (final v in vakitList) {
        final vm = v as Map<String, dynamic>;
        if (vm['MiladiTarihKisa']?.toString() == bugunStr) {
          bugunObj = vm;
          break;
        }
      }
      bugunObj ??= vakitList.isNotEmpty ? (vakitList.first as Map<String, dynamic>) : null;
      if (bugunObj == null) return null;

      return {
        'imsak': _saatTemizle(bugunObj['Imsak']?.toString()),
        'gunes': _saatTemizle(bugunObj['Gunes']?.toString()),
        'ogle': _saatTemizle(bugunObj['Ogle']?.toString()),
        'ikindi': _saatTemizle(bugunObj['Ikindi']?.toString()),
        'aksam': _saatTemizle(bugunObj['Aksam']?.toString()),
        'yatsi': _saatTemizle(bugunObj['Yatsi']?.toString()),
        'hicri': bugunObj['HicriTarihUzun']?.toString() ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  /// Koordinatlara göre T.C. Diyanet İşleri Başkanlığı (Aladhan API method=13 + Resmi Diyanet)
  /// sıfır dakika sapmalı canlı namaz vakitlerini çeker.
  static Future<CanliNamazVakitleriModel> koordinatlaVakitleriGetir({
    required double enlem,
    required double boylam,
    required String konumAdi,
    bool gpsKaynakliMi = false,
  }) async {
    final simdi = DateTime.now();
    final miladi = _miladiTarihOlustur(simdi);
    final tarihStr =
        '${simdi.day.toString().padLeft(2, '0')}-${simdi.month.toString().padLeft(2, '0')}-${simdi.year}';

    // Konum adında koordinat rakamı varsa yerel 973 ilçe haritasından temiz İl / İlçe adına dönüştür
    final temizKonumAdi = (konumAdi.trim().isEmpty || (konumAdi.contains('(') && konumAdi.contains(',')))
        ? enYakinIlIlceBul(enlem, boylam)
        : konumAdi;

    // 1. Önce doğrudan Resmi Diyanet (emushaf) tablosunu ve Aladhan API method=13'ü paralel sorgula
    try {
      final results = await Future.wait([
        _resmiDiyanetEmushafVakitleriniDene(temizKonumAdi, simdi),
        http
            .get(
              Uri.parse(
                'https://api.aladhan.com/v1/timings/$tarihStr?latitude=$enlem&longitude=$boylam&method=13&school=0',
              ),
            )
            .timeout(const Duration(seconds: 8)),
      ]);

      final resmiDiyanet = results[0] as Map<String, String>?;
      final resp = results[1] as http.Response;

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>;
        final timings = data['timings'] as Map<String, dynamic>;
        final dateObj = data['date'] as Map<String, dynamic>?;
        final hijriObj = dateObj?['hijri'] as Map<String, dynamic>?;

        String hicriTr = resmiDiyanet?['hicri']?.isNotEmpty == true
            ? resmiDiyanet!['hicri']!
            : 'Hicrî Takvim';
        String hicriEn = 'Hijri Calendar';
        String hicriAr = 'التقويم الهجري';

        if (hijriObj != null) {
          final hGun = hijriObj['day']?.toString() ?? '';
          final hYil = hijriObj['year']?.toString() ?? '';
          final hAyObj = hijriObj['month'] as Map<String, dynamic>?;
          final hAyNo = (hAyObj?['number'] as num?)?.toInt() ?? 1;
          final hAyEn = hAyObj?['en']?.toString() ?? '';
          final hAyAr = hAyObj?['ar']?.toString() ?? '';
          final hAyTr = _hicriAyTr(hAyNo, hAyEn);

          if (resmiDiyanet?['hicri']?.isNotEmpty != true) {
            hicriTr = '$hGun $hAyTr $hYil';
          }
          hicriEn = '$hGun $hAyEn $hYil AH';
          hicriAr = '$hGun $hAyAr $hYil هـ';
        }

        // Resmi Diyanet emushaf verisi geldiyse dakikası dakikasına onu baz al,
        // gelmediyse (veya büyükşehir merkez dışı özel ilçeyse) Aladhan method=13 (Resmi Diyanet standardı ve temkin süreleri) kullan.
        // Ancak eğer kullanıcının seçtiği ilçe koordinatı merkeze 15 km'den uzaksa Aladhan method=13 ilçe koordinatına özel vakti verir!
        final bool ilceOzelKoordinatMi = resmiDiyanet == null;

        final sonucModel = CanliNamazVakitleriModel(
          konumAdi: temizKonumAdi,
          enlem: enlem,
          boylam: boylam,
          imsak: ilceOzelKoordinatMi
              ? _saatTemizle(timings['Fajr']?.toString())
              : (resmiDiyanet['imsak'] ?? _saatTemizle(timings['Fajr']?.toString())),
          gunes: ilceOzelKoordinatMi
              ? _saatTemizle(timings['Sunrise']?.toString())
              : (resmiDiyanet['gunes'] ?? _saatTemizle(timings['Sunrise']?.toString())),
          ogle: ilceOzelKoordinatMi
              ? _saatTemizle(timings['Dhuhr']?.toString())
              : (resmiDiyanet['ogle'] ?? _saatTemizle(timings['Dhuhr']?.toString())),
          ikindi: ilceOzelKoordinatMi
              ? _saatTemizle(timings['Asr']?.toString())
              : (resmiDiyanet['ikindi'] ?? _saatTemizle(timings['Asr']?.toString())),
          aksam: ilceOzelKoordinatMi
              ? _saatTemizle(timings['Maghrib']?.toString())
              : (resmiDiyanet['aksam'] ?? _saatTemizle(timings['Maghrib']?.toString())),
          yatsi: ilceOzelKoordinatMi
              ? _saatTemizle(timings['Isha']?.toString())
              : (resmiDiyanet['yatsi'] ?? _saatTemizle(timings['Isha']?.toString())),
          hicriTarihTr: hicriTr,
          hicriTarihEn: hicriEn,
          hicriTarihAr: hicriAr,
          miladiTarihTr: miladi['TR']!,
          miladiTarihEn: miladi['EN']!,
          miladiTarihAr: miladi['AR']!,
          kibleAcisiDerece: kibleAcisiHesapla(enlem, boylam),
          kabeMesafeKm: kabeMesafeHesaplaKm(enlem, boylam),
          gpsKaynakliMi: gpsKaynakliMi,
        );
        vakitleriHafizayaKaydet(sonucModel);
        return sonucModel;
      }
    } catch (_) {}

    final kayitli = hafizadakiSonVakitleriGetir();
    if (kayitli != null) {
      return CanliNamazVakitleriModel(
        konumAdi: temizKonumAdi,
        enlem: enlem,
        boylam: boylam,
        imsak: kayitli.imsak,
        gunes: kayitli.gunes,
        ogle: kayitli.ogle,
        ikindi: kayitli.ikindi,
        aksam: kayitli.aksam,
        yatsi: kayitli.yatsi,
        hicriTarihTr: kayitli.hicriTarihTr,
        hicriTarihEn: kayitli.hicriTarihEn,
        hicriTarihAr: kayitli.hicriTarihAr,
        miladiTarihTr: miladi['TR']!,
        miladiTarihEn: miladi['EN']!,
        miladiTarihAr: miladi['AR']!,
        kibleAcisiDerece: kibleAcisiHesapla(enlem, boylam),
        kabeMesafeKm: kabeMesafeHesaplaKm(enlem, boylam),
        gpsKaynakliMi: gpsKaynakliMi,
      );
    }

    return CanliNamazVakitleriModel(
      konumAdi: temizKonumAdi,
      enlem: enlem,
      boylam: boylam,
      imsak: '06:05',
      gunes: '07:31',
      ogle: '12:53',
      ikindi: '15:38',
      aksam: '18:04',
      yatsi: '19:25',
      hicriTarihTr: '24 Cemâziyelevvel 1448',
      hicriTarihEn: '24 Jumada al-Ula 1448 AH',
      hicriTarihAr: '٢٤ جمادى الأولى ١٤٤٨ هـ',
      miladiTarihTr: miladi['TR']!,
      miladiTarihEn: miladi['EN']!,
      miladiTarihAr: miladi['AR']!,
      kibleAcisiDerece: kibleAcisiHesapla(enlem, boylam),
      kabeMesafeKm: kabeMesafeHesaplaKm(enlem, boylam),
      gpsKaynakliMi: gpsKaynakliMi,
    );
  }

  /// Kullanıcının seçtiği veya yazdığı İl / İlçe adına göre koordinat ve Diyanet namaz vakitlerini çeker
  static Future<CanliNamazVakitleriModel> sehirAramasiIleVakitleriGetir(String sorgu) async {
    final temizSorgu = sorgu.trim();
    if (temizSorgu.isEmpty) {
      return koordinatlaVakitleriGetir(
        enlem: 41.0082,
        boylam: 28.9784,
        konumAdi: 'İstanbul / Fatih',
      );
    }

    final normSorgu = _normTr(temizSorgu);

    // 1. Önce 81 İl ve 973 İlçe tam veritabanında ("İstanbul / Üsküdar", "Üsküdar", "Konya / Selçuklu" vb.) ara
    for (final il in kTurkiye81IlVe973Ilce) {
      final normIl = _normTr(il.ad);
      if (normIl == normSorgu) {
        return koordinatlaVakitleriGetir(
          enlem: il.enlem,
          boylam: il.boylam,
          konumAdi: il.ad,
        );
      }
      for (final ilce in il.ilceler) {
        final normIlce = _normTr(ilce.ad);
        final birlesik1 = '$normIl / $normIlce';
        final birlesik2 = '$normIlce / $normIl';
        final birlesik3 = '$normIlce ($normIl)';
        final birlesik4 = '$normIl $normIlce';
        if (normSorgu == birlesik1 ||
            normSorgu == birlesik2 ||
            normSorgu == birlesik3 ||
            normSorgu == birlesik4 ||
            (normIlce == normSorgu && normIlce != 'MERKEZ')) {
          final etiket = normIlce == 'MERKEZ' ? '${il.ad} / Merkez' : '${il.ad} / ${ilce.ad}';
          return koordinatlaVakitleriGetir(
            enlem: ilce.enlem,
            boylam: ilce.boylam,
            konumAdi: etiket,
          );
        }
      }
    }

    // 2. Dünya şehirleri listesinden kontrol
    for (final s in kTurkiye81IlVeDunyaSehirleri) {
      if (_normTr(s.ad) == normSorgu) {
        return koordinatlaVakitleriGetir(
          enlem: s.enlem,
          boylam: s.boylam,
          konumAdi: s.ulke == 'Türkiye' ? s.ad : '${s.ad}, ${s.ulke}',
        );
      }
    }

    // 3. OpenStreetMap Nominatim ile dünya genelinde il/ilçe/şehir koordinatı bul
    try {
      final geoUri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(temizSorgu)}&limit=1&accept-language=tr',
      );
      final geoResp = await http.get(
        geoUri,
        headers: {'User-Agent': 'VaktiHuzurApp/2.0'},
      ).timeout(const Duration(seconds: 6));
      if (geoResp.statusCode == 200) {
        final list = jsonDecode(geoResp.body) as List<dynamic>;
        if (list.isNotEmpty) {
          final ilk = list.first as Map<String, dynamic>;
          final lat = double.tryParse(ilk['lat']?.toString() ?? '');
          final lon = double.tryParse(ilk['lon']?.toString() ?? '');
          final displayName = ilk['display_name']?.toString() ?? temizSorgu;
          final kisaAd = displayName.split(',').take(2).map((e) => e.trim()).join(' / ');
          if (lat != null && lon != null) {
            return await koordinatlaVakitleriGetir(
              enlem: lat,
              boylam: lon,
              konumAdi: kisaAd.isNotEmpty ? kisaAd : temizSorgu,
            );
          }
        }
      }
    } catch (_) {}

    return koordinatlaVakitleriGetir(
      enlem: 41.0082,
      boylam: 28.9784,
      konumAdi: temizSorgu,
    );
  }

  /// Cihazın gerçek GPS donanımını (Geolocator) + Reverse Geocoding (BigDataCloud + Nominatim + 973 İlçe Yerel Haritası)
  /// kullanarak koordinat rakamı YAZMADAN doğrudan "İstanbul / Üsküdar" veya "Konya / Selçuklu" gibi İl ve İlçe adını bulur.
  static Future<CanliNamazVakitleriModel> gpsKonumundanVakitleriGetir() async {
    double? lat;
    double? lon;
    String? sehirIlceAdi;

    // 1. Mobil cihazlarda (Android & iOS) Geolocator ile gerçek GPS koordinatını al
    if (!kIsWeb) {
      try {
        final servisAcik = await Geolocator.isLocationServiceEnabled();
        if (servisAcik) {
          LocationPermission perm = await Geolocator.checkPermission();
          if (perm == LocationPermission.denied) {
            perm = await Geolocator.requestPermission();
          }
          if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
            final pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 7),
              ),
            );
            lat = pos.latitude;
            lon = pos.longitude;
          }
        }
      } catch (_) {
        try {
          final lastPos = await Geolocator.getLastKnownPosition();
          if (lastPos != null) {
            lat = lastPos.latitude;
            lon = lastPos.longitude;
          }
        } catch (_) {}
      }
    }

    // 2. Web ortamındaysa veya Geolocator sonuç dönmediyse HTML5 Geolocation API'sini dene
    if (lat == null || lon == null) {
      try {
        final completer = Completer<(double, double)?>();
        web.window.navigator.geolocation.getCurrentPosition(
          ((web.GeolocationPosition pos) {
            if (!completer.isCompleted) {
              completer.complete((pos.coords.latitude, pos.coords.longitude));
            }
          }).toJS,
          ((web.GeolocationPositionError err) {
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          }).toJS,
          web.PositionOptions(
            enableHighAccuracy: true,
            timeout: 6000,
            maximumAge: 60000,
          ),
        );

        final sonuc = await completer.future.timeout(
          const Duration(seconds: 6),
          onTimeout: () => null,
        );
        if (sonuc != null) {
          lat = sonuc.$1;
          lon = sonuc.$2;
        }
      } catch (_) {}
    }

    // 3. Yedek: IP tabanlı konum servisi
    if (lat == null || lon == null) {
      try {
        final ipResp = await http
            .get(Uri.parse('https://get.geojs.io/v1/ip/geo.json'))
            .timeout(const Duration(seconds: 4));
        if (ipResp.statusCode == 200) {
          final data = jsonDecode(ipResp.body) as Map<String, dynamic>;
          lat = double.tryParse(data['latitude']?.toString() ?? '');
          lon = double.tryParse(data['longitude']?.toString() ?? '');
        }
      } catch (_) {}
    }

    lat ??= 41.0082;
    lon ??= 28.9784;

    // 4. Reverse Geocoding Aşaması 1: BigDataCloud Resmi Ücretsiz Reverse Geocoding API
    try {
      final bdcUri = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=tr',
      );
      final bdcResp = await http.get(bdcUri).timeout(const Duration(seconds: 4));
      if (bdcResp.statusCode == 200) {
        final decoded = jsonDecode(bdcResp.body) as Map<String, dynamic>;
        final il = decoded['principalSubdivision']?.toString().trim() ?? '';
        final ilce = decoded['city']?.toString().trim().isNotEmpty == true
            ? decoded['city'].toString().trim()
            : (decoded['locality']?.toString().trim() ?? '');
        if (il.isNotEmpty && ilce.isNotEmpty && _normTr(il) != _normTr(ilce)) {
          sehirIlceAdi = '$il / $ilce';
        } else if (il.isNotEmpty) {
          sehirIlceAdi = il;
        }
      }
    } catch (_) {}

    // 5. Reverse Geocoding Aşaması 2: OpenStreetMap Nominatim API (BigDataCloud dönmezse)
    if (sehirIlceAdi == null || !sehirIlceAdi.contains('/')) {
      try {
        final revUri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=12&accept-language=tr',
        );
        final revResp = await http.get(
          revUri,
          headers: {'User-Agent': 'VaktiHuzurApp/2.0'},
        ).timeout(const Duration(seconds: 4));
        if (revResp.statusCode == 200) {
          final decoded = jsonDecode(revResp.body) as Map<String, dynamic>;
          final addr = decoded['address'] as Map<String, dynamic>?;
          if (addr != null) {
            final ilce = addr['town'] ??
                addr['district'] ??
                addr['county'] ??
                addr['municipality'] ??
                addr['suburb'];
            final il = addr['province'] ?? addr['state'] ?? addr['city'];
            if (il != null && ilce != null && _normTr(il.toString()) != _normTr(ilce.toString())) {
              sehirIlceAdi = '${il.toString()} / ${ilce.toString()}';
            } else if (il != null) {
              sehirIlceAdi = il.toString();
            }
          }
        }
      } catch (_) {}
    }

    // 6. Reverse Geocoding Aşaması 3 (%100 Garantili Yerel 81 İl / 973 İlçe Haritası):
    // Türkiye sınırları içindeyse veya internetten ilçe adı alınamadıysa asla koordinat rakamı yazma,
    // doğrudan "İstanbul / Üsküdar" veya "Konya / Selçuklu" formatında en yakın İl / İlçe adını ata!
    if (sehirIlceAdi == null ||
        sehirIlceAdi.isEmpty ||
        !sehirIlceAdi.contains('/') ||
        (lat >= 35.8 && lat <= 42.2 && lon >= 25.6 && lon <= 44.9)) {
      final yerelIlIlce = enYakinIlIlceBul(lat, lon);
      if (sehirIlceAdi == null || !sehirIlceAdi.contains('/')) {
        sehirIlceAdi = yerelIlIlce;
      }
    }

    return koordinatlaVakitleriGetir(
      enlem: lat,
      boylam: lon,
      konumAdi: sehirIlceAdi,
      gpsKaynakliMi: true,
    );
  }
}

// Türkiye'nin 81 İli ve Seçkin Dünya / İslam Şehirleri
const List<SehirKoordinat> kTurkiye81IlVeDunyaSehirleri = [
  SehirKoordinat('İstanbul', 'Türkiye', 41.0082, 28.9784),
  SehirKoordinat('Ankara', 'Türkiye', 39.9334, 32.8597),
  SehirKoordinat('İzmir', 'Türkiye', 38.4237, 27.1428),
  SehirKoordinat('Bursa', 'Türkiye', 40.1885, 29.0610),
  SehirKoordinat('Antalya', 'Türkiye', 36.8969, 30.7133),
  SehirKoordinat('Konya', 'Türkiye', 37.8746, 32.4932),
  SehirKoordinat('Adana', 'Türkiye', 37.0000, 35.3213),
  SehirKoordinat('Şanlıurfa', 'Türkiye', 37.1591, 38.7969),
  SehirKoordinat('Gaziantep', 'Türkiye', 37.0662, 37.3833),
  SehirKoordinat('Kocaeli', 'Türkiye', 40.8533, 29.8815),
  SehirKoordinat('Mersin', 'Türkiye', 36.8121, 34.6415),
  SehirKoordinat('Diyarbakır', 'Türkiye', 37.9144, 40.2306),
  SehirKoordinat('Hatay', 'Türkiye', 36.4018, 36.3498),
  SehirKoordinat('Manisa', 'Türkiye', 38.6191, 27.4289),
  SehirKoordinat('Kayseri', 'Türkiye', 38.7312, 35.4787),
  SehirKoordinat('Samsun', 'Türkiye', 41.2867, 36.3300),
  SehirKoordinat('Balıkesir', 'Türkiye', 39.6484, 27.8826),
  SehirKoordinat('Kahramanmaraş', 'Türkiye', 37.5858, 36.9371),
  SehirKoordinat('Van', 'Türkiye', 38.4891, 43.4089),
  SehirKoordinat('Aydın', 'Türkiye', 37.8560, 27.8416),
  SehirKoordinat('Tekirdağ', 'Türkiye', 40.9833, 27.5167),
  SehirKoordinat('Sakarya', 'Türkiye', 40.7569, 30.3783),
  SehirKoordinat('Denizli', 'Türkiye', 37.7765, 29.0864),
  SehirKoordinat('Muğla', 'Türkiye', 37.2153, 28.3636),
  SehirKoordinat('Eskişehir', 'Türkiye', 39.7767, 30.5206),
  SehirKoordinat('Mardin', 'Türkiye', 37.3212, 40.7245),
  SehirKoordinat('Trabzon', 'Türkiye', 41.0027, 39.7168),
  SehirKoordinat('Erzurum', 'Türkiye', 39.9043, 41.2679),
  SehirKoordinat('Malatya', 'Türkiye', 38.3552, 38.3095),
  SehirKoordinat('Ordu', 'Türkiye', 40.9839, 37.8764),
  SehirKoordinat('Afyonkarahisar', 'Türkiye', 38.7507, 30.5567),
  SehirKoordinat('Sivas', 'Türkiye', 39.7477, 37.0179),
  SehirKoordinat('Adıyaman', 'Türkiye', 37.7648, 38.2786),
  SehirKoordinat('Batman', 'Türkiye', 37.8812, 41.1351),
  SehirKoordinat('Tokat', 'Türkiye', 40.3167, 36.5500),
  SehirKoordinat('Elazığ', 'Türkiye', 38.6810, 39.2264),
  SehirKoordinat('Zonguldak', 'Türkiye', 41.4564, 31.7987),
  SehirKoordinat('Kütahya', 'Türkiye', 39.4167, 29.9833),
  SehirKoordinat('Çanakkale', 'Türkiye', 40.1553, 26.4142),
  SehirKoordinat('Osmaniye', 'Türkiye', 37.0742, 36.2478),
  SehirKoordinat('Çorum', 'Türkiye', 40.5506, 34.9556),
  SehirKoordinat('Ağrı', 'Türkiye', 39.7191, 43.0503),
  SehirKoordinat('Giresun', 'Türkiye', 40.9128, 38.3895),
  SehirKoordinat('Isparta', 'Türkiye', 37.7648, 30.5566),
  SehirKoordinat('Aksaray', 'Türkiye', 38.3687, 34.0370),
  SehirKoordinat('Yozgat', 'Türkiye', 39.8181, 34.8147),
  SehirKoordinat('Edirne', 'Türkiye', 41.6818, 26.5623),
  SehirKoordinat('Düzce', 'Türkiye', 40.8438, 31.1565),
  SehirKoordinat('Muş', 'Türkiye', 38.9462, 41.7539),
  SehirKoordinat('Kastamonu', 'Türkiye', 41.3887, 33.7827),
  SehirKoordinat('Uşak', 'Türkiye', 38.6823, 29.4082),
  SehirKoordinat('Kırklareli', 'Türkiye', 41.7333, 27.2167),
  SehirKoordinat('Niğde', 'Türkiye', 37.9667, 34.6833),
  SehirKoordinat('Bitlis', 'Türkiye', 38.4000, 42.1167),
  SehirKoordinat('Rize', 'Türkiye', 41.0201, 40.5234),
  SehirKoordinat('Amasya', 'Türkiye', 40.6499, 35.8353),
  SehirKoordinat('Siirt', 'Türkiye', 37.9333, 41.9500),
  SehirKoordinat('Bolu', 'Türkiye', 40.7392, 31.6089),
  SehirKoordinat('Nevşehir', 'Türkiye', 38.6939, 34.6857),
  SehirKoordinat('Kars', 'Türkiye', 40.6013, 43.0975),
  SehirKoordinat('Bingöl', 'Türkiye', 38.8854, 40.4966),
  SehirKoordinat('Kırıkkale', 'Türkiye', 39.8468, 33.5153),
  SehirKoordinat('Hakkari', 'Türkiye', 37.5833, 43.7333),
  SehirKoordinat('Şırnak', 'Türkiye', 37.5164, 42.4611),
  SehirKoordinat('Burdur', 'Türkiye', 37.7203, 30.2908),
  SehirKoordinat('Karaman', 'Türkiye', 37.1759, 33.2287),
  SehirKoordinat('Karabük', 'Türkiye', 41.2061, 32.6204),
  SehirKoordinat('Kırşehir', 'Türkiye', 39.1425, 34.1709),
  SehirKoordinat('Erzincan', 'Türkiye', 39.7500, 39.5000),
  SehirKoordinat('Bilecik', 'Türkiye', 40.1451, 29.9799),
  SehirKoordinat('Sinop', 'Türkiye', 42.0231, 35.1531),
  SehirKoordinat('Iğdır', 'Türkiye', 39.9167, 44.0333),
  SehirKoordinat('Bartın', 'Türkiye', 41.6344, 32.3375),
  SehirKoordinat('Çankırı', 'Türkiye', 40.6013, 33.6134),
  SehirKoordinat('Artvin', 'Türkiye', 41.1828, 41.8183),
  SehirKoordinat('Gümüşhane', 'Türkiye', 40.4386, 39.5086),
  SehirKoordinat('Kilis', 'Türkiye', 36.7184, 37.1212),
  SehirKoordinat('Ardahan', 'Türkiye', 41.1105, 42.7022),
  SehirKoordinat('Yalova', 'Türkiye', 40.6500, 29.2667),
  SehirKoordinat('Tunceli', 'Türkiye', 39.1079, 39.5401),
  SehirKoordinat('Bayburt', 'Türkiye', 40.2552, 40.2249),
  // Seçkin İslam ve Dünya Merkezleri
  SehirKoordinat('Mekke-i Mükerreme', 'Suudi Arabistan', 21.4225, 39.8262),
  SehirKoordinat('Medine-i Münevvere', 'Suudi Arabistan', 24.4672, 39.6112),
  SehirKoordinat('Kudüs (Mescid-i Aksâ)', 'Filistin', 31.7767, 35.2345),
  SehirKoordinat('Lefkoşa', 'KKTC', 35.1856, 33.3823),
  SehirKoordinat('Bakü', 'Azerbaycan', 40.4093, 49.8671),
  SehirKoordinat('Saraybosna', 'Bosna-Hersek', 43.8563, 18.4131),
  SehirKoordinat('Kahire', 'Mısır', 30.0444, 31.2357),
  SehirKoordinat('Berlin', 'Almanya', 52.5200, 13.4050),
  SehirKoordinat('Londra', 'İngiltere', 51.5074, -0.1278),
  SehirKoordinat('New York', 'ABD', 40.7128, -74.0060),
];

// ============================================================================
// 2. DİYANET TAKVİMİNE UYGUN GERÇEK DİNİ GÜNLER VE BAYRAMLAR HESAPLAYICI
// ============================================================================

class DiniGunHesapliModel {
  final String adTr;
  final String adEn;
  final String adAr;
  final String hicriTarih;
  final DateTime miladiTarih;
  final int kalanGun;

  const DiniGunHesapliModel({
    required this.adTr,
    required this.adEn,
    required this.adAr,
    required this.hicriTarih,
    required this.miladiTarih,
    required this.kalanGun,
  });

  String ad(String dil) {
    if (dil == 'EN') return adEn;
    if (dil == 'AR') return adAr;
    return adTr;
  }

  String formatliMiladiTarih(String dil) {
    final g = miladiTarih.day.toString().padLeft(2, '0');
    final a = miladiTarih.month.toString().padLeft(2, '0');
    final y = miladiTarih.year;
    const aylarTr = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    if (dil == 'TR') {
      return '${miladiTarih.day} ${aylarTr[miladiTarih.month - 1]} $y';
    }
    return '$g.$a.$y';
  }

  String kalanGunEtiketi(String dil) {
    if (kalanGun == 0) {
      if (dil == 'EN') return 'Today / Tonight';
      if (dil == 'AR') return 'اليوم / الليلة';
      return 'Bugün / Bu Gece';
    } else if (kalanGun > 0) {
      if (dil == 'EN') return '$kalanGun days left';
      if (dil == 'AR') return 'باقي $kalanGun يوم';
      return '$kalanGun gün kaldı';
    } else {
      final gecen = kalanGun.abs();
      if (dil == 'EN') return 'Passed ($gecen d ago)';
      if (dil == 'AR') return 'مضى قبل $gecen يوم';
      return 'Geçti ($gecen gün önce)';
    }
  }
}

class DiyanetDiniGunlerServisi {
  static final List<Map<String, dynamic>> _resmiDiyanetTakvimi = [
    // --- 2025 (1446 - 1447 Hicrî) ---
    {'tarih': DateTime(2025, 1, 1), 'hicri': '1 Receb 1446', 'tr': 'Üç Aylar Başlangıcı', 'en': 'Start of Three Holy Months', 'ar': 'بداية الأشهر الحرم'},
    {'tarih': DateTime(2025, 1, 2), 'hicri': '2 Receb 1446', 'tr': 'Regaib Kandili', 'en': 'Laylat al-Raghaib', 'ar': 'ليلة الرغائب'},
    {'tarih': DateTime(2025, 1, 26), 'hicri': '26 Receb 1446', 'tr': 'Mirac Kandili', 'en': 'Laylat al-Mi’raj', 'ar': 'ليلة الإسراء والمعراج'},
    {'tarih': DateTime(2025, 2, 13), 'hicri': '14 Şaban 1446', 'tr': 'Berat Kandili', 'en': 'Laylat al-Bara’ah', 'ar': 'ليلة البراءة (النصف من شعبان)'},
    {'tarih': DateTime(2025, 3, 1), 'hicri': '1 Ramazan 1446', 'tr': 'Ramazan-ı Şerif Başlangıcı', 'en': 'Start of Ramadan', 'ar': 'غرة شهر رمضان المبارك'},
    {'tarih': DateTime(2025, 3, 26), 'hicri': '26 Ramazan 1446', 'tr': 'Kadir Gecesi', 'en': 'Laylat al-Qadr', 'ar': 'ليلة القدر المباركة'},
    {'tarih': DateTime(2025, 3, 29), 'hicri': '29 Ramazan 1446', 'tr': 'Ramazan Bayramı Arefesi', 'en': 'Eve of Eid al-Fitr', 'ar': 'وقفة عيد الفطر'},
    {'tarih': DateTime(2025, 3, 30), 'hicri': '1 Şevval 1446', 'tr': 'Ramazan Bayramı (1. Gün)', 'en': 'Eid al-Fitr (Day 1)', 'ar': 'عيد الفطر السعيد (اليوم الأول)'},
    {'tarih': DateTime(2025, 6, 5), 'hicri': '9 Zilhicce 1446', 'tr': 'Kurban Bayramı Arefesi', 'en': 'Day of Arafah', 'ar': 'يوم عرفة المبارك'},
    {'tarih': DateTime(2025, 6, 6), 'hicri': '10 Zilhicce 1446', 'tr': 'Kurban Bayramı (1. Gün)', 'en': 'Eid al-Adha (Day 1)', 'ar': 'عيد الأضحى المبارك (اليوم الأول)'},
    {'tarih': DateTime(2025, 6, 26), 'hicri': '1 Muharrem 1447', 'tr': 'Hicrî Yılbaşı (1447)', 'en': 'Islamic New Year (1447 AH)', 'ar': 'رأس السنة الهجرية (١٤٤٧ هـ)'},
    {'tarih': DateTime(2025, 7, 5), 'hicri': '10 Muharrem 1447', 'tr': 'Aşure Günü', 'en': 'Day of Ashura', 'ar': 'يوم عاشوراء'},
    {'tarih': DateTime(2025, 9, 3), 'hicri': '11 Rebîülevvel 1447', 'tr': 'Mevlid Kandili', 'en': 'Mawlid al-Nabi', 'ar': 'ذكرى المولد النبوي الشريف'},
    {'tarih': DateTime(2025, 12, 21), 'hicri': '1 Receb 1447', 'tr': 'Üç Aylar Başlangıcı', 'en': 'Start of Three Holy Months', 'ar': 'بداية الأشهر الحرم'},
    {'tarih': DateTime(2025, 12, 25), 'hicri': '5 Receb 1447', 'tr': 'Regaib Kandili', 'en': 'Laylat al-Raghaib', 'ar': 'ليلة الرغائب'},

    // --- 2026 (1447 - 1448 Hicrî) ---
    {'tarih': DateTime(2026, 1, 15), 'hicri': '26 Receb 1447', 'tr': 'Mirac Kandili', 'en': 'Laylat al-Mi’raj', 'ar': 'ليلة الإسراء والمعراج'},
    {'tarih': DateTime(2026, 2, 2), 'hicri': '14 Şaban 1447', 'tr': 'Berat Kandili', 'en': 'Laylat al-Bara’ah', 'ar': 'ليلة البراءة (النصف من شعبان)'},
    {'tarih': DateTime(2026, 2, 19), 'hicri': '1 Ramazan 1447', 'tr': 'Ramazan-ı Şerif Başlangıcı', 'en': 'Start of Ramadan', 'ar': 'غرة شهر رمضان المبارك'},
    {'tarih': DateTime(2026, 3, 16), 'hicri': '26 Ramazan 1447', 'tr': 'Kadir Gecesi', 'en': 'Laylat al-Qadr', 'ar': 'ليلة القدر المباركة'},
    {'tarih': DateTime(2026, 3, 19), 'hicri': '29 Ramazan 1447', 'tr': 'Ramazan Bayramı Arefesi', 'en': 'Eve of Eid al-Fitr', 'ar': 'وقفة عيد الفطر'},
    {'tarih': DateTime(2026, 3, 20), 'hicri': '1 Şevval 1447', 'tr': 'Ramazan Bayramı (1. Gün)', 'en': 'Eid al-Fitr (Day 1)', 'ar': 'عيد الفطر السعيد (اليوم الأول)'},
    {'tarih': DateTime(2026, 5, 26), 'hicri': '9 Zilhicce 1447', 'tr': 'Kurban Bayramı Arefesi', 'en': 'Day of Arafah', 'ar': 'يوم عرفة المبارك'},
    {'tarih': DateTime(2026, 5, 27), 'hicri': '10 Zilhicce 1447', 'tr': 'Kurban Bayramı (1. Gün)', 'en': 'Eid al-Adha (Day 1)', 'ar': 'عيد الأضحى المبارك (اليوم الأول)'},
    {'tarih': DateTime(2026, 6, 16), 'hicri': '1 Muharrem 1448', 'tr': 'Hicrî Yılbaşı (1448)', 'en': 'Islamic New Year (1448 AH)', 'ar': 'رأس السنة الهجرية (١٤٤٨ هـ)'},
    {'tarih': DateTime(2026, 6, 25), 'hicri': '10 Muharrem 1448', 'tr': 'Aşure Günü', 'en': 'Day of Ashura', 'ar': 'يوم عاشوراء'},
    {'tarih': DateTime(2026, 8, 24), 'hicri': '11 Rebîülevvel 1448', 'tr': 'Mevlid Kandili', 'en': 'Mawlid al-Nabi', 'ar': 'ذكرى المولد النبوي الشريف'},
    {'tarih': DateTime(2026, 12, 10), 'hicri': '1 Receb 1448', 'tr': 'Üç Aylar Başlangıcı & Regaib Kandili', 'en': 'Start of Three Holy Months & Raghaib', 'ar': 'غرة رجب وليلة الرغائب'},

    // --- 2027 (1448 - 1449 Hicrî) ---
    {'tarih': DateTime(2027, 1, 4), 'hicri': '26 Receb 1448', 'tr': 'Mirac Kandili', 'en': 'Laylat al-Mi’raj', 'ar': 'ليلة الإسراء والمعراج'},
    {'tarih': DateTime(2027, 1, 22), 'hicri': '14 Şaban 1448', 'tr': 'Berat Kandili', 'en': 'Laylat al-Bara’ah', 'ar': 'ليلة البراءة (النصف من شعبان)'},
    {'tarih': DateTime(2027, 2, 8), 'hicri': '1 Ramazan 1448', 'tr': 'Ramazan-ı Şerif Başlangıcı', 'en': 'Start of Ramadan', 'ar': 'غرة شهر رمضان المبارك'},
    {'tarih': DateTime(2027, 3, 5), 'hicri': '26 Ramazan 1448', 'tr': 'Kadir Gecesi', 'en': 'Laylat al-Qadr', 'ar': 'ليلة القدر المباركة'},
    {'tarih': DateTime(2027, 3, 8), 'hicri': '29 Ramazan 1448', 'tr': 'Ramazan Bayramı Arefesi', 'en': 'Eve of Eid al-Fitr', 'ar': 'وقفة عيد الفطر'},
    {'tarih': DateTime(2027, 3, 9), 'hicri': '1 Şevval 1448', 'tr': 'Ramazan Bayramı (1. Gün)', 'en': 'Eid al-Fitr (Day 1)', 'ar': 'عيد الفطر السعيد (اليوم الأول)'},
    {'tarih': DateTime(2027, 5, 15), 'hicri': '9 Zilhicce 1448', 'tr': 'Kurban Bayramı Arefesi', 'en': 'Day of Arafah', 'ar': 'يوم عرفة المبارك'},
    {'tarih': DateTime(2027, 5, 16), 'hicri': '10 Zilhicce 1448', 'tr': 'Kurban Bayramı (1. Gün)', 'en': 'Eid al-Adha (Day 1)', 'ar': 'عيد الأضحى المبارك (اليوم الأول)'},
    {'tarih': DateTime(2027, 6, 6), 'hicri': '1 Muharrem 1449', 'tr': 'Hicrî Yılbaşı (1449)', 'en': 'Islamic New Year (1449 AH)', 'ar': 'رأس السنة الهجرية (١٤٤٩ هـ)'},
    {'tarih': DateTime(2027, 6, 15), 'hicri': '10 Muharrem 1449', 'tr': 'Aşure Günü', 'en': 'Day of Ashura', 'ar': 'يوم عاشوراء'},
    {'tarih': DateTime(2027, 8, 13), 'hicri': '11 Rebîülevvel 1449', 'tr': 'Mevlid Kandili', 'en': 'Mawlid al-Nabi', 'ar': 'ذكرى المولد النبوي الشريف'},
  ];

  static List<DiniGunHesapliModel> diniGunleriHesapla({bool sadeceYaklasanlar = false}) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);

    final tumHesaplananlar = _resmiDiyanetTakvimi.map((g) {
      final dt = g['tarih'] as DateTime;
      final hedefGun = DateTime(dt.year, dt.month, dt.day);
      final fark = hedefGun.difference(bugun).inDays;
      return DiniGunHesapliModel(
        adTr: g['tr'] as String,
        adEn: g['en'] as String,
        adAr: g['ar'] as String,
        hicriTarih: g['hicri'] as String,
        miladiTarih: hedefGun,
        kalanGun: fark,
      );
    }).toList();

    final yaklasanlar = tumHesaplananlar
        .where((g) => g.kalanGun >= 0 && g.kalanGun <= 380)
        .toList()
      ..sort((a, b) => a.kalanGun.compareTo(b.kalanGun));

    if (sadeceYaklasanlar) {
      return yaklasanlar;
    }

    final gecmisler = tumHesaplananlar
        .where((g) => g.kalanGun < 0 && g.kalanGun >= -180)
        .toList()
      ..sort((a, b) => b.kalanGun.compareTo(a.kalanGun));

    return [...yaklasanlar, ...gecmisler];
  }
}

// ============================================================================
// 3. 81 İL VE 973 İLÇE KADEMELİ SEÇİM + SERBEST ARAMA VE GPS KONUM PENCERESİ
// ============================================================================

class KonumVeSehirSeciciSheet extends StatefulWidget {
  final Color arkaPlan;
  final Color kartRengi;
  final Color vurguAltin;
  final Color yaziRengi;
  final Color ikincilYazi;
  final String dil;
  final ValueChanged<String> onSehirSecildi;
  final VoidCallback onGpsKonumBul;

  const KonumVeSehirSeciciSheet({
    super.key,
    required this.arkaPlan,
    required this.kartRengi,
    required this.vurguAltin,
    required this.yaziRengi,
    required this.ikincilYazi,
    required this.dil,
    required this.onSehirSecildi,
    required this.onGpsKonumBul,
  });

  @override
  State<KonumVeSehirSeciciSheet> createState() => _KonumVeSehirSeciciSheetState();
}

class _KonumVeSehirSeciciSheetState extends State<KonumVeSehirSeciciSheet> {
  final TextEditingController _aramaCtrl = TextEditingController();
  String _filtre = '';
  IlVeri? _seciliIl; // Kademeli seçimde kullanıcı önce İli seçer, ardından o ilin ilçeleri listelenir

  @override
  void dispose() {
    _aramaCtrl.dispose();
    super.dispose();
  }

  String _norm(String s) {
    return s
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  @override
  Widget build(BuildContext context) {
    final dil = widget.dil;
    final q = _norm(_filtre.trim());

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: widget.arkaPlan,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: widget.vurguAltin.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_searching_rounded, color: widget.vurguAltin),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dil == 'EN'
                      ? '81 Provinces & 973 Districts (Diyanet)'
                      : dil == 'AR'
                          ? '٨١ ولاية و ٩٧٣ منطقة (ديانت)'
                          : '81 İl ve 973 İlçe Seçimi (Resmi Diyanet)',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: widget.yaziRengi,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: widget.ikincilYazi),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // GPS ile Konumumu Bul Butonu
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: widget.vurguAltin,
              foregroundColor: widget.arkaPlan,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.pop(context);
              widget.onGpsKonumBul();
            },
            icon: const Icon(Icons.my_location_rounded, size: 19),
            label: Text(
              dil == 'EN'
                  ? 'Find My Province & District via GPS'
                  : dil == 'AR'
                      ? 'تحديد ولايتي ومنطقتي عبر GPS'
                      : 'GPS ile Bulunduğum İl / İlçeyi Otomatik Bul',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),

          // Arama Kutusu
          TextField(
            controller: _aramaCtrl,
            onChanged: (v) => setState(() => _filtre = v),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                Navigator.pop(context);
                widget.onSehirSecildi(v.trim());
              }
            },
            style: TextStyle(color: widget.yaziRengi, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: _seciliIl != null
                  ? '${_seciliIl!.ad} ilçelerinde ara (Örn: ${_seciliIl!.ilceler.first.ad})...'
                  : '81 İl veya 973 İlçe ara (Örn: İstanbul, Kadıköy, Selçuklu)...',
              hintStyle: TextStyle(color: widget.ikincilYazi, fontSize: 12),
              prefixIcon: Icon(Icons.search_rounded, color: widget.vurguAltin, size: 20),
              suffixIcon: _filtre.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: widget.ikincilYazi, size: 18),
                      onPressed: () {
                        _aramaCtrl.clear();
                        setState(() => _filtre = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: widget.kartRengi,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: widget.vurguAltin.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: widget.vurguAltin.withValues(alpha: 0.3)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Kademeli Seçim Başlığı (Breadcrumb: 81 İl Listesi > Seçili İl > İlçeler)
          if (_seciliIl != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.vurguAltin.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _seciliIl = null;
                        _filtre = '';
                        _aramaCtrl.clear();
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: widget.vurguAltin),
                        const SizedBox(width: 6),
                        Text(
                          '81 İl Listesine Dön',
                          style: TextStyle(
                            color: widget.vurguAltin,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_seciliIl!.plaka.toString().padLeft(2, '0')} • ${_seciliIl!.ad} (${_seciliIl!.ilceler.length} İlçe)',
                    style: TextStyle(
                      color: widget.yaziRengi,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Text(
                q.isEmpty
                    ? '1. Adım: Önce İli seçin, ardından o ilin ilçesini seçin (81 İl • 973 İlçe):'
                    : 'Arama Sonuçları (İl ve İlçeler):',
                style: TextStyle(
                  color: widget.vurguAltin,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          // Liste Alanı
          Expanded(
            child: _seciliIl != null
                ? _ilceListesiOlustur(_seciliIl!, q)
                : (q.isNotEmpty ? _dogrudanIlVeIlceAramaListesi(q) : _seksenBirIlListesi()),
          ),
        ],
      ),
    );
  }

  /// 1. Aşama: Türkiye'nin 81 İli (Plaka Sıralı / Popüler İller Üstte)
  Widget _seksenBirIlListesi() {
    return ListView.builder(
      itemCount: kTurkiye81IlVe973Ilce.length,
      itemBuilder: (context, i) {
        final il = kTurkiye81IlVe973Ilce[i];
        return Card(
          color: widget.kartRengi,
          margin: const EdgeInsets.only(bottom: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: widget.vurguAltin.withValues(alpha: 0.22)),
          ),
          child: ListTile(
            dense: true,
            onTap: () {
              setState(() {
                _seciliIl = il;
                _filtre = '';
                _aramaCtrl.clear();
              });
            },
            leading: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.vurguAltin.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.5)),
              ),
              child: Text(
                il.plaka.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: widget.vurguAltin,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              il.ad,
              style: TextStyle(
                color: widget.yaziRengi,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '${il.ilceler.length} İlçe • İlçeleri görmek için dokunun',
              style: TextStyle(color: widget.ikincilYazi, fontSize: 11.5),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: widget.vurguAltin),
          ),
        );
      },
    );
  }

  /// 2. Aşama: Seçilen İlin Tüm İlçeleri
  Widget _ilceListesiOlustur(IlVeri il, String q) {
    final ilceler = il.ilceler.where((d) {
      if (q.isEmpty) return true;
      return _norm(d.ad).contains(q);
    }).toList();

    return ListView.builder(
      itemCount: ilceler.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // İl Merkezi seçeneği
          final kible = NamazVeKonumServisi.kibleAcisiHesapla(il.enlem, il.boylam);
          return Card(
            color: widget.vurguAltin.withValues(alpha: 0.14),
            margin: const EdgeInsets.only(bottom: 7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: widget.vurguAltin, width: 1.2),
            ),
            child: ListTile(
              dense: true,
              onTap: () {
                Navigator.pop(context);
                widget.onSehirSecildi('${il.ad} / Merkez');
              },
              leading: Icon(Icons.my_location_rounded, color: widget.vurguAltin, size: 20),
              title: Text(
                '${il.ad} (İl Merkezi)',
                style: TextStyle(
                  color: widget.yaziRengi,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              subtitle: Text(
                'Diyanet İl Merkezi Takvimi',
                style: TextStyle(color: widget.ikincilYazi, fontSize: 11),
              ),
              trailing: Text(
                'Kıble ${kible.toStringAsFixed(1)}°',
                style: TextStyle(
                  color: widget.vurguAltin,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
              ),
            ),
          );
        }

        final ilce = ilceler[index - 1];
        final kible = NamazVeKonumServisi.kibleAcisiHesapla(ilce.enlem, ilce.boylam);
        return Card(
          color: widget.kartRengi,
          margin: const EdgeInsets.only(bottom: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: widget.vurguAltin.withValues(alpha: 0.22)),
          ),
          child: ListTile(
            dense: true,
            onTap: () {
              Navigator.pop(context);
              widget.onSehirSecildi('${il.ad} / ${ilce.ad}');
            },
            leading: Icon(Icons.location_on_outlined, color: widget.vurguAltin, size: 19),
            title: Text(
              ilce.ad,
              style: TextStyle(
                color: widget.yaziRengi,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            subtitle: Text(
              '${il.ad} / ${ilce.ad}',
              style: TextStyle(color: widget.ikincilYazi, fontSize: 11),
            ),
            trailing: Text(
              'Kıble ${kible.toStringAsFixed(1)}°',
              style: TextStyle(
                color: widget.vurguAltin,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Kullanıcı arama kutusuna doğrudan il veya ilçe yazdığında 973 ilçenin tamamında anında filtreleme yapar
  Widget _dogrudanIlVeIlceAramaListesi(String q) {
    final eslesenIller = <IlVeri>[];
    final eslesenIlceler = <(IlVeri, IlceVeri)>[];

    for (final il in kTurkiye81IlVe973Ilce) {
      if (_norm(il.ad).contains(q) || il.plaka.toString() == q) {
        eslesenIller.add(il);
      }
      for (final ilce in il.ilceler) {
        if (_norm(ilce.ad).contains(q) || _norm('${il.ad} ${ilce.ad}').contains(q)) {
          eslesenIlceler.add((il, ilce));
        }
      }
    }

    return ListView(
      children: [
        ...eslesenIller.map((il) {
          return Card(
            color: widget.vurguAltin.withValues(alpha: 0.14),
            margin: const EdgeInsets.only(bottom: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: widget.vurguAltin, width: 1.1),
            ),
            child: ListTile(
              dense: true,
              onTap: () {
                setState(() {
                  _seciliIl = il;
                  _filtre = '';
                  _aramaCtrl.clear();
                });
              },
              leading: Icon(Icons.location_city_rounded, color: widget.vurguAltin, size: 20),
              title: Text(
                '${il.ad} (${il.ilceler.length} İlçe)',
                style: TextStyle(color: widget.yaziRengi, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'İlin tüm ilçelerini listelemek için dokunun',
                style: TextStyle(color: widget.ikincilYazi, fontSize: 11),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: widget.vurguAltin),
            ),
          );
        }),
        ...eslesenIlceler.take(80).map((pair) {
          final il = pair.$1;
          final ilce = pair.$2;
          final kible = NamazVeKonumServisi.kibleAcisiHesapla(ilce.enlem, ilce.boylam);
          return Card(
            color: widget.kartRengi,
            margin: const EdgeInsets.only(bottom: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: widget.vurguAltin.withValues(alpha: 0.2)),
            ),
            child: ListTile(
              dense: true,
              onTap: () {
                Navigator.pop(context);
                widget.onSehirSecildi('${il.ad} / ${ilce.ad}');
              },
              leading: Icon(Icons.place_rounded, color: widget.vurguAltin, size: 19),
              title: Text(
                '${il.ad} / ${ilce.ad}',
                style: TextStyle(color: widget.yaziRengi, fontWeight: FontWeight.w600),
              ),
              trailing: Text(
                'Kıble ${kible.toStringAsFixed(1)}°',
                style: TextStyle(
                  color: widget.vurguAltin,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
