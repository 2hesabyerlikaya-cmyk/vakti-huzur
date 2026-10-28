import 'package:flutter/material.dart';
import 'audio_bookmark_tracker_service.dart';
import 'dualar_ek_arsiv.dart';
import 'quran_api_service.dart';
import 'quran_hadith_data.dart';
import 'share_story_sheet.dart';
import 'zikirmatik_ve_esmaul_husna.dart';

// ============================================================================
// GÜNLÜK DUALAR & RABBENA DUALARI VERİ MODELİ VE KATEGORİLİ KÜLLİYAT
// ============================================================================

class DuaModel {
  final String id;
  final String kategoriTr;
  final String kategoriEn;
  final String baslikTr;
  final String baslikEn;
  final String arapca;
  final String okunusTr;
  final String anlamTr;
  final String anlamEn;
  final String kaynakTr;
  final String kaynakEn;
  final int? globalAyetNo; // Kur'an ayeti ise Mişari Raşid el-Afasi MP3 tilaveti için

  const DuaModel({
    required this.id,
    required this.kategoriTr,
    required this.kategoriEn,
    required this.baslikTr,
    required this.baslikEn,
    required this.arapca,
    required this.okunusTr,
    required this.anlamTr,
    required this.anlamEn,
    required this.kaynakTr,
    required this.kaynakEn,
    this.globalAyetNo,
  });
}

const List<String> kDuaKategorileriTr = [
  'Tümü',
  'Rabbena Duaları',
  'Sabah & Akşam',
  'Şifa & Afiyet',
  'Rızık & Bereket',
  'Nazar & Korunma',
  'Namaz Tesbihatı',
  'Huzur & İnşirah',
  'Sınav & İş Kolaylığı',
  'İstiğfar & Tövbe',
];

/// Mevcut Rabbena / günlük dualar + genişletilmiş dua arşivi (dualar_ek_arsiv.dart)
final List<DuaModel> kTumDualar = [
  ...kGunlukVeRabbenaDualari,
  ...kEkDuaArsivi,
];

