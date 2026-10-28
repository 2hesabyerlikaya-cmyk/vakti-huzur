import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'prayer_location_calendar_service.dart';
import 'quran_hadith_data.dart';
import 'zikirmatik_ve_esmaul_husna.dart';
import 'web_shim_io.dart' if (dart.library.js_interop) 'package:web/web.dart' as web;

// ============================================================================
// VAKT-İ HUZUR — ANDROID (SAMSUNG VB.) & iOS ANA EKRAN / KİLİT EKRANI WİDGET SERVİSİ
// 5 AYRI WİDGET DESTEĞİ:
// 1. Günün Ayeti
// 2. Günün Hadisi
// 3. Sıradaki Namaz
// 4. 6 Vakit Çizelgesi
// 5. Günlük Zikir
// ============================================================================

class GunlukWidgetAyetModel {
  final String arapca;
  final String mealTr;
  final String mealEn;
  final String kaynakTr;
  final String kaynakEn;

  const GunlukWidgetAyetModel({
    required this.arapca,
    required this.mealTr,
    required this.mealEn,
    required this.kaynakTr,
    required this.kaynakEn,
  });
}

const List<GunlukWidgetAyetModel> kSecmeWidgetAyetleri = [
  GunlukWidgetAyetModel(
    arapca: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    mealTr: '“Biliniz ki, kalpler ancak Allah’ı anmakla (zikirle) huzur bulur.”',
    mealEn: '“Unquestionably, by the remembrance of Allah do hearts find rest.”',
    kaynakTr: 'Ra’d Suresi, 28. Ayet',
    kaynakEn: 'Surah Ar-Ra’d, 28',
  ),
  GunlukWidgetAyetModel(
    arapca: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    mealTr: '“Şüphesiz güçlükle beraber bir kolaylık vardır. Gerçekten, güçlükle beraber bir kolaylık vardır.”',
    mealEn: '“For indeed, with hardship comes ease. Indeed, with hardship comes ease.”',
    kaynakTr: 'İnşirah Suresi, 5-6. Ayetler',
    kaynakEn: 'Surah Ash-Sharh, 5-6',
  ),
  GunlukWidgetAyetModel(
    arapca: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    mealTr: '“Ey iman edenler! Sabır ve namaz ile Allah’tan yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.”',
    mealEn: '“O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.”',
    kaynakTr: 'Bakara Suresi, 153. Ayet',
    kaynakEn: 'Surah Al-Baqarah, 153',
  ),
  GunlukWidgetAyetModel(
    arapca: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
    mealTr: '“Allah hiçbir kimseye gücünün yettiğinden başkasını yüklemez.”',
    mealEn: '“Allah does not charge a soul except within its capacity.”',
    kaynakTr: 'Bakara Suresi, 286. Ayet',
    kaynakEn: 'Surah Al-Baqarah, 286',
  ),
  GunlukWidgetAyetModel(
    arapca: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ',
    mealTr: '“Kullarım beni senden sorarlarsa, bilsinler ki gerçekten ben onlara çok yakınım. Bana dua edince dua edenin duasına icabet ederim.”',
    mealEn: '“When My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant.”',
    kaynakTr: 'Bakara Suresi, 186. Ayet',
    kaynakEn: 'Surah Al-Baqarah, 186',
  ),
  GunlukWidgetAyetModel(
    arapca: 'وَمَنْ يَتَّقِ اللَّهَ يَجْعَلْ لَهُ مَخْرَجًا ۝ وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ',
    mealTr: '“Kim Allah’tan korkup sakınırsa, Allah ona bir çıkış yolu ihsan eder ve onu ummadığı yerden rızıklandırır.”',
    mealEn: '“Whoever fears Allah, He will make for him a way out and provide for him from where he does not expect.”',
    kaynakTr: 'Talâk Suresi, 2-3. Ayetler',
    kaynakEn: 'Surah At-Talaq, 2-3',
  ),
  GunlukWidgetAyetModel(
    arapca: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    mealTr: '“Rabbimiz! Bize dünyada da iyilik ve güzellik ver, ahirette de iyilik ve güzellik ver; bizi ateş azabından koru.”',
    mealEn: '“Our Lord! Grant us good in this world and good in the Hereafter, and protect us from the Fire.”',
    kaynakTr: 'Bakara Suresi, 201. Ayet',
    kaynakEn: 'Surah Al-Baqarah, 201',
  ),
];

