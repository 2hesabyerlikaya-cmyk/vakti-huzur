import 'reklam_servisi.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'web_shim_io.dart' if (dart.library.js_interop) 'package:web/web.dart' as web;
import 'translations_and_logo.dart';

// ============================================================================
// GÜNLÜK İSLAMİ QUİZ MODELİ VE SORU HAVUZU
// ============================================================================

class QuizSoruModel {
  final int id;
  final String kategoriTr;
  final String kategoriEn;
  final String kategoriAr;
  final String soruTr;
  final String soruEn;
  final String soruAr;
  final List<String> seceneklerTr;
  final List<String> seceneklerEn;
  final List<String> seceneklerAr;
  final int dogruIndex; // 0, 1, 2, 3
  final String aciklamaTr;
  final String aciklamaEn;

  const QuizSoruModel({
    required this.id,
    required this.kategoriTr,
    required this.kategoriEn,
    required this.kategoriAr,
    required this.soruTr,
    required this.soruEn,
    required this.soruAr,
    required this.seceneklerTr,
    required this.seceneklerEn,
    required this.seceneklerAr,
    required this.dogruIndex,
    required this.aciklamaTr,
    required this.aciklamaEn,
  });

  String soru(String dil) => dil == 'EN' ? soruEn : dil == 'AR' ? soruAr : soruTr;
  String kategori(String dil) => dil == 'EN' ? kategoriEn : dil == 'AR' ? kategoriAr : kategoriTr;
  List<String> secenekler(String dil) => dil == 'EN' ? seceneklerEn : dil == 'AR' ? seceneklerAr : seceneklerTr;
  String aciklama(String dil) => dil == 'EN' ? aciklamaEn : aciklamaTr;
}

