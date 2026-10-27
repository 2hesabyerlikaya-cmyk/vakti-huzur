import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'prayer_location_calendar_service.dart';
import 'quran_hadith_data.dart';
import 'web_shim_io.dart' if (dart.library.js_interop) 'package:web/web.dart' as web;

// ============================================================================
// VAKT-İ HUZUR — ANDROID (SAMSUNG VB.) & iOS ANA EKRAN / KİLİT EKRANI WİDGET SERVİSİ
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
  /// 'otomatik', 'ayet', 'hadis'
  final String icerikModu;
  final int seciliIndeksOffset;

  const WidgetAyarlariModel({
    this.icerikModu = 'otomatik',
    this.seciliIndeksOffset = 0,
  });

  WidgetAyarlariModel copyWith({
    String? icerikModu,
    int? seciliIndeksOffset,
  }) {
    return WidgetAyarlariModel(
      icerikModu: icerikModu ?? this.icerikModu,
      seciliIndeksOffset: seciliIndeksOffset ?? this.seciliIndeksOffset,
    );
  }

  Map<String, dynamic> toJson() => {
        'icerikModu': icerikModu,
        'seciliIndeksOffset': seciliIndeksOffset,
      };

  factory WidgetAyarlariModel.fromJson(Map<String, dynamic> m) {
    return WidgetAyarlariModel(
      icerikModu: (m['icerikModu'] as String?) ?? 'otomatik',
      seciliIndeksOffset: (m['seciliIndeksOffset'] as int?) ?? 0,
    );
  }
}

class VaktiHuzurWidgetServisi {
  static const String _storageKey = 'vakti_huzur_widget_ayarlari_v1';
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

  /// Seçili moda ve güne göre o günün Ayet veya Hadis bilgisini döndürür
  static ({String baslik, String arapca, String meal, String kaynak, bool ayetMi})
      gununIceriginiGetir({
    required String dil,
    WidgetAyarlariModel? ozelAyar,
  }) {
    final ayar = ozelAyar ?? ayarlarNotifier.value;
    final simdi = DateTime.now();
    final gunSayisi = simdi.year * 366 + simdi.month * 31 + simdi.day + ayar.seciliIndeksOffset;

    final bool ayetGoster = ayar.icerikModu == 'ayet' ||
        (ayar.icerikModu == 'otomatik' && (gunSayisi % 2 == 0));

    if (ayetGoster) {
      final ayet = kSecmeWidgetAyetleri[gunSayisi.abs() % kSecmeWidgetAyetleri.length];
      return (
        baslik: dil == 'EN'
            ? '✨ Vakt-i Huzur • Verse of the Day'
            : dil == 'AR'
                ? '✨ Vakt-i Huzur • آية اليوم'
                : '✨ Vakt-i Huzur • Günün Ayeti',
        arapca: ayet.arapca,
        meal: dil == 'EN' ? ayet.mealEn : ayet.mealTr,
        kaynak: dil == 'EN' ? ayet.kaynakEn : ayet.kaynakTr,
        ayetMi: true,
      );
    } else {
      final hadis = kSahihHadisHavuzu[gunSayisi.abs() % kSahihHadisHavuzu.length];
      return (
        baslik: dil == 'EN'
            ? '☪ Vakt-i Huzur • Hadith of the Day'
            : dil == 'AR'
                ? '☪ Vakt-i Huzur • حديث اليوم'
                : '☪ Vakt-i Huzur • Günün Hadisi',
        arapca: hadis['arapca'] ?? '',
        meal: dil == 'EN'
            ? (hadis['mealEn'] ?? hadis['mealTr'] ?? '')
            : (hadis['mealTr'] ?? ''),
        kaynak: dil == 'EN'
            ? (hadis['kaynakKisaEn'] ?? hadis['kaynakKisaTr'] ?? '')
            : (hadis['kaynakKisaTr'] ?? ''),
        ayetMi: false,
      );
    }
  }

  /// Hem Android (Samsung vb.) hem de iOS (iPhone WidgetKit) ana ekran & kilit ekranı widget'larını günceller
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

    final icerik = gununIceriginiGetir(dil: dil);

    if (kIsWeb) {
      return true;
    }

