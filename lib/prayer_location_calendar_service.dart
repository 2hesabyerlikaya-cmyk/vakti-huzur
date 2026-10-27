import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'js_bridge.dart';
import 'web_shim_io.dart' if (dart.library.js_interop) 'package:web/web.dart' as web;

// ============================================================================
// 1. CANLI NAMAZ VAKİTLERİ, GPS KONUM VE KÜRESEL TRİGONOMETRİ KIBLE MODELİ
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
    return CanliNamazVakitleriModel(
      konumAdi: m['konumAdi']?.toString() ?? 'İstanbul',
      enlem: lat,
      boylam: lon,
      imsak: m['imsak']?.toString() ?? '05:48',
      gunes: m['gunes']?.toString() ?? '07:14',
      ogle: m['ogle']?.toString() ?? '12:56',
      ikindi: m['ikindi']?.toString() ?? '15:52',
      aksam: m['aksam']?.toString() ?? '18:24',
      yatsi: m['yatsi']?.toString() ?? '19:44',
      hicriTarihTr: m['hicriTarihTr']?.toString() ?? '14 Cemâziyelevvel 1448',
      hicriTarihEn: m['hicriTarihEn']?.toString() ?? '14 Jumada al-Ula 1448 AH',
      hicriTarihAr: m['hicriTarihAr']?.toString() ?? '١٤ جمادى الأولى ١٤٤٨ هـ',
      miladiTarihTr: m['miladiTarihTr']?.toString() ?? '27 Ekim 2026 Salı',
      miladiTarihEn: m['miladiTarihEn']?.toString() ?? 'Tuesday, 27 October 2026',
      miladiTarihAr: m['miladiTarihAr']?.toString() ?? 'الثلاثاء 27 أكتوبر 2026 م',
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
  static const String _vakitHafizaKey = 'nur_huzur_son_namaz_vakitleri_v1';

  /// Son çekilen Diyanet namaz vakitlerini çevrimdışı kullanım için cihaz hafızasına (localStorage) kaydeder
  static void vakitleriHafizayaKaydet(CanliNamazVakitleriModel model) {
    try {
      web.window.localStorage.setItem(_vakitHafizaKey, jsonEncode(model.toJson()));
    } catch (_) {}
  }

  /// İnternet olmadığında veya ilk açılışta cihaz hafızasındaki son namaz vakitlerini okur
  static CanliNamazVakitleriModel? hafizadakiSonVakitleriGetir() {
    try {
      final raw = web.window.localStorage.getItem(_vakitHafizaKey);
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

  /// Koordinatlara göre T.C. Diyanet İşleri Başkanlığı (method=13) canlı namaz vakitlerini çeker
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

    try {
      final uri = Uri.parse(
        'https://api.aladhan.com/v1/timings/$tarihStr?latitude=$enlem&longitude=$boylam&method=13',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>;
        final timings = data['timings'] as Map<String, dynamic>;
        final dateObj = data['date'] as Map<String, dynamic>?;
        final hijriObj = dateObj?['hijri'] as Map<String, dynamic>?;

        String hicriTr = 'Hicrî Takvim';
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

          hicriTr = '$hGun $hAyTr $hYil';
          hicriEn = '$hGun $hAyEn $hYil AH';
          hicriAr = '$hGun $hAyAr $hYil هـ';
        }

        final sonucModel = CanliNamazVakitleriModel(
          konumAdi: konumAdi,
          enlem: enlem,
          boylam: boylam,
          imsak: _saatTemizle(timings['Fajr']?.toString()),
          gunes: _saatTemizle(timings['Sunrise']?.toString()),
          ogle: _saatTemizle(timings['Dhuhr']?.toString()),
          ikindi: _saatTemizle(timings['Asr']?.toString()),
          aksam: _saatTemizle(timings['Maghrib']?.toString()),
          yatsi: _saatTemizle(timings['Isha']?.toString()),
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
    } catch (_) {
      // Çevrimdışı / ağ hatası durumunda önce cihaz hafızasındaki (localStorage) son vakitleri kontrol et
    }

    final kayitli = hafizadakiSonVakitleriGetir();
    if (kayitli != null) {
      return CanliNamazVakitleriModel(
        konumAdi: konumAdi.isNotEmpty ? konumAdi : kayitli.konumAdi,
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
      konumAdi: konumAdi,
      enlem: enlem,
      boylam: boylam,
      imsak: '05:48',
      gunes: '07:14',
      ogle: '12:56',
      ikindi: '15:52',
      aksam: '18:24',
      yatsi: '19:44',
      hicriTarihTr: '14 Cemâziyelevvel 1448',
      hicriTarihEn: '14 Jumada al-Ula 1448 AH',
      hicriTarihAr: '١٤ جمادى الأولى ١٤٤٨ هـ',
      miladiTarihTr: miladi['TR']!,
      miladiTarihEn: miladi['EN']!,
      miladiTarihAr: miladi['AR']!,
      kibleAcisiDerece: kibleAcisiHesapla(enlem, boylam),
      kabeMesafeKm: kabeMesafeHesaplaKm(enlem, boylam),
      gpsKaynakliMi: gpsKaynakliMi,
    );
  }

  /// Kullanıcının yazdığı şehir/ilçe adına göre koordinat ve Diyanet namaz vakitlerini çeker
  static Future<CanliNamazVakitleriModel> sehirAramasiIleVakitleriGetir(String sorgu) async {
    final temizSorgu = sorgu.trim();
    if (temizSorgu.isEmpty) {
      return koordinatlaVakitleriGetir(
        enlem: 41.0082,
        boylam: 28.9784,
        konumAdi: 'İstanbul',
      );
    }

    // 1. Önce Türkiye 81 İl / Dünya şehirleri yerel listesinden tam eşleşme kontrolü
    for (final s in kTurkiye81IlVeDunyaSehirleri) {
      if (s.ad.toLowerCase() == temizSorgu.toLowerCase()) {
        return koordinatlaVakitleriGetir(
          enlem: s.enlem,
          boylam: s.boylam,
          konumAdi: s.ulke == 'Türkiye' ? s.ad : '${s.ad}, ${s.ulke}',
        );
      }
    }

    // 2. OpenStreetMap Nominatim ile dünya genelinde il/ilçe/şehir koordinatı bul
    try {
      final geoUri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(temizSorgu)}&limit=1&accept-language=tr',
      );
      final geoResp = await http.get(geoUri).timeout(const Duration(seconds: 6));
      if (geoResp.statusCode == 200) {
        final list = jsonDecode(geoResp.body) as List<dynamic>;
        if (list.isNotEmpty) {
          final ilk = list.first as Map<String, dynamic>;
          final lat = double.tryParse(ilk['lat']?.toString() ?? '');
          final lon = double.tryParse(ilk['lon']?.toString() ?? '');
          final displayName = ilk['display_name']?.toString() ?? temizSorgu;
          final kisaAd = displayName.split(',').take(2).map((e) => e.trim()).join(', ');
          if (lat != null && lon != null) {
            return koordinatlaVakitleriGetir(
              enlem: lat,
              boylam: lon,
              konumAdi: kisaAd.isNotEmpty ? kisaAd : temizSorgu,
            );
          }
        }
      }
    } catch (_) {}

    // 3. Yedek olarak doğrudan Aladhan timingsByCity (method=13) servisini çağır
    try {
      final simdi = DateTime.now();
      final miladi = _miladiTarihOlustur(simdi);
      final uri = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=${Uri.encodeComponent(temizSorgu)}&country=Turkey&method=13',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 7));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>;
        final timings = data['timings'] as Map<String, dynamic>;
        final meta = data['meta'] as Map<String, dynamic>?;
        final lat = (meta?['latitude'] as num?)?.toDouble() ?? 41.0082;
        final lon = (meta?['longitude'] as num?)?.toDouble() ?? 28.9784;
        final dateObj = data['date'] as Map<String, dynamic>?;
        final hijriObj = dateObj?['hijri'] as Map<String, dynamic>?;

        final hGun = hijriObj?['day']?.toString() ?? '14';
        final hYil = hijriObj?['year']?.toString() ?? '1448';
        final hAyObj = hijriObj?['month'] as Map<String, dynamic>?;
        final hAyNo = (hAyObj?['number'] as num?)?.toInt() ?? 5;
        final hAyEn = hAyObj?['en']?.toString() ?? 'Jumada al-Ula';
        final hAyAr = hAyObj?['ar']?.toString() ?? 'جمادى الأولى';
        final hAyTr = _hicriAyTr(hAyNo, hAyEn);

        final sehirModel = CanliNamazVakitleriModel(
          konumAdi: temizSorgu,
          enlem: lat,
          boylam: lon,
          imsak: _saatTemizle(timings['Fajr']?.toString()),
          gunes: _saatTemizle(timings['Sunrise']?.toString()),
          ogle: _saatTemizle(timings['Dhuhr']?.toString()),
          ikindi: _saatTemizle(timings['Asr']?.toString()),
          aksam: _saatTemizle(timings['Maghrib']?.toString()),
          yatsi: _saatTemizle(timings['Isha']?.toString()),
          hicriTarihTr: '$hGun $hAyTr $hYil',
          hicriTarihEn: '$hGun $hAyEn $hYil AH',
          hicriTarihAr: '$hGun $hAyAr $hYil هـ',
          miladiTarihTr: miladi['TR']!,
          miladiTarihEn: miladi['EN']!,
          miladiTarihAr: miladi['AR']!,
          kibleAcisiDerece: kibleAcisiHesapla(lat, lon),
          kabeMesafeKm: kabeMesafeHesaplaKm(lat, lon),
        );
        vakitleriHafizayaKaydet(sehirModel);
        return sehirModel;
      }
    } catch (_) {}

    return koordinatlaVakitleriGetir(
      enlem: 41.0082,
      boylam: 28.9784,
      konumAdi: temizSorgu,
    );
  }

  /// Tarayıcı/Cihaz GPS iznini (HTML5 Geolocation API) + Nominatim Reverse Geocoding kullanarak konumu bulur
  static Future<CanliNamazVakitleriModel> gpsKonumundanVakitleriGetir() async {
    double? lat;
    double? lon;
    String? sehirIlceAdi;

    // 1. Tarayıcı HTML5 Geolocation API'sini dene
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
        const Duration(seconds: 7),
        onTimeout: () => null,
      );
      if (sonuc != null) {
        lat = sonuc.$1;
        lon = sonuc.$2;
      }
    } catch (_) {}

    // 2. Eğer masaüstü tarayıcıda GPS donanımı yoksa veya izin verilmediyse IP tabanlı konum servisine başvur
    if (lat == null || lon == null) {
      try {
        final ipResp = await http
            .get(Uri.parse('https://get.geojs.io/v1/ip/geo.json'))
            .timeout(const Duration(seconds: 5));
        if (ipResp.statusCode == 200) {
          final data = jsonDecode(ipResp.body) as Map<String, dynamic>;
          lat = double.tryParse(data['latitude']?.toString() ?? '');
          lon = double.tryParse(data['longitude']?.toString() ?? '');
          final city = data['city']?.toString() ?? '';
          final country = data['country']?.toString() ?? '';
          if (city.isNotEmpty) {
            sehirIlceAdi = country.isNotEmpty ? '$city, $country' : city;
          }
        }
      } catch (_) {}
    }

    lat ??= 41.0082;
    lon ??= 28.9784;

    // 3. Nominatim OpenStreetMap Reverse Geocoding ile tam İl / İlçe adını çöz
    try {
      final revUri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=12&accept-language=tr',
      );
      final revResp = await http.get(revUri).timeout(const Duration(seconds: 5));
      if (revResp.statusCode == 200) {
        final decoded = jsonDecode(revResp.body) as Map<String, dynamic>;
        final addr = decoded['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final ilce = addr['town'] ??
              addr['district'] ??
              addr['suburb'] ??
              addr['municipality'] ??
              addr['county'];
          final il = addr['province'] ?? addr['state'] ?? addr['city'];
          if (ilce != null && il != null && ilce.toString() != il.toString()) {
            sehirIlceAdi = '$ilce, $il';
          } else if (il != null) {
            sehirIlceAdi = il.toString();
          }
        }
      }
    } catch (_) {}

    return koordinatlaVakitleriGetir(
      enlem: lat,
      boylam: lon,
      konumAdi: sehirIlceAdi ?? 'Konum (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})',
      gpsKaynakliMi: true,
    );
  }
}