class WidgetAyarlariModel {
  final String icerikModu; // 'otomatik', 'ayet', 'hadis'
  final int seciliIndeksOffset;
  final int seciliWidgetSekmesi; // 0..4

  const WidgetAyarlariModel({
    this.icerikModu = 'otomatik',
    this.seciliIndeksOffset = 0,
    this.seciliWidgetSekmesi = 0,
  });

  WidgetAyarlariModel copyWith({
    String? icerikModu,
    int? seciliIndeksOffset,
    int? seciliWidgetSekmesi,
  }) {
    return WidgetAyarlariModel(
      icerikModu: icerikModu ?? this.icerikModu,
      seciliIndeksOffset: seciliIndeksOffset ?? this.seciliIndeksOffset,
      seciliWidgetSekmesi: seciliWidgetSekmesi ?? this.seciliWidgetSekmesi,
    );
  }

  Map<String, dynamic> toJson() => {
        'icerikModu': icerikModu,
        'seciliIndeksOffset': seciliIndeksOffset,
        'seciliWidgetSekmesi': seciliWidgetSekmesi,
      };

  factory WidgetAyarlariModel.fromJson(Map<String, dynamic> m) {
    return WidgetAyarlariModel(
      icerikModu: (m['icerikModu'] as String?) ?? 'otomatik',
      seciliIndeksOffset: (m['seciliIndeksOffset'] as int?) ?? 0,
      seciliWidgetSekmesi: (m['seciliWidgetSekmesi'] as int?) ?? 0,
    );
  }
}

class VaktiHuzurWidgetServisi {
  static const String _storageKey = 'vakti_huzur_widget_ayarlari_v2';
  static bool _groupConfigured = false;

  static final ValueNotifier<WidgetAyarlariModel> ayarlarNotifier =
      ValueNotifier<WidgetAyarlariModel>(_yukle());

