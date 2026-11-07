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
  final int? globalAyetNo; // Kur'an ayeti ise MP3 tilaveti için

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

  String kategori(String dil) => kDuaKategoriEtiket(kategoriTr, dil);

  String baslik(String dil) {
    if (dil == 'DE') return _kDuaCeviriDe[id]?['baslik'] ?? baslikEn;
    if (dil == 'FR') return _kDuaCeviriFr[id]?['baslik'] ?? baslikEn;
    if (dil == 'EN' || dil == 'AR') return baslikEn;
    return baslikTr;
  }

  String anlam(String dil) {
    if (dil == 'DE') return _kDuaCeviriDe[id]?['anlam'] ?? anlamEn;
    if (dil == 'FR') return _kDuaCeviriFr[id]?['anlam'] ?? anlamEn;
    if (dil == 'EN') return anlamEn;
    if (dil == 'AR') return arapca;
    return anlamTr;
  }

  String kaynak(String dil) {
    if (dil == 'DE') {
      return _kDuaCeviriDe[id]?['kaynak'] ??
          kaynakEn
              .replaceAll('The Holy Qur’an', 'Der Edle Koran')
              .replaceAll('Surah', 'Sure')
              .replaceAll('Hadith', 'Hadith Nr.');
    }
    if (dil == 'FR') {
      return _kDuaCeviriFr[id]?['kaynak'] ??
          kaynakEn
              .replaceAll('The Holy Qur’an', 'Le Saint Coran')
              .replaceAll('Surah', 'Sourate')
              .replaceAll('Hadith', 'Hadith n°');
    }
    if (dil == 'EN' || dil == 'AR') return kaynakEn;
    return kaynakTr;
  }
}

String kDuaKategoriEtiket(String katTr, String dil) {
  if (dil == 'TR') return katTr;
  const mapEn = {
    'Tümü': 'All',
    'Rabbena Duaları': 'Rabbana Duas',
    'Sabah & Akşam': 'Morning & Evening',
    'Şifa & Afiyet': 'Healing & Well-Being',
    'Rızık & Bereket': 'Provision & Barakah',
    'Nazar & Korunma': 'Protection & Evil Eye',
    'Namaz Tesbihatı': 'Post-Prayer Tasbihat',
    'Huzur & İnşirah': 'Peace & Relief',
    'Sınav & İş Kolaylığı': 'Exam & Ease',
    'İstiğfar & Tövbe': 'Repentance & Istighfar',
  };
  const mapDe = {
    'Tümü': 'Alle',
    'Rabbena Duaları': 'Rabbana-Bittgebete',
    'Sabah & Akşam': 'Morgen & Abend',
    'Şifa & Afiyet': 'Heilung & Gesundheit',
    'Rızık & Bereket': 'Versorgung & Segen',
    'Nazar & Korunma': 'Schutz & Böser Blick',
    'Namaz Tesbihatı': 'Gebets-Tasbihat',
    'Huzur & İnşirah': 'Innere Ruhe & Trost',
    'Sınav & İş Kolaylığı': 'Prüfung & Erleichterung',
    'İstiğfar & Tövbe': 'Vergebung & Reue',
  };
  const mapFr = {
    'Tümü': 'Tout',
    'Rabbena Duaları': 'Invocations Rabbana',
    'Sabah & Akşam': 'Matin & Soir',
    'Şifa & Afiyet': 'Guérison & Santé',
    'Rızık & Bereket': 'Subsistance & Bénédiction',
    'Nazar & Korunma': 'Protection & Mauvais Œil',
    'Namaz Tesbihatı': 'Tasbihat après la Prière',
    'Huzur & İnşirah': 'Paix & Sérénité',
    'Sınav & İş Kolaylığı': 'Examen & Facilité',
    'İstiğfar & Tövbe': 'Pardon & Repentir',
  };
  if (dil == 'DE') return mapDe[katTr] ?? mapEn[katTr] ?? katTr;
  if (dil == 'FR') return mapFr[katTr] ?? mapEn[katTr] ?? katTr;
  return mapEn[katTr] ?? katTr;
}

