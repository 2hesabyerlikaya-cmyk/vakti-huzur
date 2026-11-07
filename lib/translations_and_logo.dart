import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'web_shim_io.dart' if (dart.library.js_interop) 'package:web/web.dart' as web;

class KullaniciProfilServisi {
  static const String _isimKey = 'vakti_huzur_kullanici_rumuz_v1';
  static const String _premiumKey = 'vakti_huzur_kullanici_premium_v1';

  static String? rumuzGetir() {
    try {
      final val = web.window.localStorage.getItem(_isimKey);
      if (val != null && val.trim().isNotEmpty) return val.trim();
    } catch (_) {}
    return null;
  }

  static void rumuzKaydet(String rumuz) {
    try {
      web.window.localStorage.setItem(_isimKey, rumuz.trim());
    } catch (_) {}
  }

  static bool premiumAktifMi() {
    try {
      return web.window.localStorage.getItem(_premiumKey) == 'true';
    } catch (_) {}
    return false;
  }

  static final ValueNotifier<bool> premiumNotifier =
      ValueNotifier<bool>(premiumAktifMi());

  static void premiumAyarla(bool aktif) {
    try {
      web.window.localStorage.setItem(_premiumKey, aktif ? 'true' : 'false');
    } catch (_) {}
    premiumNotifier.value = aktif;
  }
}

// ============================================================================
// ============================================================================
// UYGULAMA TEMA MODELİ
// ============================================================================

class IslamiTema {
  final int id;
  final Color arkaPlan;
  final Color kartRengi;
  final Color vurguAltin;
  final Color yumusakAltin;
  final Color yaziRengi;
  final Color ikincilYazi;
  final bool karanlikMi;
  final bool gorselTemaMi;
  final IconData ikon;

  const IslamiTema({
    required this.id,
    required this.arkaPlan,
    required this.kartRengi,
    required this.vurguAltin,
    required this.yumusakAltin,
    required this.yaziRengi,
    required this.ikincilYazi,
    required this.karanlikMi,
    this.gorselTemaMi = false,
    required this.ikon,
  });
}

typedef ModernTema = IslamiTema;

// MODERN İSLAMİ UYGULAMA LOGOSU (RUB EL HİZB 8 KÖŞELİ YILDIZ & ALTIN HİLAL)
// ============================================================================

class ModernIslamiLogo extends StatelessWidget {
  final double boyut;
  final Color altinRenk;
  final Color arkaPlanRenk;

  const ModernIslamiLogo({
    super.key,
    this.boyut = 36,
    this.altinRenk = const Color(0xFFD4AF37),
    this.arkaPlanRenk = const Color(0xFF0A291E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boyut,
      height: boyut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            arkaPlanRenk,
            Color.lerp(arkaPlanRenk, Colors.black, 0.35) ?? arkaPlanRenk,
          ],
        ),
        borderRadius: BorderRadius.circular(boyut * 0.28),
        border: Border.all(
          color: altinRenk.withValues(alpha: 0.75),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: altinRenk.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _RubElHizbHilalLogoPainter(altinRenk: altinRenk),
      ),
    );
  }
}

class _RubElHizbHilalLogoPainter extends CustomPainter {
  final Color altinRenk;

  _RubElHizbHilalLogoPainter({required this.altinRenk});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.36;

    // 1. Sekiz Köşeli İslami Yıldız (Rub el Hizb - İki Döndürülmüş Kare)
    final yildizPaint = Paint()
      ..color = altinRenk.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeJoin = StrokeJoin.round;

    for (final angleOffset in [0.0, math.pi / 4]) {
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = angleOffset + (i * math.pi / 2) + (math.pi / 4);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, yildizPaint);
    }

    // 2. İç Altın Hilal (İki Dairenin Farkı ile Keskin Zarif Hilal)
    final hilalDisR = size.width * 0.23;
    final hilalIcR = size.width * 0.19;
    final disMerkez = Offset(center.dx - size.width * 0.01, center.dy + size.height * 0.01);
    final icMerkez = Offset(center.dx + size.width * 0.055, center.dy - size.height * 0.045);

    final disDaire = Path()..addOval(Rect.fromCircle(center: disMerkez, radius: hilalDisR));
    final icDaire = Path()..addOval(Rect.fromCircle(center: icMerkez, radius: hilalIcR));
    final hilalPath = Path.combine(PathOperation.difference, disDaire, icDaire);

    final hilalPaint = Paint()
      ..color = altinRenk
      ..style = PaintingStyle.fill;
    canvas.drawPath(hilalPath, hilalPaint);

    // 3. Hilalin Kucağındaki Elmas / Nur Noktası
    final elmasMerkez = Offset(center.dx + size.width * 0.09, center.dy - size.height * 0.08);
    final elmasR = size.width * 0.048;
    final elmasPath = Path()
      ..moveTo(elmasMerkez.dx, elmasMerkez.dy - elmasR)
      ..lineTo(elmasMerkez.dx + elmasR * 0.75, elmasMerkez.dy)
      ..lineTo(elmasMerkez.dx, elmasMerkez.dy + elmasR)
      ..lineTo(elmasMerkez.dx - elmasR * 0.75, elmasMerkez.dy)
      ..close();
    canvas.drawPath(elmasPath, hilalPaint);
  }

  @override
  bool shouldRepaint(covariant _RubElHizbHilalLogoPainter oldDelegate) =>
      oldDelegate.altinRenk != altinRenk;
}

// ============================================================================
// 5 DİL ÇEVİRİ SÖZLÜĞÜ (TR / EN / DE / FR / AR) & OTOMATİK SİSTEM DİLİ ALGILAMA
// ============================================================================

class Ceviri {
  static const String _dilStorageKey = 'vakti_beraat_secili_dil_v1';

  /// Telefonun sistem diline göre (veya kaydedilmiş tercihe göre) başlangıç dilini döndürür
  static String baslangicDiliniBelirle() {
    try {
      final kayitli = web.window.localStorage.getItem(_dilStorageKey);
      if (kayitli != null && _sozluk.containsKey(kayitli)) {
        return kayitli;
      }
    } catch (_) {}
    try {
      final sysCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode.toLowerCase();
      if (sysCode == 'de') return 'DE';
      if (sysCode == 'fr') return 'FR';
      if (sysCode == 'en') return 'EN';
      if (sysCode == 'ar') return 'AR';
      if (sysCode == 'tr') return 'TR';
    } catch (_) {}
    return 'TR';
  }