// Türkiye'nin 81 İli ve Seçkin Dünya / İslam Şehirleri (Gerçek Enlem & Boylam Koordinatlarıyla)
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
  final int kalanGun; // 0: Bugün, >0: X gün kaldı, <0: X gün önce geçti

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
  /// T.C. Diyanet İşleri Başkanlığı Vakit Hesaplama Dairesi Resmi Dini Günler Listesi (2025 - 2027)
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

  /// İçinde bulunduğumuz tarihe (DateTime.now()) göre dini günleri ve kalan gün sayılarını hesaplar.
  /// Önce yaklaşan dini günleri (en yakından uzağa), ardından son geçen dini günleri listeler.
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

    // Yaklaşanlar (0 ile +380 gün arası)
    final yaklasanlar = tumHesaplananlar
        .where((g) => g.kalanGun >= 0 && g.kalanGun <= 380)
        .toList()
      ..sort((a, b) => a.kalanGun.compareTo(b.kalanGun));

    if (sadeceYaklasanlar) {
      return yaklasanlar;
    }

    // İçinde bulunduğumuz yılda yakın zamanda geçmiş olanlar (-180 ile -1 gün arası)
    final gecmisler = tumHesaplananlar
        .where((g) => g.kalanGun < 0 && g.kalanGun >= -180)
        .toList()
      ..sort((a, b) => b.kalanGun.compareTo(a.kalanGun));

    return [...yaklasanlar, ...gecmisler];
  }
}

