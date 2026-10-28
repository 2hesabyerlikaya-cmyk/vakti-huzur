import 'dualar_ve_rabbena.dart';

// ============================================================================
// GENİŞLETİLMİŞ DUA ARŞİVİ (43 DUA)
// Sabah-Akşam, Şifa, Rızık, Nazar & Korunma ve Namaz Tesbihatı
// ============================================================================

DuaModel _d({
  required String id,
  required String katTr,
  required String katEn,
  required String baslikTr,
  required String baslikEn,
  required String arapca,
  required String okunus,
  required String anlamTr,
  required String anlamEn,
  required String kaynakTr,
  required String kaynakEn,
  int? ayet,
}) {
  return DuaModel(
    id: id,
    kategoriTr: katTr,
    kategoriEn: katEn,
    baslikTr: baslikTr,
    baslikEn: baslikEn,
    arapca: arapca,
    okunusTr: okunus,
    anlamTr: anlamTr,
    anlamEn: anlamEn,
    kaynakTr: kaynakTr,
    kaynakEn: kaynakEn,
    globalAyetNo: ayet,
  );
}

const _sabah = 'Sabah & Akşam';
const _sabahEn = 'Morning & Evening';
const _sifa = 'Şifa & Afiyet';
const _sifaEn = 'Healing & Well-Being';
const _rizik = 'Rızık & Bereket';
const _rizikEn = 'Provision & Barakah';
const _nazar = 'Nazar & Korunma';
const _nazarEn = 'Evil Eye & Protection';
const _tesbihat = 'Namaz Tesbihatı';
const _tesbihatEn = 'Post-Prayer Tasbihat';