/// Zengin İslami Soru Havuzu (Siyer, Kur'an-ı Kerim, Fıkıh, Akâid, Sahabe, Ahlak)
const List<QuizSoruModel> kIslamiSoruHavuzu = [
  QuizSoruModel(
    id: 1,
    kategoriTr: "Kur'an-ı Kerim",
    kategoriEn: "Holy Quran",
    kategoriAr: "القرآن الكريم",
    soruTr: "Kur'an-ı Kerim'in 'Kur'an'ın Kalbi' olarak nitelendirilen suresi hangisidir?",
    soruEn: "Which surah is known as the 'Heart of the Quran'?",
    soruAr: "أي سورة تُعرف بـ 'قلب القرآن'؟",
    seceneklerTr: ["Yâsîn Suresi", "Fâtiha Suresi", "İhlâs Suresi", "Rahmân Suresi"],
    seceneklerEn: ["Surah Ya-Sin", "Surah Al-Fatihah", "Surah Al-Ikhlas", "Surah Ar-Rahman"],
    seceneklerAr: ["سورة يس", "سورة الفاتحة", "سورة الإخلاص", "سورة الرحمن"],
    dogruIndex: 0,
    aciklamaTr: "Peygamber Efendimiz (s.a.v.) 'Her şeyin bir kalbi vardır; Kur'an'ın kalbi de Yâsîn'dir' buyurmuştur (Tirmizî, Sevâbü'l-Kur'an, 7).",
    aciklamaEn: "The Prophet (pbuh) said: 'Everything has a heart, and the heart of the Quran is Ya-Sin' (Tirmidhi).",
  ),
  QuizSoruModel(
    id: 2,
    kategoriTr: "Siyer & Peygamberimiz",
    kategoriEn: "Prophetic Seerah",
    kategoriAr: "السيرة النبوية",
    soruTr: "Peygamberimiz Hz. Muhammed'e (s.a.v.) inen ilk ayetler hangi surede yer almaktadır?",
    soruEn: "In which surah were the first verses revealed to Prophet Muhammad (pbuh)?",
    soruAr: "في أي سورة نزلت أول آيات على النبي محمد صلى الله عليه وسلم؟",
    seceneklerTr: ["Alak Suresi", "Müddessir Suresi", "Fâtiha Suresi", "Kadir Suresi"],
    seceneklerEn: ["Surah Al-Alaq", "Surah Al-Muddathir", "Surah Al-Fatihah", "Surah Al-Qadr"],
    seceneklerAr: ["سورة العلق", "سورة المدثر", "سورة الفاتحة", "سورة القدر"],
    dogruIndex: 0,
    aciklamaTr: "Hira Mağarası'nda Cebrail (a.s.) vasıtasıyla inen ilk vahiy Alak Suresi'nin ilk beş ayetidir: 'Yaratan Rabbinin adıyla oku!'",
    aciklamaEn: "The first revelation in Cave Hira was the first 5 verses of Surah Al-Alaq: 'Read in the name of your Lord who created.'",
  ),
  QuizSoruModel(
    id: 3,
    kategoriTr: "İbadet & Fıkıh",
    kategoriEn: "Worship & Fiqh",
    kategoriAr: "العبادات والفقه",
    soruTr: "İslam'ın beş şartından biri olan zekât, nisap miktarı mala sahip olanlara senede kaç kez farzdır?",
    soruEn: "Zakat, one of the five pillars of Islam, is obligatory how many times per year for eligible wealth?",
    soruAr: "الزكاة، أحد أركان الإسلام الخمسة، كم مرة تجب في العام؟",
    seceneklerTr: ["Yılda 1 kez", "Her ay 1 kez", "Yılda 2 kez", "İki yılda 1 kez"],
    seceneklerEn: ["Once a year", "Once a month", "Twice a year", "Once every two years"],
    seceneklerAr: ["مرة واحدة في السنة", "مرة كل شهر", "مرتان في السنة", "مرة كل سنتين"],
    dogruIndex: 0,
    aciklamaTr: "Zekât, nisap miktarı malın üzerinden bir kamerî yıl (354 gün) geçtikten sonra yılda bir defa verilir.",
    aciklamaEn: "Zakat becomes due once per lunar year after wealth has been held above the nisab threshold for a full year.",
  ),
  QuizSoruModel(
    id: 4,
    kategoriTr: "Sahabe-i Kiram",
    kategoriEn: "Companions (Sahabah)",
    kategoriAr: "الصحابة الكرام",
    soruTr: "Hicret gecesi Peygamberimiz'in (s.a.v.) yatağına yatarak canını feda etmeye hazır olan sahabi kimdir?",
    soruEn: "Which companion risked his life by sleeping in the Prophet's bed during the night of Hijrah?",
    soruAr: "من الصحابي الذي بات في فراش النبي ليلة الهجرة فداءً له؟",
    seceneklerTr: ["Hz. Ali (r.a.)", "Hz. Ebubekir (r.a.)", "Hz. Ömer (r.a.)", "Hz. Osman (r.a.)"],
    seceneklerEn: ["Ali ibn Abi Talib (ra)", "Abu Bakr As-Siddiq (ra)", "Umar ibn Al-Khattab (ra)", "Uthman ibn Affan (ra)"],
    seceneklerAr: ["علي بن أبي طالب رضي الله عنه", "أبو بكر الصديق رضي الله عنه", "عمر بن الخطاب رضي الله عنه", "عثمان بن عفان رضي الله عنه"],
    dogruIndex: 0,
    aciklamaTr: "Hz. Ali (r.a.), müşriklerin suikast planına rağmen Hz. Peygamber'in yatağına yatarak emanetleri sahiplerine teslim etme görevini üstlenmiştir.",
    aciklamaEn: "Ali (ra) willingly slept in the Prophet's bed during the Migration night and later safely returned all trusts to their owners.",
  ),
  QuizSoruModel(
    id: 5,
    kategoriTr: "Kur'an-ı Kerim",
    kategoriEn: "Holy Quran",
    kategoriAr: "القرآن الكريم",
    soruTr: "Kur'an-ı Kerim'in en uzun suresi hangisidir?",
    soruEn: "Which is the longest surah in the Holy Quran?",
    soruAr: "ما هي أطول سورة في القرآن الكريم؟",
    seceneklerTr: ["Bakara Suresi (286 Ayet)", "Âl-i İmrân Suresi", "Nisâ Suresi", "A'râf Suresi"],
    seceneklerEn: ["Surah Al-Baqarah (286 Verses)", "Surah Ali 'Imran", "Surah An-Nisa", "Surah Al-A'raf"],
    seceneklerAr: ["سورة البقرة (٢٨٦ آية)", "سورة آل عمران", "سورة النساء", "سورة الأعراف"],
    dogruIndex: 0,
    aciklamaTr: "Bakara Suresi 286 ayetiyle Kur'an-ı Kerim'in en uzun suresidir ve içinde Âyetü'l-Kürsî yer alır.",
    aciklamaEn: "Surah Al-Baqarah, with 286 verses, is the longest chapter in the Quran and contains Ayat al-Kursi.",
  ),
  QuizSoruModel(
    id: 6,
    kategoriTr: "Akâid & İman",
    kategoriEn: "Aqeedah & Faith",
    kategoriAr: "العقيدة والإيمان",
    soruTr: "Dört büyük melekten biri olan ve tabiat olaylarını idare etmekle görevli melek hangisidir?",
    soruEn: "Which of the four archangels is tasked with managing natural events and provision?",
    soruAr: "أي من الملائكة الأربعة الكبار موكل بالرياح والأمطار والأرزاق؟",
    seceneklerTr: ["Mikâil (a.s.)", "Cebrail (a.s.)", "İsrafil (a.s.)", "Azrail (a.s.)"],
    seceneklerEn: ["Mikaeel (Michael)", "Jibreel (Gabriel)", "Israfeel (Raphael)", "Izraeel (Azrael)"],
    seceneklerAr: ["ميكائيل عليه السلام", "جبريل عليه السلام", "إسرافيل عليه السلام", "عزرائيل عليه السلام"],
    dogruIndex: 0,
    aciklamaTr: "Mikâil (a.s.), Allah'ın izniyle yağmur, rüzgâr ve rızık gibi tabiat olaylarını düzenlemekle görevlidir.",
    aciklamaEn: "Angel Mikaeel is commissioned with natural phenomena such as rain, vegetation, and provisions.",
  ),
  QuizSoruModel(
    id: 7,
    kategoriTr: "Siyer & Peygamberimiz",
    kategoriEn: "Prophetic Seerah",
    kategoriAr: "السيرة النبوية",
    soruTr: "Peygamber Efendimiz'in (s.a.v.) Medine'ye hicretinden sonra devesi Kasvâ'nın çöktüğü arsada inşa edilen mescid hangisidir?",
    soruEn: "Which mosque was built on the land where the Prophet's camel Qaswa knelt in Madinah?",
    soruAr: "أي مسجد بُني في المكان الذي بركت فيه ناقة النبي القصواء بالمدينة؟",
    seceneklerTr: ["Mescid-i Nebevî", "Kuba Mescidi", "Mescid-i Kıbleteyn", "Mescid-i Cum'a"],
    seceneklerEn: ["Al-Masjid an-Nabawi", "Quba Mosque", "Masjid al-Qiblatayn", "Jumu'ah Mosque"],
    seceneklerAr: ["المسجد النبوي الشريف", "مسجد قباء", "مسجد القبلتين", "مسجد الجمعة"],
    dogruIndex: 0,
    aciklamaTr: "Mescid-i Nebevî, iki yetim çocuğa ait olan ve bedeli ödenerek satın alınan arsa üzerine Peygamberimiz ve ashabı tarafından bizzat inşa edilmiştir.",
    aciklamaEn: "Al-Masjid an-Nabawi was constructed by the Prophet (pbuh) and his companions upon reaching central Madinah.",
  ),
  QuizSoruModel(
    id: 8,
    kategoriTr: "Kur'an-ı Kerim",
    kategoriEn: "Holy Quran",
    kategoriAr: "القرآن الكريم",
    soruTr: "Kur'an-ı Kerim'de başında Besmele bulunmayan tek sure hangisidir?",
    soruEn: "Which is the only surah in the Quran that does not begin with Bismillah?",
    soruAr: "ما هي السورة الوحيدة في القرآن التي لا تبدأ بالبسملة؟",
    seceneklerTr: ["Tevbe Suresi", "Enfâl Suresi", "Yûnus Suresi", "Hûd Suresi"],
    seceneklerEn: ["Surah At-Tawbah", "Surah Al-Anfal", "Surah Yunus", "Surah Hud"],
    seceneklerAr: ["سورة التوبة", "سورة الأنفال", "سورة يونس", "سورة هود"],
    dogruIndex: 0,
    aciklamaTr: "Tevbe Suresi müşriklere ültimatom ve savaş ilanıyla başladığı için rahmet ve emân ifadesi olan Besmele ile başlamaz.",
    aciklamaEn: "Surah At-Tawbah begins without Bismillah as it declared severe disavowal and ultimatum towards treaty-breakers.",
  ),
  QuizSoruModel(
    id: 9,
    kategoriTr: "İbadet & Fıkıh",
    kategoriEn: "Worship & Fiqh",
    kategoriAr: "العبادات والفقه",
    soruTr: "Cuma namazının farzı kaç rekâttır?",
    soruEn: "How many rak'ahs is the obligatory (fard) part of Friday prayer?",
    soruAr: "كم عدد ركعات فرض صلاة الجمعة؟",
    seceneklerTr: ["2 Rekât", "4 Rekât", "3 Rekât", "1 Rekât"],
    seceneklerEn: ["2 Rak'ahs", "4 Rak'ahs", "3 Rak'ahs", "1 Rak'ah"],
    seceneklerAr: ["ركعتان", "أربع ركعات", "ثلاث ركعات", "ركعة واحدة"],
    dogruIndex: 0,
    aciklamaTr: "Cuma namazının farzı cemaatle ve imam arkasında kılınan 2 rekâttır; öncesinde hutbe dinlenir.",
    aciklamaEn: "The obligatory (fard) portion of Friday prayer is 2 rak'ahs prayed in congregation following the Khutbah.",
  ),
  QuizSoruModel(
    id: 10,
    kategoriTr: "Peygamberler Tarihi",
    kategoriEn: "Stories of Prophets",
    kategoriAr: "قصص الأنبياء",
    soruTr: "Kur'an'da 'Halîlullah' (Allah'ın Dostu) olarak anılan peygamber kimdir?",
    soruEn: "Which prophet is given the title 'Khaleelullah' (Friend of Allah) in the Quran?",
    soruAr: "من هو النبي الملقب بـ 'خليل الله' في القرآن الكريم؟",
    seceneklerTr: ["Hz. İbrahim (a.s.)", "Hz. Musa (a.s.)", "Hz. İsa (a.s.)", "Hz. Nuh (a.s.)"],
    seceneklerEn: ["Prophet Ibrahim (Abraham)", "Prophet Musa (Moses)", "Prophet Isa (Jesus)", "Prophet Nuh (Noah)"],
    seceneklerAr: ["إبراهيم عليه السلام", "موسى عليه السلام", "عيسى عليه السلام", "نوح عليه السلام"],
    dogruIndex: 0,
    aciklamaTr: "Nisâ Suresi 125. ayette: 'Allah İbrahim'i dost (halîl) edinmiştir' buyrulmaktadır.",
    aciklamaEn: "The Quran states in An-Nisa 125: 'And Allah took Ibrahim as an intimate friend.'",
  ),
  QuizSoruModel(
    id: 11,
    kategoriTr: "Kur'an-ı Kerim",
    kategoriEn: "Holy Quran",
    kategoriAr: "القرآن الكريم",
    soruTr: "Kur'an-ı Kerim'in 'Ümmü'l-Kitâb' (Kitabın Anası) olarak bilinen ilk suresi hangisidir?",
    soruEn: "Which surah is known as 'Umm al-Kitab' (Mother of the Book)?",
    soruAr: "أي سورة تُعرف بـ 'أم الكتاب'؟",
    seceneklerTr: ["Fâtiha Suresi", "Bakara Suresi", "İhlâs Suresi", "Âl-i İmrân Suresi"],
    seceneklerEn: ["Surah Al-Fatihah", "Surah Al-Baqarah", "Surah Al-Ikhlas", "Surah Ali 'Imran"],
    seceneklerAr: ["سورة الفاتحة", "سورة البقرة", "سورة الإخلاص", "سورة آل عمران"],
    dogruIndex: 0,
    aciklamaTr: "Fâtiha Suresi Kur'an'ın özünü ve tüm manasını ihtiva ettiği için 'Ümmü'l-Kitâb' ve 'Seb'ul-Mesânî' unvanlarıyla anılır.",
    aciklamaEn: "Surah Al-Fatihah embodies the essence of the Quran and is titled Umm al-Kitab.",
  ),
  QuizSoruModel(
    id: 12,
    kategoriTr: "Siyer & Peygamberimiz",
    kategoriEn: "Prophetic Seerah",
    kategoriAr: "السيرة النبوية",
    soruTr: "Peygamber Efendimiz (s.a.v.) Veda Haccı'nı hicretin kaçıncı yılında ifa etmiştir?",
    soruEn: "In which year of the Hijrah did Prophet Muhammad (pbuh) perform the Farewell Pilgrimage?",
    soruAr: "في أي سنة هجرية أدى النبي صلى الله عليه وسلم حجة الوداع؟",
    seceneklerTr: ["Hicretin 10. Yılı", "Hicretin 8. Yılı", "Hicretin 9. Yılı", "Hicretin 11. Yılı"],
    seceneklerEn: ["10th Year AH", "8th Year AH", "9th Year AH", "11th Year AH"],
    seceneklerAr: ["السنة العاشرة للهجرة", "السنة الثامنة للهجرة", "السنة التاسعة للهجرة", "السنة الحادية عشرة"],
    dogruIndex: 0,
    aciklamaTr: "Peygamberimiz (s.a.v.) Hicretin 10. yılında 100 bini aşkın ashabıyla Veda Haccı'nı gerçekleştirmiş ve Veda Hutbesi'ni irad etmiştir.",
    aciklamaEn: "The Farewell Pilgrimage took place in the 10th year of the Islamic calendar with over 100,000 companions.",
  ),
  QuizSoruModel(
    id: 13,
    kategoriTr: "Ahlak & Hadis",
    kategoriEn: "Ethics & Hadith",
    kategoriAr: "الأخلاق والحديث",
    soruTr: "'Müslüman, elinden ve dilinden diğer Müslümanların emin olduğu kimsedir' hadisi hangi temel esere aittir?",
    soruEn: "'A true Muslim is the one from whose tongue and hand others are safe.' In which works is this recorded?",
    soruAr: "'المسلم من سلم المسلمون من لسانه ويده'. في أي الصحاح ورد هذا الحديث؟",
    seceneklerTr: ["Sahih-i Buhârî & Müslim", "Sünen-i Dârimî", "Muvatta", "Müsned-i Zeyd"],
    seceneklerEn: ["Sahih al-Bukhari & Muslim", "Sunan ad-Darimi", "Muwatta Imam Malik", "Musnad of Zayd"],
    seceneklerAr: ["صحيح البخاري ومسلم", "سنن الدارمي", "موطأ الإمام مالك", "مسند زيد"],
    dogruIndex: 0,
    aciklamaTr: "Bu sahih hadis-i şerif İslam ahlakının temel taşlarından biridir ve müttefekun aleyhtir (Buhârî, İman, 4; Müslim, İman, 64).",
    aciklamaEn: "Agreed upon by Bukhari and Muslim, this is a cornerstone teaching on Islamic ethics and social harmony.",
  ),
  QuizSoruModel(
    id: 14,
    kategoriTr: "İbadet & Fıkıh",
    kategoriEn: "Worship & Fiqh",
    kategoriAr: "العبادات والفقه",
    soruTr: "Oruç tutmaya niyetlenen kişinin imsak vaktinden önce yediği berekete vesile olan yemeğe ne ad verilir?",
    soruEn: "What is the pre-dawn meal eaten by fasting believers before Fajr called?",
    soruAr: "ما اسم الوجبة المباركة التي يتناولها الصائم قبل طلوع الفجر؟",
    seceneklerTr: ["Sahur", "İftar", "Kuşluk", "Teheccüd"],
    seceneklerEn: ["Suhur", "Iftar", "Duha", "Tahajjud"],
    seceneklerAr: ["السحور", "الإفطار", "الضحى", "التهجد"],
    dogruIndex: 0,
    aciklamaTr: "Peygamberimiz 'Sahura kalkın, zira sahurda bereket vardır' buyurmuştur (Buhârî, Savm, 20).",
    aciklamaEn: "The Prophet (pbuh) said: 'Take the Suhur meal, for indeed there is blessing in Suhur' (Bukhari).",
  ),
  QuizSoruModel(
    id: 15,
    kategoriTr: "Kur'an-ı Kerim",
    kategoriEn: "Holy Quran",
    kategoriAr: "القرآن الكريم",
    soruTr: "Kur'an-ı Kerim'de kaç cüz ve kaç sure bulunmaktadır?",
    soruEn: "How many Juz (parts) and Surahs (chapters) are in the Holy Quran?",
    soruAr: "كم جزءاً وكم سورة في القرآن الكريم؟",
    seceneklerTr: ["30 Cüz - 114 Sure", "30 Cüz - 110 Sure", "28 Cüz - 114 Sure", "30 Cüz - 112 Sure"],
    seceneklerEn: ["30 Juz - 114 Surahs", "30 Juz - 110 Surahs", "28 Juz - 114 Surahs", "30 Juz - 112 Surahs"],
    seceneklerAr: ["٣٠ جزءاً - ١١٤ سورة", "٣٠ جزءاً - ١١٠ سور", "٢٨ جزءاً - ١١٤ سورة", "٣٠ جزءاً - ١١٢ سورة"],
    dogruIndex: 0,
    aciklamaTr: "Kur'an-ı Kerim 30 eşit cüzden ve 114 sureden teşekkül etmektedir; toplam 6236 ayettir.",
    aciklamaEn: "The Quran contains 30 parts (juz) and 114 chapters (surahs) totaling 6,236 verses.",
  ),
  QuizSoruModel(
    id: 16,
    kategoriTr: "Peygamberler Tarihi",
    kategoriEn: "Stories of Prophets",
    kategoriAr: "قصص الأنبياء",
    soruTr: "Büyük tufanda gemi inşa ederek inananları ve hayvan çiftlerini kurtaran ulu'l-azm peygamber kimdir?",
    soruEn: "Which resolute prophet built the Ark by divine command to save believers from the great deluge?",
    soruAr: "من هو النبي من أولي العزم الذي بنى السفينة بأمر الله لإنقاذ المؤمنين من الطوفان؟",
    seceneklerTr: ["Hz. Nuh (a.s.)", "Hz. Hud (a.s.)", "Hz. Salih (a.s.)", "Hz. Lut (a.s.)"],
    seceneklerEn: ["Prophet Nuh (Noah)", "Prophet Hud", "Prophet Salih", "Prophet Lut (Lot)"],
    seceneklerAr: ["نوح عليه السلام", "هود عليه السلام", "صالح عليه السلام", "لوط عليه السلام"],
    dogruIndex: 0,
    aciklamaTr: "Hz. Nuh (a.s.), kavmini 950 yıl tevhide davet etmiş ve ilahi emirle tufan gemisini inşa etmiştir.",
    aciklamaEn: "Prophet Nuh (as) called his people to monotheism for nearly a millennium and constructed the Ark.",
  ),
  QuizSoruModel(
    id: 17,
    kategoriTr: "İbadet & Fıkıh",
    kategoriEn: "Worship & Fiqh",
    kategoriAr: "العبادات والفقه",
    soruTr: "Günde beş vakit namaz hicret öncesi hangi mübarek gecede farz kılınmıştır?",
    soruEn: "On which blessed night before the Hijrah were the five daily prayers made obligatory?",
    soruAr: "في أي ليلة مباركة فُرضت الصلوات الخمس قبل الهجرة؟",
    seceneklerTr: ["İsrâ ve Mi'râc Gecesi", "Kadir Gecesi", "Berat Gecesi", "Mevlid Kandili"],
    seceneklerEn: ["The Night of Isra and Mi'raj", "Laylat al-Qadr", "Laylat al-Bara'at", "Mawlid an-Nabi"],
    seceneklerAr: ["ليلة الإسراء والمعراج", "ليلة القدر", "ليلة النصف من شعبان", "المولد النبوي"],
    dogruIndex: 0,
    aciklamaTr: "Beş vakit namaz, Peygamberimiz'in semaya yükseldiği Mi'râc hadisesinde vasıtasız olarak farz kılınmıştır.",
    aciklamaEn: "The five daily prayers were ordained directly by Allah during the miraculous Ascension (Mi'raj).",
  ),
  QuizSoruModel(
    id: 18,
    kategoriTr: "Kur'an-ı Kerim",
    kategoriEn: "Holy Quran",
    kategoriAr: "القرآن الكريم",
    soruTr: "Tevhid inancını en veciz ve berrak şekilde açıklayan 'De ki: O Allah tektir' ayetiyle başlayan sure hangisidir?",
    soruEn: "Which surah defines pure monotheism, starting with 'Say, He is Allah, [who is] One'?",
    soruAr: "أي سورة توضح عقيدة التوحيد الصافية وتبدأ بـ 'قُلْ هُوَ اللَّهُ أَحَدٌ'؟",
    seceneklerTr: ["İhlâs Suresi", "Felak Suresi", "Nâs Suresi", "Kâfirûn Suresi"],
    seceneklerEn: ["Surah Al-Ikhlas", "Surah Al-Falaq", "Surah An-Nas", "Surah Al-Kafirun"],
    seceneklerAr: ["سورة الإخلاص", "سورة الفلق", "سورة الناس", "سورة الكافرون"],
    dogruIndex: 0,
    aciklamaTr: "İhlâs Suresi Kur'an'ın üçte birine denk fazilete sahip olup tevhidin en berrak ifadesidir.",
    aciklamaEn: "Surah Al-Ikhlas is considered equivalent to one-third of the Quran in virtue and core theological meaning.",
  ),
  QuizSoruModel(
    id: 19,
    kategoriTr: "Siyer & Peygamberimiz",
    kategoriEn: "Prophetic Seerah",
    kategoriAr: "السيرة النبوية",
    soruTr: "Peygamberimiz'in (s.a.v.) Medine'ye teşriflerinde ilk ev sahipliği yapan ve kabri İstanbul Eyüpsultan'da bulunan büyük sahabi kimdir?",
    soruEn: "Which revered companion hosted the Prophet upon arriving in Madinah, whose tomb is in Istanbul?",
    soruAr: "من هو الصحابي الجليل الذي استضاف النبي في المدينة وقبره اليوم في إسطنبول؟",
    seceneklerTr: ["Ebu Eyyûb el-Ensârî (r.a.)", "Sa'd b. Muaz (r.a.)", "Enes b. Malik (r.a.)", "Mus'ab b. Umeyr (r.a.)"],
    seceneklerEn: ["Abu Ayyub al-Ansari (ra)", "Sa'd ibn Mu'adh (ra)", "Anas ibn Malik (ra)", "Mus'ab ibn 'Umayr (ra)"],
    seceneklerAr: ["أبو أيوب الأنصاري رضي الله عنه", "سعد بن معاذ رضي الله عنه", "أنس بن مالك رضي الله عنه", "مصعب بن عمير رضي الله عنه"],
    dogruIndex: 0,
    aciklamaTr: "Halid b. Zeyd Ebu Eyyûb el-Ensârî (r.a.), Mescid-i Nebevî yapılana kadar Peygamberimiz'i 7 ay evinde ağırlamıştır.",
    aciklamaEn: "Abu Ayyub al-Ansari hosted the Prophet (pbuh) for seven months until his home adjacent to the mosque was ready.",
  ),
  QuizSoruModel(
    id: 20,
    kategoriTr: "Akâid & İman",
    kategoriEn: "Aqeedah & Faith",
    kategoriAr: "العقيدة والإيمان",
    soruTr: "İmanın altı şartından biri olan 'Kadere İman' neyi ifade eder?",
    soruEn: "What does belief in 'Qadar' (Divine Decree), the 6th pillar of Iman, entail?",
    soruAr: "ماذا يعني الإيمان بالقدر، الركن السادس من أركان الإيمان؟",
    seceneklerTr: [
      "Hayır ve şerrin Allah'ın ilmi, iradesi ve takdiriyle olduğuna inanmak",
      "Sadece peygamberlere inanmak",
      "Sadece ölümden sonraki hayata inanmak",
      "Yalnızca meleklere inanmak"
    ],
    seceneklerEn: [
      "Belief that all good and decree unfold with Allah's knowledge and will",
      "Belief only in Prophets",
      "Belief only in the Hereafter",
      "Belief only in Angels"
    ],
    seceneklerAr: [
      "الإيمان بأن كل خير وشر يجري بعلم الله وإرادته ومشيئته",
      "الإيمان بالأنبياء فقط",
      "الإيمان باليوم الآخر فقط",
      "الإيمان بالملائكة فقط"
    ],
    dogruIndex: 0,
    aciklamaTr: "Kadere iman; kâinatta meydana gelen her şeyin Allah'ın ezeli ilmi, iradesi ve yaratması ile gerçekleştiğini tasdik etmektir.",
    aciklamaEn: "Belief in divine decree means submitting that everything in the cosmos occurs according to God's eternal knowledge and creative will.",
  ),
];