const Map<String, Map<String, String>> _kDuaCeviriDe = {
  'rabbena_atina': {
    'baslik': 'Rabbana Atina (Gutes im Diesseits und Jenseits)',
    'anlam': '„Unser Herr, gib uns im Diesseits Gutes und im Jenseits Gutes und bewahre uns vor der Strafe des Höllenfeuers.“',
    'kaynak': 'Der Edle Koran — Sure Al-Baqara, 2:201',
  },
  'rabbenagfirlî': {
    'baslik': 'Rabbanaghfirli (Vergebung für Eltern & Gläubige)',
    'anlam': '„Unser Herr, vergib mir und meinen Eltern und den Gläubigen an dem Tag, da die Abrechnung stattfinden wird.“',
    'kaynak': 'Der Edle Koran — Sure Ibrahim, 14:41',
  },
  'rabbena_la_tuzig': {
    'baslik': 'Rabbana La Tuzigh Qulubana (Standhaftigkeit in der Rechtleitung)',
    'anlam': '„Unser Herr, lass unsere Herzen nicht abschweifen, nachdem Du uns rechtgeleitet hast, und schenke uns Barmherzigkeit von Dir.“',
    'kaynak': 'Der Edle Koran — Sure Ali Imran, 3:8',
  },
  'rabbena_heb_lena': {
    'baslik': 'Bittgebet für rechtschaffene Familie & Nachkommen',
    'anlam': '„Unser Herr, schenke uns an unseren Gattinnen und unseren Nachkommen Grund zur Augenfreude und mache uns für die Gottesfürchtigen zu einem Vorbild.“',
    'kaynak': 'Der Edle Koran — Sure Al-Furqan, 25:74',
  },
  'rabbena_efrig': {
    'baslik': 'Bittgebet um Geduld und Standhaftigkeit',
    'anlam': '„Unser Herr, gieße Geduld über uns aus, festige unsere Schritte und hilf uns.“',
    'kaynak': 'Der Edle Koran — Sure Al-Baqara, 2:250',
  },
  'rabbi_yessir': {
    'baslik': 'Rabbi Yassir (Gebet für Erleichterung & Prüfungserfolg)',
    'anlam': '„Mein Herr! Erleichtere es mir und erschwere es nicht. Mein Herr, führe diese Angelegenheit zum Guten.“',
    'kaynak': 'Prophetische Bittgebetstradition (Sahih al-Buchari, Wissen 11)',
  },
  'rabbi_srahli_sadri': {
    'baslik': 'Gebet des Propheten Musa für Zuversicht & Klarheit',
    'anlam': '„Mein Herr, weite mir meine Brust, erleichtere mir meine Angelegenheit und löse den Knoten von meiner Zunge, damit sie meine Rede verstehen.“',
    'kaynak': 'Der Edle Koran — Sure Ta-Ha, 20:25-28',
  },
  'rabbi_zidni_ilma': {
    'baslik': 'Bittgebet um nützliches Wissen (Rabbi Zidni Ilma)',
    'anlam': '„Mein Herr, mehre mein Wissen und mein Verständnis und reihe mich unter die Rechtschaffenen ein.“',
    'kaynak': 'Der Edle Koran — Sure Ta-Ha 20:114 & Asch-Schu’ara 26:83',
  },
  'yunus_duasi': {
    'baslik': 'Bittgebet des Propheten Yunus um Befreiung aus der Not',
    'anlam': '„Es gibt keinen Gott außer Dir! Preis sei Dir! Gewiss, ich gehöre zu den Ungerechten.“',
    'kaynak': 'Der Edle Koran — Sure Al-Anbiya, 21:87',
  },
  'kalp_huzuru_duasi': {
    'baslik': 'Prophetische Zuflucht vor Kummer, Sorge & Schuldenlast',
    'anlam': '„O Allah, ich suche Zuflucht bei Dir vor Sorge und Kummer, vor Schwäche und Trägheit, vor Geiz und Feigheit sowie vor der Last der Schulden.“',
    'kaynak': 'Sahih al-Buchari, Bittgebete 36 — Hadith 6369',
  },
  'peygamber_sifa_duasi': {
    'baslik': 'Prophetisches Bittgebet um vollständige Heilung',
    'anlam': '„O Allah, Herr der Menschen! Nimm das Leiden hinweg und heile, denn Du bist der Heiler. Es gibt keine Heilung außer Deiner Heilung, die keine Krankheit zurücklässt.“',
    'kaynak': 'Sahih al-Buchari, Medizin 38 & Sahih Muslim',
  },
  'eyyub_sifa_duasi': {
    'baslik': 'Heilungsgebet des Propheten Ayyub (Hiob)',
    'anlam': '„Mein Herr! Gewiss, mir ist Unheil widerfahren, und Du bist der Barmherzigste der Barmherzigen.“',
    'kaynak': 'Der Edle Koran — Sure Al-Anbiya, 21:83',
  },
  'helal_rizik_duasi': {
    'baslik': 'Bittgebet um erlaubte Versorgung (Halal Rizq)',
    'anlam': '„O Allah, genüge mir mit dem, was Du erlaubt hast, gegenüber dem, was Du verboten hast, und mache mich durch Deine Huld unabhängig von allen außer Dir.“',
    'kaynak': 'Dschami at-Tirmidhi, Bittgebete 110 — Hadith 3563',
  },
  'faydali_ilim_temiz_rizik': {
    'baslik': 'Morgengebet um nützliches Wissen, reine Versorgung & angenommene Taten',
    'anlam': '„O Allah, ich bitte Dich um nützliches Wissen, gute und reine Versorgung und angenommene Taten.“',
    'kaynak': 'Sunan Ibn Madscha, Hadith 925',
  },
  'sabah_aksam_afiyet': {
    'baslik': 'Morgen- & Abendgebet um Verzeihung und Wohlergehen',
    'anlam': '„O Allah, ich bitte Dich um Verzeihung und Wohlergehen im Diesseits und im Jenseits.“',
    'kaynak': 'Sunan Abi Dawud, Hadith 5074',
  },
  'hasbiyallahu': {
    'baslik': 'Gebet des Gottvertrauens (HasbiyAllahu La Ilaha Illa Hu)',
    'anlam': '„Allah genügt mir; es gibt keinen Gott außer Ihm. Auf Ihn vertraue ich, und Er ist der Herr des gewaltigen Thrones.“',
    'kaynak': 'Der Edle Koran — Sure At-Tawba, 9:129',
  },
  'seyyidul_istigfar': {
    'baslik': 'Sayyid al-Istighfar (Das höchste Gebet um Vergebung)',
    'anlam': '„O Allah, Du bist mein Herr, es gibt keinen Gott außer Dir. Du hast mich erschaffen und ich bin Dein Diener... Vergib mir, denn niemand vergibt die Sünden außer Dir.“',
    'kaynak': 'Sahih al-Buchari, Bittgebete 2 — Hadith 6306',
  },
  'ek_asbahna': {
    'baslik': 'Asbahna wa Asbahal-Mulku Lillah (Morgengebet)',
    'anlam': '„Wir haben den Morgen erreicht und die Herrschaft gehört Allah. Alles Lob gebührt Allah. Es gibt keinen Gott außer Allah allein, ohne Teilhaber.“',
  },
  'ek_bike_asbahna': {
    'baslik': 'Allahumma Bika Asbahna (Morgen- & Abendgebet der Hingabe)',
    'anlam': '„O Allah, durch Dich erreichen wir den Morgen und den Abend, durch Dich leben und sterben wir, und zu Dir ist die Auferstehung.“',
  },
  'ek_bismillahillezi': {
    'baslik': 'Bismillahilladhi La Yadurru (3x — Schutz vor jedem Schaden)',
    'anlam': '„Im Namen Allahs, mit dessen Namen nichts auf der Erde und im Himmel schaden kann, und Er ist der Allhörende, der Allwissende.“',
  },
  'ek_raditu_billahi': {
    'baslik': 'Raditu Billahi Rabban (Gebet der Zufriedenheit — 3x)',
    'anlam': '„Ich bin zufrieden mit Allah als meinem Herrn, mit dem Islam als meiner Religion und mit Muhammad ﷺ als meinem Propheten.“',
  },
  'ek_ya_hayyu_ya_kayyum': {
    'baslik': 'Ya Hayyu Ya Qayyum (Bittgebet um Beistand in allen Dingen)',
    'anlam': '„O Ewiglebender, o Erhalter! Bei Deiner Barmherzigkeit suche ich Hilfe. Ordne alle meine Angelegenheiten und überlasse mich keinen Augenblick mir selbst.“',
  },
  'ek_afini_fi_bedeni': {
    'baslik': 'Allahumma Afini Fi Badani (Gesundheit für Körper, Gehör & Augen — 3x)',
    'anlam': '„O Allah, schenke mir Gesundheit in meinem Körper, meinem Gehör und meinem Augenlicht. Es gibt keinen Gott außer Dir.“',
  },
  'ek_subhanallahi_ve_bihamdihi_100': {
    'baslik': 'Subhanallahi wa Bihamdihi (Morgens & Abends 100x)',
    'anlam': '„Preis sei Allah und alles Lob gebührt Ihm.“ (100-mal morgens und abends gesprochen tilgt Sünden selbst wie Meereschaum.)',
  },
  'ek_kelimatillahi_tammat': {
    'baslik': 'A’udhu Bi-Kalimatillahit-Tammat (Abends 3x)',
    'anlam': '„Ich suche Zuflucht bei den vollkommenen Worten Allahs vor dem Übel dessen, was Er erschaffen hat.“',
  },
  'ek_alimel_gayb': {
    'baslik': 'Allahumma Alimal-Ghaybi wasch-Schahadah (Schutz vor dem eigenen Ego)',
    'anlam': '„O Allah, Kenner des Verborgenen und des Offenkundigen, Schöpfer der Himmel und der Erde... Ich suche Zuflucht bei Dir vor dem Übel meiner Seele und des Satans.“',
  },
  'ek_ayetel_kursi_sabah': {
    'baslik': 'Ayat al-Kursi (Morgens, Abends & vor dem Schlafen)',
    'anlam': '„Allah — es gibt keinen Gott außer Ihm, dem Lebendigen und Beständigen. Ihn überkommt weder Schlummer noch Schlaf...“',
  },
  'ek_rabben_nas': {
    'baslik': 'Allahumma Rabban-Nas (Heilungsgebet für Kranke)',
    'anlam': '„O Allah, Herr der Menschen, nimm das Leiden hinweg und heile, denn Du bist der Heiler. Es gibt keine Heilung außer Deiner Heilung.“',
  },
  'ek_euzu_bi_izzetillah': {
    'baslik': 'Bittgebet bei Schmerzen (Hand auf die schmerzende Stelle, 7x)',
    'anlam': '„Im Namen Allahs (3x). Ich suche Zuflucht bei Allah und Seiner Macht vor dem Übel dessen, was ich empfinde und befürchte (7x).“',
  },
  'ek_esalullahel_azim': {
    'baslik': 'As’alullahal-Azim (Beim Krankenbesuch 7x)',
    'anlam': '„Ich bitte Allah, den Allmächtigen, den Herrn des gewaltigen Thrones, dich zu heilen.“',
  },
  'ek_cebrail_rukyesi': {
    'baslik': 'Bismillahi Arqik (Ruqyah des Engels Gabriel)',
    'anlam': '„Im Namen Allahs spreche ich Ruqyah über dich gegen alles, was dir schadet, gegen das Übel jeder Seele oder jedes neidischen Auges. Möge Allah dich heilen.“',
  },
  'ek_eyyub_duasi': {
    'baslik': 'Heilungsgebet des Propheten Ayyub (Hiob)',
    'anlam': '„Mir ist Unheil widerfahren, und Du bist der Barmherzigste der Barmherzigen.“',
  },
  'ek_ve_iza_maridtu': {
    'baslik': 'Wa Idha Maridtu Fahuwa Yaschfin (Wort des Propheten Ibrahim)',
    'anlam': '„Und wenn ich krank bin, so ist Er es, der mich heilt.“',
  },
  'ek_kotu_hastaliklardan': {
    'baslik': 'Bittgebet um Schutz vor schweren Krankheiten',
    'anlam': '„O Allah, ich suche Zuflucht bei Dir vor Aussatz, Wahnsinn, Lepra und allen schlimmen Krankheiten.“',
  },
  'ek_la_bese_tahur': {
    'baslik': 'La Ba’sa Tahurun Inscha’Allah (Trostworte für Kranke)',
    'anlam': '„Kein Schaden; es ist eine Reinigung von Sünden, so Allah will.“',
  },
  'ek_magfiret_rahmet_rizik': {
    'baslik': 'Bittgebet um Vergebung, Barmherzigkeit, Rechtleitung & Versorgung',
    'anlam': '„O Allah, vergib mir, erbarme Dich meiner, leite mich recht, schenke mir Wohlergehen und versorge mich.“',
  },
  'ek_musa_rizik_duasi': {
    'baslik': 'Bittgebet des Propheten Musa um Gutes & Versorgung',
    'anlam': '„Mein Herr, ich bedarf dessen, was Du an Gutem zu mir herabsendest.“',
  },
  'ek_hem_hazen_borc': {
    'baslik': 'Zuflucht vor Kummer, Trägheit und Schuldenlast',
    'anlam': '„O Allah, ich suche Zuflucht bei Dir vor Sorge und Kummer, vor Unfähigkeit und Trägheit, vor Geiz, Feigheit und der Last der Schulden.“',
  },
  'ek_aslih_li_dini': {
    'baslik': 'Bittgebet um Bewahrung von Religion, Diesseits und Jenseits',
    'anlam': '„O Allah, bringe meine Religion in Ordnung, die der Schutz meiner Angelegenheiten ist, mein Diesseits und mein Jenseits.“',
  },
  'ek_bereket_mal_evlat': {
    'baslik': 'Bittgebet um Segen in Besitz und Familie',
    'anlam': '„O Allah, mehre meinen Besitz und meine Nachkommen und segne mir das, was Du mir gegeben hast.“',
  },
  'ek_istigfar_rizik_nuh': {
    'baslik': 'Versorgung und Segen durch Vergebungsbitte (Rat des Propheten Nuh)',
    'anlam': '„Bittet euren Herrn um Vergebung, denn Er ist allvergebend; Er sendet euch reichlich Regen vom Himmel und stärkt euch mit Besitz und Kindern.“',
  },
  'ek_tevekkul_rizik_talak': {
    'baslik': 'Versorgung von unerwarteter Seite (Sure At-Talaq 2-3)',
    'anlam': '„Und wer Allah fürchtet, dem schafft Er einen Ausweg und versorgt ihn von wo er nicht damit rechnet. Und wer auf Allah vertraut, dem genügt Er.“',
  },
  'ek_muavvizeteyn': {
    'baslik': 'Al-Ichlas, Al-Falaq & An-Nas (Schutzsuren — 3x Morgens & Abends)',
    'anlam': '„Sprich: Ich suche Zuflucht beim Herrn des Tagesanbruchs vor dem Übel dessen, was Er erschaffen hat... und vor dem Übel des Neiders, wenn er neidet.“',
  },
  'ek_hasan_huseyin_nazar': {
    'baslik': 'Schutzgebet gegen den bösen Blick (für Hasan & Husayn)',
    'anlam': '„Ich suche Zuflucht bei den vollkommenen Worten Allahs vor jedem Teufel, jedem giftigen Tier und jedem bösen Blick.“',
  },
  'ek_maşaallah_kehf': {
    'baslik': 'Mascha’Allah La Quwwata Illa Billah (Beim Anblick einer Gabe)',
    'anlam': '„Was Allah will! Es gibt keine Kraft außer bei Allah.“',
  },
  'ek_bereket_duasi_nazar': {
    'baslik': 'Barakallahu Lah (Segenswunsch gegen den bösen Blick)',
    'anlam': '„O Allah, segne es für ihn.“',
  },
  'ek_nazar_ayeti_kalem': {
    'baslik': 'Schutzvers gegen den bösen Blick (Sure Al-Qalam 51-52)',
    'anlam': '„Und fast würden diejenigen, die ungläubig sind, dich mit ihren Blicken zu Fall bringen, wenn sie die Ermahnung hören... Doch es ist nur eine Ermahnung für die Welten.“',
  },
  'ek_evden_cikarken': {
    'baslik': 'Bittgebet beim Verlassen des Hauses',
    'anlam': '„Im Namen Allahs, ich vertraue auf Allah; es gibt weder Macht noch Kraft außer bei Allah.“',
  },
  'ek_zevali_nimet': {
    'baslik': 'Zuflucht vor dem Verlust von Gaben und Gesundheit',
    'anlam': '„O Allah, ich suche Zuflucht bei Dir vor dem Schwinden Deiner Gunst, der Veränderung Deines Schutzes und Deinem plötzlichen Zorn.“',
  },
  'ek_kabir_fitne_korunma': {
    'baslik': 'Zuflucht vor Trägheit und den Prüfungen des Grabes',
    'anlam': '„O Allah, ich suche Zuflucht bei Dir vor Unfähigkeit, Trägheit, Feigheit, Geiz sowie vor der Strafe des Grabes und den Prüfungen von Leben und Tod.“',
  },
  'ek_uyku_oncesi': {
    'baslik': 'Schutzgebet vor dem Einschlafen',
    'anlam': '„In Deinem Namen, mein Herr, lege ich mich nieder und erhebe mich wieder. Wenn Du meine Seele nimmst, erbarme Dich ihrer; wenn Du sie lässt, bewahre sie.“',
  },
  'ek_hemezatis_seyatin': {
    'baslik': 'Zuflucht vor den Einflüsterungen der Satane',
    'anlam': '„Mein Herr, ich suche Zuflucht bei Dir vor den Aufstachelungen der Satane und davor, dass sie mich aufsuchen.“',
  },
  'ek_tesbihat_entes_selam': {
    'baslik': 'Astaghfirullah (3x) & Allahumma Antas-Salam (Nach dem Gebet)',
    'anlam': '„Ich bitte Allah um Vergebung (3x). O Allah, Du bist der Friede und von Dir kommt der Friede. Segensreich bist Du, o Besitzer von Majestät und Ehre.“',
  },
  'ek_tesbihat_33': {
    'baslik': '33 Subhanallah, 33 Alhamdulillah, 33 Allahu Akbar & Tahlil',
    'anlam': '„Wer nach jedem Gebet 33-mal Subhanallah, 33-mal Alhamdulillah und 33-mal Allahu Akbar spricht und die Hundert mit dem Einheitsbekenntnis vollendet, dem werden seine Sünden vergeben.“',
  },
  'ek_einni_ala_zikrike': {
    'baslik': 'Allahumma A’inni Ala Dhikrika (Empfehlung an Mu’adh)',
    'anlam': '„O Allah, hilf mir, Deiner zu gedenken, Dir zu danken und Dir auf die beste Weise zu dienen.“',
  },
  'ek_la_mania_lima_ataytе': {
    'baslik': 'La Mani’a Lima A’tayta (Nach den Pflichtgebeten)',
    'anlam': '„O Allah, niemand kann zurückhalten, was Du gibst, und niemand kann geben, was Du zurückhältst.“',
  },
  'ek_ayetel_kursi_namaz': {
    'baslik': 'Ayat al-Kursi nach jedem Pflichtgebet',
    'anlam': '„Wer Ayat al-Kursi nach jedem Pflichtgebet rezitiert, den trennt nichts vom Eintritt ins Paradies außer dem Tod.“',
  },
  'ek_salli_barik': {
    'baslik': 'Salat al-Ibrahimiyyah (Salli & Barik Segensgebete)',
    'anlam': '„O Allah, segne Muhammad und die Familie Muhammads, wie Du Ibrahim und die Familie Ibrahims gesegnet hast. Du bist des Lobes würdig und ruhmreich.“',
  },
  'ek_ebubekir_namaz_duasi': {
    'baslik': 'Das Abu Bakr für das Gebet gelehrte Bittgebet',
    'anlam': '„O Allah, ich habe mir selbst viel Unrecht zugefügt, und niemand vergibt die Sünden außer Dir. Vergib mir aus Deiner Huld und erbarme Dich meiner.“',
  },
  'ek_teşehhud_sonrasi_istiaze': {
    'baslik': 'Zuflucht vor vier Dingen im letzten Sitzen des Gebets',
    'anlam': '„O Allah, ich suche Zuflucht bei Dir vor der Strafe der Hölle, der Strafe des Grabes, den Prüfungen von Leben und Tod und der Versuchung des falschen Messias.“',
  },
};