  static WidgetAyarlariModel _yukle() {
    try {
      final raw = web.window.localStorage.getItem(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        return WidgetAyarlariModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}
    return const WidgetAyarlariModel();
  }

  static void _kaydet(WidgetAyarlariModel yeni) {
    ayarlarNotifier.value = yeni;
    try {
      web.window.localStorage.setItem(_storageKey, jsonEncode(yeni.toJson()));
    } catch (_) {}
  }

  /// Günün Ayeti bilgisini döndürür
  static ({String baslik, String arapca, String meal, String kaynak}) gununAyetiniGetir({
    required String dil,
    int offset = 0,
  }) {
    final simdi = DateTime.now();
    final idx = (simdi.year * 366 + simdi.month * 31 + simdi.day + offset).abs() %
        kSecmeWidgetAyetleri.length;
    final a = kSecmeWidgetAyetleri[idx];
    return (
      baslik: dil == 'EN'
          ? '✨ Vakt-i Huzur • Verse of the Day'
          : dil == 'AR'
              ? '✨ Vakt-i Huzur • آية اليوم'
              : '✨ Vakt-i Huzur • Günün Ayeti',
      arapca: a.arapca,
      meal: dil == 'EN' ? a.mealEn : a.mealTr,
      kaynak: dil == 'EN' ? a.kaynakEn : a.kaynakTr,
    );
  }

  /// Günün Hadisi bilgisini döndürür
  static ({String baslik, String arapca, String meal, String kaynak}) gununHadisiniGetir({
    required String dil,
    int offset = 0,
  }) {
    final simdi = DateTime.now();
    final idx = (simdi.year * 366 + simdi.month * 31 + simdi.day + offset).abs() %
        kSahihHadisHavuzu.length;
    final h = kSahihHadisHavuzu[idx];
    return (
      baslik: dil == 'EN'
          ? '☪ Vakt-i Huzur • Hadith of the Day'
          : dil == 'AR'
              ? '☪ Vakt-i Huzur • حديث اليوم'
              : '☪ Vakt-i Huzur • Günün Hadisi',
      arapca: h['arapca'] ?? '',
      meal: dil == 'EN'
          ? (h['mealEn'] ?? h['mealTr'] ?? '')
          : (h['mealTr'] ?? ''),
      kaynak: dil == 'EN'
          ? (h['kaynakKisaEn'] ?? h['kaynakKisaTr'] ?? '')
          : (h['kaynakKisaTr'] ?? ''),
    );
  }

  /// Günlük Zikir bilgisini döndürür
  static ({String arapca, String okunus, String anlam, String sayac}) gunlukZikirGetir({
    required String dil,
  }) {
    final toplam = ZikirmatikHafizaServisi.toplamZikirNotifier.value;
    return (
      arapca: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      okunus: 'Sübhânallâhi ve bi-hamdihî',
      anlam: dil == 'EN'
          ? '“Glory be to Allah and His is the praise.”'
          : '“Allah’ı hamd ile noksan sıfatlardan tenzih ederim.”',
      sayac: '$toplam / 100',
    );
  }

  /// Hem Android hem iOS ana ekran & kilit ekranı widget'larının verilerini senkronize eder
  static Future<bool> widgetVerileriniSenkronizeEt({
    required CanliNamazVakitleriModel vakitModel,
    required String siradakiVakitAdi,
    required String kalanSureMetni,
    required String dil,
    WidgetAyarlariModel? yeniAyar,
  }) async {
    if (yeniAyar != null) {
      _kaydet(yeniAyar);
    }

    final ayar = yeniAyar ?? ayarlarNotifier.value;
    final ayet = gununAyetiniGetir(dil: dil, offset: ayar.seciliIndeksOffset);
    final hadis = gununHadisiniGetir(dil: dil, offset: ayar.seciliIndeksOffset);
    final zikir = gunlukZikirGetir(dil: dil);

    if (kIsWeb) {
      return true;
    }

    try {
      if (!_groupConfigured) {
        _groupConfigured = true;
        await HomeWidget.setAppGroupId('group.com.vaktihuzur.app');
      }

      await Future.wait([
        // Temel Namaz Vakitleri & Sıradaki Vakit
        HomeWidget.saveWidgetData<String>('widget_konum', vakitModel.konumAdi),
        HomeWidget.saveWidgetData<String>('widget_hicri_tarih', vakitModel.hicriTarihTr),
        HomeWidget.saveWidgetData<String>(
          'widget_siradaki_vakit',
          dil == 'EN' ? 'Next: $siradakiVakitAdi' : 'Sıradaki: $siradakiVakitAdi',
        ),
        HomeWidget.saveWidgetData<String>('widget_kalan_sure', kalanSureMetni),
        HomeWidget.saveWidgetData<String>('widget_imsak', vakitModel.imsak),
        HomeWidget.saveWidgetData<String>('widget_gunes', vakitModel.gunes),
        HomeWidget.saveWidgetData<String>('widget_ogle', vakitModel.ogle),
        HomeWidget.saveWidgetData<String>('widget_ikindi', vakitModel.ikindi),
        HomeWidget.saveWidgetData<String>('widget_aksam', vakitModel.aksam),
        HomeWidget.saveWidgetData<String>('widget_yatsi', vakitModel.yatsi),

        // Günün Ayeti
        HomeWidget.saveWidgetData<String>('widget_ayet_baslik', ayet.baslik),
        HomeWidget.saveWidgetData<String>('widget_ayet_arapca', ayet.arapca),
        HomeWidget.saveWidgetData<String>('widget_ayet_meal', ayet.meal),
        HomeWidget.saveWidgetData<String>('widget_ayet_kaynak', ayet.kaynak),

        // Günün Hadisi
        HomeWidget.saveWidgetData<String>('widget_hadis_baslik', hadis.baslik),
        HomeWidget.saveWidgetData<String>('widget_hadis_arapca', hadis.arapca),
        HomeWidget.saveWidgetData<String>('widget_hadis_meal', hadis.meal),
        HomeWidget.saveWidgetData<String>('widget_hadis_kaynak', hadis.kaynak),

        // Günlük Zikir
        HomeWidget.saveWidgetData<String>('widget_zikir_arapca', zikir.arapca),
        HomeWidget.saveWidgetData<String>('widget_zikir_okunus', zikir.okunus),
        HomeWidget.saveWidgetData<String>('widget_zikir_anlam', zikir.anlam),
        HomeWidget.saveWidgetData<String>('widget_zikir_sayac', zikir.sayac),

        // Geriye dönük uyumluluk (Legacy)
        HomeWidget.saveWidgetData<String>('widget_icerik_baslik', ayet.baslik),
        HomeWidget.saveWidgetData<String>('widget_icerik_arapca', ayet.arapca),
        HomeWidget.saveWidgetData<String>('widget_icerik_meal', ayet.meal),
        HomeWidget.saveWidgetData<String>('widget_icerik_kaynak', ayet.kaynak),
      ]);

      // 5 Farklı Android & iOS Widget'ını da anında tetikle
      await Future.wait([
        HomeWidget.updateWidget(
          name: 'VaktiHuzurNamazWidgetProvider',
          androidName: 'VaktiHuzurNamazWidgetProvider',
          iOSName: 'VaktiHuzurNamazWidget',
        ),
        HomeWidget.updateWidget(
          name: 'VaktiHuzurAyetWidgetProvider',
          androidName: 'VaktiHuzurAyetWidgetProvider',
          iOSName: 'VaktiHuzurAyetWidget',
        ),
        HomeWidget.updateWidget(
          name: 'VaktiHuzurHadisWidgetProvider',
          androidName: 'VaktiHuzurHadisWidgetProvider',
          iOSName: 'VaktiHuzurHadisWidget',
        ),
        HomeWidget.updateWidget(
          name: 'VaktiHuzurSiradakiWidgetProvider',
          androidName: 'VaktiHuzurSiradakiWidgetProvider',
          iOSName: 'VaktiHuzurSiradakiWidget',
        ),
        HomeWidget.updateWidget(
          name: 'VaktiHuzurZikirWidgetProvider',
          androidName: 'VaktiHuzurZikirWidgetProvider',
          iOSName: 'VaktiHuzurZikirWidget',
        ),
        HomeWidget.updateWidget(
          name: 'VaktiHuzurAyetHadisWidgetProvider',
          androidName: 'VaktiHuzurAyetHadisWidgetProvider',
          iOSName: 'VaktiHuzurAyetHadisWidget',
        ),
      ]);

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Samsung / Android 8.0+ cihazlarda seçilen spesifik widget'ı ana ekrana ekleme penceresi açar
  /// 0: Ayet, 1: Hadis, 2: Sıradaki Namaz, 3: 6 Vakit Çizelgesi, 4: Günlük Zikir
  static Future<bool> androidAnaEkranaSabitle({required int widgetTipi}) async {
    if (kIsWeb) return false;
    try {
      final supported = await HomeWidget.isRequestPinWidgetSupported();
      if (supported == true) {
        String providerName;
        switch (widgetTipi) {
          case 0:
            providerName = 'VaktiHuzurAyetWidgetProvider';
            break;
          case 1:
            providerName = 'VaktiHuzurHadisWidgetProvider';
            break;
          case 2:
            providerName = 'VaktiHuzurSiradakiWidgetProvider';
            break;
          case 3:
            providerName = 'VaktiHuzurNamazWidgetProvider';
            break;
          case 4:
            providerName = 'VaktiHuzurZikirWidgetProvider';
            break;
          default:
            providerName = 'VaktiHuzurNamazWidgetProvider';
        }
        await HomeWidget.requestPinWidget(androidName: providerName);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Uygulama içi "Kilit Ekranı & Widget Ayarları" penceresini açar
  static void panelGoster(
    BuildContext context, {
    required Color arkaPlan,
    required Color kartRengi,
    required Color vurguAltin,
    required Color yumusakAltin,
    required Color yaziRengi,
    required Color ikincilYazi,
    required String dil,
    CanliNamazVakitleriModel? vakitModel,
    String siradakiVakitAdi = 'Akşam',
    String kalanSureMetni = '01s 24dk',
  }) {
    final aktifVakit = vakitModel ??
        NamazVeKonumServisi.hafizadakiSonVakitleriGetir() ??
        CanliNamazVakitleriModel(
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
          kibleAcisiDerece: 151.6,
          kabeMesafeKm: 2403,
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KilitEkraniVeWidgetAyarlariSheet(
        arkaPlan: arkaPlan,
        kartRengi: kartRengi,
        vurguAltin: vurguAltin,
        yumusakAltin: yumusakAltin,
        yaziRengi: yaziRengi,
        ikincilYazi: ikincilYazi,
        dil: dil,
        vakitModel: aktifVakit,
        siradakiVakitAdi: siradakiVakitAdi,
        kalanSureMetni: kalanSureMetni,
      ),
    );
  }
}

class _KilitEkraniVeWidgetAyarlariSheet extends StatefulWidget {
  final Color arkaPlan;
  final Color kartRengi;
  final Color vurguAltin;
  final Color yumusakAltin;
  final Color yaziRengi;
  final Color ikincilYazi;
  final String dil;
  final CanliNamazVakitleriModel vakitModel;
  final String siradakiVakitAdi;
  final String kalanSureMetni;

  const _KilitEkraniVeWidgetAyarlariSheet({
    required this.arkaPlan,
    required this.kartRengi,
    required this.vurguAltin,
    required this.yumusakAltin,
    required this.yaziRengi,
    required this.ikincilYazi,
    required this.dil,
    required this.vakitModel,
    required this.siradakiVakitAdi,
    required this.kalanSureMetni,
  });

  @override
  State<_KilitEkraniVeWidgetAyarlariSheet> createState() =>
      _KilitEkraniVeWidgetAyarlariSheetState();
}

class _KilitEkraniVeWidgetAyarlariSheetState
    extends State<_KilitEkraniVeWidgetAyarlariSheet> {
  int _onizlemePlatformIndex = 0; // 0: Samsung / Android, 1: iPhone (iOS)
  int _seciliWidgetTipi = 0; // 0: Ayet, 1: Hadis, 2: Sıradaki Namaz, 3: 6 Vakit, 4: Günlük Zikir
  late WidgetAyarlariModel _ayar;
  bool _guncelleniyor = false;

  @override
  void initState() {
    super.initState();
    _ayar = VaktiHuzurWidgetServisi.ayarlarNotifier.value;
    _seciliWidgetTipi = _ayar.seciliWidgetSekmesi;
  }

  Future<void> _simdiSenkronizeEt({WidgetAyarlariModel? yeniAyar, bool bildirimGoster = true}) async {
    if (yeniAyar != null) {
      setState(() => _ayar = yeniAyar);
    }
    setState(() => _guncelleniyor = true);
    HapticFeedback.mediumImpact();

    await VaktiHuzurWidgetServisi.widgetVerileriniSenkronizeEt(
      vakitModel: widget.vakitModel,
      siradakiVakitAdi: widget.siradakiVakitAdi,
      kalanSureMetni: widget.kalanSureMetni,
      dil: widget.dil,
      yeniAyar: _ayar.copyWith(seciliWidgetSekmesi: _seciliWidgetTipi),
    );

    if (!mounted) return;
    setState(() => _guncelleniyor = false);

    if (bildirimGoster) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: widget.kartRengi,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: widget.vurguAltin, width: 1.2),
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: widget.vurguAltin, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.dil == 'EN'
                      ? 'All 5 Vakt-i Huzur Widgets successfully synced!'
                      : '5 Vakt-i Huzur Widget’ının tüm verileri başarıyla güncellendi!',
                  style: TextStyle(
                    color: widget.yaziRengi,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _anaEkranaSabitleTiklandi(int tip) async {
    HapticFeedback.mediumImpact();
    final ok = await VaktiHuzurWidgetServisi.androidAnaEkranaSabitle(widgetTipi: tip);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ana ekrana basılı tutup "Widget’lar" menüsünden Vakt-i Huzur’u seçebilirsiniz.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dil = widget.dil;
    final v = widget.vakitModel;
    final ayet = VaktiHuzurWidgetServisi.gununAyetiniGetir(dil: dil, offset: _ayar.seciliIndeksOffset);
    final hadis = VaktiHuzurWidgetServisi.gununHadisiniGetir(dil: dil, offset: _ayar.seciliIndeksOffset);
    final zikir = VaktiHuzurWidgetServisi.gunlukZikirGetir(dil: dil);

    final widgetBasliklari = [
      {'ad': '1. Günün Ayeti', 'ikon': Icons.menu_book_rounded},
      {'ad': '2. Günün Hadisi', 'ikon': Icons.verified_rounded},
      {'ad': '3. Sıradaki Namaz', 'ikon': Icons.hourglass_top_rounded},
      {'ad': '4. 6 Vakit Çizelgesi', 'ikon': Icons.mosque_rounded},
      {'ad': '5. Günlük Zikir', 'ikon': Icons.touch_app_rounded},
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: widget.arkaPlan,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: widget.vurguAltin, width: 1.4)),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                // Tutamaç
                Center(
                  child: Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.vurguAltin.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Başlık
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.vurguAltin.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.5)),
                      ),
                      child: Icon(Icons.widgets_rounded, color: widget.vurguAltin, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dil == 'EN'
                                ? '5 Home & Lock Screen Widgets'
                                : dil == 'AR'
                                    ? '٥ ويدجت لشاشة القفل والرئيسية'
                                    : '5 Farklı Widget & Kilit Ekranı',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 17.5,
                              fontWeight: FontWeight.bold,
                              color: widget.yumusakAltin,
                            ),
                          ),
                          Text(
                            dil == 'EN'
                                ? 'Samsung / Android & iPhone (iOS) Live Preview'
                                : 'Samsung / Android & iPhone (iOS) Canlı Önizleme',
                            style: TextStyle(color: widget.ikincilYazi, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: widget.ikincilYazi),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // PLATFORM SEÇİCİ (SAMSUNG vs iPHONE)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.kartRengi,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _onizlemePlatformIndex = 0);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _onizlemePlatformIndex == 0 ? widget.vurguAltin : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_android_rounded,
                                  size: 16,
                                  color: _onizlemePlatformIndex == 0 ? widget.arkaPlan : widget.yaziRengi,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Samsung / Android',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _onizlemePlatformIndex == 0 ? widget.arkaPlan : widget.yaziRengi,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _onizlemePlatformIndex = 1);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _onizlemePlatformIndex == 1 ? widget.vurguAltin : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_iphone_rounded,
                                  size: 16,
                                  color: _onizlemePlatformIndex == 1 ? widget.arkaPlan : widget.yaziRengi,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'iPhone (iOS WidgetKit)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _onizlemePlatformIndex == 1 ? widget.arkaPlan : widget.yaziRengi,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 5 WİDGET TÜRÜ SEÇİM ÇUBUĞU (KAYDIRILABİLİR CHİPLER)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < widgetBasliklari.length; i++) ...[
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _seciliWidgetTipi = i);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: _seciliWidgetTipi == i
                                  ? widget.vurguAltin.withValues(alpha: 0.22)
                                  : widget.kartRengi,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _seciliWidgetTipi == i
                                    ? widget.vurguAltin
                                    : widget.vurguAltin.withValues(alpha: 0.25),
                                width: _seciliWidgetTipi == i ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  widgetBasliklari[i]['ikon'] as IconData,
                                  size: 15,
                                  color: _seciliWidgetTipi == i ? widget.vurguAltin : widget.ikincilYazi,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widgetBasliklari[i]['ad'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _seciliWidgetTipi == i ? FontWeight.bold : FontWeight.w500,
                                    color: _seciliWidgetTipi == i ? widget.yumusakAltin : widget.yaziRengi,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SEÇİLİ WİDGETIN CANLI ÖNİZLEMESİ
                _widgetCanliOnizlemeKarti(
                  tip: _seciliWidgetTipi,
                  v: v,
                  ayet: ayet,
                  hadis: hadis,
                  zikir: zikir,
                ),
                const SizedBox(height: 12),

                // WİDGET İŞLEM BUTONLARI (ANA EKRANA EKLE + DEĞİŞTİR)
                Row(
                  children: [
                    if (!kIsWeb) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: widget.vurguAltin),
                            foregroundColor: widget.vurguAltin,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _anaEkranaSabitleTiklandi(_seciliWidgetTipi),
                          icon: const Icon(Icons.add_to_home_screen_rounded, size: 18),
                          label: Text(
                            dil == 'EN' ? 'Add to Home Screen' : 'Bu Widget’ı Ekle',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (_seciliWidgetTipi == 0 || _seciliWidgetTipi == 1) ...[
                      IconButton(
                        tooltip: 'Sonraki Ayet / Hadis',
                        style: IconButton.styleFrom(
                          backgroundColor: widget.kartRengi,
                          side: BorderSide(color: widget.vurguAltin.withValues(alpha: 0.3)),
                        ),
                        onPressed: () {
                          final yeni = _ayar.copyWith(
                            seciliIndeksOffset: _ayar.seciliIndeksOffset + 1,
                          );
                          _simdiSenkronizeEt(yeniAyar: yeni, bildirimGoster: false);
                        },
                        icon: Icon(Icons.refresh_rounded, color: widget.vurguAltin),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 18),

                // WİDGET VERİLERİNİ ŞİMDİ GÜNCELLE (SENKRONİZE ET)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.vurguAltin,
                    foregroundColor: widget.arkaPlan,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _guncelleniyor ? null : () => _simdiSenkronizeEt(),
                  icon: _guncelleniyor
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: widget.arkaPlan),
                        )
                      : const Icon(Icons.sync_rounded, size: 20),
                  label: Text(
                    dil == 'EN'
                        ? 'Sync All 5 Widgets Now'
                        : '5 Widget’ı Şimdi Senkronize Et',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // TÜM 5 WİDGETIN ÖZET LİSTESİ
                Text(
                  dil == 'EN' ? 'All 5 Available Widgets:' : 'Kullanılabilir 5 Widget Türü:',
                  style: TextStyle(
                    color: widget.yumusakAltin,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _widgetBilgiSatiri(
                  '1. Günün Ayeti',
                  'Günün Kur’an ayetini Arapça metni, meali ve suresiyle ana ekranda gösterir.',
                  Icons.menu_book_rounded,
                  0,
                ),
                _widgetBilgiSatiri(
                  '2. Günün Hadisi',
                  'Buhârî ve Müslim kaynaklı sahih hadis-i şerifi ve hikmetini gösterir.',
                  Icons.verified_rounded,
                  1,
                ),
                _widgetBilgiSatiri(
                  '3. Sıradaki Namaz',
                  'Sıradaki vakti ve kalan süreyi büyük harflerle canlı geri sayımla gösterir.',
                  Icons.hourglass_top_rounded,
                  2,
                ),
                _widgetBilgiSatiri(
                  '4. 6 Vakit Çizelgesi',
                  'İmsak, Güneş, Öğle, İkindi, Akşam ve Yatsı vakitlerini tam liste sunar.',
                  Icons.mosque_rounded,
                  3,
                ),
                _widgetBilgiSatiri(
                  '5. Günlük Zikir',
                  'Günün tesbihatını, Arapça zikrini ve Zikirmatik sayacını ekranda tutar.',
                  Icons.touch_app_rounded,
                  4,
                ),
                const SizedBox(height: 14),

                // NASIL EKLENİR BİLGİLENDİRME
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.kartRengi,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: widget.vurguAltin, size: 17),
                          const SizedBox(width: 7),
                          Text(
                            'Telefonunuzun Ekranına Nasıl Eklenir?',
                            style: TextStyle(
                              color: widget.yumusakAltin,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '• Samsung / Android: Ana ekranda boş bir yere basılı tutun ➔ "Widget’lar"a dokunun ➔ "Vakt-i Huzur" altındaki 5 widget’tan dilediğinizi ekranınıza sürükleyin.\n'
                        '• iPhone (iOS): Ana ekrana veya Kilit Ekranına basılı tutun ➔ "+" / "Özelleştir" butonuna dokunup "Vakt-i Huzur" widget’ını seçin.',
                        style: TextStyle(
                          color: widget.ikincilYazi,
                          fontSize: 11.5,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _widgetBilgiSatiri(String baslik, String aciklama, IconData ikon, int tipIndex) {
    final secili = _seciliWidgetTipi == tipIndex;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _seciliWidgetTipi = tipIndex);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: secili ? widget.vurguAltin.withValues(alpha: 0.14) : widget.kartRengi,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: secili ? widget.vurguAltin : widget.vurguAltin.withValues(alpha: 0.18),
            width: secili ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(ikon, color: widget.vurguAltin, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: widget.yaziRengi,
                    ),
                  ),
                  Text(
                    aciklama,
                    style: TextStyle(fontSize: 11, color: widget.ikincilYazi),
                  ),
                ],
              ),
            ),
            if (secili)
              Icon(Icons.check_circle_rounded, color: widget.vurguAltin, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _widgetCanliOnizlemeKarti({
    required int tip,
    required CanliNamazVakitleriModel v,
    required ({String baslik, String arapca, String meal, String kaynak}) ayet,
    required ({String baslik, String arapca, String meal, String kaynak}) hadis,
    required ({String arapca, String okunus, String anlam, String sayac}) zikir,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E2C20),
            Color(0xFF0A2017),
            Color(0xFF06140E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9B650), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: () {
        switch (tip) {
          // 0: GÜNÜN AYETİ
          case 0:
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ayet.baslik,
                        style: const TextStyle(
                          color: Color(0xFFD9B650),
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9B650).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ayet.kaynak,
                        style: const TextStyle(
                          color: Color(0xFFF2E2B6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ayet.arapca,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    color: Color(0xFFF2E2B6),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ayet.meal,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            );

          // 1: GÜNÜN HADİSİ
          case 1:
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hadis.baslik,
                        style: const TextStyle(
                          color: Color(0xFFD9B650),
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9B650).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hadis.kaynak,
                        style: const TextStyle(
                          color: Color(0xFFF2E2B6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  hadis.arapca,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    color: Color(0xFFF2E2B6),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hadis.meal,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            );

          // 2: SIRADAKİ NAMAZ
          case 2:
            return Column(
              children: [
                Text(
                  '☪ Vakt-i Huzur • ${v.konumAdi}',
                  style: const TextStyle(
                    color: Color(0xFFD9B650),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sıradaki: ${widget.siradakiVakitAdi} Vakti',
                  style: const TextStyle(
                    color: Color(0xFFF2E2B6),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.kalanSureMetni,
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    color: Color(0xFFD4AF37),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Kalan Süre • Diyanet',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                ),
              ],
            );

          // 3: 6 VAKİT ÇİZELGESİ
          case 3:
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '☪ Vakt-i Huzur • ${v.konumAdi}',
                            style: const TextStyle(
                              color: Color(0xFFF2E2B6),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            v.hicriTarihTr,
                            style: const TextStyle(
                              color: Color(0xFFB7D4C5),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9B650).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD9B650).withValues(alpha: 0.55)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.siradakiVakitAdi,
                            style: const TextStyle(
                              color: Color(0xFFD9B650),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.kalanSureMetni,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _widgetVakitSutun('İmsak', v.imsak, widget.siradakiVakitAdi == 'İmsak'),
                    _widgetVakitSutun('Güneş', v.gunes, widget.siradakiVakitAdi == 'Güneş'),
                    _widgetVakitSutun('Öğle', v.ogle, widget.siradakiVakitAdi == 'Öğle'),
                    _widgetVakitSutun('İkindi', v.ikindi, widget.siradakiVakitAdi == 'İkindi'),
                    _widgetVakitSutun('Akşam', v.aksam, widget.siradakiVakitAdi == 'Akşam'),
                    _widgetVakitSutun('Yatsı', v.yatsi, widget.siradakiVakitAdi == 'Yatsı'),
                  ],
                ),
              ],
            );

          // 4: GÜNLÜK ZİKİR
          case 4:
          default:
            return Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '📿 Vakt-i Huzur • Günlük Zikir',
                        style: TextStyle(
                          color: Color(0xFFD9B650),
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9B650).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        zikir.sayac,
                        style: const TextStyle(
                          color: Color(0xFFF2E2B6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  zikir.arapca,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    color: Color(0xFFF2E2B6),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  zikir.okunus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  zikir.anlam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    color: Colors.white,
                    fontSize: 11.5,
                  ),
                ),
              ],
            );
        }
      }(),
    );
  }

  Widget _widgetVakitSutun(String ad, String saat, bool aktifMi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: aktifMi
          ? BoxDecoration(
              color: const Color(0xFFD9B650).withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD9B650), width: 0.9),
            )
          : null,
      child: Column(
        children: [
          Text(
            ad,
            style: TextStyle(
              color: aktifMi ? const Color(0xFFD9B650) : const Color(0xFFB7D4C5),
              fontSize: 10,
              fontWeight: aktifMi ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            saat,
            style: TextStyle(
              color: aktifMi ? Colors.white : const Color(0xFFF2E2B6),
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