  /// Seçilen dili kalıcı olarak kaydeder
  static void diliKaydet(String dil) {
    try {
      web.window.localStorage.setItem(_dilStorageKey, dil);
    } catch (_) {}
  }

  /// TR / EN / DE / FR arasında yardımcı çok dilli metin seçici
  static String sec(
    String dil, {
    required String tr,
    required String en,
    String? de,
    String? fr,
    String? ar,
  }) {
    switch (dil) {
      case 'DE':
        return de ?? en;
      case 'FR':
        return fr ?? en;
      case 'EN':
        return en;
      case 'AR':
        return ar ?? en;
      default:
        return tr;
    }
  }

  static String m(String dil, String anahtar) {
    return _sozluk[dil]?[anahtar] ?? _sozluk['EN']?[anahtar] ?? _sozluk['TR']![anahtar] ?? anahtar;
  }

  static const Map<String, Map<String, String>> _sozluk = {
    'TR': {
      'app_title': 'Vakt-i Beraat',
      'app_subtitle': 'Kurumsal İslami Rehber',
      'tab_reels': 'Akış (Reels)',
      'tab_home': 'Ana Sayfa',
      'tab_quiz': 'Quiz',
      'tab_library': 'Kütüphane',
      'flow_title': 'Manevi Akış',
      'short_tafsir': 'Kısa Tefsir ve Hikmeti',
      'swipe_hint': 'Kaydırın',
      'liked_showcase_title': 'Beğenilen Ayet & Hadisler',
      'liked_empty': 'Henüz beğendiğiniz bir ayet veya hadis bulunmuyor. Akış (Reels) ekranında kalp ikonuna dokunarak buraya ekleyebilirsiniz.',
      'saved': 'Kayıtlı',
      'save': 'Kaydet',
      'share': 'Paylaş',
      'copied_msg': 'doğrulama bilgisiyle panoya kopyalandı.',
      'drawer_theme_title': 'ARKA PLAN TEMASI SEÇİMİ',
      'drawer_font_title': 'YAZI BOYUTU AYARI (ARAPÇA & MEAL)',
      'drawer_lang_title': 'DİL SEÇİMİ / LANGUAGE / SPRACHE / LANGUE',
      'drawer_saved': 'Kaydedilenler (Favoriler)',
      'drawer_calendar': 'Dini Günler Takvimi',
      'saved_empty': 'Henüz kaydedilmiş bir ayet veya hadis bulunmuyor.\nAkış sekmesindeki kaydet ikonuna dokunarak ekleyebilirsiniz.',
      'calendar_title': 'Dini Günler ve Geceler Takvimi (1448)',
      'date_banner': '25 Ekim 2026 Pazar  •  14 Cemâziyelevvel 1448',
      'remaining_time': 'Vaktine Kalan Süre',
      'adhan_label': 'Ezanı',
      'diyanet_cal': 'Diyanet Takvimi',
      'next_badge': 'Sıradaki',
      'imsak': 'İmsak',
      'gunes': 'Güneş',
      'ogle': 'Öğle',
      'ikindi': 'İkindi',
      'aksam': 'Akşam',
      'yatsi': 'Yatsı',
      'dua_title': 'Günün Duası',
      'dua_meaning': '“Rabbimiz! Bize dünyada da iyilik ve güzellik ver, ahirette de iyilik ve güzellik ver; bizi ateş azabından koru.”',
      'dua_source': 'Kaynak: T.C. Diyanet İşleri Başkanlığı Meali — Bakara Suresi, 201. Ayet',
      'qibla_title': 'Kıbleyi Bul (Kıble Pusulası)',
      'turn_left': 'Sola Çevir',
      'align_qibla': 'Kıbleye Hizala',
      'turn_right': 'Sağa Çevir',
      'lib_title': 'İslami Kütüphane',
      'tab_quran': 'Kur’an-ı Kerim',
      'tab_hadith': 'Hadis Külliyatı',
      'verse_unit': 'Ayet',
      'mode_list': 'Mealli Liste Görünümü',
      'mode_mushaf': 'Arapça Mushaf (Sayfa) Görünümü',
      'pronunciation': 'Okunuşu',
      'tafsir_note': 'Tefsir Notu',
      'mushaf_footer': 'Resm-i Osmânî Mushaf-ı Şerif Tertibi',
      'theme_0_name': '1. Medine Yeşili & Kubbe',
      'theme_0_sub': 'Ravza-i Mutahhara huzuru ve kubbe yeşili (Varsayılan)',
      'theme_1_name': '2. Kâbe Gece & Altın',
      'theme_1_sub': 'Kisve-i Şerif siyahı ve saf altın işlemeler',
      'theme_2_name': '3. Bordo Yakut & Altın',
      'theme_2_sub': 'Koyu bordo-yakut (#2A121B) ve altın sarısı (#D4AF37)',
      'theme_3_name': '4. Klasik Osmanlı Çini Mavisi',
      'theme_3_sub': 'İznik çinisi turkuazı, çivit mavisi ve altın',
      'theme_4_name': '5. Minimalist Nur / Bej',
      'theme_4_sub': 'Ferah Mushaf kağıdı beji ve koyu zümrüt',
      'theme_5_name': '6. Görsel Tema (Cami & Doğa Fotoğrafları)',
      'theme_5_sub': '24 Seçkin HD Cami, Kâbe ve Doğa fotoğrafı arka planı',
      'search_surah': '114 Sure içinde ara (Örn: Yâsîn, Mülk, 36)...',
      'loading_surah': 'Surenin tüm ayetleri Diyanet & Mushaf veritabanından yükleniyor...',
      'infinite_badge': 'Sonsuz Akış • 6236 Ayet & Sahih Hadis',
    },
    'EN': {
      'app_title': 'Vakt-i Beraat',
      'app_subtitle': 'Official Islamic Guide',
      'tab_reels': 'Spiritual Flow',
      'tab_home': 'Prayer Times',
      'tab_quiz': 'Quiz',
      'tab_library': 'Library',
      'flow_title': 'Spiritual Flow',
      'short_tafsir': 'Brief Commentary & Wisdom',
      'swipe_hint': 'Swipe',
      'liked_showcase_title': 'Liked Verses & Hadiths',
      'liked_empty': 'No liked verses or hadiths yet. Tap the heart icon on any card in the Flow tab to showcase them here.',
      'saved': 'Saved',
      'save': 'Save',
      'share': 'Share',
      'copied_msg': 'copied to clipboard with verified source.',
      'drawer_theme_title': 'BACKGROUND THEME SELECTION',
      'drawer_font_title': 'FONT SIZE (ARABIC & TRANSLATION)',
      'drawer_lang_title': 'LANGUAGE / DİL / SPRACHE / LANGUE',
      'drawer_saved': 'Saved Bookmarks',
      'drawer_calendar': 'Islamic Holy Days Calendar',
      'saved_empty': 'No verses or hadiths bookmarked yet.\nTap the bookmark icon on any card in the Flow tab.',
      'calendar_title': 'Islamic Holy Days & Nights (1448 AH)',
      'date_banner': 'Sunday, 25 October 2026  •  14 Jumada al-Ula 1448',
      'remaining_time': 'Time Remaining Until',
      'adhan_label': 'Adhan',
      'diyanet_cal': 'Presidency of Religious Affairs',
      'next_badge': 'Next',
      'imsak': 'Fajr',
      'gunes': 'Sunrise',
      'ogle': 'Dhuhr',
      'ikindi': 'Asr',
      'aksam': 'Maghrib',
      'yatsi': 'Isha',
      'dua_title': 'Supplication of the Day',
      'dua_meaning': '“Our Lord! Grant us good in this world and good in the Hereafter, and protect us from the torment of the Fire.”',
      'dua_source': 'Source: Presidency of Religious Affairs — Surah Al-Baqarah, Verse 201',
      'qibla_title': 'Qibla Finder (Qibla Compass)',
      'turn_left': 'Rotate Left',
      'align_qibla': 'Align Qibla',
      'turn_right': 'Rotate Right',
      'lib_title': 'Islamic Library',
      'tab_quran': 'The Holy Qur’an',
      'tab_hadith': 'Hadith Corpus',
      'verse_unit': 'Verses',
      'mode_list': 'Translation List View',
      'mode_mushaf': 'Arabic Mushaf (Page) View',
      'pronunciation': 'Transliteration',
      'tafsir_note': 'Commentary Note',
      'mushaf_footer': 'Uthmani Script Mushaf Layout',
      'theme_0_name': '1. Madinah Green & Dome',
      'theme_0_sub': 'Rawdah serenity & green dome tones (Default)',
      'theme_1_name': '2. Kaaba Night & Gold',
      'theme_1_sub': 'Kiswah obsidian black & pure gold embroidery',
      'theme_2_name': '3. Burgundy Ruby & Gold',
      'theme_2_sub': 'Deep burgundy ruby (#2A121B) & royal gold (#D4AF37)',
      'theme_3_name': '4. Classic Ottoman Iznik Tile Blue',
      'theme_3_sub': 'Iznik turquoise, cobalt blue & gold',
      'theme_4_name': '5. Minimalist Nur / Beige',
      'theme_4_sub': 'Soft Mushaf parchment beige & deep emerald',
      'theme_5_name': '6. Visual Theme (Mosque & Nature Photos)',
      'theme_5_sub': '24 Curated HD Mosque, Kaaba & Nature backgrounds',
      'search_surah': 'Search among 114 Surahs (e.g., Ya-Sin, Mulk, 36)...',
      'loading_surah': 'Loading all verses of the Surah from the official database...',
      'infinite_badge': 'Infinite Flow • 6,236 Verses & Sahih Hadiths',
    },
    'DE': {
      'app_title': 'Vakt-i Beraat',
      'app_subtitle': 'Islamischer Gebets- & Koranführer',
      'tab_reels': 'Spiritueller Feed',
      'tab_home': 'Gebetszeiten',
      'tab_quiz': 'Quiz',
      'tab_library': 'Bibliothek',
      'flow_title': 'Spiritueller Feed',
      'short_tafsir': 'Kurzer Kommentar & Weisheit',
      'swipe_hint': 'Wischen',
      'liked_showcase_title': 'Geliebte Verse & Hadithe',
      'liked_empty': 'Noch keine markierten Verse oder Hadithe. Tippen Sie im Feed auf das Herz-Symbol, um sie hier zu speichern.',
      'saved': 'Gespeichert',
      'save': 'Speichern',
      'share': 'Teilen',
      'copied_msg': 'mit verifizierter Quelle in die Zwischenablage kopiert.',
      'drawer_theme_title': 'HINTERGRUND-THEMA AUSWÄHLEN',
      'drawer_font_title': 'SCHRIFTGRÖSSE (ARABISCH & ÜBERSETZUNG)',
      'drawer_lang_title': 'SPRACHE / LANGUAGE / DİL SEÇİMİ',
      'drawer_saved': 'Gespeicherte Favoriten',
      'drawer_calendar': 'Islamischer Festtagskalender',
      'saved_empty': 'Noch keine Verse oder Hadithe gespeichert.\nTippen Sie auf das Lesezeichen-Symbol im Feed.',
      'calendar_title': 'Islamische Festtage & Nächte (1448 n.H.)',
      'date_banner': 'Sonntag, 25. Oktober 2026  •  14. Dschumada al-Ula 1448',
      'remaining_time': 'Verbleibende Zeit bis',
      'adhan_label': 'Adhan',
      'diyanet_cal': 'Diyanet Gebetskalender',
      'next_badge': 'Nächstes',
      'imsak': 'Fadschr',
      'gunes': 'Sonnenaufgang',
      'ogle': 'Dhuhr',
      'ikindi': 'Assr',
      'aksam': 'Maghrib',
      'yatsi': 'Ischa',
      'dua_title': 'Bittgebet des Tages',
      'dua_meaning': '„Unser Herr, gib uns im Diesseits Gutes und im Jenseits Gutes und bewahre uns vor der Strafe des Höllenfeuers.“',
      'dua_source': 'Quelle: Koranübersetzung Bubenheim & Elyas — Sure Al-Baqara, Vers 201',
      'qibla_title': 'Qibla-Finder (Qibla-Kompass)',
      'turn_left': 'Nach links drehen',
      'align_qibla': 'Zur Qibla ausrichten',
      'turn_right': 'Nach rechts drehen',
      'lib_title': 'Islamische Bibliothek',
      'tab_quran': 'Der Edle Koran',
      'tab_hadith': 'Hadith-Sammlung',
      'verse_unit': 'Verse',
      'mode_list': 'Übersetzungs-Listenansicht',
      'mode_mushaf': 'Arabische Mushaf-Seitenansicht',
      'pronunciation': 'Aussprache',
      'tafsir_note': 'Tafsir-Hinweis',
      'mushaf_footer': 'Uthmanische Mushaf-Schreibweise',
      'theme_0_name': '1. Medina-Grün & Kuppel',
      'theme_0_sub': 'Ruhe der Rawdah & grüne Kuppel-Töne (Standard)',
      'theme_1_name': '2. Kaaba-Nacht & Gold',
      'theme_1_sub': 'Kiswah-Schwarz & reine Goldstickerei',
      'theme_2_name': '3. Burgunder-Rubin & Gold',
      'theme_2_sub': 'Tiefes Rubinrot (#2A121B) & Königsgold (#D4AF37)',
      'theme_3_name': '4. Klassisches Osmanisches Iznik-Blau',
      'theme_3_sub': 'Iznik-Türkis, Kobaltblau & Gold',
      'theme_4_name': '5. Minimalistisches Nur / Beige',
      'theme_4_sub': 'Sanftes Mushaf-Pergamentbeige & Smaragdgrün',
      'theme_5_name': '6. Fotothema (Moschee- & Naturfotos)',
      'theme_5_sub': '24 ausgewählte HD-Moschee-, Kaaba- & Naturhintergründe',
      'search_surah': 'Unter 114 Suren suchen (z.B. Ya-Sin, Mulk, 36)...',
      'loading_surah': 'Alle Verse der Sure werden geladen (Bubenheim & Elyas)...',
      'infinite_badge': 'Unendlicher Feed • 6.236 Verse & Sahih Hadithe',
    },
    'FR': {
      'app_title': 'Vakt-i Beraat',
      'app_subtitle': 'Guide Islamique & Horaires de Prière',
      'tab_reels': 'Flux Spirituel',
      'tab_home': 'Heures de Prière',
      'tab_quiz': 'Quiz',
      'tab_library': 'Bibliothèque',
      'flow_title': 'Flux Spirituel',
      'short_tafsir': 'Bref Commentaire & Sagesse',
      'swipe_hint': 'Glisser',
      'liked_showcase_title': 'Versets & Hadiths Aimés',
      'liked_empty': 'Aucun verset ou hadith aimé pour le moment. Appuyez sur l’icône cœur dans le flux pour les ajouter ici.',
      'saved': 'Enregistré',
      'save': 'Enregistrer',
      'share': 'Partager',
      'copied_msg': 'copié dans le presse-papiers avec sa source vérifiée.',
      'drawer_theme_title': 'CHOIX DU THÈME D’ARRIÈRE-PLAN',
      'drawer_font_title': 'TAILLE DE POLICE (ARABE & TRADUCTION)',
      'drawer_lang_title': 'LANGUE / LANGUAGE / SPRACHE / DİL',
      'drawer_saved': 'Favoris Enregistrés',
      'drawer_calendar': 'Calendrier des Jours Saints Islamiques',
      'saved_empty': 'Aucun verset ou hadith enregistré pour le moment.\nAppuyez sur l’icône de signet dans le flux.',
      'calendar_title': 'Jours et Nuits Bénis de l’Islam (1448 H)',
      'date_banner': 'Dimanche 25 Octobre 2026  •  14 Joumada al-Oula 1448',
      'remaining_time': 'Temps Restant Avant',
      'adhan_label': 'Adhan',
      'diyanet_cal': 'Calendrier Officiel Diyanet',
      'next_badge': 'Suivante',
      'imsak': 'Fajr',
      'gunes': 'Lever',
      'ogle': 'Dhuhr',
      'ikindi': 'Asr',
      'aksam': 'Maghrib',
      'yatsi': 'Isha',
      'dua_title': 'Invocation du Jour',
      'dua_meaning': '« Seigneur ! Accorde-nous belle part ici-bas, et belle part aussi dans l’au-delà ; et protège-nous du châtiment du Feu ! »',
      'dua_source': 'Source : Traduction Muhammad Hamidullah — Sourate Al-Baqarah, Verset 201',
      'qibla_title': 'Boussole Qibla (Direction de la Mecque)',
      'turn_left': 'Tourner à gauche',
      'align_qibla': 'Aligner sur la Qibla',
      'turn_right': 'Tourner à droite',
      'lib_title': 'Bibliothèque Islamique',
      'tab_quran': 'Le Saint Coran',
      'tab_hadith': 'Corpus de Hadiths',
      'verse_unit': 'Versets',
      'mode_list': 'Vue Liste avec Traduction',
      'mode_mushaf': 'Vue Page du Moushaf Arabe',
      'pronunciation': 'Phonétique',
      'tafsir_note': 'Note de Tafsir',
      'mushaf_footer': 'Moushaf en Graphie Othmanienne',
      'theme_0_name': '1. Vert de Médine & Dôme',
      'theme_0_sub': 'Sérénité de la Rawdah et tons du Dôme Vert (Défaut)',
      'theme_1_name': '2. Nuit de la Kaaba & Or',
      'theme_1_sub': 'Noir de la Kiswah et broderies d’or pur',
      'theme_2_name': '3. Rubis Bordeaux & Or',
      'theme_2_sub': 'Bordeaux profond (#2A121B) et or royal (#D4AF37)',
      'theme_3_name': '4. Bleu Faïence Ottomane d’Iznik',
      'theme_3_sub': 'Turquoise d’Iznik, bleu cobalt et or',
      'theme_4_name': '5. Minimaliste Nour / Beige',
      'theme_4_sub': 'Beige parchemin du Moushaf et émeraude foncé',
      'theme_5_name': '6. Thème Visuel (Photos Mosquées & Nature)',
      'theme_5_sub': '24 Arrière-plans HD de mosquées, de la Kaaba et de la nature',
      'search_surah': 'Rechercher parmi les 114 Sourates (ex: Ya-Sin, Mulk, 36)...',
      'loading_surah': 'Chargement des versets de la Sourate (Traduction Hamidullah)...',
      'infinite_badge': 'Flux Infini • 6 236 Versets & Hadiths Sahih',
    },
    'AR': {
      'app_title': 'Vakt-i Beraat',
      'app_subtitle': 'الدليل الإسلامي المعتمد',
      'tab_reels': 'نفحات إيمانية',
      'tab_home': 'الرئيسية',
      'tab_quiz': 'المسابقة',
      'tab_library': 'المكتبة الإسلامية',
      'flow_title': 'نفحات إيمانية',
      'short_tafsir': 'التفسير المختصر والحكمة',
      'swipe_hint': 'اسحب',
      'liked_showcase_title': 'الآيات والأحاديث المعجب بها',
      'liked_empty': 'لم تقم بالإعجاب بأي آية أو حديث بعد.',
      'saved': 'محفوظ',
      'save': 'حفظ',
      'share': 'مشاركة',
      'copied_msg': 'تم النسخ إلى الحافظة مع المصدر الموثق.',
      'drawer_theme_title': 'اختيار السمة والخلفية',
      'drawer_font_title': 'حجم الخط (العربية والترجمة)',
      'drawer_lang_title': 'اللغة / LANGUAGE',
      'drawer_saved': 'المحفوظات (المفضلة)',
      'drawer_calendar': 'تقويم المناسبات الإسلامية',
      'saved_empty': 'لا توجد آيات أو أحاديث محفوظة حتى الآن.',
      'calendar_title': 'تقويم الأيام والليالي المباركة (١٤٤٨ هـ)',
      'date_banner': 'الأحد ٢٥ أكتوبر ٢٠٢٦ م  •  ١٤ جمادى الأولى ١٤٤٨ هـ',
      'remaining_time': 'الوقت المتبقي لصلاة',
      'adhan_label': 'أذان',
      'diyanet_cal': 'تقويم الشؤون الدينية',
      'next_badge': 'القادمة',
      'imsak': 'الفجر',
      'gunes': 'الشروق',
      'ogle': 'الظهر',
      'ikindi': 'العصر',
      'aksam': 'المغرب',
      'yatsi': 'العشاء',
      'dua_title': 'دعاء اليوم',
      'dua_meaning': '«رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ» — نسأل الله خيري الدنيا والآخرة والنجاة من النار.',
      'dua_source': 'المصدر: القرآن الكريم — سورة البقرة، الآية ٢٠١',
      'qibla_title': 'اتجاه القبلة (بوصلة القبلة)',
      'turn_left': 'تدوير لليسار',
      'align_qibla': 'محاذاة القبلة',
      'turn_right': 'تدوير لليمين',
      'lib_title': 'المكتبة الإسلامية',
      'tab_quran': 'القرآن الكريم',
      'tab_hadith': 'موسوعة الحديث',
      'verse_unit': 'آية',
      'mode_list': 'عرض القائمة والتفسير',
      'mode_mushaf': 'عرض صفحة المصحف الشريف',
      'pronunciation': 'النطق',
      'tafsir_note': 'لطيفة تفسيرية',
      'mushaf_footer': 'مصحف المدينة المنورة بالرسم العثماني',
      'theme_0_name': '١. رحاب المدينة والقبة الخضراء',
      'theme_0_sub': 'سكينة الروضة الشريفة وألوان القبة (الافتراضي)',
      'theme_1_name': '٢. ليل الكعبة المشرفة والذهب',
      'theme_1_sub': 'سواد كسوة الكعبة وتطريز الذهب الخالص',
      'theme_2_name': '٣. الياقوت العنابي والذهب',
      'theme_2_sub': 'العنابي الداكن الفاخر مع زخارف الذهب',
      'theme_3_name': '٤. الخزف العثماني الأزرق',
      'theme_3_sub': 'فيروز إزنيق والأزرق الملكي والذهب',
      'theme_4_name': '٥. نور وورق المصحف الكريم',
      'theme_4_sub': 'خلفية ورقية هادئة مع الزمرد الداكن',
      'theme_5_name': '٦. السمة المصورة (صور المساجد والطبيعة)',
      'theme_5_sub': '٢٤ خلفية عالية الدقة للمساجد والكعبة والطبيعة',
      'search_surah': 'ابحث في ١١٤ سورة (مثال: يس، الملك، ٣٦)...',
      'loading_surah': 'جاري تحميل جميع آيات السورة من قاعدة البيانات المعتمدة...',
      'infinite_badge': 'تدفق لا نهائي • ٦٢٣٦ آية وأحاديث صحيحة',
    },
  };