const List<DuaModel> kGunlukVeRabbenaDualari = [
  // 1. RABBENA DUALARI (KUR'AN-I KERİM'DEN)
  DuaModel(
    id: 'rabbena_atina',
    kategoriTr: 'Rabbena Duaları',
    kategoriEn: 'Rabbana Duas',
    baslikTr: 'Rabbenâ Âtinâ (Dünya ve Ahiret İyiliği)',
    baslikEn: 'Rabbana Atina (Goodness in Both Worlds)',
    arapca: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    okunusTr: 'Rabbenâ âtinâ fid-dünyâ haseneten ve fil-âhirati haseneten ve kınâ azâben-nâr.',
    anlamTr: '“Rabbimiz! Bize dünyada da iyilik ve güzellik ver, ahirette de iyilik ve güzellik ver; bizi ateş azabından koru.”',
    anlamEn: '“Our Lord! Grant us good in this world and good in the Hereafter, and protect us from the torment of the Fire.”',
    kaynakTr: 'Kur’an-ı Kerim — Bakara Suresi, 201. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah Al-Baqarah, 2:201',
    globalAyetNo: 208,
  ),
  DuaModel(
    id: 'rabbenagfirlî',
    kategoriTr: 'Rabbena Duaları',
    kategoriEn: 'Rabbana Duas',
    baslikTr: 'Rabbenağfirlî (Anne-Baba ve Müminler İçin Mağfiret)',
    baslikEn: 'Rabbanaghfirli (Forgiveness for Parents & Believers)',
    arapca: 'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
    okunusTr: 'Rabbenağfirlî ve li-vâlideyye ve lil-mü’minîne yevme yekûmül-hisâb.',
    anlamTr: '“Ey Rabbimiz! Hesap görülecek günde beni, ana-babamı ve bütün müminleri bağışla!”',
    anlamEn: '“Our Lord! Forgive me, my parents, and the believers on the Day the account is established.”',
    kaynakTr: 'Kur’an-ı Kerim — İbrâhîm Suresi, 41. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah Ibrahim, 14:41',
    globalAyetNo: 1791,
  ),
  DuaModel(
    id: 'rabbena_la_tuzig',
    kategoriTr: 'Rabbena Duaları',
    kategoriEn: 'Rabbana Duas',
    baslikTr: 'Rabbenâ Lâ Tüziğ Kulûbenâ (Hidayet Üzere Sebat)',
    baslikEn: 'Rabbana La Tuzigh Qulubana (Steadfastness in Guidance)',
    arapca: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً ۚ إِنَّكَ أَنْتَ الْوَهَّابُ',
    okunusTr: 'Rabbenâ lâ tüziğ kulûbenâ ba’de iz hedeytenâ ve heb lenâ min ledünke rahmeh, inneke entel-Vehhâb.',
    anlamTr: '“Rabbimiz! Bizi doğru yola ilettikten sonra kalplerimizi eğriltme ve bize katından bir rahmet bağışla. Şüphesiz Sen çok bağışlayansın.”',
    anlamEn: '“Our Lord! Let not our hearts deviate after You have guided us, and grant us mercy from Yourself. Indeed, You are the Bestower.”',
    kaynakTr: 'Kur’an-ı Kerim — Âl-i İmrân Suresi, 8. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah Ali ’Imran, 3:8',
    globalAyetNo: 301,
  ),
  DuaModel(
    id: 'rabbena_heb_lena',
    kategoriTr: 'Rabbena Duaları',
    kategoriEn: 'Rabbana Duas',
    baslikTr: 'Göz Aydınlığı Eş veEvlat Duası',
    baslikEn: 'Supplication for Righteous Family & Offspring',
    arapca: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
    okunusTr: 'Rabbenâ heb lenâ min ezvâcinâ ve zürriyyâtinâ kurrate a’yünin vec’alnâ lil-müttekîne imâmâ.',
    anlamTr: '“Rabbimiz! Bize gözümüzü aydınlatacak eşler ve zürriyetler bağışla ve bizi takvâ sahiplerine önder kıl!”',
    anlamEn: '“Our Lord! Grant us from among our spouses and offspring comfort to our eyes and make us a leader for the righteous.”',
    kaynakTr: 'Kur’an-ı Kerim — Furkân Suresi, 74. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah Al-Furqan, 25:74',
    globalAyetNo: 2929,
  ),
  DuaModel(
    id: 'rabbena_efrig',
    kategoriTr: 'Rabbena Duaları',
    kategoriEn: 'Rabbana Duas',
    baslikTr: 'Sabır ve Metanet Duası (Rabbenâ Efriğ Aleynâ Sabran)',
    baslikEn: 'Supplication for Patience and Firmness',
    arapca: 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
    okunusTr: 'Rabbenâ efriğ aleynâ sabran ve sebbit akdâmenâ vensurnâ alel-kavmil-kâfirîn.',
    anlamTr: '“Ey Rabbimiz! Üzerimize sabır yağdır, ayaklarımızı sağlam bastır ve hakka karşı duranlara karşı bize yardım et.”',
    anlamEn: '“Our Lord! Pour upon us patience, plant firmly our feet, and give us victory.”',
    kaynakTr: 'Kur’an-ı Kerim — Bakara Suresi, 250. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah Al-Baqarah, 2:250',
    globalAyetNo: 257,
  ),

  // 2. SINAV & İŞ KOLAYLIĞI DUALARI
  DuaModel(
    id: 'rabbi_yessir',
    kategoriTr: 'Sınav & İş Kolaylığı',
    kategoriEn: 'Exam & Ease in Affairs',
    baslikTr: 'Rabbi Yessir (İş ve Sınav Kolaylığı Duası)',
    baslikEn: 'Rabbi Yassir (Prayer for Ease & Success)',
    arapca: 'رَبِّ يَسِّرْ وَلَا تُعَسِّرْ رَبِّ تَمِّمْ بِالْخَيْرِ',
    okunusTr: 'Rabbi yessir ve lâ tuassir, Rabbi temmim bil-hayr.',
    anlamTr: '“Rabbim! İşimi kolaylaştır, güçleştirme. Rabbim! Bu işimi hayırla tamamla ve sonuçlandır.”',
    anlamEn: '“My Lord! Make things easy and do not make them difficult. My Lord, complete this affair with goodness.”',
    kaynakTr: 'Meşhur Dua & Hadis-i Şerif İktibası (Buhârî, İlim 11)',
    kaynakEn: 'Prophetic Supplication Tradition (Bukhari, Knowledge 11)',
  ),
  DuaModel(
    id: 'rabbi_srahli_sadri',
    kategoriTr: 'Sınav & İş Kolaylığı',
    kategoriEn: 'Exam & Ease in Affairs',
    baslikTr: 'Hz. Mûsâ’nın (a.s.) İnşirah ve Hitabet Duası',
    baslikEn: 'Prophet Musa’s Prayer for Confidence & Clarity',
    arapca: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي يَفْقَهُوا قَوْلِي',
    okunusTr: 'Rabbişrahlî sadrî ve yessirlî emrî vahlül ukdeten min lisânî yefkahû kavlî.',
    anlamTr: '“Rabbim! Gönlüme ferahlık ver, işimi bana kolaylaştır, dilimdeki tutukluğu çöz ki sözümü iyi anlasınlar.”',
    anlamEn: '“My Lord, expand for me my breast, ease for me my task, and untie the knot from my tongue that they may understand my speech.”',
    kaynakTr: 'Kur’an-ı Kerim — Tâhâ Suresi, 25-28. Ayetler',
    kaynakEn: 'The Holy Qur’an — Surah Ta-Ha, 20:25-28',
    globalAyetNo: 2373,
  ),
  DuaModel(
    id: 'rabbi_zidni_ilma',
    kategoriTr: 'Sınav & İş Kolaylığı',
    kategoriEn: 'Exam & Ease in Affairs',
    baslikTr: 'İlim ve Zihin Açıklığı Duası (Rabbi Zidnî İlmâ)',
    baslikEn: 'Prayer for Increase in Beneficial Knowledge',
    arapca: 'رَبِّ زِدْنِي عِلْمًا وَفَهْمًا وَأَلْحِقْنِي بِالصَّالِحِينَ',
    okunusTr: 'Rabbi zidnî ilmen ve fehmen ve elhıknî bis-sâlihîn.',
    anlamTr: '“Rabbim! İlmimi ve anlayışımı (kavrayışımı) artır ve beni salih kullarının arasına kat.”',
    anlamEn: '“My Lord, increase me in knowledge and understanding, and join me with the righteous.”',
    kaynakTr: 'Kur’an-ı Kerim — Tâhâ Suresi, 114. Ayet & Şuarâ 83',
    kaynakEn: 'The Holy Qur’an — Surah Ta-Ha 20:114 & Ash-Shu’ara 26:83',
    globalAyetNo: 2462,
  ),

  // 3. HUZUR & İNŞİRAH DUALARI
  DuaModel(
    id: 'yunus_duasi',
    kategoriTr: 'Huzur & İnşirah',
    kategoriEn: 'Peace & Relief',
    baslikTr: 'Hz. Yûnus’un (a.s.) Sıkıntıdan Kurtuluş Duası',
    baslikEn: 'Prophet Yunus’s Prayer for Relief from Distress',
    arapca: 'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    okunusTr: 'Lâ ilâhe illâ ente sübhâneke innî küntü minez-zâlimîn.',
    anlamTr: '“Senden başka hiçbir ilâh yoktur. Seni bütün noksanlıklardan tenzih ederim. Gerçekten ben nefsine zulmedenlerden oldum.”',
    anlamEn: '“There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.”',
    kaynakTr: 'Kur’an-ı Kerim — Enbiyâ Suresi, 87. Ayet & Tirmizî, Daavât 81',
    kaynakEn: 'The Holy Qur’an — Surah Al-Anbiya, 21:87',
    globalAyetNo: 2570,
  ),
  DuaModel(
    id: 'kalp_huzuru_duasi',
    kategoriTr: 'Huzur & İnşirah',
    kategoriEn: 'Peace & Relief',
    baslikTr: 'Üzüntü, Kaygı ve Kederden Korunma Duası',
    baslikEn: 'Prophetic Refuge from Anxiety & Grief',
    arapca: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
    okunusTr: 'Allâhümme innî eûzü bike minel-hemmi vel-hazen, vel-aczi vel-kesel, vel-buhli vel-cübn, ve dal’id-deyni ve galebetir-ricâl.',
    anlamTr: '“Allah’ım! Üzüntü ve kederden, acizlik ve tembellikten, cimrilik ve korkaklıktan, borç yükünün ağırlığından ve insanların baskısından Sana sığınırım.”',
    anlamEn: '“O Allah, I seek refuge in You from anxiety and sorrow, weakness and laziness, miserliness and cowardice, the burden of debts and being overpowered by men.”',
    kaynakTr: 'Sahîh-i Buhârî, Daavât 36 — Hadis No: 6369',
    kaynakEn: 'Sahih al-Bukhari, Book of Invocations 36 — Hadith 6369',
  ),

  // 4. ŞİFA & AFİYET DUALARI
  DuaModel(
    id: 'peygamber_sifa_duasi',
    kategoriTr: 'Şifa & Afiyet',
    kategoriEn: 'Healing & Well-being',
    baslikTr: 'Peygamber Efendimiz’in (s.a.v.) Şifa Duası',
    baslikEn: 'Prophetic Prayer for Complete Healing',
    arapca: 'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
    okunusTr: 'Allâhümme Rabben-nâsi ezhibil-be’se, işfi enteş-Şâfî, lâ şifâe illâ şifâüke, şifâen lâ yuğâdiru sekamâ.',
    anlamTr: '“Ey insanların Rabbi olan Allah’ım! Bu ızdırabı ve hastalığı gider. Şifa ver, çünkü gerçek Şâfî (şifa veren) Sensin. Senin şifandan başka şifa yoktur; hiçbir hastalık izi bırakmayacak bir şifa ihsan eyle.”',
    anlamEn: '“O Allah, Lord of mankind! Remove the affliction and heal, for You are the Healer. There is no healing except Your healing—a healing that leaves no illness behind.”',
    kaynakTr: 'Sahîh-i Buhârî, Tıb 38 (Hadis No: 5743) & Müslim, Selâm 46',
    kaynakEn: 'Sahih al-Bukhari, Medicine 38 & Sahih Muslim',
  ),
  DuaModel(
    id: 'eyyub_sifa_duasi',
    kategoriTr: 'Şifa & Afiyet',
    kategoriEn: 'Healing & Well-being',
    baslikTr: 'Hz. Eyyûb’un (a.s.) Şifa ve Rahmet Duası',
    baslikEn: 'Prophet Ayyub’s Supplication for Healing',
    arapca: 'رَبِّ إِنِّي مَسَّنِيَ الضُّرُّ وَأَنْتَ أَرْحَمُ الرَّاحِمِينَ',
    okunusTr: 'Rabbi innî messeniyed-durru ve ente erhamür-râhimîn.',
    anlamTr: '“Rabbim! Şüphesiz bana hastalık ve sıkıntı dokundu. Sen ise merhamet edenlerin en merhametlisisin.”',
    anlamEn: '“Indeed, adversity has touched me, and You are the Most Merciful of the merciful.”',
    kaynakTr: 'Kur’an-ı Kerim — Enbiyâ Suresi, 83. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah Al-Anbiya, 21:83',
    globalAyetNo: 2566,
  ),

  // 5. RIZIK & BEREKET DUALARI
  DuaModel(
    id: 'helal_rizik_duasi',
    kategoriTr: 'Rızık & Bereket',
    kategoriEn: 'Provision & Barakah',
    baslikTr: 'Helal Rızık ve Gönül Zenginliği Duası',
    baslikEn: 'Supplication for Lawful Provision & Sufficiency',
    arapca: 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
    okunusTr: 'Allâhümmekfinî bi-halâlike an harâmik, ve ağninî bi-fadlike ammen sivâk.',
    anlamTr: '“Allah’ım! Bana helal rızkınla yetinmeyi nasip ederek beni haramlardan koru ve lütfunla beni Senden başkasına muhtaç etme.”',
    anlamEn: '“O Allah, suffice me with what You have made lawful against what You have made unlawful, and enrich me by Your grace so that I need none selain You.”',
    kaynakTr: 'Sünen-i Tirmizî, Daavât 110 — Hadis No: 3563',
    kaynakEn: 'Jami’ at-Tirmidhi, Invocations 110 — Hadith 3563',
  ),
  DuaModel(
    id: 'faydali_ilim_temiz_rizik',
    kategoriTr: 'Rızık & Bereket',
    kategoriEn: 'Provision & Barakah',
    baslikTr: 'Faydalı İlim, Temiz Rızık ve Makbul Amel Duası',
    baslikEn: 'Morning Prayer for Knowledge, Provision & Accepted Deeds',
    arapca: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا',
    okunusTr: 'Allâhümme innî es’elüke ilmen nâfian, ve rızkan tayyiben, ve amelen mütekabbelâ.',
    anlamTr: '“Allah’ım! Senden faydalı bir ilim, helal ve temiz bir rızık ve katında kabul olunan salih bir amel diliyorum.”',
    anlamEn: '“O Allah, I ask You for beneficial knowledge, pure provision, and deeds that are accepted.”',
    kaynakTr: 'Sünen-i İbn Mâce, İkâme 32 — Hadis No: 925',
    kaynakEn: 'Sunan Ibn Majah, Hadith 925',
  ),

  // 6. SABAH & AKŞAM DUALARI
  DuaModel(
    id: 'sabah_aksam_afiyet',
    kategoriTr: 'Sabah & Akşam',
    kategoriEn: 'Morning & Evening',
    baslikTr: 'Sabah ve Akşam Dünya-Ahiret Afiyet Duası',
    baslikEn: 'Morning & Evening Prayer for Pardon and Well-Being',
    arapca: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
    okunusTr: 'Allâhümme innî es’elükel-afve vel-âfiyete fid-dünyâ vel-âhirah.',
    anlamTr: '“Allah’ım! Senden dünyada ve ahirette af, mağfiret ve tam bir afiyet (sağlık ve huzur) dilerim.”',
    anlamEn: '“O Allah, I ask You for pardon and well-being in this world and in the Hereafter.”',
    kaynakTr: 'Sünen-i Ebû Dâvûd, Edeb 101 — Hadis No: 5074',
    kaynakEn: 'Sunan Abi Dawud, Hadith 5074',
  ),
  DuaModel(
    id: 'hasbiyallahu',
    kategoriTr: 'Sabah & Akşam',
    kategoriEn: 'Morning & Evening',
    baslikTr: 'Tevekkül Duası (Hasbiyallâhu Lâ İlâhe İllâ Hû)',
    baslikEn: 'Prayer of Reliance upon Allah (HasbiyAllahu)',
    arapca: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ ۖ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    okunusTr: 'Hasbiyallâhu lâ ilâhe illâ hû, aleyhi tevekkeltü ve hüve Rabbül-arşil-azîm.',
    anlamTr: '“Bana Allah yeter! O’ndan başka hiçbir ilâh yoktur. Ben yalnızca O’na tevekkül ettim (güvendim). O, yüce Arş’ın Rabbidir.”',
    anlamEn: '“Sufficient for me is Allah; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne.”',
    kaynakTr: 'Kur’an-ı Kerim — Tevbe Suresi, 129. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah At-Tawbah, 9:129',
    globalAyetNo: 1364,
  ),

  // 7. İSTİĞFAR & TÖVBE DUALARI
  DuaModel(
    id: 'seyyidul_istigfar',
    kategoriTr: 'İstiğfar & Tövbe',
    kategoriEn: 'Istighfar & Repentance',
    baslikTr: 'Seyyidü’l-İstiğfar (İstiğfarların Efendisi)',
    baslikEn: 'Sayyid al-Istighfar (The Master Supplication for Forgiveness)',
    arapca: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    okunusTr: 'Allâhümme ente Rabbî lâ ilâhe illâ ente halaktenî ve ene abdüke ve ene alâ ahdike ve va’dike mesteta’tü. Eûzü bike min şerri mâ sana’tü, ebûü leke bi-ni’metike aleyye ve ebûü bi-zenbî fağfirlî fe-innehû lâ yağfiruz-zünûbe illâ ente.',
    anlamTr: '“Allah’ım! Sen benim Rabbimsin, Senden başka ilâh yoktur. Beni Sen yarattın ve ben Senin kulunum. Gücüm yettiğince Sana verdiğim söz ve vaad üzereyim. Yaptığım hataların şerrinden Sana sığınırım. Üzerimdeki nimetini itiraf eder, günahımı da ikrar ederim. Beni bağışla; çünkü günahları Senden başka bağışlayacak hiç kimse yoktur.”',
    anlamEn: '“O Allah, You are my Lord, there is none worthy of worship except You. You created me and I am Your servant... Forgive me, for none forgives sins except You.”',
    kaynakTr: 'Sahîh-i Buhârî, Daavât 2 — Hadis No: 6306',
    kaynakEn: 'Sahih al-Bukhari, Invocations 2 — Hadith 6306',
  ),
];