final List<DuaModel> kEkDuaArsivi = [
  // ─────────────────────────── SABAH & AKŞAM (10) ───────────────────────────
  _d(
    id: 'ek_asbahna',
    katTr: _sabah,
    katEn: _sabahEn,
    baslikTr: 'Asbahnâ ve Asbahal-Mülkü Lillâh (Sabah Duası)',
    baslikEn: 'We Have Entered the Morning (Morning Supplication)',
    arapca:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    okunus:
        'Asbahnâ ve asbahal-mülkü lillâh, vel-hamdü lillâh, lâ ilâhe illallâhu vahdehû lâ şerîke leh, lehül-mülkü ve lehül-hamdü ve hüve alâ külli şey’in kadîr.',
    anlamTr:
        '“Sabaha erdik, mülk de Allah’ındır. Hamd Allah’a mahsustur. Allah’tan başka ilâh yoktur; O tektir, ortağı yoktur. Mülk O’nundur, hamd O’nadır ve O her şeye kâdirdir.”',
    anlamEn:
        '“We have entered the morning and the dominion belongs to Allah. Praise be to Allah. There is no deity but Allah alone, without partner.”',
    kaynakTr: 'Sahîh-i Müslim, Zikir 75 — Hadis No: 2723',
    kaynakEn: 'Sahih Muslim, Dhikr 75 — Hadith 2723',
  ),
  _d(
    id: 'ek_bike_asbahna',
    katTr: _sabah,
    katEn: _sabahEn,
    baslikTr: 'Allâhümme Bike Asbahnâ (Sabah-Akşam Teslimiyet Duası)',
    baslikEn: 'O Allah, By You We Enter the Morning',
    arapca:
        'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
    okunus:
        'Allâhümme bike asbahnâ, ve bike emseynâ, ve bike nahyâ, ve bike nemûtü ve ileyken-nüşûr.',
    anlamTr:
        '“Allah’ım! Senin (kudretinle) sabaha ve akşama erdik. Seninle yaşar, Seninle ölürüz. Dönüş ancak Sanadır.”',
    anlamEn:
        '“O Allah, by You we enter the morning and the evening, by You we live and die, and to You is the resurrection.”',
    kaynakTr: 'Sünen-i Tirmizî, Daavât 13 — Hadis No: 3391',
    kaynakEn: 'Jami’ at-Tirmidhi, Hadith 3391',
  ),
  _d(
    id: 'ek_bismillahillezi',
    katTr: _sabah,
    katEn: _sabahEn,
    baslikTr: 'Bismillâhillezî Lâ Yedurru (3 Kere — Her Türlü Zarardan Korunma)',
    baslikEn: 'In the Name of Allah With Whose Name Nothing Harms (3x)',
    arapca:
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    okunus:
        'Bismillâhillezî lâ yedurru measmihî şey’ün fil-ardı ve lâ fis-semâi ve hüves-semîul-alîm.',
    anlamTr:
        '“İsmi anıldığında yerde ve gökte hiçbir şeyin zarar veremediği Allah’ın adıyla. O her şeyi işiten ve bilendir.” (Sabah ve akşam 3 kere okuyana o gün hiçbir şey zarar vermez.)',
    anlamEn:
        '“In the name of Allah, with whose name nothing on earth or in heaven can cause harm, and He is the All-Hearing, All-Knowing.”',
    kaynakTr: 'Sünen-i Ebû Dâvûd, Edeb 110 — Hadis No: 5088; Tirmizî 3388',
    kaynakEn: 'Sunan Abi Dawud 5088; Tirmidhi 3388',
  ),
  _d(
    id: 'ek_raditu_billahi',
    katTr: _sabah,
    katEn: _sabahEn,
    baslikTr: 'Radîtü Billâhi Rabben (Rıza Duası — 3 Kere)',
    baslikEn: 'I Am Pleased With Allah as My Lord (3x)',
    arapca:
        'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
    okunus: 'Radîtü billâhi Rabben, ve bil-İslâmi dînen, ve bi-Muhammedin sallallâhu aleyhi ve sellem nebiyyâ.',
    anlamTr:
        '“Rab olarak Allah’tan, din olarak İslâm’dan, peygamber olarak Hz. Muhammed’den (s.a.v.) razı oldum.”',
    anlamEn:
        '“I am pleased with Allah as Lord, Islam as religion, and Muhammad ﷺ as Prophet.”',
    kaynakTr: 'Sünen-i Ebû Dâvûd, Edeb 110 — Hadis No: 5072; Tirmizî 3389',
    kaynakEn: 'Sunan Abi Dawud 5072; Tirmidhi 3389',
  ),
  _d(
    id: 'ek_ya_hayyu_ya_kayyum',
    katTr: _sabah,
    katEn: _sabahEn,
    baslikTr: 'Yâ Hayyu Yâ Kayyûm (Hz. Fâtıma’ya Öğretilen Dua)',
    baslikEn: 'O Ever-Living, O Sustainer (Taught to Fatimah)',
    arapca:
        'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
    okunus:
        'Yâ Hayyu yâ Kayyûm, bi-rahmetike esteğîs, aslih lî şe’nî küllehû ve lâ tekilnî ilâ nefsî tarfete ayn.',
    anlamTr:
        '“Ey diri olan, ey her şeyi ayakta tutan Allah’ım! Rahmetinle yardım diliyorum. Bütün işlerimi düzelt ve beni göz açıp kapayıncaya kadar bile nefsimle baş başa bırakma.”',
    anlamEn:
        '“O Ever-Living, O Sustainer, by Your mercy I seek help. Rectify all my affairs and do not leave me to myself even for the blink of an eye.”',
    kaynakTr: 'Nesâî, es-Sünenü’l-Kübrâ — Hadis No: 10405; Hâkim, el-Müstedrek 1/545',
    kaynakEn: 'An-Nasa’i, as-Sunan al-Kubra 10405; Al-Hakim 1/545',
  ),
  _d(
    id: 'ek_afini_fi_bedeni',
    katTr: _sabah,
    katEn: _sabahEn,
    baslikTr: 'Allâhümme Âfinî Fî Bedenî (Beden, Kulak ve Göz Sağlığı — 3 Kere)',
    baslikEn: 'O Allah, Grant Me Health in My Body (3x)',
    arapca:
        'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَٰهَ إِلَّا أَنْتَ',
    okunus: 'Allâhümme âfinî fî bedenî, Allâhümme âfinî fî sem’î, Allâhümme âfinî fî basarî, lâ ilâhe illâ ente.',
    anlamTr:
        '“Allah’ım! Bedenime afiyet ver. Allah’ım! Kulağıma afiyet ver. Allah’ım! Gözüme afiyet ver. Senden başka ilâh yoktur.”',
    anlamEn:
        '“O Allah, grant me well-being in my body, my hearing and my sight. There is no deity but You.”',
    kaynakTr: 'Sünen-i Ebû Dâvûd, Edeb 110 — Hadis No: 5090',
    kaynakEn: 'Sunan Abi Dawud, Hadith 5090',
  ),
  _d(
    id: 'ek_subhanallahi_ve_bihamdihi_100',
    katTr: _sabah,
    katEn: _sabahEn,
    baslikTr: 'Sübhânallâhi ve Bihamdihî (Sabah-Akşam 100 Kere)',
    baslikEn: 'Glory and Praise Be to Allah (100x)',
    arapca: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    okunus: 'Sübhânallâhi ve bi-hamdihî.',
    anlamTr:
        '“Allah’ı hamd ile tesbih ederim.” (Sabah ve akşam yüz kere söyleyen kimseden daha faziletli bir amelle kıyamet gününe kimse gelemez; ancak onun gibi veya daha fazla söyleyen müstesna.)',
    anlamEn: '“Glory be to Allah and praise be to Him.” (Recited 100 times morning and evening.)',
    kaynakTr: 'Sahîh-i Müslim, Zikir 28 — Hadis No: 2692',
    kaynakEn: 'Sahih Muslim, Dhikr 28 — Hadith 2692',
  ),
  _d(
    id: 'ek_kelimatillahi_tammat',
    katTr: _sabah,
    katEn: _sabahEn,
    baslikTr: 'Eûzü Bi-Kelimâtillâhit-Tâmmât (Akşam 3 Kere)',
    baslikEn: 'I Seek Refuge in the Perfect Words of Allah (Evening 3x)',
    arapca: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    okunus: 'Eûzü bi-kelimâtillâhit-tâmmâti min şerri mâ halak.',
    anlamTr:
        '“Yarattığı şeylerin şerrinden Allah’ın eksiksiz kelimelerine sığınırım.” (Bir yere konaklayıp bunu söyleyene oradan ayrılıncaya kadar hiçbir şey zarar vermez.)',
    anlamEn: '“I seek refuge in the perfect words of Allah from the evil of what He has created.”',
    kaynakTr: 'Sahîh-i Müslim, Zikir 54-55 — Hadis No: 2708-2709',
    kaynakEn: 'Sahih Muslim, Hadith 2708-2709',
  ),
  _d(
    id: 'ek_alimel_gayb',
    katTr: _sabah,
    katEn: _sabahEn,
    baslikTr: 'Allâhümme Âlimel-Ğaybi veş-Şehâdeh (Nefsin Şerrinden Korunma)',
    baslikEn: 'O Allah, Knower of the Unseen and the Seen',
    arapca:
        'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ',
    okunus:
        'Allâhümme âlimel-ğaybi veş-şehâdeh, fâtıras-semâvâti vel-ard, Rabbe külli şey’in ve melîkeh, eşhedü en lâ ilâhe illâ ente, eûzü bike min şerri nefsî ve min şerriş-şeytâni ve şirkih.',
    anlamTr:
        '“Gaybı ve görüneni bilen, gökleri ve yeri yaratan, her şeyin Rabbi ve sahibi olan Allah’ım! Senden başka ilâh olmadığına şahitlik ederim. Nefsimin şerrinden, şeytanın şerrinden ve şirkinden Sana sığınırım.”',
    anlamEn:
        '“O Allah, Knower of the unseen and the seen, Creator of the heavens and earth... I seek refuge in You from the evil of my soul and of Satan.”',
    kaynakTr: 'Sünen-i Ebû Dâvûd, Edeb 110 — Hadis No: 5067; Tirmizî 3392',
    kaynakEn: 'Sunan Abi Dawud 5067; Tirmidhi 3392',
  ),
  _d(
    id: 'ek_ayetel_kursi_sabah',
    katTr: _sabah,
    katEn: _sabahEn,
    baslikTr: 'Âyetü’l-Kürsî (Sabah-Akşam ve Yatmadan Önce)',
    baslikEn: 'Ayat al-Kursi (Morning, Evening & Before Sleep)',
    arapca:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
    okunus:
        'Allâhü lâ ilâhe illâ hüvel-hayyül-kayyûm, lâ te’huzühû sinetün ve lâ nevm, lehû mâ fis-semâvâti ve mâ fil-ard...',
    anlamTr:
        '“Allah, kendisinden başka ilâh olmayandır. Diridir, her şeyi ayakta tutandır. O’nu ne uyuklama ne de uyku tutar. Göklerde ve yerde ne varsa O’nundur...” (Yatmadan okuyana sabaha kadar Allah tarafından bir koruyucu görevlendirilir.)',
    anlamEn:
        '“Allah — there is no deity except Him, the Ever-Living, the Sustainer. Neither drowsiness overtakes Him nor sleep...”',
    kaynakTr: 'Bakara Suresi, 255. Ayet — Sahîh-i Buhârî, Vekâle 10 — Hadis No: 2311',
    kaynakEn: 'Surah Al-Baqarah 2:255 — Sahih al-Bukhari 2311',
    ayet: 262,
  ),

  // ─────────────────────────── ŞİFA & AFİYET (8) ───────────────────────────
  _d(
    id: 'ek_rabben_nas',
    katTr: _sifa,
    katEn: _sifaEn,
    baslikTr: 'Allâhümme Rabben-Nâs (Hastaya Okunan Şifa Duası)',
    baslikEn: 'O Allah, Lord of Mankind, Remove the Harm',
    arapca:
        'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
    okunus:
        'Allâhümme Rabben-nâs, ezhibil-be’s, işfi entеş-Şâfî, lâ şifâe illâ şifâük, şifâen lâ yüğâdiru sekamâ.',
    anlamTr:
        '“Ey insanların Rabbi olan Allah’ım! Sıkıntıyı gider. Şifa ver; şifa veren ancak Sensin. Senin şifandan başka şifa yoktur. Hiçbir hastalık bırakmayan bir şifa ver.”',
    anlamEn:
        '“O Allah, Lord of mankind, remove the harm and heal, for You are the Healer. There is no cure but Yours, a cure that leaves no illness.”',
    kaynakTr: 'Sahîh-i Buhârî, Merdâ 20 — Hadis No: 5743; Müslim, Selâm 46',
    kaynakEn: 'Sahih al-Bukhari 5743; Sahih Muslim 2191',
  ),
  _d(
    id: 'ek_euzu_bi_izzetillah',
    katTr: _sifa,
    katEn: _sifaEn,
    baslikTr: 'Ağrıyan Yere El Koyarak Okunan Dua (7 Kere)',
    baslikEn: 'Supplication for Pain (Hand on the Painful Area, 7x)',
    arapca: 'بِسْمِ اللَّهِ (ثَلَاثًا)، أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ (سَبْعًا)',
    okunus: 'Bismillâh (3 kere). Eûzü billâhi ve kudretihî min şerri mâ ecidü ve uhâzir (7 kere).',
    anlamTr:
        '“Allah’ın adıyla (3 kere). Hissettiğim ve endişe ettiğim şeyin şerrinden Allah’a ve O’nun kudretine sığınırım (7 kere).”',
    anlamEn:
        '“In the name of Allah (3x). I seek refuge in Allah and His power from the evil of what I feel and fear (7x).”',
    kaynakTr: 'Sahîh-i Müslim, Selâm 67 — Hadis No: 2202',
    kaynakEn: 'Sahih Muslim, Hadith 2202',
  ),
  _d(
    id: 'ek_esalullahel_azim',
    katTr: _sifa,
    katEn: _sifaEn,
    baslikTr: 'Es’elullâhel-Azîm (Hasta Ziyaretinde 7 Kere)',
    baslikEn: 'I Ask Allah the Mighty to Cure You (7x)',
    arapca: 'أَسْأَلُ اللَّهَ الْعَظِيمَ، رَبَّ الْعَرْشِ الْعَظِيمِ، أَنْ يَشْفِيَكَ',
    okunus: 'Es’elullâhel-azîm, Rabbel-arşil-azîm, en yeşfiyek.',
    anlamTr: '“Yüce Arş’ın Rabbi olan yüce Allah’tan sana şifa vermesini dilerim.”',
    anlamEn: '“I ask Allah the Mighty, Lord of the Mighty Throne, to cure you.”',
    kaynakTr: 'Sünen-i Ebû Dâvûd, Cenâiz 12 — Hadis No: 3106; Tirmizî 2083',
    kaynakEn: 'Sunan Abi Dawud 3106; Tirmidhi 2083',
  ),
  _d(
    id: 'ek_cebrail_rukyesi',
    katTr: _sifa,
    katEn: _sifaEn,
    baslikTr: 'Bismillâhi Erkîk (Cebrâil’in Peygamberimize Okuduğu Rukye)',
    baslikEn: 'In the Name of Allah I Perform Ruqyah (Jibril’s Ruqyah)',
    arapca:
        'بِسْمِ اللَّهِ أَرْقِيكَ، مِنْ كُلِّ شَيْءٍ يُؤْذِيكَ، مِنْ شَرِّ كُلِّ نَفْسٍ أَوْ عَيْنِ حَاسِدٍ، اللَّهُ يَشْفِيكَ، بِسْمِ اللَّهِ أَرْقِيكَ',
    okunus:
        'Bismillâhi erkîk, min külli şey’in yü’zîk, min şerri külli nefsin ev aynin hâsid, Allâhu yeşfîk, bismillâhi erkîk.',
    anlamTr:
        '“Sana eziyet veren her şeyden, her nefsin ve kıskanç gözün şerrinden (korunman için) Allah’ın adıyla sana okuyorum. Allah sana şifa versin. Allah’ın adıyla sana okuyorum.”',
    anlamEn:
        '“In the name of Allah I perform ruqyah for you, from everything that harms you, from the evil of every soul or envious eye. May Allah cure you.”',
    kaynakTr: 'Sahîh-i Müslim, Selâm 40 — Hadis No: 2186',
    kaynakEn: 'Sahih Muslim, Hadith 2186',
  ),
  _d(
    id: 'ek_eyyub_duasi',
    katTr: _sifa,
    katEn: _sifaEn,
    baslikTr: 'Hz. Eyyûb’un (a.s.) Şifa Duası',
    baslikEn: 'Supplication of Prophet Ayyub (Job)',
    arapca: 'أَنِّي مَسَّنِيَ الضُّرُّ وَأَنْتَ أَرْحَمُ الرَّاحِمِينَ',
    okunus: 'Ennî messeniyed-durru ve ente erhamur-râhimîn.',
    anlamTr: '“(Rabbim!) Başıma bu dert geldi. Sen ise merhametlilerin en merhametlisisin.”',
    anlamEn: '“Indeed, adversity has touched me, and You are the Most Merciful of the merciful.”',
    kaynakTr: 'Kur’an-ı Kerim — Enbiyâ Suresi, 83. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah Al-Anbiya 21:83',
    ayet: 2566,
  ),
  _d(
    id: 'ek_ve_iza_maridtu',
    katTr: _sifa,
    katEn: _sifaEn,
    baslikTr: 'Ve İzâ Maridtü Fehüve Yeşfîn (Hz. İbrâhim’in Sözü)',
    baslikEn: 'And When I Am Ill, It Is He Who Cures Me',
    arapca: 'وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ',
    okunus: 'Ve izâ maridtü fehüve yeşfîn.',
    anlamTr: '“Hastalandığım zaman bana şifa veren O’dur.”',
    anlamEn: '“And when I am ill, it is He who cures me.”',
    kaynakTr: 'Kur’an-ı Kerim — Şuarâ Suresi, 80. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah Ash-Shu’ara 26:80',
    ayet: 3012,
  ),
  _d(
    id: 'ek_kotu_hastaliklardan',
    katTr: _sifa,
    katEn: _sifaEn,
    baslikTr: 'Kötü Hastalıklardan Korunma Duası',
    baslikEn: 'Seeking Refuge From Severe Diseases',
    arapca:
        'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْبَرَصِ، وَالْجُنُونِ، وَالْجُذَامِ، وَمِنْ سَيِّئِ الْأَسْقَامِ',
    okunus: 'Allâhümme innî eûzü bike minel-baras, vel-cünûn, vel-cüzâm, ve min seyyiil-eskâm.',
    anlamTr: '“Allah’ım! Alaca hastalığından, delilikten, cüzamdan ve kötü hastalıkların hepsinden Sana sığınırım.”',
    anlamEn: '“O Allah, I seek refuge in You from leprosy, madness, and all evil diseases.”',
    kaynakTr: 'Sünen-i Ebû Dâvûd, Vitr 32 — Hadis No: 1554; Nesâî, İstiâze 36',
    kaynakEn: 'Sunan Abi Dawud 1554; An-Nasa’i',
  ),
  _d(
    id: 'ek_la_bese_tahur',
    katTr: _sifa,
    katEn: _sifaEn,
    baslikTr: 'Lâ Be’se Tahûrun İnşâallah (Hastaya Teselli)',
    baslikEn: 'No Harm, It Is a Purification, God Willing',
    arapca: 'لَا بَأْسَ، طَهُورٌ إِنْ شَاءَ اللَّهُ',
    okunus: 'Lâ be’se, tahûrun inşâallah.',
    anlamTr: '“Zararı yok, inşallah (bu hastalık) günahlardan temizlenmeye vesiledir.”',
    anlamEn: '“No harm; it is a purification, if Allah wills.”',
    kaynakTr: 'Sahîh-i Buhârî, Merdâ 10 — Hadis No: 5656',
    kaynakEn: 'Sahih al-Bukhari, Hadith 5656',
  ),

  // ─────────────────────────── RIZIK & BEREKET (7) ───────────────────────────
  _d(
    id: 'ek_magfiret_rahmet_rizik',
    katTr: _rizik,
    katEn: _rizikEn,
    baslikTr: 'Mağfiret, Rahmet, Hidayet, Afiyet ve Rızık Duası',
    baslikEn: 'Forgiveness, Mercy, Guidance, Health & Provision',
    arapca: 'اللَّهُمَّ اغْفِرْ لِي، وَارْحَمْنِي، وَاهْدِنِي، وَعَافِنِي، وَارْزُقْنِي',
    okunus: 'Allâhümmağfir lî, verhamnî, vehdinî, ve âfinî, verzuknî.',
    anlamTr: '“Allah’ım! Beni bağışla, bana merhamet et, beni hidayete erdir, bana afiyet ver ve beni rızıklandır.”',
    anlamEn: '“O Allah, forgive me, have mercy on me, guide me, grant me well-being and provide for me.”',
    kaynakTr: 'Sahîh-i Müslim, Zikir 35 — Hadis No: 2697',
    kaynakEn: 'Sahih Muslim, Hadith 2697',
  ),
  _d(
    id: 'ek_musa_rizik_duasi',
    katTr: _rizik,
    katEn: _rizikEn,
    baslikTr: 'Hz. Mûsâ’nın (a.s.) Hayır ve Rızık Duası',
    baslikEn: 'Prophet Musa’s Supplication for Good',
    arapca: 'رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
    okunus: 'Rabbi innî limâ enzelte ileyye min hayrin fakîr.',
    anlamTr: '“Rabbim! Doğrusu bana indireceğin her hayra muhtacım.”',
    anlamEn: '“My Lord, indeed I am, for whatever good You would send down to me, in need.”',
    kaynakTr: 'Kur’an-ı Kerim — Kasas Suresi, 24. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah Al-Qasas 28:24',
    ayet: 3276,
  ),
  _d(
    id: 'ek_hem_hazen_borc',
    katTr: _rizik,
    katEn: _rizikEn,
    baslikTr: 'Keder, Tembellik ve Borç Yükünden Kurtulma Duası',
    baslikEn: 'Refuge From Worry, Laziness and Debt',
    arapca:
        'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
    okunus:
        'Allâhümme innî eûzü bike minel-hemmi vel-hazen, vel-aczi vel-kesel, vel-buhli vel-cübn, ve dale’id-deyni ve ğalebetir-ricâl.',
    anlamTr:
        '“Allah’ım! Tasadan ve kederden, acizlikten ve tembellikten, cimrilikten ve korkaklıktan, borç yükünden ve insanların baskısından Sana sığınırım.”',
    anlamEn:
        '“O Allah, I seek refuge in You from worry and grief, helplessness and laziness, miserliness and cowardice, the burden of debt and being overpowered by men.”',
    kaynakTr: 'Sahîh-i Buhârî, Daavât 36 — Hadis No: 6369',
    kaynakEn: 'Sahih al-Bukhari, Hadith 6369',
  ),
  _d(
    id: 'ek_aslih_li_dini',
    katTr: _rizik,
    katEn: _rizikEn,
    baslikTr: 'Din, Dünya ve Ahiretin Islahı Duası',
    baslikEn: 'Rectify My Religion, Worldly Life and Hereafter',
    arapca:
        'اللَّهُمَّ أَصْلِحْ لِي دِينِيَ الَّذِي هُوَ عِصْمَةُ أَمْرِي، وَأَصْلِحْ لِي دُنْيَايَ الَّتِي فِيهَا مَعَاشِي، وَأَصْلِحْ لِي آخِرَتِي الَّتِي فِيهَا مَعَادِي',
    okunus:
        'Allâhümme aslih lî dîniyellezî hüve ismetü emrî, ve aslih lî dünyâyelletî fîhâ meâşî, ve aslih lî âhiretiyelletî fîhâ meâdî.',
    anlamTr:
        '“Allah’ım! İşlerimin koruyucusu olan dinimi ıslah et. Geçimimin içinde olduğu dünyamı ıslah et. Dönüşümün olacağı ahiretimi ıslah et.”',
    anlamEn:
        '“O Allah, set right my religion which is the safeguard of my affairs, my worldly life wherein is my livelihood, and my Hereafter to which is my return.”',
    kaynakTr: 'Sahîh-i Müslim, Zikir 71 — Hadis No: 2720',
    kaynakEn: 'Sahih Muslim, Hadith 2720',
  ),
  _d(
    id: 'ek_bereket_mal_evlat',
    katTr: _rizik,
    katEn: _rizikEn,
    baslikTr: 'Mal, Evlat ve Bereket Duası (Hz. Enes İçin Yapılan Dua)',
    baslikEn: 'Supplication for Wealth, Children and Barakah',
    arapca: 'اللَّهُمَّ أَكْثِرْ مَالِي وَوَلَدِي، وَبَارِكْ لِي فِيمَا أَعْطَيْتَنِي',
    okunus: 'Allâhümme eksir mâlî ve veledî, ve bârik lî fîmâ a’tayteni.',
    anlamTr: '“Allah’ım! Malımı ve evladımı çoğalt ve bana verdiklerini hakkımda bereketli kıl.”',
    anlamEn: '“O Allah, increase my wealth and children, and bless me in what You have given me.”',
    kaynakTr: 'Sahîh-i Buhârî, Daavât 19 — Hadis No: 6334 (Hz. Enes için yapılan duadan)',
    kaynakEn: 'Sahih al-Bukhari, Hadith 6334 (prayer for Anas)',
  ),
  _d(
    id: 'ek_istigfar_rizik_nuh',
    katTr: _rizik,
    katEn: _rizikEn,
    baslikTr: 'İstiğfar ile Gelen Rızık ve Bereket (Hz. Nûh’un Tavsiyesi)',
    baslikEn: 'Provision Through Seeking Forgiveness (Nuh)',
    arapca:
        'فَقُلْتُ اسْتَغْفِرُوا رَبَّكُمْ إِنَّهُ كَانَ غَفَّارًا ۝ يُرْسِلِ السَّمَاءَ عَلَيْكُمْ مِدْرَارًا ۝ وَيُمْدِدْكُمْ بِأَمْوَالٍ وَبَنِينَ',
    okunus:
        'Fe kultüstağfirû Rabbeküm innehû kâne ğaffârâ. Yursilis-semâe aleyküm midrârâ. Ve yumdidküm bi-emvâlin ve benîn.',
    anlamTr:
        '“Rabbinizden bağışlanma dileyin; çünkü O çok bağışlayıcıdır. Size gökten bol bol yağmur indirsin, mallar ve oğullarla sizi desteklesin.”',
    anlamEn:
        '“Ask forgiveness of your Lord; indeed, He is ever a Perpetual Forgiver. He will send rain upon you in abundance and give you increase in wealth and children.”',
    kaynakTr: 'Kur’an-ı Kerim — Nûh Suresi, 10-12. Ayetler',
    kaynakEn: 'The Holy Qur’an — Surah Nuh 71:10-12',
  ),
  _d(
    id: 'ek_tevekkul_rizik_talak',
    katTr: _rizik,
    katEn: _rizikEn,
    baslikTr: 'Ummadığı Yerden Rızık (Talâk Suresi Tevekkül Ayeti)',
    baslikEn: 'Provision From Where One Does Not Expect',
    arapca:
        'وَمَنْ يَتَّقِ اللَّهَ يَجْعَلْ لَهُ مَخْرَجًا ۝ وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ ۚ وَمَنْ يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
    okunus:
        'Ve men yettekıllâhe yec’al lehû mahracâ. Ve yerzukhü min haysü lâ yahtesib, ve men yetevekkel alallâhi fehüve hasbüh.',
    anlamTr:
        '“Kim Allah’a karşı gelmekten sakınırsa Allah ona bir çıkış yolu ihsan eder ve onu hesaba katmadığı yerden rızıklandırır. Kim Allah’a tevekkül ederse O, ona yeter.”',
    anlamEn:
        '“Whoever fears Allah, He will make for him a way out and provide for him from where he does not expect. And whoever relies upon Allah — He is sufficient for him.”',
    kaynakTr: 'Kur’an-ı Kerim — Talâk Suresi, 2-3. Ayetler',
    kaynakEn: 'The Holy Qur’an — Surah At-Talaq 65:2-3',
  ),

  // ─────────────────────────── NAZAR & KORUNMA (10) ───────────────────────────
  _d(
    id: 'ek_muavvizeteyn',
    katTr: _nazar,
    katEn: _nazarEn,
    baslikTr: 'İhlâs, Felak ve Nâs Sureleri (Sabah-Akşam 3’er Kere)',
    baslikEn: 'Al-Ikhlas, Al-Falaq & An-Nas (3x Morning & Evening)',
    arapca:
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    okunus:
        'Kul eûzü bi-Rabbil-felak. Min şerri mâ halak. Ve min şerri ğâsikın izâ vekab. Ve min şerrin-neffâsâti fil-ukad. Ve min şerri hâsidin izâ hased.',
    anlamTr:
        '“De ki: Yarattığı şeylerin şerrinden, karanlığı çöktüğü zaman gecenin şerrinden, düğümlere üfleyenlerin şerrinden ve haset ettiği zaman hasetçinin şerrinden, sabahın Rabbine sığınırım.” (Sabah-akşam üçer kere okumak her şeye karşı yeterlidir.)',
    anlamEn:
        '“Say: I seek refuge in the Lord of daybreak from the evil of what He created... and from the evil of an envier when he envies.”',
    kaynakTr: 'Felak Suresi 1-5 — Sünen-i Ebû Dâvûd, Edeb 110 — Hadis No: 5082; Tirmizî 3575',
    kaynakEn: 'Surah Al-Falaq 113:1-5 — Abu Dawud 5082; Tirmidhi 3575',
  ),
  _d(
    id: 'ek_hasan_huseyin_nazar',
    katTr: _nazar,
    katEn: _nazarEn,
    baslikTr: 'Nazardan Korunma Duası (Hz. Hasan ve Hüseyin’e Okunan)',
    baslikEn: 'Protection From the Evil Eye (Recited for Hasan & Husayn)',
    arapca:
        'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ، مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ',
    okunus: 'Eûzü bi-kelimâtillâhit-tâmmeh, min külli şeytânin ve hâmmeh, ve min külli aynin lâmmeh.',
    anlamTr:
        '“Her şeytandan, her zararlı haşereden ve her kem gözden Allah’ın eksiksiz kelimelerine sığınırım.”',
    anlamEn:
        '“I seek refuge in the perfect words of Allah from every devil, every poisonous creature, and every evil eye.”',
    kaynakTr: 'Sahîh-i Buhârî, Enbiyâ 10 — Hadis No: 3371',
    kaynakEn: 'Sahih al-Bukhari, Hadith 3371',
  ),
  _d(
    id: 'ek_maşaallah_kehf',
    katTr: _nazar,
    katEn: _nazarEn,
    baslikTr: 'Mâşâallah Lâ Kuvvete İllâ Billâh (Nimeti Görünce)',
    baslikEn: 'Masha’Allah, There Is No Power Except With Allah',
    arapca: 'مَا شَاءَ اللَّهُ لَا قُوَّةَ إِلَّا بِاللَّهِ',
    okunus: 'Mâşâallâh, lâ kuvvete illâ billâh.',
    anlamTr: '“Allah dilemiş! Kuvvet ancak Allah’ın yardımıyladır.” (Hoşa giden bir nimeti görünce söylenir.)',
    anlamEn: '“What Allah willed! There is no power except with Allah.”',
    kaynakTr: 'Kur’an-ı Kerim — Kehf Suresi, 39. Ayet',
    kaynakEn: 'The Holy Qur’an — Surah Al-Kahf 18:39',
    ayet: 2179,
  ),
  _d(
    id: 'ek_bereket_duasi_nazar',
    katTr: _nazar,
    katEn: _nazarEn,
    baslikTr: 'Bârakallâhu Leh (Nazar Değdirmemek İçin Bereket Duası)',
    baslikEn: 'May Allah Bless It (To Avoid Giving the Evil Eye)',
    arapca: 'اللَّهُمَّ بَارِكْ عَلَيْهِ',
    okunus: 'Allâhümme bârik aleyh.',
    anlamTr:
        '“Allah’ım! Onu bereketli kıl.” (Biriniz kardeşinde hoşuna giden bir şey görürse ona bereketle dua etsin.)',
    anlamEn: '“O Allah, bless him.” (Say it when you see something you admire in your brother.)',
    kaynakTr: 'Sünen-i İbn Mâce, Tıb 32 — Hadis No: 3509',
    kaynakEn: 'Sunan Ibn Majah, Hadith 3509',
  ),
  _d(
    id: 'ek_nazar_ayeti_kalem',
    katTr: _nazar,
    katEn: _nazarEn,
    baslikTr: 'Nazar Ayeti (Kalem Suresi 51-52)',
    baslikEn: 'Verse of the Evil Eye (Al-Qalam 51-52)',
    arapca:
        'وَإِنْ يَكَادُ الَّذِينَ كَفَرُوا لَيُزْلِقُونَكَ بِأَبْصَارِهِمْ لَمَّا سَمِعُوا الذِّكْرَ وَيَقُولُونَ إِنَّهُ لَمَجْنُونٌ ۝ وَمَا هُوَ إِلَّا ذِكْرٌ لِلْعَالَمِينَ',
    okunus:
        'Ve in yekâdüllezîne keferû le-yuzlikûneke bi-ebsârihim lemmâ semiuz-zikra ve yekûlûne innehû le-mecnûn. Ve mâ hüve illâ zikrun lil-âlemîn.',
    anlamTr:
        '“Şüphesiz inkâr edenler Zikr’i (Kur’an’ı) işittiklerinde neredeyse seni gözleriyle devireceklerdi. Bir de ‘O mutlaka delidir’ diyorlar. Hâlbuki o (Kur’an), âlemler için ancak bir öğüttür.”',
    anlamEn:
        '“And indeed, those who disbelieve would almost make you slip with their eyes when they hear the message... But it is not except a reminder to the worlds.”',
    kaynakTr: 'Kur’an-ı Kerim — Kalem Suresi, 51-52. Ayetler',
    kaynakEn: 'The Holy Qur’an — Surah Al-Qalam 68:51-52',
  ),
  _d(
    id: 'ek_evden_cikarken',
    katTr: _nazar,
    katEn: _nazarEn,
    baslikTr: 'Evden Çıkarken Okunan Dua (Korunma ve Tevekkül)',
    baslikEn: 'Supplication When Leaving the House',
    arapca: 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    okunus: 'Bismillâh, tevekkeltü alallâh, lâ havle ve lâ kuvvete illâ billâh.',
    anlamTr:
        '“Allah’ın adıyla (çıkarım). Allah’a tevekkül ettim. Güç ve kuvvet ancak Allah’ın yardımıyladır.” (Bunu söyleyene ‘Hidayet olundun, kifayet olundun ve korundun’ denir.)',
    anlamEn: '“In the name of Allah, I rely upon Allah; there is no might nor power except with Allah.”',
    kaynakTr: 'Sünen-i Ebû Dâvûd, Edeb 103 — Hadis No: 5095; Tirmizî 3426',
    kaynakEn: 'Sunan Abi Dawud 5095; Tirmidhi 3426',
  ),
  _d(
    id: 'ek_zevali_nimet',
    katTr: _nazar,
    katEn: _nazarEn,
    baslikTr: 'Nimetin Elden Gitmesinden Korunma Duası',
    baslikEn: 'Refuge From the Loss of Blessings',
    arapca:
        'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ',
    okunus:
        'Allâhümme innî eûzü bike min zevâli ni’metik, ve tehavvüli âfiyetik, ve fücâeti nikmetik, ve cemî’i sahatik.',
    anlamTr:
        '“Allah’ım! Nimetinin yok olmasından, verdiğin afiyetin değişmesinden, cezanın ansızın gelmesinden ve her türlü gazabından Sana sığınırım.”',
    anlamEn:
        '“O Allah, I seek refuge in You from the loss of Your blessings, the change of Your protection, the suddenness of Your punishment, and all Your displeasure.”',
    kaynakTr: 'Sahîh-i Müslim, Rikâk 96 — Hadis No: 2739',
    kaynakEn: 'Sahih Muslim, Hadith 2739',
  ),
  _d(
    id: 'ek_kabir_fitne_korunma',
    katTr: _nazar,
    katEn: _nazarEn,
    baslikTr: 'Acizlik, Tembellik ve Kabir Azabından Korunma',
    baslikEn: 'Refuge From Incapacity, Laziness and the Punishment of the Grave',
    arapca:
        'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَالْجُبْنِ وَالْهَرَمِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ',
    okunus:
        'Allâhümme innî eûzü bike minel-acz vel-kesel, vel-cübni vel-herem vel-buhl, ve eûzü bike min azâbil-kabr, ve min fitnetil-mahyâ vel-memât.',
    anlamTr:
        '“Allah’ım! Acizlikten, tembellikten, korkaklıktan, ihtiyarlığın düşkünlüğünden ve cimrilikten Sana sığınırım. Kabir azabından, hayatın ve ölümün fitnesinden de Sana sığınırım.”',
    anlamEn:
        '“O Allah, I seek refuge in You from incapacity, laziness, cowardice, decrepitude and miserliness, and from the punishment of the grave and the trials of life and death.”',
    kaynakTr: 'Sahîh-i Buhârî, Daavât 38 — Hadis No: 6367; Müslim 2706',
    kaynakEn: 'Sahih al-Bukhari 6367; Sahih Muslim 2706',
  ),
  _d(
    id: 'ek_uyku_oncesi',
    katTr: _nazar,
    katEn: _nazarEn,
    baslikTr: 'Yatarken Okunan Korunma Duası',
    baslikEn: 'Supplication Before Sleep',
    arapca:
        'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، إِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
    okunus:
        'Bismike Rabbî vada’tü cenbî ve bike erfeuh, in emsekte nefsî ferhamhâ, ve in erseltehâ fahfazhâ bimâ tahfazu bihî ibâdekes-sâlihîn.',
    anlamTr:
        '“Rabbim! Senin adınla yanımı yere koydum, Seninle kaldırırım. Eğer canımı alırsan ona merhamet et; eğer geri bırakırsan salih kullarını koruduğun şeyle onu da koru.”',
    anlamEn:
        '“In Your name, my Lord, I lay down my side and by You I raise it. If You take my soul, have mercy on it; if You release it, protect it as You protect Your righteous servants.”',
    kaynakTr: 'Sahîh-i Buhârî, Daavât 13 — Hadis No: 6320; Müslim 2714',
    kaynakEn: 'Sahih al-Bukhari 6320; Sahih Muslim 2714',
  ),
  _d(
    id: 'ek_hemezatis_seyatin',
    katTr: _nazar,
    katEn: _nazarEn,
    baslikTr: 'Şeytanın Vesveselerinden Korunma Duası',
    baslikEn: 'Refuge From the Whispers of the Devils',
    arapca:
        'رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ ۝ وَأَعُوذُ بِكَ رَبِّ أَنْ يَحْضُرُونِ',
    okunus: 'Rabbi eûzü bike min hemezâtiş-şeyâtîn. Ve eûzü bike Rabbi en yahdurûn.',
    anlamTr: '“Rabbim! Şeytanların vesveselerinden Sana sığınırım. Onların yanımda bulunmalarından da Sana sığınırım Rabbim!”',
    anlamEn: '“My Lord, I seek refuge in You from the incitements of the devils, and I seek refuge in You lest they be present with me.”',
    kaynakTr: 'Kur’an-ı Kerim — Mü’minûn Suresi, 97-98. Ayetler',
    kaynakEn: 'The Holy Qur’an — Surah Al-Mu’minun 23:97-98',
    ayet: 2770,
  ),

  // ─────────────────────────── NAMAZ TESBİHATI (8) ───────────────────────────
  _d(
    id: 'ek_tesbihat_entes_selam',
    katTr: _tesbihat,
    katEn: _tesbihatEn,
    baslikTr: '3 Kere Estağfirullah ve Allâhümme Entes-Selâm',
    baslikEn: 'Astaghfirullah (3x) and Allahumma Antas-Salam',
    arapca:
        'أَسْتَغْفِرُ اللَّهَ (ثَلَاثًا)، اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    okunus: 'Estağfirullah (3 kere). Allâhümme entes-selâmü ve minkes-selâm, tebârekte yâ zel-celâli vel-ikrâm.',
    anlamTr:
        '“Allah’tan bağışlanma dilerim (3 kere). Allah’ım! Sen selâmsın (her türlü eksiklikten uzaksın), selâmet ancak Sendendir. Ey celâl ve ikram sahibi! Sen ne yücesin.”',
    anlamEn:
        '“I seek Allah’s forgiveness (3x). O Allah, You are Peace and from You is peace. Blessed are You, O Possessor of Majesty and Honor.”',
    kaynakTr: 'Sahîh-i Müslim, Mesâcid 135 — Hadis No: 591',
    kaynakEn: 'Sahih Muslim, Hadith 591',
  ),
  _d(
    id: 'ek_tesbihat_33',
    katTr: _tesbihat,
    katEn: _tesbihatEn,
    baslikTr: '33 Sübhânallah, 33 Elhamdülillah, 33 Allâhu Ekber ve Tevhid',
    baslikEn: 'Subhanallah 33, Alhamdulillah 33, Allahu Akbar 33 and Tahlil',
    arapca:
        'سُبْحَانَ اللَّهِ (٣٣)، الْحَمْدُ لِلَّهِ (٣٣)، اللَّهُ أَكْبَرُ (٣٣)، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    okunus:
        'Sübhânallah (33), Elhamdülillah (33), Allâhu ekber (33). Lâ ilâhe illallâhu vahdehû lâ şerîke leh, lehül-mülkü ve lehül-hamdü ve hüve alâ külli şey’in kadîr.',
    anlamTr:
        '“Kim her namazdan sonra 33 defa Sübhânallah, 33 defa Elhamdülillah, 33 defa Allâhu ekber der ve yüzü tevhid ile tamamlarsa, deniz köpüğü kadar olsa bile günahları bağışlanır.”',
    anlamEn:
        '“Whoever glorifies Allah 33 times, praises Him 33 times and magnifies Him 33 times after every prayer, completing a hundred with the tahlil, his sins are forgiven even if like the foam of the sea.”',
    kaynakTr: 'Sahîh-i Müslim, Mesâcid 146 — Hadis No: 597',
    kaynakEn: 'Sahih Muslim, Hadith 597',
  ),
  _d(
    id: 'ek_einni_ala_zikrike',
    katTr: _tesbihat,
    katEn: _tesbihatEn,
    baslikTr: 'Allâhümme Einnî Alâ Zikrike (Hz. Muâz’a Tavsiye Edilen)',
    baslikEn: 'O Allah, Help Me Remember You (Advised to Mu’adh)',
    arapca: 'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ',
    okunus: 'Allâhümme einnî alâ zikrike ve şükrike ve husni ibâdetik.',
    anlamTr: '“Allah’ım! Seni anmak, Sana şükretmek ve Sana güzelce ibadet etmek için bana yardım et.”',
    anlamEn: '“O Allah, help me to remember You, to thank You, and to worship You in the best manner.”',
    kaynakTr: 'Sünen-i Ebû Dâvûd, Vitr 26 — Hadis No: 1522; Nesâî, Sehv 60',
    kaynakEn: 'Sunan Abi Dawud 1522; An-Nasa’i',
  ),
  _d(
    id: 'ek_la_mania_lima_ataytе',
    katTr: _tesbihat,
    katEn: _tesbihatEn,
    baslikTr: 'Lâ Mânia Limâ A’tayte (Farz Namazlardan Sonra)',
    baslikEn: 'None Can Withhold What You Give (After Obligatory Prayers)',
    arapca:
        'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
    okunus:
        'Lâ ilâhe illallâhu vahdehû lâ şerîke leh, lehül-mülkü ve lehül-hamdü ve hüve alâ külli şey’in kadîr. Allâhümme lâ mânia limâ a’tayte, ve lâ mu’tıye limâ mena’te, ve lâ yenfeu zel-ceddi minkel-cedd.',
    anlamTr:
        '“Allah’tan başka ilâh yoktur; O tektir, ortağı yoktur... Allah’ım! Senin verdiğine engel olacak, engel olduğunu da verecek kimse yoktur. Hiçbir zenginin zenginliği Sana karşı fayda vermez.”',
    anlamEn:
        '“There is no deity but Allah alone... O Allah, none can withhold what You give, nor give what You withhold, and the wealth of the wealthy cannot avail against You.”',
    kaynakTr: 'Sahîh-i Buhârî, Ezân 155 — Hadis No: 844; Müslim 593',
    kaynakEn: 'Sahih al-Bukhari 844; Sahih Muslim 593',
  ),
  _d(
    id: 'ek_ayetel_kursi_namaz',
    katTr: _tesbihat,
    katEn: _tesbihatEn,
    baslikTr: 'Her Farz Namazdan Sonra Âyetü’l-Kürsî',
    baslikEn: 'Ayat al-Kursi After Every Obligatory Prayer',
    arapca:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ',
    okunus:
        'Allâhü lâ ilâhe illâ hüvel-hayyül-kayyûm, lâ te’huzühû sinetün ve lâ nevm, lehû mâ fis-semâvâti ve mâ fil-ard, men zellezî yeşfeu indehû illâ bi-iznih...',
    anlamTr:
        '“Kim her farz namazın ardından Âyetü’l-Kürsî’yi okursa, onun cennete girmesine ölümden başka hiçbir engel kalmaz.”',
    anlamEn:
        '“Whoever recites Ayat al-Kursi after every obligatory prayer, nothing prevents him from entering Paradise except death.”',
    kaynakTr: 'Bakara 255 — Nesâî, es-Sünenü’l-Kübrâ — Hadis No: 9848',
    kaynakEn: 'Al-Baqarah 2:255 — An-Nasa’i, as-Sunan al-Kubra 9848',
    ayet: 262,
  ),
  _d(
    id: 'ek_salli_barik',
    katTr: _tesbihat,
    katEn: _tesbihatEn,
    baslikTr: 'Salli ve Bârik Duaları (Salavât-ı İbrâhîmiyye)',
    baslikEn: 'Salat al-Ibrahimiyyah (Salli & Barik)',
    arapca:
        'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
    okunus:
        'Allâhümme salli alâ Muhammedin ve alâ âli Muhammed, kemâ salleyte alâ İbrâhîme ve alâ âli İbrâhîm, inneke hamîdün mecîd. Allâhümme bârik alâ Muhammedin ve alâ âli Muhammed, kemâ bârakte alâ İbrâhîme ve alâ âli İbrâhîm, inneke hamîdün mecîd.',
    anlamTr:
        '“Allah’ım! İbrâhim’e ve âline rahmet ettiğin gibi Muhammed’e ve âline de rahmet et. Allah’ım! İbrâhim’e ve âline bereket verdiğin gibi Muhammed’e ve âline de bereket ver. Şüphesiz Sen övülmeye layıksın, şanı yücesin.”',
    anlamEn:
        '“O Allah, send prayers upon Muhammad and the family of Muhammad as You sent prayers upon Ibrahim... and bless Muhammad as You blessed Ibrahim. You are Praiseworthy, Glorious.”',
    kaynakTr: 'Sahîh-i Buhârî, Enbiyâ 10 — Hadis No: 3370; Müslim 406',
    kaynakEn: 'Sahih al-Bukhari 3370; Sahih Muslim 406',
  ),
  _d(
    id: 'ek_ebubekir_namaz_duasi',
    katTr: _tesbihat,
    katEn: _tesbihatEn,
    baslikTr: 'Hz. Ebû Bekir’e Namazda Okuması İçin Öğretilen Dua',
    baslikEn: 'Supplication Taught to Abu Bakr for His Prayer',
    arapca:
        'اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ، فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ، وَارْحَمْنِي، إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ',
    okunus:
        'Allâhümme innî zalemtü nefsî zulmen kesîran, ve lâ yağfiruz-zünûbe illâ ente, fağfir lî mağfiraten min indik, verhamnî, inneke entel-ğafûrur-rahîm.',
    anlamTr:
        '“Allah’ım! Ben nefsime çokça zulmettim. Günahları ancak Sen bağışlarsın. Katından bir bağışlama ile beni bağışla ve bana merhamet et. Şüphesiz Sen çok bağışlayan, çok merhamet edensin.”',
    anlamEn:
        '“O Allah, I have wronged myself greatly and none forgives sins but You, so grant me forgiveness from You and have mercy on me. You are the Forgiving, the Merciful.”',
    kaynakTr: 'Sahîh-i Buhârî, Ezân 149 — Hadis No: 834; Müslim 2705',
    kaynakEn: 'Sahih al-Bukhari 834; Sahih Muslim 2705',
  ),
  _d(
    id: 'ek_teşehhud_sonrasi_istiaze',
    katTr: _tesbihat,
    katEn: _tesbihatEn,
    baslikTr: 'Son Oturuşta Dört Şeyden Allah’a Sığınma',
    baslikEn: 'Seeking Refuge From Four Things in the Final Sitting',
    arapca:
        'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَمِنْ عَذَابِ الْقَبْرِ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ، وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ',
    okunus:
        'Allâhümme innî eûzü bike min azâbi cehennem, ve min azâbil-kabr, ve min fitnetil-mahyâ vel-memât, ve min şerri fitnetil-mesîhid-deccâl.',
    anlamTr:
        '“Allah’ım! Cehennem azabından, kabir azabından, hayatın ve ölümün fitnesinden ve Mesih Deccâl’in fitnesinin şerrinden Sana sığınırım.”',
    anlamEn:
        '“O Allah, I seek refuge in You from the punishment of Hell, the punishment of the grave, the trials of life and death, and the evil of the trial of the False Messiah.”',
    kaynakTr: 'Sahîh-i Müslim, Mesâcid 128 — Hadis No: 588',
    kaynakEn: 'Sahih Muslim, Hadith 588',
  ),
];