  /// Reels kartlarını seçili dile göre döndürür
  static Map<String, String> reelsMetin(String dil, String id) {
    if (dil == 'DE') {
      return _reelsDe[id] ?? _reelsEn[id] ?? _reelsTr[id]!;
    } else if (dil == 'FR') {
      return _reelsFr[id] ?? _reelsEn[id] ?? _reelsTr[id]!;
    } else if (dil == 'EN') {
      return _reelsEn[id] ?? _reelsTr[id]!;
    } else if (dil == 'AR') {
      return _reelsAr[id] ?? _reelsTr[id]!;
    }
    return _reelsTr[id]!;
  }

  static const Map<String, Map<String, String>> _reelsDe = {
    '1': {
      'tur': 'Edler Koranvers',
      'konu': 'Hilfe suchen durch Geduld & Gebet',
      'meal': '„O die ihr glaubt, sucht Hilfe in der Geduld und im Gebet! Gewiss, Allah ist mit den Standhaften.“',
      'kaynakKisa': 'Sure Al-Baqara, Vers 153',
      'dogrulanmis': 'Verifizierte Quelle: Bubenheim & Elyas Koranübersetzung • Al-Baqara 2:153',
      'tefsir': 'Geduld bewahrt die Standhaftigkeit des Herzens, während das Gebet den Gläubigen direkt mit seinem Herrn verbindet.',
    },
    '2': {
      'tur': 'Prophetischer Hadith',
      'konu': 'Der Wert der Absichten & Aufrichtigkeit',
      'meal': '„Die Taten sind entsprechend den Absichten, und jedem Menschen gebührt nur das, was er beabsichtigt hat.“',
      'kaynakKisa': 'Sahih al-Buchari, Offenbarung 1',
      'dogrulanmis': 'Verifizierte Quelle: Sahih al-Buchari, Buch der Offenbarung, Kap. 1 — Hadith Nr. 1',
      'tefsir': 'Der Wert jeder guten Tat bei Allah hängt von der aufrichtigen Absicht im Herzen ab.',
    },
    '3': {
      'tur': 'Edler Koranvers',
      'konu': 'Mit der Erschwernis kommt die Erleichterung',
      'meal': '„Denn gewiss, mit der Erschwernis ist Erleichterung. Gewiss, mit der Erschwernis ist Erleichterung.“',
      'kaynakKisa': 'Sure Asch-Scharh, Verse 5-6',
      'dogrulanmis': 'Verifizierte Quelle: Bubenheim & Elyas Koranübersetzung • Asch-Scharh 94:5-6',
      'tefsir': 'In jeder Prüfung liegt bereits eine göttliche Tür der Erleichterung verborgen.',
    },
    '4': {
      'tur': 'Prophetischer Hadith',
      'konu': 'Reinheit des Herzens & rechtschaffene Taten',
      'meal': '„Gewiss, Allah schaut nicht auf euer Äußeres und euren Besitz, sondern Er schaut auf eure Herzen und eure Taten.“',
      'kaynakKisa': 'Sahih Muslim, Birr 34',
      'dogrulanmis': 'Verifizierte Quelle: Sahih Muslim, Buch der Güte, Kap. 10 — Hadith Nr. 2564',
      'tefsir': 'Was den Menschen vor Allah erhöht, ist ein barmherziges, aufrichtiges Herz und rechtschaffenes Handeln.',
    },
    '5': {
      'tur': 'Edler Koranvers',
      'konu': 'Ruhe der Herzen im Gedenken Allahs',
      'meal': '„Wahrlich, im Gedenken Allahs finden die Herzen Ruhe!“',
      'kaynakKisa': 'Sure Ar-Ra’d, Vers 28',
      'dogrulanmis': 'Verifizierte Quelle: Bubenheim & Elyas Koranübersetzung • Ar-Ra’d 13:28',
      'tefsir': 'Die menschliche Seele findet wahren inneren Frieden nur in der Erinnerung an ihren Schöpfer.',
    },
    '6': {
      'tur': 'Prophetischer Hadith',
      'konu': 'Erleichtert und erschwert nicht',
      'meal': '„Erleichtert und erschwert nicht; verkündet frohe Botschaft und schreckt nicht ab.“',
      'kaynakKisa': 'Sahih al-Buchari, Wissen 11',
      'dogrulanmis': 'Verifizierte Quelle: Sahih al-Buchari, Buch des Wissens, Kap. 11 — Hadith Nr. 69',
      'tefsir': 'Dieser Hadith erinnert daran, dass der Islam eine Religion der Barmherzigkeit, Güte und Hoffnung ist.',
    },
  };