// ============================================================================
// GÜNLÜK DUALAR & RABBENA DUALARI LİSTE BİLEŞENİ
// ============================================================================

class DualarVeRabbenaListeWidget extends StatefulWidget {
  final Color arkaPlan;
  final Color kartRengi;
  final Color vurguAltin;
  final Color yumusakAltin;
  final Color yaziRengi;
  final Color ikincilYazi;
  final String dil;

  const DualarVeRabbenaListeWidget({
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
  State<DualarVeRabbenaListeWidget> createState() => _DualarVeRabbenaListeWidgetState();
}

class _DualarVeRabbenaListeWidgetState extends State<DualarVeRabbenaListeWidget> {
  String _seciliKategori = 'Tümü';
  String _arama = '';

  void _duaSesliDinle(DuaModel dua) {
    if (dua.globalAyetNo != null) {
      KuranSesOynaticiServisi.tekAyetOynatDuraklat(
        globalAyetNo: dua.globalAyetNo!,
        kartId: 'dua_${dua.id}',
      );
    } else {
      ZikirmatikHafizaServisi.sesliOkut(dua.arapca);
    }
  }

  void _duaPaylas(DuaModel dua, int index) {
    final palet = kReelsArkaPlanPaletleri[(index + 5) % kReelsArkaPlanPaletleri.length];
    final kart = DinamikReelsKart(
      id: 'dua_story_${dua.id}',
      ayetMi: dua.globalAyetNo != null,
      globalAyetNo: dua.globalAyetNo,
      arapcaMetin: dua.arapca,
      konuTr: '${dua.kategoriTr} • ${dua.baslikTr}',
      konuEn: '${dua.kategoriEn} • ${dua.baslikEn}',
      mealTr: dua.anlamTr,
      mealEn: dua.anlamEn,
      kaynakKisaTr: dua.baslikTr,
      kaynakKisaEn: dua.baslikEn,
      dogrulanmisTr: 'Doğrulanmış Kaynak: ${dua.kaynakTr}',
      dogrulanmisEn: 'Verified Source: ${dua.kaynakEn}',
      tefsirTr: 'Okunuşu: ${dua.okunusTr}',
      tefsirEn: 'Transliteration: ${dua.okunusTr}',
      arkaPlanRenkleri: palet,
      desenIndex: index % 8,
    );
    PaylasimStoryBottomSheet.goster(context, kart, widget.dil);
  }

  @override
  Widget build(BuildContext context) {
    final dil = widget.dil;
    final filtrelenmis = kTumDualar.where((d) {
      final katUygun = _seciliKategori == 'Tümü' || d.kategoriTr == _seciliKategori;
      if (!katUygun) return false;
      if (_arama.trim().isEmpty) return true;
      final q = _arama.toLowerCase();
      return d.baslikTr.toLowerCase().contains(q) ||
          d.baslikEn.toLowerCase().contains(q) ||
          d.kategoriTr.toLowerCase().contains(q) ||
          d.anlamTr.toLowerCase().contains(q) ||
          d.okunusTr.toLowerCase().contains(q) ||
          d.kaynakTr.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        // 1. Arama Çubuğu
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _arama = v),
            style: TextStyle(color: widget.yaziRengi, fontSize: 14),
            decoration: InputDecoration(
              hintText: dil == 'EN'
                  ? 'Search Duas (e.g. Rabbana, Healing, Exam, Provision)...'
                  : dil == 'AR'
                      ? 'ابحث في الأدعية المأثورة والقرآنية...'
                      : 'Dualar içinde ara (Örn: Rabbena, Şifa, Sınav, Rızık, İstiğfar)...',
              hintStyle: TextStyle(color: widget.ikincilYazi, fontSize: 12.5),
              prefixIcon: Icon(Icons.search_rounded, color: widget.vurguAltin),
              filled: true,
              fillColor: widget.kartRengi,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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

        // 2. Yatay Kategori Seçici Çipler
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: kDuaKategorileriTr.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final kat = kDuaKategorileriTr[idx];
              final secili = _seciliKategori == kat;
              return ChoiceChip(
                label: Text(
                  kat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: secili ? widget.arkaPlan : widget.yaziRengi,
                  ),
                ),
                selected: secili,
                selectedColor: widget.vurguAltin,
                backgroundColor: widget.kartRengi,
                showCheckmark: false,
                onSelected: (_) => setState(() => _seciliKategori = kat),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // 3. Kategorili Dualar Listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: filtrelenmis.length,
            itemBuilder: (context, idx) {
              final dua = filtrelenmis[idx];
              final baslik = dil == 'EN' ? dua.baslikEn : dua.baslikTr;
              final anlam = dil == 'EN' ? dua.anlamEn : dua.anlamTr;
              final kaynak = dil == 'EN' ? dua.kaynakEn : dua.kaynakTr;
              final kategori = dil == 'EN' ? dua.kategoriEn : dua.kategoriTr;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: widget.kartRengi,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.vurguAltin.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.45)),
                          ),
                          child: Text(
                            kategori,
                            style: TextStyle(
                              color: widget.vurguAltin,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ValueListenableBuilder<bool>(
                              valueListenable: KuranSesOynaticiServisi.caliyorMu,
                              builder: (context, caliyor, _) {
                                return ValueListenableBuilder<int?>(
                                  valueListenable: KuranSesOynaticiServisi.aktifGlobalAyetNo,
                                  builder: (context, aktifNo, _) {
                                    final buCaliyor = caliyor &&
                                        dua.globalAyetNo != null &&
                                        aktifNo == dua.globalAyetNo;
                                    return OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: widget.vurguAltin,
                                        side: BorderSide(
                                          color: widget.vurguAltin.withValues(alpha: 0.5),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () => _duaSesliDinle(dua),
                                      icon: Icon(
                                        buCaliyor
                                            ? Icons.pause_circle_filled_rounded
                                            : Icons.volume_up_rounded,
                                        size: 16,
                                      ),
                                      label: Text(
                                        buCaliyor
                                            ? 'Duraklat'
                                            : (dil == 'EN'
                                                ? 'Listen'
                                                : dil == 'AR'
                                                    ? 'استمع'
                                                    : 'Sesli Dinle'),
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Story / WhatsApp Paylaş',
                              onPressed: () => _duaPaylas(dua, idx),
                              icon: Icon(
                                Icons.ios_share_rounded,
                                color: widget.vurguAltin,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      baslik,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: widget.yaziRengi,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dua.arapca,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 26,
                        height: 1.75,
                        color: widget.yumusakAltin,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: widget.arkaPlan.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Okunuşu: ${dua.okunusTr}',
                        style: TextStyle(
                          color: widget.ikincilYazi,
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      anlam,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        color: widget.yaziRengi,
                        fontSize: 14.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.verified_outlined, size: 14, color: widget.vurguAltin),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            kaynak,
                            style: TextStyle(
                              color: widget.vurguAltin,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