    try {
      if (!_groupConfigured) {
        _groupConfigured = true;
        await HomeWidget.setAppGroupId('group.com.vaktihuzur.app');
      }

      await Future.wait([
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
        HomeWidget.saveWidgetData<String>('widget_icerik_baslik', icerik.baslik),
        HomeWidget.saveWidgetData<String>('widget_icerik_arapca', icerik.arapca),
        HomeWidget.saveWidgetData<String>('widget_icerik_meal', icerik.meal),
        HomeWidget.saveWidgetData<String>('widget_icerik_kaynak', icerik.kaynak),
      ]);

      await HomeWidget.updateWidget(
        name: 'VaktiHuzurNamazWidgetProvider',
        androidName: 'VaktiHuzurNamazWidgetProvider',
        iOSName: 'VaktiHuzurNamazWidget',
      );
      await HomeWidget.updateWidget(
        name: 'VaktiHuzurAyetHadisWidgetProvider',
        androidName: 'VaktiHuzurAyetHadisWidgetProvider',
        iOSName: 'VaktiHuzurAyetHadisWidget',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Samsung/Android 8.0+ cihazlarda widget'ı doğrudan ana ekrana sabitleme isteği gönderir
  static Future<bool> androidAnaEkranaSabitle({required bool namazWidgetMi}) async {
    if (kIsWeb) return false;
    try {
      final supported = await HomeWidget.isRequestPinWidgetSupported();
      if (supported == true) {
        await HomeWidget.requestPinWidget(
          androidName: namazWidgetMi
              ? 'VaktiHuzurNamazWidgetProvider'
              : 'VaktiHuzurAyetHadisWidgetProvider',
        );
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
  /// 0: Samsung / Android (Ana Ekran & Kilit Ekranı), 1: iPhone / iOS (Kilit Ekranı & WidgetKit)
  int _onizlemePlatformIndex = 0;
  late WidgetAyarlariModel _ayar;
  bool _guncelleniyor = false;

  @override
  void initState() {
    super.initState();
    _ayar = VaktiHuzurWidgetServisi.ayarlarNotifier.value;
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
      yeniAyar: _ayar,
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
                      ? 'Vakt-i Huzur Home & Lock Screen Widgets updated!'
                      : 'Vakt-i Huzur Ana Ekran & Kilit Ekranı Widget verileri güncellendi!',
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

  @override
  Widget build(BuildContext context) {
    final dil = widget.dil;
    final v = widget.vakitModel;
    final icerik = VaktiHuzurWidgetServisi.gununIceriginiGetir(
      dil: dil,
      ozelAyar: _ayar,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: widget.arkaPlan,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: widget.vurguAltin, width: 1.4),
            ),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
              children: [
                // Üst Tutamaç
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
                        border: Border.all(
                          color: widget.vurguAltin.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        Icons.widgets_rounded,
                        color: widget.vurguAltin,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dil == 'EN'
                                ? 'Lock Screen & Home Widgets'
                                : dil == 'AR'
                                    ? 'إعدادات الويدجت وشاشة القفل'
                                    : 'Kilit Ekranı & Widget Ayarları',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.yumusakAltin,
                            ),
                          ),
                          Text(
                            dil == 'EN'
                                ? 'Samsung / Android & iPhone (iOS) Live Widgets'
                                : 'Samsung / Android & iPhone (iOS) Canlı Widget Önizleme',
                            style: TextStyle(
                              color: widget.ikincilYazi,
                              fontSize: 12,
                            ),
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
                const SizedBox(height: 16),

                // PLATFORM ÖNİZLEME SEÇİCİ (SAMSUNG/ANDROID vs iPHONE/iOS)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.kartRengi,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.vurguAltin.withValues(alpha: 0.35),
                    ),
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _onizlemePlatformIndex == 0
                                  ? widget.vurguAltin
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_android_rounded,
                                  size: 16,
                                  color: _onizlemePlatformIndex == 0
                                      ? widget.arkaPlan
                                      : widget.yaziRengi,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Samsung / Android',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: _onizlemePlatformIndex == 0
                                        ? widget.arkaPlan
                                        : widget.yaziRengi,
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _onizlemePlatformIndex == 1
                                  ? widget.vurguAltin
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_iphone_rounded,
                                  size: 16,
                                  color: _onizlemePlatformIndex == 1
                                      ? widget.arkaPlan
                                      : widget.yaziRengi,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'iPhone (iOS Kilit Ekranı)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: _onizlemePlatformIndex == 1
                                        ? widget.arkaPlan
                                        : widget.yaziRengi,
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
                const SizedBox(height: 16),

                // iPHONE KİLİT EKRANI ÖZEL ÖNİZLEMESİ (Eğer iPhone seçiliyse üstte saat + kilit ekranı widgetları)
                if (_onizlemePlatformIndex == 1) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF061610),
                          Color(0xFF0E2B20),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFD9B650).withValues(alpha: 0.55),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // iOS Lock Screen Inline Widget (Saatin Üstündeki Satır)
                        Text(
                          '☪ ${v.konumAdi} • ${widget.siradakiVakitAdi} (${widget.kalanSureMetni})',
                          style: const TextStyle(
                            color: Color(0xFFF2E2B6),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // iOS Lock Screen Saat
                        Text(
                          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // iOS Lock Screen Rectangular Widgets (2 Adet Yan Yana / Alt Alta)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '☪ VAKT-İ HUZUR • ${v.konumAdi.toUpperCase()}',
                                style: const TextStyle(
                                  color: Color(0xFFD9B650),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sıradaki: ${widget.siradakiVakitAdi} Vakti • ${widget.kalanSureMetni}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'İm:${v.imsak}  Gü:${v.gunes}  Öğ:${v.ogle}  İk:${v.ikindi}  Ak:${v.aksam}  Ya:${v.yatsi}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 1. WİDGET ÖNİZLEMESİ: "VAKT-İ HUZUR: NAMAZ VAKİTLERİ"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1. Vakt-i Huzur: Namaz Vakitleri Widget’ı',
                      style: TextStyle(
                        color: widget.yumusakAltin,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (!kIsWeb)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: widget.vurguAltin,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () async {
                          final ok = await VaktiHuzurWidgetServisi.androidAnaEkranaSabitle(
                            namazWidgetMi: true,
                          );
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ana ekranınıza basılı tutup Widget’lar menüsünden Vakt-i Huzur’u ekleyebilirsiniz.',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add_to_home_screen_rounded, size: 15),
                        label: const Text(
                          'Ana Ekrana Ekle',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
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
                    border: Border.all(
                      color: const Color(0xFFD9B650),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
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
                                const SizedBox(height: 2),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9B650).withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFD9B650).withValues(alpha: 0.55),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Sıradaki: ${widget.siradakiVakitAdi}',
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
                  ),
                ),
                const SizedBox(height: 16),

                // 2. WİDGET ÖNİZLEMESİ: "VAKT-İ HUZUR: GÜNÜN AYETİ & HADİSİ"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2. Vakt-i Huzur: Günün Ayeti & Hadisi Widget’ı',
                      style: TextStyle(
                        color: widget.yumusakAltin,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: widget.vurguAltin,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        final yeni = _ayar.copyWith(
                          seciliIndeksOffset: _ayar.seciliIndeksOffset + 1,
                        );
                        _simdiSenkronizeEt(yeniAyar: yeni, bildirimGoster: false);
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 15),
                      label: const Text(
                        'Farklı Ayet/Hadis',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
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
                    border: Border.all(
                      color: const Color(0xFFD9B650),
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              icerik.baslik,
                              style: const TextStyle(
                                color: Color(0xFFD9B650),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9B650).withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              icerik.kaynak,
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
                        icerik.arapca,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          color: Color(0xFFF2E2B6),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        icerik.meal,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // WİDGET İÇERİK SEÇİMİ (OTOMATİK / SADECE AYET / SADECE HADİS)
                Text(
                  dil == 'EN'
                      ? 'Select Spiritual Widget Content:'
                      : '2. Widget’ta Gösterilecek İçeriği Seçin:',
                  style: TextStyle(
                    color: widget.yaziRengi,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _modSecimChip(
                      kod: 'otomatik',
                      etiket: 'Her Gün Otomatik (Ayet & Hadis)',
                      ikon: Icons.auto_awesome_rounded,
                    ),
                    _modSecimChip(
                      kod: 'ayet',
                      etiket: 'Günün Kur’an Ayeti',
                      ikon: Icons.menu_book_rounded,
                    ),
                    _modSecimChip(
                      kod: 'hadis',
                      etiket: 'Günün Sahih Hadisi',
                      ikon: Icons.verified_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // WİDGET VERİLERİNİ ŞİMDİ GÜNCELLE BUTONU
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.vurguAltin,
                    foregroundColor: widget.arkaPlan,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _guncelleniyor ? null : () => _simdiSenkronizeEt(),
                  icon: _guncelleniyor
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.arkaPlan,
                          ),
                        )
                      : const Icon(Icons.sync_rounded, size: 20),
                  label: Text(
                    dil == 'EN'
                        ? 'Update Widget Data Now'
                        : 'Widget Verilerini Şimdi Güncelle',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // TELEFONA EKLEME REHBER KARTI (SAMSUNG/ANDROID & iPHONE)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.kartRengi,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.vurguAltin.withValues(alpha: 0.28),
                    ),
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
                        '• Samsung / Android: Ana ekranda boş bir yere basılı tutun ➔ "Widget’lar"a dokunun ➔ "Vakt-i Huzur"u seçip ekranınıza sürükleyin.\n'
                        '• iPhone (iOS): Kilit ekranına veya Ana ekrana basılı tutun ➔ "Özelleştir / +" butonuna dokunun ➔ "Vakt-i Huzur" widget’ını seçin.',
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

  Widget _modSecimChip({
    required String kod,
    required String etiket,
    required IconData ikon,
  }) {
    final secili = _ayar.icerikModu == kod;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        final yeni = _ayar.copyWith(icerikModu: kod);
        _simdiSenkronizeEt(yeniAyar: yeni, bildirimGoster: false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: secili
              ? widget.vurguAltin.withValues(alpha: 0.22)
              : widget.kartRengi,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: secili
                ? widget.vurguAltin
                : widget.vurguAltin.withValues(alpha: 0.3),
            width: secili ? 1.4 : 0.9,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ikon,
              size: 15,
              color: secili ? widget.vurguAltin : widget.ikincilYazi,
            ),
            const SizedBox(width: 6),
            Text(
              etiket,
              style: TextStyle(
                color: secili ? widget.yumusakAltin : widget.yaziRengi,
                fontWeight: secili ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