  static const Map<String, Map<String, String>> _reelsFr = {
    '1': {
      'tur': 'Noble Verset',
      'konu': 'Chercher secours par la patience et la prière',
      'meal': '« Ô vous qui avez cru ! Cherchez secours dans l’endurance et la prière, car Allah est avec les endurants. »',
      'kaynakKisa': 'Sourate Al-Baqarah, Verset 153',
      'dogrulanmis': 'Source vérifiée : Traduction Muhammad Hamidullah • Al-Baqarah 2:153',
      'tefsir': 'La patience préserve la force du cœur, tandis que la prière relie directement le croyant à son Seigneur.',
    },
    '2': {
      'tur': 'Hadith Prophétique',
      'konu': 'La valeur des intentions et la sincérité',
      'meal': '« Les actes ne valent que par les intentions, et chacun n’a pour lui que ce qu’il a eu réellement l’intention de faire. »',
      'kaynakKisa': 'Sahih al-Boukhari, Révélation 1',
      'dogrulanmis': 'Source vérifiée : Sahih al-Boukhari, Livre de la Révélation, Ch. 1 — Hadith n° 1',
      'tefsir': 'La valeur spirituelle de toute bonne action auprès d’Allah dépend de la sincérité du cœur.',
    },
    '3': {
      'tur': 'Noble Verset',
      'konu': 'La facilité accompagne la difficulté',
      'meal': '« À côté de la difficulté est, certes, une facilité ! À côté de la difficulté est, certes, une facilité ! »',
      'kaynakKisa': 'Sourate Ach-Charh, Versets 5-6',
      'dogrulanmis': 'Source vérifiée : Traduction Muhammad Hamidullah • Ach-Charh 94:5-6',
      'tefsir': 'Au cœur de chaque épreuve se cache une porte divine de soulagement et de miséricorde.',
    },
    '4': {
      'tur': 'Hadith Prophétique',
      'konu': 'La pureté du cœur et les bonnes œuvres',
      'meal': '« Certes, Allah ne regarde ni votre apparence ni vos biens, mais Il regarde vos cœurs et vos œuvres. »',
      'kaynakKisa': 'Sahih Mouslim, Birr 34',
      'dogrulanmis': 'Source vérifiée : Sahih Mouslim, Livre de la Piété, Ch. 10 — Hadith n° 2564',
      'tefsir': 'Ce qui élève l’être humain auprès d’Allah est un cœur sincère, miséricordieux et des actes pieux.',
    },
    '5': {
      'tur': 'Noble Verset',
      'konu': 'L’apaisement des cœurs par le rappel d’Allah',
      'meal': '« N’est-ce point par l’évocation d’Allah que se tranquillisent les cœurs ? »',
      'kaynakKisa': 'Sourate Ar-Ra’d, Verset 28',
      'dogrulanmis': 'Source vérifiée : Traduction Muhammad Hamidullah • Ar-Ra’d 13:28',
      'tefsir': 'L’âme humaine ne trouve la véritable paix intérieure que dans le souvenir et la confiance en son Créateur.',
    },
    '6': {
      'tur': 'Hadith Prophétique',
      'konu': 'Facilitez et ne rendez pas les choses difficiles',
      'meal': '« Facilitez et ne rendez pas les choses difficiles ; annoncez la bonne nouvelle et ne faites pas fuir les gens. »',
      'kaynakKisa': 'Sahih al-Boukhari, Science 11',
      'dogrulanmis': 'Source vérifiée : Sahih al-Boukhari, Livre de la Science, Ch. 11 — Hadith n° 69',
      'tefsir': 'Ce hadith rappelle que l’Islam est une religion de miséricorde, de douceur et d’espérance.',
    },
  };