// ============================================================================
// GÜNLÜK 5 SORUYU BELİRLEYEN VE DEVAMLI TUTAN SERVİS
// ============================================================================

class GunlukQuizServisi {
  static const String _storagePrefix = 'vakti_huzur_quiz_gun_';

  static String bugunKodu() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Her gün için deterministik (aynı gün herkes aynı 5 soruyu çözer) 5 soru seçer
  static List<QuizSoruModel> bugununSorulari() {
    final now = DateTime.now();
    final gunSayisi = now.year * 365 + now.month * 31 + now.day;
    final havuz = List<QuizSoruModel>.from(kIslamiSoruHavuzu);
    final secilenler = <QuizSoruModel>[];

    int index = gunSayisi % havuz.length;
    for (int i = 0; i < 5; i++) {
      secilenler.add(havuz[(index + i * 3) % havuz.length]);
    }
    return secilenler;
  }

  /// Bugünün quiz tamamlanma durumunu okur
  static Map<String, dynamic>? bugununDurumunuYukle() {
    try {
      final raw = web.window.localStorage.getItem('$_storagePrefix${bugunKodu()}');
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Bugünün quiz skorunu kalıcı kaydeder
  static void bugununDurumunuKaydet({
    required int dogruSayisi,
    required List<int?> secilenCevaplar,
  }) {
    try {
      final veri = jsonEncode({
        'tamamlandi': true,
        'skor': dogruSayisi,
        'tarih': bugunKodu(),
        'cevaplar': secilenCevaplar,
      });
      web.window.localStorage.setItem('$_storagePrefix${bugunKodu()}', veri);
    } catch (_) {}
  }
}

// ============================================================================
// QUİZ EKRANI (WIDGET)
// ============================================================================

class GunlukIslamiQuizSekmesi extends StatefulWidget {
  final ModernTema tema;
  final String dil;
  final VoidCallback onMenuAc;

  const GunlukIslamiQuizSekmesi({
    super.key,
    required this.tema,
    required this.dil,
    required this.onMenuAc,
  });

  @override
  State<GunlukIslamiQuizSekmesi> createState() => _GunlukIslamiQuizSekmesiState();
}

class _GunlukIslamiQuizSekmesiState extends State<GunlukIslamiQuizSekmesi> {
  late List<QuizSoruModel> _sorular;
  int _aktifSoruIndex = 0;
  final List<int?> _secilenCevaplar = [null, null, null, null, null];
  bool _cevapVerildi = false;
  bool _tamamlandi = false;
  int _skor = 0;
  Timer? _geceSayaci;
  Duration _kalanSure = Duration.zero;

  @override
  void initState() {
    super.initState();
    _sorulariYukle();
    _geceSayaciniBaslat();
  }

  @override
  void dispose() {
    _geceSayaci?.cancel();
    super.dispose();
  }

  void _geceSayaciniBaslat() {
    _kalanSureyiHesapla();
    _geceSayaci = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _kalanSureyiHesapla();
    });
  }