const Map<String, Map<String, String>> _kDuaCeviriFr = {
  'rabbena_atina': {
    'baslik': 'Rabbana Atina (Le bien ici-bas et dans l’au-delà)',
    'anlam': '« Seigneur ! Accorde-nous belle part ici-bas, et belle part aussi dans l’au-delà ; et protège-nous du châtiment du Feu ! »',
    'kaynak': 'Le Saint Coran — Sourate Al-Baqarah, 2:201',
  },
  'rabbenagfirlî': {
    'baslik': 'Rabbanaghfirli (Pardon pour les parents et les croyants)',
    'anlam': '« Ô notre Seigneur ! Pardonne-moi, ainsi qu’à mes père et mère et aux croyants, le jour où les comptes seront rendus. »',
    'kaynak': 'Le Saint Coran — Sourate Ibrahim, 14:41',
  },
  'rabbena_la_tuzig': {
    'baslik': 'Rabbana La Tuzigh Qulubana (Constance dans la guidée)',
    'anlam': '« Seigneur ! Ne laisse pas dévier nos cœurs après que Tu nous aies guidés ; et accorde-nous Ta miséricorde. C’est Toi, certes, le Grand Donateur ! »',
    'kaynak': 'Le Saint Coran — Sourate Ali ’Imran, 3:8',
  },
  'rabbena_heb_lena': {
    'baslik': 'Invocation pour une famille et une descendance pieuses',
    'anlam': '« Seigneur, donne-nous, en nos épouses et nos descendants, la joie des yeux, et fais de nous un guide pour les pieux. »',
    'kaynak': 'Le Saint Coran — Sourate Al-Furqan, 25:74',
  },
  'rabbena_efrig': {
    'baslik': 'Invocation pour la patience et la fermeté',
    'anlam': '« Seigneur ! Déverse sur nous l’endurance, affermis nos pas et donne-nous la victoire. »',
    'kaynak': 'Le Saint Coran — Sourate Al-Baqarah, 2:250',
  },
  'rabbi_yessir': {
    'baslik': 'Rabbi Yassir (Prière pour la facilité et la réussite)',
    'anlam': '« Mon Seigneur ! Facilite-moi les choses et ne les rends pas difficiles. Mon Seigneur, achève cette affaire par le bien. »',
    'kaynak': 'Tradition prophétique (Sahih al-Boukhari, Science 11)',
  },
  'rabbi_srahli_sadri': {
    'baslik': 'Prière du Prophète Moussa pour la sérénité et l’éloquence',
    'anlam': '« Seigneur, ouvre-moi ma poitrine, et facilite ma mission, et dénoue un nœud en ma langue, afin qu’ils comprennent mes paroles. »',
    'kaynak': 'Le Saint Coran — Sourate Ta-Ha, 20:25-28',
  },
  'rabbi_zidni_ilma': {
    'baslik': 'Invocation pour l’accroissement de la science utile',
    'anlam': '« Ô mon Seigneur, accrois mes connaissances et ma compréhension, et fais-moi rejoindre les vertueux. »',
    'kaynak': 'Le Saint Coran — Sourate Ta-Ha 20:114 & Ach-Chou’ara 26:83',
  },
  'yunus_duasi': {
    'baslik': 'Invocation du Prophète Younous pour la délivrance de l’épreuve',
    'anlam': '« Pas de divinité à part Toi ! Pureté à Toi ! J’ai été vraiment du nombre des injustes. »',
    'kaynak': 'Le Saint Coran — Sourate Al-Anbiya, 21:87',
  },
  'kalp_huzuru_duasi': {
    'baslik': 'Refuge prophétique contre le souci, la tristesse et les dettes',
    'anlam': '« Ô Allah, je cherche refuge auprès de Toi contre le souci et la tristesse, l’incapacité et la paresse, l’avarice et la lâcheté, et le poids des dettes. »',
    'kaynak': 'Sahih al-Boukhari, Invocations 36 — Hadith 6369',
  },
  'peygamber_sifa_duasi': {
    'baslik': 'Invocation prophétique pour une guérison complète',
    'anlam': '« Ô Allah, Seigneur des hommes ! Éloigne le mal et guéris, car Tu es Celui qui guérit. Il n’y a de guérison que Ta guérison, une guérison qui ne laisse aucune maladie. »',
    'kaynak': 'Sahih al-Boukhari, Médecine 38 & Sahih Mouslim',
  },
  'eyyub_sifa_duasi': {
    'baslik': 'Invocation de guérison du Prophète Ayyoub (Job)',
    'anlam': '« Seigneur, le mal m’a touché. Mais Toi, Tu es le plus Miséricordieux des miséricordieux ! »',
    'kaynak': 'Le Saint Coran — Sourate Al-Anbiya, 21:83',
  },
  'helal_rizik_duasi': {
    'baslik': 'Invocation pour une subsistance licite et suffisante',
    'anlam': '« Ô Allah, suffis-moi par ce que Tu as rendu licite face à ce que Tu as interdit, et enrichis-moi par Ta grâce afin que je n’aie besoin de personne d’autre que Toi. »',
    'kaynak': 'Jami’ at-Tirmidhi, Invocations 110 — Hadith 3563',
  },
  'faydali_ilim_temiz_rizik': {
    'baslik': 'Prière du matin pour le savoir utile et la subsistance pure',
    'anlam': '« Ô Allah, je Te demande une science utile, une subsistance bonne et pure, et des œuvres acceptées. »',
    'kaynak': 'Sounan Ibn Majah, Hadith 925',
  },
  'sabah_aksam_afiyet': {
    'baslik': 'Invocation du matin et du soir pour le pardon et la préservation',
    'anlam': '« Ô Allah, je Te demande le pardon et la préservation dans ce monde et dans l’au-delà. »',
    'kaynak': 'Sounan Abi Dawoud, Hadith 5074',
  },
  'hasbiyallahu': {
    'baslik': 'Invocation de confiance en Allah (HasbiyAllahu)',
    'anlam': '« Allah me suffit ! Il n’y a de divinité que Lui. En Lui je place ma confiance ; et Il est le Seigneur du Trône immense. »',
    'kaynak': 'Le Saint Coran — Sourate At-Tawbah, 9:129',
  },
  'seyyidul_istigfar': {
    'baslik': 'Sayyid al-Istighfar (La maîtresse des demandes de pardon)',
    'anlam': '« Ô Allah, Tu es mon Seigneur, il n’y a de divinité que Toi. Tu m’as créé et je suis Ton serviteur... Pardonne-moi, car nul ne pardonne les péchés si ce n’est Toi. »',
    'kaynak': 'Sahih al-Boukhari, Invocations 2 — Hadith 6306',
  },
  'ek_asbahna': {
    'baslik': 'Asbahna wa Asbahal-Moulkou Lillah (Invocation du matin)',
    'anlam': '« Nous voici au matin et la royauté appartient à Allah. Louange à Allah. Il n’y a de divinité qu’Allah seul, sans associé. »',
  },
  'ek_bike_asbahna': {
    'baslik': 'Allahoumma Bika Asbahna (Abandon confiant matin & soir)',
    'anlam': '« Ô Allah, c’est par Toi que nous entrons dans le matin et dans le soir, par Toi que nous vivons et mourons, et vers Toi est la résurrection. »',
  },
  'ek_bismillahillezi': {
    'baslik': 'Bismillahilladhi La Yadourrou (3x — Protection contre tout mal)',
    'anlam': '« Au nom d’Allah avec le nom Duquel rien sur terre ni dans le ciel ne peut nuire, et Il est l’Audient, l’Omniscient. »',
  },
  'ek_raditu_billahi': {
    'baslik': 'Raditou Billahi Rabban (Invocation d’agrément — 3x)',
    'anlam': '« J’agrée Allah comme Seigneur, l’Islam comme religion et Mouhammad ﷺ comme Prophète. »',
  },
  'ek_ya_hayyu_ya_kayyum': {
    'baslik': 'Ya Hayyou Ya Qayyoum (Invocation enseignée à Fatima)',
    'anlam': '« Ô Vivant, ô Subsistant, par Ta miséricorde j’implore secours. Réforme toutes mes affaires et ne me laisse pas à moi-même le temps d’un clin d’œil. »',
  },
  'ek_afini_fi_bedeni': {
    'baslik': 'Allahoumma Afini Fi Badani (Santé du corps, de l’ouïe et de la vue — 3x)',
    'anlam': '« Ô Allah, accorde-moi la santé dans mon corps, dans mon ouïe et dans ma vue. Il n’y a de divinité que Toi. »',
  },
  'ek_subhanallahi_ve_bihamdihi_100': {
    'baslik': 'Soubhanallahi wa Bihamdihi (100x matin et soir)',
    'anlam': '« Gloire et pureté à Allah et par Sa louange. » (Récité 100 fois matin et soir, efface les péchés fussent-ils comme l’écume de la mer.)',
  },
  'ek_kelimatillahi_tammat': {
    'baslik': 'A’oudhou Bi-Kalimatillahit-Tammat (Le soir 3x)',
    'anlam': '« Je cherche refuge dans les paroles parfaites d’Allah contre le mal de ce qu’Il a créé. »',
  },
  'ek_alimel_gayb': {
    'baslik': 'Allahoumma Alimal-Ghaybi wach-Chahadah (Protection contre le mal de l’âme)',
    'anlam': '« Ô Allah, Connaisseur de l’invisible et du visible, Créateur des cieux et de la terre... Je cherche refuge auprès de Toi contre le mal de mon âme et du diable. »',
  },
  'ek_ayetel_kursi_sabah': {
    'baslik': 'Ayat al-Koursi (Matin, soir et avant le sommeil)',
    'anlam': '« Allah ! Point de divinité à part Lui, le Vivant, Celui qui subsiste par Lui-même. Ni somnolence ni sommeil ne Le saisissent... »',
  },
  'ek_rabben_nas': {
    'baslik': 'Allahoumma Rabban-Nas (Invocation de guérison pour le malade)',
    'anlam': '« Ô Allah, Seigneur des hommes, éloigne le mal et guéris, car Tu es Celui qui guérit. Il n’y a de guérison que Ta guérison. »',
  },
  'ek_euzu_bi_izzetillah': {
    'baslik': 'Invocation contre la douleur (Main sur la zone douloureuse, 7x)',
    'anlam': '« Au nom d’Allah (3x). Je cherche refuge auprès d’Allah et de Sa puissance contre le mal de ce que je ressens et redoute (7x). »',
  },
  'ek_esalullahel_azim': {
    'baslik': 'As’aloullahal-Azim (Lors de la visite au malade, 7x)',
    'anlam': '« Je demande à Allah l’Immense, Seigneur du Trône immense, de te guérir. »',
  },
  'ek_cebrail_rukyesi': {
    'baslik': 'Bismillahi Arqik (Roqya de l’Ange Jibril)',
    'anlam': '« Au nom d’Allah je te fais la roqya contre toute chose qui te nuit, contre le mal de toute âme ou œil envieux. Qu’Allah te guérisse. »',
  },
  'ek_eyyub_duasi': {
    'baslik': 'Invocation de guérison du Prophète Ayyoub (Job)',
    'anlam': '« Le mal m’a touché. Mais Toi, Tu es le plus Miséricordieux des miséricordieux ! »',
  },
  'ek_ve_iza_maridtu': {
    'baslik': 'Wa Idha Maridtou Fahouwa Yachfin (Parole du Prophète Ibrahim)',
    'anlam': '« Et quand je suis malade, c’est Lui qui me guérit. »',
  },
  'ek_kotu_hastaliklardan': {
    'baslik': 'Refuge contre les maladies graves',
    'anlam': '« Ô Allah, je cherche refuge auprès de Toi contre la lèpre, la folie et toutes les mauvaises maladies. »',
  },
  'ek_la_bese_tahur': {
    'baslik': 'La Ba’sa Tahouroun Incha’Allah (Parole d’apaisement au malade)',
    'anlam': '« Pas de mal ; c’est une purification, si Allah le veut. »',
  },
  'ek_magfiret_rahmet_rizik': {
    'baslik': 'Invocation pour le pardon, la miséricorde, la guidée et la subsistance',
    'anlam': '« Ô Allah, pardonne-moi, fais-moi miséricorde, guide-moi, accorde-moi le salut et pourvois à mes besoins. »',
  },
  'ek_musa_rizik_duasi': {
    'baslik': 'Invocation du Prophète Moussa pour le bien et la subsistance',
    'anlam': '« Seigneur, j’ai grand besoin de tout bien que Tu feras descendre vers moi. »',
  },
  'ek_hem_hazen_borc': {
    'baslik': 'Refuge contre l’angoisse, la paresse et le poids des dettes',
    'anlam': '« Ô Allah, je cherche refuge auprès de Toi contre le souci et la tristesse, l’incapacité et la paresse, l’avarice, la lâcheté et le poids des dettes. »',
  },
  'ek_aslih_li_dini': {
    'baslik': 'Invocation pour la préservation de la religion, de ce monde et de l’au-delà',
    'anlam': '« Ô Allah, réforme ma religion qui est la sauvegarde de mes affaires, mon bas-monde où se trouve ma subsistance, et mon au-delà vers lequel est mon retour. »',
  },
  'ek_bereket_mal_evlat': {
    'baslik': 'Invocation de bénédiction dans les biens et la famille',
    'anlam': '« Ô Allah, accrois mes biens et ma descendance, et bénis ce que Tu m’as accordé. »',
  },
  'ek_istigfar_rizik_nuh': {
    'baslik': 'La subsistance et la bénédiction par l’Istighfar (Conseil de Nouh)',
    'anlam': '« Implorez le pardon de votre Seigneur, car Il est grand Pardonneur, pour qu’Il vous envoie du ciel des pluies abondantes et vous accorde biens et enfants. »',
  },
  'ek_tevekkul_rizik_talak': {
    'baslik': 'La subsistance d’où l’on ne s’y attend pas (Sourate At-Talaq 2-3)',
    'anlam': '« Et quiconque craint Allah, Il lui donnera une issue favorable, et lui accordera Ses dons par des moyens sur lesquels il ne comptait pas. Et quiconque place sa confiance en Allah, Il lui suffit. »',
  },
  'ek_muavvizeteyn': {
    'baslik': 'Al-Ikhlas, Al-Falaq & An-Nas (Sourates protectrices — 3x matin et soir)',
    'anlam': '« Dis : Je cherche protection auprès du Seigneur de l’aube naissante, contre le mal des êtres qu’Il a créés... et contre le mal de l’envieux quand il envie. »',
  },
  'ek_hasan_huseyin_nazar': {
    'baslik': 'Protection contre le mauvais œil (pour Al-Hasan et Al-Housayn)',
    'anlam': '« Je cherche protection par les paroles parfaites d’Allah contre tout démon, tout être venimeux et tout mauvais œil. »',
  },
  'ek_maşaallah_kehf': {
    'baslik': 'Macha’Allah La Qouwwata Illa Billah (Devant un bienfait)',
    'anlam': '« Ce qu’Allah veut ! Il n’y a de puissance que par Allah. »',
  },
  'ek_bereket_duasi_nazar': {
    'baslik': 'Barakallahou Lah (Invocation de bénédiction contre le mauvais œil)',
    'anlam': '« Ô Allah, bénis-le. »',
  },
  'ek_nazar_ayeti_kalem': {
    'baslik': 'Verset contre le mauvais œil (Sourate Al-Qalam 51-52)',
    'anlam': '« Peu s’en faut que ceux qui mécroient ne te transpercent par leurs regards, quand ils entendent le Coran... Mais ce n’est qu’un rappel pour les mondes. »',
  },
  'ek_evden_cikarken': {
    'baslik': 'Invocation en sortant de la maison',
    'anlam': '« Au nom d’Allah, je place ma confiance en Allah ; il n’y a de force ni de puissance que par Allah. »',
  },
  'ek_zevali_nimet': {
    'baslik': 'Refuge contre la disparition des bienfaits',
    'anlam': '« Ô Allah, je cherche refuge auprès de Toi contre la disparition de Tes bienfaits, l’altération de Ta préservation et Ton courroux soudain. »',
  },
  'ek_kabir_fitne_korunma': {
    'baslik': 'Refuge contre la paresse et le châtiment de la tombe',
    'anlam': '« Ô Allah, je cherche refuge auprès de Toi contre l’incapacité, la paresse, la lâcheté, l’avarice, ainsi que contre le châtiment de la tombe et les épreuves de la vie et de la mort. »',
  },
  'ek_uyku_oncesi': {
    'baslik': 'Invocation protectrice avant de dormir',
    'anlam': '« En Ton nom, mon Seigneur, je me couche et par Toi je me relève. Si Tu retiens mon âme, fais-lui miséricorde ; si Tu la renvoies, protège-la comme Tu protèges Tes pieux serviteurs. »',
  },
  'ek_hemezatis_seyatin': {
    'baslik': 'Refuge contre les suggestions des démons',
    'anlam': '« Seigneur, je cherche protection auprès de Toi contre les suggestions des diables, et je cherche protection auprès de Toi contre leur présence auprès de moi. »',
  },
  'ek_tesbihat_entes_selam': {
    'baslik': 'Astaghfiroullah (3x) & Allahoumma Antas-Salam (Après la prière)',
    'anlam': '« Je demande pardon à Allah (3x). Ô Allah, Tu es la Paix et de Toi vient la paix. Béni sois-Tu, ô Détenteur de la Majesté et de la Générosité. »',
  },
  'ek_tesbihat_33': {
    'baslik': '33 Soubhanallah, 33 Alhamdoulillah, 33 Allahou Akbar & Tahlil',
    'anlam': '« Quiconque glorifie Allah 33 fois, Le loue 33 fois et proclame Sa grandeur 33 fois après chaque prière, puis complète la centaine par l’unicité, voit ses péchés pardonnés. »',
  },
  'ek_einni_ala_zikrike': {
    'baslik': 'Allahoumma A’inni Ala Dhikrika (Conseillé à Mou’adh)',
    'anlam': '« Ô Allah, aide-moi à T’évoquer, à Te remercier et à T’adorer de la meilleure manière. »',
  },
  'ek_la_mania_lima_ataytе': {
    'baslik': 'La Mani’a Lima A’tayta (Après les prières obligatoires)',
    'anlam': '« Ô Allah, nul ne peut retenir ce que Tu donnes, ni donner ce que Tu retiens. »',
  },
  'ek_ayetel_kursi_namaz': {
    'baslik': 'Ayat al-Koursi après chaque prière obligatoire',
    'anlam': '« Quiconque récite Ayat al-Koursi après chaque prière obligatoire, rien ne l’empêche d’entrer au Paradis si ce n’est la mort. »',
  },
  'ek_salli_barik': {
    'baslik': 'Salat al-Ibrahimiyyah (Salli & Barik)',
    'anlam': '« Ô Allah, prie sur Mouhammad et sur la famille de Mouhammad comme Tu as prié sur Ibrahim, et bénis Mouhammad comme Tu as béni Ibrahim. »',
  },
  'ek_ebubekir_namaz_duasi': {
    'baslik': 'Invocation enseignée à Abou Bakr pour sa prière',
    'anlam': '« Ô Allah, je me suis fait beaucoup de tort à moi-même et nul ne pardonne les péchés si ce n’est Toi. Accorde-moi un pardon de Ta part et fais-moi miséricorde. »',
  },
  'ek_teşehhud_sonrasi_istiaze': {
    'baslik': 'Refuge contre quatre choses lors du dernier Tachahhoud',
    'anlam': '« Ô Allah, je cherche refuge auprès de Toi contre le châtiment de l’Enfer, le châtiment de la tombe, les épreuves de la vie et de la mort et l’épreuve du Faux Messie. »',
  },
};

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
      konuDe: '${dua.kategori('DE')} • ${dua.baslik('DE')}',
      konuFr: '${dua.kategori('FR')} • ${dua.baslik('FR')}',
      mealTr: dua.anlamTr,
      mealEn: dua.anlamEn,
      mealDe: dua.anlam('DE'),
      mealFr: dua.anlam('FR'),
      kaynakKisaTr: dua.baslikTr,
      kaynakKisaEn: dua.baslikEn,
      kaynakKisaDe: dua.baslik('DE'),
      kaynakKisaFr: dua.baslik('FR'),
      dogrulanmisTr: 'Doğrulanmış Kaynak: ${dua.kaynakTr}',
      dogrulanmisEn: 'Verified Source: ${dua.kaynakEn}',
      dogrulanmisDe: 'Verifizierte Quelle: ${dua.kaynak('DE')}',
      dogrulanmisFr: 'Source vérifiée : ${dua.kaynak('FR')}',
      tefsirTr: 'Okunuşu: ${dua.okunusTr}',
      tefsirEn: 'Transliteration: ${dua.okunusTr}',
      tefsirDe: 'Aussprache: ${dua.okunusTr}',
      tefsirFr: 'Phonétique : ${dua.okunusTr}',
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
      return d.baslik(dil).toLowerCase().contains(q) ||
          d.anlam(dil).toLowerCase().contains(q) ||
          d.baslikTr.toLowerCase().contains(q) ||
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
              hintText: dil == 'DE'
                  ? 'Bittgebete durchsuchen (z.B. Rabbana, Heilung, Prüfung)...'
                  : dil == 'FR'
                      ? 'Rechercher une invocation (ex: Rabbana, Guérison, Examen)...'
                      : dil == 'EN'
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
                  kDuaKategoriEtiket(kat, dil),
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
              final baslik = dua.baslik(dil);
              final anlam = dua.anlam(dil);
              final kaynak = dua.kaynak(dil);
              final kategori = dua.kategori(dil);

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