  static const Map<String, Map<String, String>> _reelsTr = {
    '1': {
      'tur': 'Ayet-i Kerime',
      'konu': 'Sabır ve Namazla Yardım İsteme',
      'meal': '“Ey iman edenler! Sabır ve namaz ile Allah’tan yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.”',
      'kaynakKisa': 'Bakara Suresi, 153. Ayet',
      'dogrulanmis': 'Doğrulanmış Kaynak: T.C. Diyanet İşleri Başkanlığı Kur’an-ı Kerim Meali • Bakara 2/153',
      'tefsir': 'Sabır kalbin direncini korurken, namaz kulu doğrudan Rabbine bağlayan en güçlü sığınaktır. Allah’ın sabredenlerle beraber olması, onlara sekînet ve yardım lütfetmesidir.',
    },
    '2': {
      'tur': 'Hadis-i Şerif',
      'konu': 'Niyetlerin Değeri ve İhlas',
      'meal': '“Ameller niyetlere göredir. Herkese ancak niyet ettiği şey vardır.”',
      'kaynakKisa': 'Sahîh-i Buhârî, Bed’ü’l-Vahy 1',
      'dogrulanmis': 'Doğrulanmış Kaynak: Sahîh-i Buhârî, Kitâbü Bed’i’l-Vahy, Bab 1 — Hadis No: 1',
      'tefsir': 'Yapılan her güzel işin Allah katındaki değeri kalpteki halis niyete bağlıdır. Sıradan bir günlük iş bile samimi bir niyetle ibadete dönüşebilir.',
    },
    '3': {
      'tur': 'Ayet-i Kerime',
      'konu': 'Zorlukla Beraber Gelen Kolaylık',
      'meal': '“Şüphesiz güçlükle beraber bir kolaylık vardır. Gerçekten, güçlükle beraber bir kolaylık vardır.”',
      'kaynakKisa': 'İnşirah Suresi, 5-6. Ayetler',
      'dogrulanmis': 'Doğrulanmış Kaynak: T.C. Diyanet İşleri Başkanlığı Kur’an-ı Kerim Meali • İnşirah 94/5-6',
      'tefsir': 'Ayet-i kerimede “zorluktan sonra” değil, “zorlukla beraber” ifadesi kullanılmıştır. Her darlığın bağrında Allah’ın lütfettiği bir ferahlık kapısı gizlidir.',
    },
    '4': {
      'tur': 'Hadis-i Şerif',
      'konu': 'Allah’ın Kuluna Bakışı ve Kalp Temizliği',
      'meal': '“Şüphesiz Allah sizin suretlerinize ve mallarınıza bakmaz; fakat kalplerinize ve amellerinize bakar.”',
      'kaynakKisa': 'Sahîh-i Müslim, Birr 34',
      'dogrulanmis': 'Doğrulanmış Kaynak: Sahîh-i Müslim, Kitâbü’l-Birr ve’s-Sıla, Bab 10 — Hadis No: 2564',
      'tefsir': 'Dünyevi statü veya servet üstünlük ölçüsü değildir. İnsanı yücelten şey; merhamet, takva ve samimiyetle dolu bir kalp ile salih amellerdir.',
    },
    '5': {
      'tur': 'Ayet-i Kerime',
      'konu': 'Kalplerin Huzur Bulması',
      'meal': '“Biliniz ki, kalpler ancak Allah’ı anmakla (zikirle) huzur bulur.”',
      'kaynakKisa': 'Ra’d Suresi, 28. Ayet',
      'dogrulanmis': 'Doğrulanmış Kaynak: T.C. Diyanet İşleri Başkanlığı Kur’an-ı Kerim Meali • Ra’d 13/28',
      'tefsir': 'İnsan ruhu sonsuzluk için yaratılmıştır. Kalbin içsel huzursuzluğu, ancak Yaratıcısını tanıması, O’nu anması ve O’na güvenmesiyle gerçek sekînete kavuşur.',
    },
    '6': {
      'tur': 'Hadis-i Şerif',
      'konu': 'Kolaylaştırınız, Zorlaştırmayınız',
      'meal': '“Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.”',
      'kaynakKisa': 'Sahîh-i Buhârî, İlim 11',
      'dogrulanmis': 'Doğrulanmış Kaynak: Sahîh-i Buhârî, Kitâbü’l-İlim, Bab 11 — Hadis No: 69',
      'tefsir': 'Peygamber Efendimiz’in (s.a.v.) davet metodunu özetleyen bu hadis, İslam’ın rahmet dini olduğunu hatırlatır. İnsanlara karşı şefkatli ve ümit verici olmak esastır.',
    },
  };