  void _kalanSureyiHesapla() {
    final now = DateTime.now();
    final yarin = DateTime(now.year, now.month, now.day + 1);
    final fark = yarin.difference(now);
    setState(() => _kalanSure = fark);
  }

  void _sorulariYukle() {
    _sorular = GunlukQuizServisi.bugununSorulari();
    final kayitli = GunlukQuizServisi.bugununDurumunuYukle();
    if (kayitli != null && kayitli['tamamlandi'] == true) {
      _tamamlandi = true;
      _skor = kayitli['skor'] as int? ?? 0;
      final rawCevap = kayitli['cevaplar'] as List<dynamic>?;
      if (rawCevap != null) {
        for (int i = 0; i < rawCevap.length && i < 5; i++) {
          _secilenCevaplar[i] = rawCevap[i] as int?;
        }
      }
    }
  }

  void _sikSec(int secenekIndex) {
    if (_cevapVerildi || _tamamlandi) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _secilenCevaplar[_aktifSoruIndex] = secenekIndex;
      _cevapVerildi = true;
      if (secenekIndex == _sorular[_aktifSoruIndex].dogruIndex) {
        _skor++;
      }
    });
  }

  void _sonrakiSoruyaGec() {
    HapticFeedback.selectionClick();
    if (_aktifSoruIndex + 1 < _sorular.length) {
      setState(() {
        _aktifSoruIndex++;
        _cevapVerildi = false;
      });
    } else {
      // 5 soru bitti!
      HapticFeedback.heavyImpact();
      GunlukQuizServisi.bugununDurumunuKaydet(
        dogruSayisi: _skor,
        secilenCevaplar: _secilenCevaplar,
      );
      setState(() {
        _tamamlandi = true;
      });
      // Günlük 5 soru tamamlandığında İslami / Aile Güvenlikli Geçiş Reklamı
      InterstitialReklamYoneticisi.goster();
    }
  }

  void _pratikYenidenBaslat() {
    setState(() {
      _tamamlandi = false;
      _aktifSoruIndex = 0;
      _cevapVerildi = false;
      _skor = 0;
      for (int i = 0; i < 5; i++) {
        _secilenCevaplar[i] = null;
      }
    });
  }

  String _formatKalanSure(Duration d) {
    final s = d.inHours.toString().padLeft(2, '0');
    final dkk = (d.inMinutes % 60).toString().padLeft(2, '0');
    final sn = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$s:$dkk:$sn';
  }

  @override
  Widget build(BuildContext context) {
    final tema = widget.tema;
    final dil = widget.dil;

    return Scaffold(
      backgroundColor: tema.arkaPlan,
      appBar: AppBar(
        backgroundColor: tema.karanlikMi ? tema.arkaPlan : const Color(0xFF0F3D2E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: tema.vurguAltin),
          tooltip: 'Menü',
          onPressed: widget.onMenuAc,
        ),
        title: Row(
          children: [
            ModernIslamiLogo(
              boyut: 28,
              altinRenk: tema.vurguAltin,
              arkaPlanRenk: tema.arkaPlan,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dil == 'EN'
                        ? 'Daily Islamic Quiz'
                        : dil == 'AR'
                            ? 'المسابقة الإسلامية اليومية'
                            : 'Günlük İslami Quiz',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: tema.yaziRengi,
                    ),
                  ),
                  Text(
                    dil == 'EN'
                        ? '5 Questions Every Day'
                        : dil == 'AR'
                            ? '٥ أسئلة يومياً لزيادة المعرفة'
                            : 'Her Gün Yeni 5 Soru ile İlim & Hikmet',
                    style: TextStyle(
                      fontSize: 11,
                      color: tema.vurguAltin.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _tamamlandi ? _skorVeYarinEkrani(tema, dil) : _soruCozumEkrani(tema, dil),
    );
  }

  Widget _soruCozumEkrani(ModernTema tema, String dil) {
    final soru = _sorular[_aktifSoruIndex];
    final seciliSecenek = _secilenCevaplar[_aktifSoruIndex];
    final secenekler = soru.secenekler(dil);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        children: [
          // İlerleme Çubuğu ve Başlık
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: tema.kartRengi,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.3)),
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
                        color: tema.vurguAltin.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        soru.kategori(dil),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: tema.vurguAltin,
                        ),
                      ),
                    ),
                    Text(
                      dil == 'EN'
                          ? 'Question ${_aktifSoruIndex + 1} / 5'
                          : dil == 'AR'
                              ? 'السؤال ${_aktifSoruIndex + 1} من ٥'
                              : 'Soru ${_aktifSoruIndex + 1} / 5',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: tema.yaziRengi,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_aktifSoruIndex + 1) / 5.0,
                    minHeight: 7,
                    backgroundColor: tema.arkaPlan.withValues(alpha: 0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(tema.vurguAltin),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Soru Kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tema.kartRengi,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline_rounded, color: tema.vurguAltin, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      dil == 'EN' ? 'Daily Question' : dil == 'AR' ? 'سؤال اليوم' : 'Günün Sorusu',
                      style: TextStyle(
                        color: tema.vurguAltin,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  soru.soru(dil),
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: tema.yaziRengi,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Şıklar (A, B, C, D)
          for (int i = 0; i < secenekler.length; i++) ...[
            _sikKarti(
              index: i,
              metin: secenekler[i],
              dogruIndex: soru.dogruIndex,
              seciliIndex: seciliSecenek,
              cevapVerildi: _cevapVerildi,
              tema: tema,
              onTap: () => _sikSec(i),
            ),
            const SizedBox(height: 10),
          ],

          // Açıklama ve Sonraki Butonu
          if (_cevapVerildi) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (seciliSecenek == soru.dogruIndex
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFFE74C3C))
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (seciliSecenek == soru.dogruIndex
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE74C3C))
                      .withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    seciliSecenek == soru.dogruIndex
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    color: seciliSecenek == soru.dogruIndex
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFFE74C3C),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seciliSecenek == soru.dogruIndex
                              ? (dil == 'EN' ? 'Correct!' : dil == 'AR' ? 'إجابة صحيحة!' : 'Tebrikler, Doğru Cevap!')
                              : (dil == 'EN' ? 'Incorrect' : dil == 'AR' ? 'إجابة غير صحيحة' : 'Doğru Cevap: ${secenekler[soru.dogruIndex]}'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: seciliSecenek == soru.dogruIndex
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFE74C3C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          soru.aciklama(dil),
                          style: TextStyle(
                            fontSize: 12,
                            color: tema.yaziRengi.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: tema.vurguAltin,
                foregroundColor: tema.arkaPlan,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _sonrakiSoruyaGec,
              icon: Icon(
                _aktifSoruIndex + 1 == 5 ? Icons.star_rounded : Icons.arrow_forward_rounded,
                size: 20,
              ),
              label: Text(
                _aktifSoruIndex + 1 == 5
                    ? (dil == 'EN' ? 'View Today\'s Score' : dil == 'AR' ? 'عرض نتيجة اليوم' : 'Günün Skorunu Gör')
                    : (dil == 'EN' ? 'Next Question' : dil == 'AR' ? 'السؤال التالي' : 'Sonraki Soruya Geç'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sikKarti({
    required int index,
    required String metin,
    required int dogruIndex,
    required int? seciliIndex,
    required bool cevapVerildi,
    required ModernTema tema,
    required VoidCallback onTap,
  }) {
    Color cerceveRenk = tema.vurguAltin.withValues(alpha: 0.25);
    Color arkaRenk = tema.kartRengi;
    Color yaziRenk = tema.yaziRengi;
    IconData? durumIkonu;

    if (cevapVerildi) {
      if (index == dogruIndex) {
        cerceveRenk = const Color(0xFF2ECC71);
        arkaRenk = const Color(0xFF2ECC71).withValues(alpha: 0.2);
        durumIkonu = Icons.check_circle_rounded;
      } else if (index == seciliIndex) {
        cerceveRenk = const Color(0xFFE74C3C);
        arkaRenk = const Color(0xFFE74C3C).withValues(alpha: 0.2);
        durumIkonu = Icons.cancel_rounded;
      }
    }

    final harfler = ['A', 'B', 'C', 'D'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: cevapVerildi ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: arkaRenk,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cerceveRenk, width: cevapVerildi && (index == dogruIndex || index == seciliIndex) ? 1.8 : 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tema.vurguAltin.withValues(alpha: 0.16),
                  border: Border.all(color: cerceveRenk),
                ),
                child: Text(
                  harfler[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: tema.vurguAltin,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  metin,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: yaziRenk,
                  ),
                ),
              ),
              if (durumIkonu != null) ...[
                const SizedBox(width: 8),
                Icon(
                  durumIkonu,
                  color: index == dogruIndex ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // GÜNÜN SKORU VE "YARIN YENİ 5 SORU İÇİN TEKRAR GEL" EKRANI
  // ============================================================================

  Widget _skorVeYarinEkrani(ModernTema tema, String dil) {
    String tebrikMesaji;
    if (_skor == 5) {
      tebrikMesaji = dil == 'EN'
          ? '🌟 Perfect! 5 out of 5! May Allah increase your sacred knowledge.'
          : dil == 'AR'
              ? '🌟 ممتاز! ٥ من ٥ كاملة! زادكم الله علماً ونوراً.'
              : '🌟 Mükemmel! 5\'te 5 Tam Puan! İlim ve maneviyatınız daim olsun.';
    } else if (_skor >= 3) {
      tebrikMesaji = dil == 'EN'
          ? '🌿 Great result! You answered $_skor out of 5 correctly.'
          : dil == 'AR'
              ? '🌿 نتيجة ممتازة! أجبت على $_skor من ٥ أسئلة بشكل صحيح.'
              : '🌿 Gayet Başarılı! 5 sorudan $_skor tanesini doğru bildiniz.';
    } else {
      tebrikMesaji = dil == 'EN'
          ? '📖 A good effort! Every question is a seed of sacred wisdom.'
          : dil == 'AR'
              ? '📖 محاولة مباركة! كل معلومة دينية خطوة نحو النور.'
              : '📖 Güzel bir gayret! Öğrenilen her İslami hakikat bir nurdur.';
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          // Ana Tebrik & Skor Kartı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tema.kartRengi,
                  tema.arkaPlan.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: tema.vurguAltin, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: tema.vurguAltin.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tema.vurguAltin.withValues(alpha: 0.2),
                    border: Border.all(color: tema.vurguAltin, width: 2),
                  ),
                  child: Icon(
                    _skor >= 3 ? Icons.emoji_events_rounded : Icons.workspace_premium_rounded,
                    color: tema.vurguAltin,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  dil == 'EN'
                      ? 'Today\'s Quiz Completed!'
                      : dil == 'AR'
                          ? 'اكتملت مسابقة اليوم!'
                          : 'Günün Quizini Tamamladınız!',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: tema.yaziRengi,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  dil == 'EN' ? 'Your Daily Score:' : dil == 'AR' ? 'نتيجتك اليوم:' : 'Günün Skoru:',
                  style: TextStyle(
                    color: tema.ikincilYazi,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_skor / 5',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: tema.vurguAltin,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tebrikMesaji,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tema.yaziRengi,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // "YARIN YENİ 5 SORU İÇİN TEKRAR GEL" BANNERI VE GERİ SAYIM
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3D2E).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.45)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_rounded, color: tema.vurguAltin, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        dil == 'EN'
                            ? 'Come Back Tomorrow for 5 New Questions!'
                            : dil == 'AR'
                                ? 'عد غداً للحصول على ٥ أسئلة جديدة!'
                                : 'Yarın Yeni 5 Soru İçin Tekrar Gel!',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: tema.yaziRengi,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dil == 'EN'
                      ? 'New questions unlock every midnight. Time remaining:'
                      : dil == 'AR'
                          ? 'تتجدد الأسئلة تلقائياً منتصف الليل. الوقت المتبقي:'
                          : 'Her gece 00:00\'da yeni sorular eklenir. Kalan süre:',
                  style: TextStyle(fontSize: 12, color: tema.ikincilYazi),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: tema.arkaPlan,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _formatKalanSure(_kalanSure),
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: tema.vurguAltin,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pratik Yap (Yeniden Çöz) Butonu
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: tema.vurguAltin.withValues(alpha: 0.6)),
              foregroundColor: tema.vurguAltin,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _pratikYenidenBaslat,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              dil == 'EN'
                  ? 'Retake Today\'s Questions (Practice)'
                  : dil == 'AR'
                      ? 'إعادة حل أسئلة اليوم (تدريب)'
                      : 'Soruları Yeniden Çöz (Pratik Yap)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
          ),
          const SizedBox(height: 20),

          // Bugünün 5 Sorusunun İncelemesi (Review)
          Text(
            dil == 'EN' ? 'Question Review & Tafsir Notes' : dil == 'AR' ? 'مراجعة أسئلة اليوم وتفسيرها' : 'Bugünün Soruları ve Hikmetleri',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: tema.vurguAltin,
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < _sorular.length; i++) ...[
            _soruIncelemeKarti(
              sira: i + 1,
              soru: _sorular[i],
              secilenIdx: _secilenCevaplar[i],
              tema: tema,
              dil: dil,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _soruIncelemeKarti({
    required int sira,
    required QuizSoruModel soru,
    required int? secilenIdx,
    required ModernTema tema,
    required String dil,
  }) {
    final dogruMu = secilenIdx == soru.dogruIndex;
    final secenekler = soru.secenekler(dil);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tema.kartRengi,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tema.vurguAltin.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                dogruMu ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: dogruMu ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$sira. ${soru.soru(dil)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: tema.yaziRengi,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '✓ ${dil == 'EN' ? 'Correct: ' : dil == 'AR' ? 'الصحيح: ' : 'Doğru: '}${secenekler[soru.dogruIndex]}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2ECC71),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            soru.aciklama(dil),
            style: TextStyle(
              fontSize: 11.5,
              color: tema.ikincilYazi,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
