import 'dart:math' as math;
import 'package:flutter/material.dart';

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
// 3 DİL ÇEVİRİ SÖZLÜĞÜ (TR / EN / AR)
// ============================================================================

class Ceviri {
  static String m(String dil, String anahtar) {
    return _sozluk[dil]?[anahtar] ?? _sozluk['TR']![anahtar] ?? anahtar;
  }

  static const Map<String, Map<String, String>> _sozluk = {
    'TR': {
      'app_title': 'Vakt-i Huzur',
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
      'drawer_font_title': 'YAZI BOYUTU AYARI (ARAPÇA & TÜRKÇE)',
      'drawer_lang_title': 'DİL SEÇİMİ / LANGUAGE',
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
      'app_title': 'Vakt-i Huzur',
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
      'drawer_lang_title': 'LANGUAGE / DİL SEÇİMİ',
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
      'theme_3_name': '4. Klasik Ottoman Iznik Tile Blue',
      'theme_3_sub': 'Iznik turquoise, cobalt blue & gold',
      'theme_4_name': '5. Minimalist Nur / Beige',
      'theme_4_sub': 'Soft Mushaf parchment beige & deep emerald',
      'theme_5_name': '6. Visual Theme (Mosque & Nature Photos)',
      'theme_5_sub': '24 Curated HD Mosque, Kaaba & Nature backgrounds',
      'search_surah': 'Search among 114 Surahs (e.g., Ya-Sin, Mulk, 36)...',
      'loading_surah': 'Loading all verses of the Surah from the official database...',
      'infinite_badge': 'Infinite Flow • 6,236 Verses & Sahih Hadiths',
    },
    'AR': {
      'app_title': 'Vakt-i Huzur',
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
    if (dil == 'EN') {
      return _reelsEn[id] ?? _reelsTr[id]!;
    } else if (dil == 'AR') {
      return _reelsAr[id] ?? _reelsTr[id]!;
    }
    return _reelsTr[id]!;
  }

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