  static const Map<String, Map<String, String>> _reelsEn = {
    '1': {
      'tur': 'Holy Verse',
      'konu': 'Seeking Help Through Patience & Prayer',
      'meal': '“O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.”',
      'kaynakKisa': 'Surah Al-Baqarah, Verse 153',
      'dogrulanmis': 'Verified Source: Presidency of Religious Affairs Qur’an Translation • Al-Baqarah 2:153',
      'tefsir': 'Patience preserves the resilience of the heart, while prayer is the strongest sanctuary connecting the believer directly to the Creator.',
    },
    '2': {
      'tur': 'Prophetic Hadith',
      'konu': 'The Value of Intentions & Sincerity',
      'meal': '“Actions are judged only by intentions, and every person shall have only what they intended.”',
      'kaynakKisa': 'Sahih al-Bukhari, Revelation 1',
      'dogrulanmis': 'Verified Source: Sahih al-Bukhari, Book of Revelation, Ch. 1 — Hadith No: 1',
      'tefsir': 'The spiritual worth of every good deed depends on the sincere intention in the heart. Even daily work becomes worship through pure intention.',
    },
    '3': {
      'tur': 'Holy Verse',
      'konu': 'Ease Accompanying Every Hardship',
      'meal': '“For indeed, with hardship comes ease. Indeed, with hardship comes ease.”',
      'kaynakKisa': 'Surah Ash-Sharh, Verses 5-6',
      'dogrulanmis': 'Verified Source: Presidency of Religious Affairs Qur’an Translation • Ash-Sharh 94:5-6',
      'tefsir': 'The verse states “with hardship” rather than merely “after hardship” — teaching that within every trial lies a divine door of relief.',
    },
    '4': {
      'tur': 'Prophetic Hadith',
      'konu': 'Purity of Heart & Righteous Deeds',
      'meal': '“Indeed, Allah does not look at your outward appearance or your wealth, but He looks at your hearts and your deeds.”',
      'kaynakKisa': 'Sahih Muslim, Birr 34',
      'dogrulanmis': 'Verified Source: Sahih Muslim, Book of Virtue, Ch. 10 — Hadith No: 2564',
      'tefsir': 'Worldly status or wealth is never a measure of superiority before Allah. What elevates a person is a compassionate, sincere heart and righteous action.',
    },
    '5': {
      'tur': 'Holy Verse',
      'konu': 'Tranquility of the Hearts',
      'meal': '“Unquestionably, by the remembrance of Allah do hearts find rest and tranquility.”',
      'kaynakKisa': 'Surah Ar-Ra’d, Verse 28',
      'dogrulanmis': 'Verified Source: Presidency of Religious Affairs Qur’an Translation • Ar-Ra’d 13:28',
      'tefsir': 'The human soul was created for eternity; inner restlessness finds true peace only in remembering and trusting its Creator.',
    },
    '6': {
      'tur': 'Prophetic Hadith',
      'konu': 'Make Things Easy, Give Glad Tidings',
      'meal': '“Make things easy and do not make them difficult; give glad tidings and do not drive people away.”',
      'kaynakKisa': 'Sahih al-Bukhari, Knowledge 11',
      'dogrulanmis': 'Verified Source: Sahih al-Bukhari, Book of Knowledge, Ch. 11 — Hadith No: 69',
      'tefsir': 'Summarizing the prophetic way of guidance, this hadith reminds us that Islam is a religion of mercy, gentleness, and hope.',
    },
  };