// ============================================================================
// 3. ŞEHİR / İLÇE ARAMA VE GPS KONUM SEÇİM PENCERESİ (BOTTOM SHEET)
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

  @override
  void dispose() {
    _aramaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dil = widget.dil;
    final filtrelenmis = kTurkiye81IlVeDunyaSehirleri.where((s) {
      if (_filtre.trim().isEmpty) return true;
      final q = _filtre.toLowerCase();
      return s.ad.toLowerCase().contains(q) || s.ulke.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: widget.arkaPlan,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.4)),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.location_searching_rounded, color: widget.vurguAltin),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dil == 'EN'
                      ? 'Select Location or Search City (Diyanet)'
                      : dil == 'AR'
                          ? 'تحديد الموقع أو البحث عن مدينة'
                          : 'Konum Seçimi & Şehir/İlçe Arama (Diyanet)',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: widget.yaziRengi,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // GPS ile Konumumu Bul Butonu
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: widget.vurguAltin,
              foregroundColor: widget.arkaPlan,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.pop(context);
              widget.onGpsKonumBul();
            },
            icon: const Icon(Icons.my_location_rounded, size: 19),
            label: Text(
              dil == 'EN'
                  ? 'Find My Current Location via GPS'
                  : dil == 'AR'
                      ? 'تحديد موقعي الحالي عبر GPS'
                      : 'GPS ile Bulunduğum Konumu Otomatik Bul',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
          ),
          const SizedBox(height: 12),

          // Serbest Şehir / İlçe Arama Kutusu
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _aramaCtrl,
                  onChanged: (v) => setState(() => _filtre = v),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      Navigator.pop(context);
                      widget.onSehirSecildi(v.trim());
                    }
                  },
                  style: TextStyle(color: widget.yaziRengi, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: dil == 'EN'
                        ? 'Type any city or district (e.g. Üsküdar, Konya, London)...'
                        : dil == 'AR'
                            ? 'اكتب اسم أي مدينة أو منطقة...'
                            : 'Herhangi bir il, ilçe veya dünya şehri yazın (Örn: Üsküdar, Selçuklu, Mekke)...',
                    hintStyle: TextStyle(color: widget.ikincilYazi, fontSize: 12.5),
                    prefixIcon: Icon(Icons.search_rounded, color: widget.vurguAltin),
                    filled: true,
                    fillColor: widget.kartRengi,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.vurguAltin,
                  side: BorderSide(color: widget.vurguAltin),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final sorgu = _aramaCtrl.text.trim();
                  if (sorgu.isNotEmpty) {
                    Navigator.pop(context);
                    widget.onSehirSecildi(sorgu);
                  }
                },
                child: Text(
                  dil == 'EN' ? 'Search' : dil == 'AR' ? 'بحث' : 'Ara',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: filtrelenmis.length,
              itemBuilder: (context, i) {
                final s = filtrelenmis[i];
                final kible = NamazVeKonumServisi.kibleAcisiHesapla(s.enlem, s.boylam);
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
                      widget.onSehirSecildi(s.ad);
                    },
                    leading: Icon(Icons.location_city_rounded, color: widget.vurguAltin, size: 19),
                    title: Text(
                      s.ad,
                      style: TextStyle(color: widget.yaziRengi, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${s.ulke}  •  ${s.enlem.toStringAsFixed(2)}°K, ${s.boylam.toStringAsFixed(2)}°D',
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
            ),
          ),
        ],
      ),
    );
  }
}