  static const Map<String, Map<String, String>> _reelsAr = {
    '1': {
      'tur': 'آية كريمة',
      'konu': 'الاستعانة بالصبر والصلاة',
      'meal': '﴿يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ﴾',
      'kaynakKisa': 'سورة البقرة، الآية ١٥٣',
      'dogrulanmis': 'المصدر الموثق: المصحف الشريف وتفسير رئاسة الشؤون الدينية • البقرة ٢/١٥٣',
      'tefsir': 'الصبر يحفظ ثبات القلب، والصلاة صلة روحية متينة تربط العبد بربه، ومعية الله للصابرين معية نصر وتأييد وسكينة.',
    },
    '2': {
      'tur': 'حديث شريف',
      'konu': 'قيمة النيات والإخلاص',
      'meal': '«إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى»',
      'kaynakKisa': 'صحيح البخاري، بدء الوحي ١',
      'dogrulanmis': 'المصدر الموثق: صحيح البخاري، كتاب بدء الوحي، باب ١ — حديث رقم: ١',
      'tefsir': 'مدار قبول الأعمال وصلاحها عند الله تعالى إنما هو على النية الخالصة في القلب، فبالنية الصالحة تنقلب العادات إلى عبادات.',
    },
    '3': {
      'tur': 'آية كريمة',
      'konu': 'مع العسر يسراً',
      'meal': '﴿فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾',
      'kaynakKisa': 'سورة الشرح، الآيتان ٥-٦',
      'dogrulanmis': 'المصدر الموثق: المصحف الشريف وتفسير رئاسة الشؤون الدينية • الشرح ٩٤/٥-٦',
      'tefsir': 'وعد إلهي صادق بأن الفرج والتيسير مقترنان بالشدة، ولن يغلب عسرٌ يسرين أبداً لمن توكل على الله.',
    },
    '4': {
      'tur': 'حديث شريف',
      'konu': 'نظر الله إلى القلوب والأعمال',
      'meal': '«إِنَّ اللَّهَ لَا يَنْظُرُ إِلَى صُوَرِكُمْ وَأَمْوَالِكُمْ، وَلَكِنْ يَنْظُرُ إِلَى قُلُوبِكُمْ وَأَعْمَالِكُمْ»',
      'kaynakKisa': 'صحيح مسلم، البر ٣٤',
      'dogrulanmis': 'المصدر الموثق: صحيح مسلم، كتاب البر والصلة، باب ١٠ — حديث رقم: ٢٥٦٤',
      'tefsir': 'الميزان الحقيقي عند الله تعالى هو نقاء القلب وتقواه وصلاح العمل، لا المظاهر الدنيوية الزائلة.',
    },
    '5': {
      'tur': 'آية كريمة',
      'konu': 'طمأنينة القلوب بذكر الله',
      'meal': '﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾',
      'kaynakKisa': 'سورة الرعد، الآية ٢٨',
      'dogrulanmis': 'المصدر الموثق: المصحف الشريف وتفسير رئاسة الشؤون الدينية • الرعد ١٣/٢٨',
      'tefsir': 'لا تسكن الروح ولا يزول قلقها إلا بمعرفة خالقها وذكره والأنس بقربه سبحانه.',
    },
    '6': {
      'tur': 'حديث شريف',
      'konu': 'التيسير والتبشير في الدين',
      'meal': '«يَسِّرُوا وَلَا تُعَسِّرُوا، وَبَشِّرُوا وَلَا تُنَفِّرُوا»',
      'kaynakKisa': 'صحيح البخاري، العلم ١١',
      'dogrulanmis': 'المصدر الموثق: صحيح البخاري، كتاب العلم، باب ١١ — حديث رقم: ٦٩',
      'tefsir': 'منهج النبوة قائم على الرحمة والرفق والتيسير على الناس وفتح أبواب الرجاء والأمل.',
    },
  };
}
