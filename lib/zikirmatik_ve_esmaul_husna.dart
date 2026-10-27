import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'js_bridge.dart';
import 'web_shim_io.dart' if (dart.library.js_interop) 'package:web/web.dart' as web;
import 'quran_api_service.dart';
import 'quran_hadith_data.dart';
import 'share_story_sheet.dart';

// ============================================================================
// 1. ALLAH'IN 99 GÜZEL İSMİ (99 ESMAÜ'L HÜSNA) VERİ MODELİ VE TAM LİSTESİ (1-99)
// ============================================================================

class EsmaModel {
  final int sira;
  final String arapca;
  final String okunus;
  final String adEn;
  final String anlamTr;
  final String anlamEn;
  final int zikirSayisi;

  const EsmaModel({
    required this.sira,
    required this.arapca,
    required this.okunus,
    required this.adEn,
    required this.anlamTr,
    required this.anlamEn,
    required this.zikirSayisi,
  });

  String get zikirLafzi => sira == 1 ? 'Yâ Allah (c.c.)' : 'Yâ ${okunus.replaceFirst(RegExp(r'^E[A-Za-zşŞçÇğĞüÜöÖıİ]+-'), '')}';
}

const List<EsmaModel> k99EsmaulHusna = [
  EsmaModel(sira: 1, arapca: 'اللَّهُ', okunus: 'Allah (c.c.)', adEn: 'Allah', anlamTr: 'Bütün kemâl sıfatları kendisinde toplayan, eşi ve benzeri olmayan tek yaratıcı.', anlamEn: 'The Greatest Name, the One and Only God worthy of all worship.', zikirSayisi: 66),
  EsmaModel(sira: 2, arapca: 'الرَّحْمَٰنُ', okunus: 'Er-Rahmân', adEn: 'Ar-Rahman', anlamTr: 'Dünyada bütün mahlûkata merhamet eden, şefkat gösteren ve rızık veren.', anlamEn: 'The Most Gracious, the Beneficent to all creation in this world.', zikirSayisi: 298),
  EsmaModel(sira: 3, arapca: 'الرَّحِيمُ', okunus: 'Er-Rahîm', adEn: 'Ar-Rahim', anlamTr: 'Ahirette yalnızca mümin kullarına sonsuz rahmet ve ikramda bulunan.', anlamEn: 'The Most Merciful, especially compassionate to believers in the Hereafter.', zikirSayisi: 258),
  EsmaModel(sira: 4, arapca: 'الْمَلِكُ', okunus: 'El-Melik', adEn: 'Al-Malik', anlamTr: 'Bütün kâinatın mutlak sahibi, mülk ve saltanatı devamlı olan hükümdar.', anlamEn: 'The Sovereign Lord, the Eternal King of the entire universe.', zikirSayisi: 90),
  EsmaModel(sira: 5, arapca: 'الْقُدُّوسُ', okunus: 'El-Kuddûs', adEn: 'Al-Quddus', anlamTr: 'Her türlü eksiklik, kusur ve noksanlıktan münezzeh, tertemiz ve mukaddes.', anlamEn: 'The Most Pure, the Most Holy, free from all imperfection.', zikirSayisi: 170),
  EsmaModel(sira: 6, arapca: 'السَّلَامُ', okunus: 'Es-Selâm', adEn: 'As-Salam', anlamTr: 'Kullarını selâmete çıkaran, her türlü korku ve afetten emin kılan esenlik kaynağı.', anlamEn: 'The Source of Peace, Safety, and Perfection.', zikirSayisi: 131),
  EsmaModel(sira: 7, arapca: 'الْمُؤْمِنُ', okunus: 'El-Mü’min', adEn: 'Al-Mu’min', anlamTr: 'Kalplere iman nuru bahşeden, kendisine sığınanlara güven ve emniyet veren.', anlamEn: 'The Bestower of Faith and Security.', zikirSayisi: 137),
  EsmaModel(sira: 8, arapca: 'الْمُهَيْمِنُ', okunus: 'El-Müheymin', adEn: 'Al-Muhaymin', anlamTr: 'Bütün varlıkları ilmi ve kudretiyle görüp gözeten, koruyan ve kollayan.', anlamEn: 'The Guardian, the All-Watchful Protector over all things.', zikirSayisi: 145),
  EsmaModel(sira: 9, arapca: 'الْعَزِيزُ', okunus: 'El-Azîz', adEn: 'Al-Aziz', anlamTr: 'İzzet ve kudret sahibi, mağlup edilmesi imkânsız olan mutlak galip.', anlamEn: 'The Almighty, the Invincible, the Most Honorable.', zikirSayisi: 94),
  EsmaModel(sira: 10, arapca: 'الْجَبَّارُ', okunus: 'El-Cebbâr', adEn: 'Al-Jabbar', anlamTr: 'Kırılanları onaran, dertlilere derman olan, iradesini her durumda yürüten.', anlamEn: 'The Restorer, the Compeller who mends broken hearts.', zikirSayisi: 206),
  EsmaModel(sira: 11, arapca: 'الْمُتَكَبِّرُ', okunus: 'El-Mütekebbir', adEn: 'Al-Mutakabbir', anlamTr: 'Büyüklükte eşi olmayan, azamet ve ululuk yalnızca kendisine mahsus olan.', anlamEn: 'The Supreme in Majesty and Greatness.', zikirSayisi: 662),
  EsmaModel(sira: 12, arapca: 'الْخَالِقُ', okunus: 'El-Hâlık', adEn: 'Al-Khaliq', anlamTr: 'Her şeyi yoktan ve kusursuz bir ölçüyle takdir edip yaratan.', anlamEn: 'The Creator who brings everything into existence from nothing.', zikirSayisi: 731),
  EsmaModel(sira: 13, arapca: 'الْبَارِئُ', okunus: 'El-Bâri’', adEn: 'Al-Bari’', anlamTr: 'Yarattığı varlıkları birbirine uyumlu ve benzersiz bir nizama göre var eden.', anlamEn: 'The Evolver, the Maker of harmony and proportion.', zikirSayisi: 214),
  EsmaModel(sira: 14, arapca: 'الْمُصَوِّرُ', okunus: 'El-Musavvir', adEn: 'Al-Musawwir', anlamTr: 'Her varlığa kendine has en güzel suret, şekil ve özelliği veren.', anlamEn: 'The Fashioner of Forms and unique beauty.', zikirSayisi: 336),
  EsmaModel(sira: 15, arapca: 'الْغَفَّارُ', okunus: 'El-Gaffâr', adEn: 'Al-Ghaffar', anlamTr: 'Kullarının günahlarını örten, tövbeleri kabul edip tekrar tekrar bağışlayan.', anlamEn: 'The Perpetual Forgiver of sins and faults.', zikirSayisi: 1281),
  EsmaModel(sira: 16, arapca: 'الْقَهَّارُ', okunus: 'El-Kahhâr', adEn: 'Al-Qahhar', anlamTr: 'Her şeye galip gelen, zalimleri ve zorbaları kudretiyle boyun eğdiren.', anlamEn: 'The Subduer, the Dominant over all creation.', zikirSayisi: 306),
  EsmaModel(sira: 17, arapca: 'الْوَهَّابُ', okunus: 'El-Vehhâb', adEn: 'Al-Wahhab', anlamTr: 'Karşılıksız olarak bolca nimet, lütuf ve ihsan bağışlayan.', anlamEn: 'The Supreme Bestower of endless gifts without measure.', zikirSayisi: 14),
  EsmaModel(sira: 18, arapca: 'الرَّزَّاقُ', okunus: 'Er-Rezzâk', adEn: 'Ar-Razzaq', anlamTr: 'Yaratılmış bütün canlıların maddi ve manevi rızıklarını kesintisiz veren.', anlamEn: 'The All-Provider and Sustainer of both body and soul.', zikirSayisi: 308),
  EsmaModel(sira: 19, arapca: 'الْفَتَّاحُ', okunus: 'El-Fettâh', adEn: 'Al-Fattah', anlamTr: 'Her türlü müşkülü çözen, hayır, rahmet ve bereket kapılarını açan.', anlamEn: 'The Opener of doors of mercy, relief, and victory.', zikirSayisi: 489),
  EsmaModel(sira: 20, arapca: 'الْعَلِيمُ', okunus: 'El-Alîm', adEn: 'Al-Alim', anlamTr: 'Gizli ve açık, geçmiş ve gelecek her şeyi en ince ayrıntısına kadar bilen.', anlamEn: 'The All-Knowing, nothing is hidden from His knowledge.', zikirSayisi: 150),
  EsmaModel(sira: 21, arapca: 'الْقَابِضُ', okunus: 'El-Kâbıd', adEn: 'Al-Qabid', anlamTr: 'Dilediğine hikmetiyle rızkı daraltan, ruhları kabzeden ve kalpleri sıkan.', anlamEn: 'The Withholder, the Constrictor according to His wisdom.', zikirSayisi: 903),
  EsmaModel(sira: 22, arapca: 'الْبَاسِطُ', okunus: 'El-Bâsıt', adEn: 'Al-Basit', anlamTr: 'Rızıkları genişleten, kalplere ferahlık, inşirah ve huzur veren.', anlamEn: 'The Expander of provision and spiritual joy.', zikirSayisi: 72),
  EsmaModel(sira: 23, arapca: 'الْخَافِضُ', okunus: 'El-Hâfıd', adEn: 'Al-Khafid', anlamTr: 'Kibirlenenleri ve zalimleri alçaltan, hak ettikleri dereceye indiren.', anlamEn: 'The Abaser of the arrogant and unjust.', zikirSayisi: 1481),
  EsmaModel(sira: 24, arapca: 'الرَّافِعُ', okunus: 'Er-Râfi’', adEn: 'Ar-Rafi’', anlamTr: 'İman ve tevazu sahiplerinin şerefini dünyada ve ahirette yükselten.', anlamEn: 'The Exalter who elevates the humble believers.', zikirSayisi: 351),
  EsmaModel(sira: 25, arapca: 'الْمُعِزُّ', okunus: 'El-Mu’izz', adEn: 'Al-Mu’izz', anlamTr: 'Dilediği kuluna izzet, vakar, şeref ve itibar bahşeden.', anlamEn: 'The Giver of Honor, Dignity, and Strength.', zikirSayisi: 117),
  EsmaModel(sira: 26, arapca: 'الْمُذِلُّ', okunus: 'El-Müzill', adEn: 'Al-Mudhill', anlamTr: 'Emrine asi olup zulmedenleri zillete düşüren.', anlamEn: 'The Humiliator of those who persist in tyranny.', zikirSayisi: 770),
  EsmaModel(sira: 27, arapca: 'السَّمِيعُ', okunus: 'Es-Semî’', adEn: 'As-Sami’', anlamTr: 'Fısıltıları ve kalplerden geçen bütün duaları eksiksiz işiten.', anlamEn: 'The All-Hearing who hears every whispered prayer.', zikirSayisi: 180),
  EsmaModel(sira: 28, arapca: 'الْبَصِيرُ', okunus: 'El-Basîr', adEn: 'Al-Basir', anlamTr: 'Karanlıkta ve aydınlıkta, gizli ve açık her şeyi kemâliyle gören.', anlamEn: 'The All-Seeing who perceives all things clearly.', zikirSayisi: 302),
  EsmaModel(sira: 29, arapca: 'الْحَكَمُ', okunus: 'El-Hakem', adEn: 'Al-Hakam', anlamTr: 'Mutlak hüküm sahibi, hak ile batılı ayıran ve hükmü asla bozulmayan.', anlamEn: 'The Impartial Judge whose decree is final and true.', zikirSayisi: 68),
  EsmaModel(sira: 30, arapca: 'الْعَدْلُ', okunus: 'El-Adl', adEn: 'Al-Adl', anlamTr: 'Sonsuz adalet sahibi, hiçbir kuluna zerre kadar zulmetmeyen.', anlamEn: 'The Utterly Just in all His judgments and actions.', zikirSayisi: 104),
  EsmaModel(sira: 31, arapca: 'اللَّطِيفُ', okunus: 'El-Latîf', adEn: 'Al-Latif', anlamTr: 'En ince işlerin bütün inceliklerini bilen, kullarına sezdirmeden lütufta bulunan.', anlamEn: 'The Subtle, the Most Gentle and Gracious.', zikirSayisi: 129),
  EsmaModel(sira: 32, arapca: 'الْخَبِيرُ', okunus: 'El-Habîr', adEn: 'Al-Khabir', anlamTr: 'Her şeyin iç yüzünden ve gizli sırlarından haberdar olan.', anlamEn: 'The All-Aware who knows the inner reality of all things.', zikirSayisi: 812),
  EsmaModel(sira: 33, arapca: 'الْحَلِيمُ', okunus: 'El-Halîm', adEn: 'Al-Halim', anlamTr: 'Günahkârları cezalandırmakta acele etmeyen, tövbe için mühlet tanıyan yumuşaklık sahibi.', anlamEn: 'The Most Forbearing, Clement, and Slow to anger.', zikirSayisi: 88),
  EsmaModel(sira: 34, arapca: 'الْعَظِيمُ', okunus: 'El-Azîm', adEn: 'Al-Azim', anlamTr: 'Zâtı ve sıfatları bakımından pek yüce, azameti akılların idrakini aşan.', anlamEn: 'The Magnificent, the Supreme in Glory.', zikirSayisi: 1020),
  EsmaModel(sira: 35, arapca: 'الْغَفُورُ', okunus: 'El-Gafûr', adEn: 'Al-Ghafur', anlamTr: 'Mağfireti bol olan, samimi tövbe edenin bütün günahlarını bağışlayan.', anlamEn: 'The All-Forgiving whose mercy covers all sins.', zikirSayisi: 1286),
  EsmaModel(sira: 36, arapca: 'الشَّكُورُ', okunus: 'Eş-Şekûr', adEn: 'Ash-Shakur', anlamTr: 'Kullarının az ibadet ve şükrüne karşılık kat kat fazla sevap ve nimet veren.', anlamEn: 'The Most Appreciative who rewards small deeds abundantly.', zikirSayisi: 526),
  EsmaModel(sira: 37, arapca: 'الْعَلِيُّ', okunus: 'El-Aliyy', adEn: 'Al-Aliyy', anlamTr: 'İzzet, şeref ve hükümranlıkta en yüce, her şeyden üstün olan.', anlamEn: 'The Most High, the Exalted above all.', zikirSayisi: 110),
  EsmaModel(sira: 38, arapca: 'الْكَبِيرُ', okunus: 'El-Kebîr', adEn: 'Al-Kabir', anlamTr: 'Büyüklüğü sınırsız olan, varlığının kemâline hudut bulunmayan.', anlamEn: 'The Most Great, incomparable in majesty.', zikirSayisi: 232),
  EsmaModel(sira: 39, arapca: 'الْحَفِيظُ', okunus: 'El-Hafîz', adEn: 'Al-Hafiz', anlamTr: 'Kâinatı ve kendisine sığınan kullarını her türlü tehlikeden koruyan.', anlamEn: 'The Preserver and Protector of all creation.', zikirSayisi: 998),
  EsmaModel(sira: 40, arapca: 'الْمُقِيتُ', okunus: 'El-Mukît', adEn: 'Al-Muqit', anlamTr: 'Her yaratılmışın gıdasını ve azığını kudretiyle takdir edip ulaştıran.', anlamEn: 'The Sustainer and Nourisher of all beings.', zikirSayisi: 550),
  EsmaModel(sira: 41, arapca: 'الْحَسِيبُ', okunus: 'El-Hasîb', adEn: 'Al-Hasib', anlamTr: 'Kullarına her hususta kâfi gelen (yeten) ve herkesin hesabını en adil şekilde gören.', anlamEn: 'The Reckoner who suffices for all who trust in Him.', zikirSayisi: 80),
  EsmaModel(sira: 42, arapca: 'الْجَلِيلُ', okunus: 'El-Celîl', adEn: 'Al-Jalil', anlamTr: 'Celâl, ululuk ve heybet sahibi, yücelik sıfatlarıyla muttasıf olan.', anlamEn: 'The Majestic, the Glorious.', zikirSayisi: 73),
  EsmaModel(sira: 43, arapca: 'الْكَرِيمُ', okunus: 'El-Kerîm', adEn: 'Al-Karim', anlamTr: 'Cömertliği, ikramı ve ihsanı sınırsız olan, istemeden de veren.', anlamEn: 'The Most Generous, the Bountiful.', zikirSayisi: 270),
  EsmaModel(sira: 44, arapca: 'الرَّقِيبُ', okunus: 'Er-Rakîb', adEn: 'Ar-Raqib', anlamTr: 'Bütün varlıkları her an gözeten, hiçbir şey kendisinden غائب olmayan.', anlamEn: 'The Ever-Watchful Observer.', zikirSayisi: 312),
  EsmaModel(sira: 45, arapca: 'الْمُجِيبُ', okunus: 'El-Mücîb', adEn: 'Al-Mujib', anlamTr: 'Kendisine el açıp dua edenlerin yakarışlarına icabet eden.', anlamEn: 'The Responsive who answers prayers and supplications.', zikirSayisi: 55),
  EsmaModel(sira: 46, arapca: 'الْوَاسِعُ', okunus: 'El-Vâsi’', adEn: 'Al-Wasi’', anlamTr: 'İlmi, rahmeti, kudreti ve mağfireti her şeyi kuşatacak kadar geniş olan.', anlamEn: 'The All-Encompassing in mercy and knowledge.', zikirSayisi: 137),
  EsmaModel(sira: 47, arapca: 'الْحَكِيمُ', okunus: 'El-Hakîm', adEn: 'Al-Hakim', anlamTr: 'Her emri, işi ve yaratması sonsuz hikmet ve yerindelik içeren.', anlamEn: 'The All-Wise in every decree and creation.', zikirSayisi: 78),
  EsmaModel(sira: 48, arapca: 'الْوَدُودُ', okunus: 'El-Vedûd', adEn: 'Al-Wadud', anlamTr: 'Salih kullarını çok seven ve gönüllerde en çok sevilmeye layık olan.', anlamEn: 'The Most Loving, the Affectionate.', zikirSayisi: 20),
  EsmaModel(sira: 49, arapca: 'الْمَجِيدُ', okunus: 'El-Mecîd', adEn: 'Al-Majid', anlamTr: 'Şanı pek yüce, şerefi büyük ve ikramı sonsuz olan.', anlamEn: 'The All-Glorious, Noble and Generous.', zikirSayisi: 57),
  EsmaModel(sira: 50, arapca: 'الْبَاعِثُ', okunus: 'El-Bâis', adEn: 'Al-Ba’ith', anlamTr: 'Peygamberler gönderen, ölüleri ve kalpleri yeniden dirilten.', anlamEn: 'The Resurrector and Awakener of hearts.', zikirSayisi: 573),
  EsmaModel(sira: 51, arapca: 'الشَّهِيدُ', okunus: 'Eş-Şehîd', adEn: 'Ash-Shahid', anlamTr: 'Her zaman ve her yerde hazır olup yapılan her şeye bizzat şahit olan.', anlamEn: 'The All-Witnessing to every action and thought.', zikirSayisi: 319),
  EsmaModel(sira: 52, arapca: 'الْحَقُّ', okunus: 'El-Hakk', adEn: 'Al-Haqq', anlamTr: 'Varlığı hiç değişmeden sabit ve gerçek olan, hakkı ortaya çıkaran.', anlamEn: 'The Ultimate Truth and Reality.', zikirSayisi: 108),
  EsmaModel(sira: 53, arapca: 'الْوَكِيلُ', okunus: 'El-Vekîl', adEn: 'Al-Wakil', anlamTr: 'Kendisine tevekkül edenlerin işlerini en güzel biçimde yoluna koyan.', anlamEn: 'The Trustee, the Disposer of Affairs.', zikirSayisi: 66),
  EsmaModel(sira: 54, arapca: 'الْقَوِيُّ', okunus: 'El-Kaviyy', adEn: 'Al-Qawiyy', anlamTr: 'Kudreti pek üstün, gücüne hiçbir şeyin galip gelemediği mutlak kuvvet sahibi.', anlamEn: 'The All-Strong, Possessor of inexhaustible power.', zikirSayisi: 116),
  EsmaModel(sira: 55, arapca: 'الْمَتِينُ', okunus: 'El-Metîn', adEn: 'Al-Matin', anlamTr: 'Kudretinde hiçbir sarsıntı ve yorgunluk olmayan, son derece sağlam.', anlamEn: 'The Firm, the Steadfast in power.', zikirSayisi: 500),
  EsmaModel(sira: 56, arapca: 'الْوَلِيُّ', okunus: 'El-Veliyy', adEn: 'Al-Waliyy', anlamTr: 'Müminlerin gerçek dostu, yardımcısı ve koruyucusu.', anlamEn: 'The Protecting Friend and Helper of believers.', zikirSayisi: 46),
  EsmaModel(sira: 57, arapca: 'الْحَمِيدُ', okunus: 'El-Hamîd', adEn: 'Al-Hamid', anlamTr: 'Her hâlükârda bütün övgü, senâ ve hamdlere layık olan.', anlamEn: 'The Praiseworthy in all circumstances.', zikirSayisi: 62),
  EsmaModel(sira: 58, arapca: 'الْمُحْصِي', okunus: 'El-Muhsî', adEn: 'Al-Muhsi', anlamTr: 'Varlıkların sayısını ve her birinin bütün hallerini tek tek bilen.', anlamEn: 'The All-Enumerating who accounts for everything.', zikirSayisi: 148),
  EsmaModel(sira: 59, arapca: 'الْمُبْدِئُ', okunus: 'El-Mübdi’', adEn: 'Al-Mubdi’', anlamTr: 'Mahlûkatı maddesiz ve örneksiz olarak ilk defa yaratan.', anlamEn: 'The Originator of all creation.', zikirSayisi: 56),
  EsmaModel(sira: 60, arapca: 'الْمُعِيدُ', okunus: 'El-Mu’îd', adEn: 'Al-Mu’id', anlamTr: 'Yaratılmışları ölümünden sonra ahirette yeniden dirilten.', anlamEn: 'The Restorer who brings creation back to life.', zikirSayisi: 124),
  EsmaModel(sira: 61, arapca: 'الْمُحْيِي', okunus: 'El-Muhyî', adEn: 'Al-Muhyi', anlamTr: 'Can bağışlayan, hayat veren, çorak toprakları ve kalpleri ihya eden.', anlamEn: 'The Giver of Life and spiritual revival.', zikirSayisi: 68),
  EsmaModel(sira: 62, arapca: 'الْمُمِيتُ', okunus: 'El-Mümît', adEn: 'Al-Mumit', anlamTr: 'Eceli geldiğinde canlıların hayatını sona erdiren, ölümü yaratan.', anlamEn: 'The Creator of Death according to His decree.', zikirSayisi: 490),
  EsmaModel(sira: 63, arapca: 'الْحَيُّ', okunus: 'El-Hayy', adEn: 'Al-Hayy', anlamTr: 'Ezelî ve ebedî diri olan, hayatın yegâne kaynağı.', anlamEn: 'The Ever-Living who never dies.', zikirSayisi: 18),
  EsmaModel(sira: 64, arapca: 'الْقَيُّومُ', okunus: 'El-Kayyûm', adEn: 'Al-Qayyum', anlamTr: 'Kendi zâtıyla kâim olan ve bütün kâinatı ayakta tutup yöneten.', anlamEn: 'The Self-Subsisting Sustainer of all existence.', zikirSayisi: 156),
  EsmaModel(sira: 65, arapca: 'الْوَاجِدُ', okunus: 'El-Vâcid', adEn: 'Al-Wajid', anlamTr: 'İstediği her şeyi istediği anda bulan, hiçbir şeye muhtaç olmayan.', anlamEn: 'The Finder, the Self-Sufficient.', zikirSayisi: 14),
  EsmaModel(sira: 66, arapca: 'الْمَاجِدُ', okunus: 'El-Mâcid', adEn: 'Al-Majid', anlamTr: 'Kadri ve şanı yüce, kerem ve ihsanı bol olan.', anlamEn: 'The Illustrious, the Magnanimous.', zikirSayisi: 48),
  EsmaModel(sira: 67, arapca: 'الْوَاحِدُ', okunus: 'El-Vâhid', adEn: 'Al-Wahid', anlamTr: 'Zâtında, sıfatlarında ve fiillerinde tek olan, ortağı bulunmayan.', anlamEn: 'The One, the Unique without partner.', zikirSayisi: 19),
  EsmaModel(sira: 68, arapca: 'الصَّمَدُ', okunus: 'Es-Samed', adEn: 'As-Samad', anlamTr: 'Her şeyin kendisine muhtaç olduğu, kendisi ise hiçbir şeye muhtaç olmayan.', anlamEn: 'The Eternal Refuge sought by all creation.', zikirSayisi: 134),
  EsmaModel(sira: 69, arapca: 'الْقَادِرُ', okunus: 'El-Kâdir', adEn: 'Al-Qadir', anlamTr: 'Dilediği her şeye tam gücü yeten, kudret sahibi.', anlamEn: 'The All-Capable, the Omnipotent.', zikirSayisi: 305),
  EsmaModel(sira: 70, arapca: 'الْمُقْتَدِرُ', okunus: 'El-Muktedir', adEn: 'Al-Muqtadir', anlamTr: 'Kudreti her şeye galip olan, kuvvet ve iktidar sahipleri üzerinde tasarruf eden.', anlamEn: 'The All-Powerful Determiner.', zikirSayisi: 744),
  EsmaModel(sira: 71, arapca: 'الْمُقَدِّمُ', okunus: 'El-Mukaddim', adEn: 'Al-Muqaddim', anlamTr: 'Dilediğini hikmetiyle öne geçiren ve yükselten.', anlamEn: 'The Expediter who brings forward whom He wills.', zikirSayisi: 184),
  EsmaModel(sira: 72, arapca: 'الْمُؤَخِّرُ', okunus: 'El-Muahhir', adEn: 'Al-Mu’akhkhir', anlamTr: 'Dilediğini hikmetiyle erteleyen veya geride bırakan.', anlamEn: 'The Delayer according to His wisdom.', zikirSayisi: 846),
  EsmaModel(sira: 73, arapca: 'الْأَوَّلُ', okunus: 'El-Evvel', adEn: 'Al-Awwal', anlamTr: 'Varlığının başlangıcı olmayan, her şeyden önce var olan ezelî.', anlamEn: 'The First, without beginning.', zikirSayisi: 37),
  EsmaModel(sira: 74, arapca: 'الْآخِرُ', okunus: 'El-Âhir', adEn: 'Al-Akhir', anlamTr: 'Her şey yok olduktan sonra da varlığı sonsuza dek devam edecek olan ebedî.', anlamEn: 'The Last, Eternal without end.', zikirSayisi: 801),
  EsmaModel(sira: 75, arapca: 'الظَّاهِرُ', okunus: 'Ez-Zâhir', adEn: 'Az-Zahir', anlamTr: 'Kâinattaki sayısız delil ve sanatıyla varlığı apaçık ortada olan.', anlamEn: 'The Manifest whose signs are evident everywhere.', zikirSayisi: 1106),
  EsmaModel(sira: 76, arapca: 'الْبَاطِنُ', okunus: 'El-Bâtın', adEn: 'Al-Batin', anlamTr: 'Zâtının mahiyeti akıl ve duyularla idrak edilemeyen, her şeyin iç yüzünü bilen.', anlamEn: 'The Hidden, closer to us than our jugular vein.', zikirSayisi: 62),
  EsmaModel(sira: 77, arapca: 'الْوَالِي', okunus: 'El-Vâlî', adEn: 'Al-Wali', anlamTr: 'Kâinattaki bütün işleri tek başına idare eden ve yöneten.', anlamEn: 'The Sole Governor of all creation.', zikirSayisi: 47),
  EsmaModel(sira: 78, arapca: 'الْمُتَعَالِي', okunus: 'El-Müteâlî', adEn: 'Al-Muta’ali', anlamTr: 'Aklın tasavvur edebileceği her şeyden çok daha yüce ve aşkın olan.', anlamEn: 'The Supremely Exalted.', zikirSayisi: 551),
  EsmaModel(sira: 79, arapca: 'الْبَرُّ', okunus: 'El-Berr', adEn: 'Al-Barr', anlamTr: 'Kullarına karşı iyiliği, şefkati ve lütfu pek bol olan.', anlamEn: 'The Source of All Goodness and Kindness.', zikirSayisi: 202),
  EsmaModel(sira: 80, arapca: 'التَّوَّابُ', okunus: 'Et-Tevvâb', adEn: 'At-Tawwab', anlamTr: 'Tövbeleri daima kabul eden ve kullarını tövbeye muvaffak kılan.', anlamEn: 'The Ever-Acceptor of Repentance.', zikirSayisi: 409),
  EsmaModel(sira: 81, arapca: 'الْمُنْتَقِمُ', okunus: 'El-Müntekım', adEn: 'Al-Muntaqim', anlamTr: 'Mazlumların hakkını alan, zalimleri adaletiyle cezalandıran.', anlamEn: 'The Avenger of the oppressed with perfect justice.', zikirSayisi: 630),
  EsmaModel(sira: 82, arapca: 'الْعَفُوُّ', okunus: 'El-Afüvv', adEn: 'Al-Afuww', anlamTr: 'Günahları kökünden silip affeden; “Allah’ım! Sen affedicisin, affı seversin” duasının muhatabı.', anlamEn: 'The Pardoner who erases sins completely.', zikirSayisi: 156),
  EsmaModel(sira: 83, arapca: 'الرَّؤُوفُ', okunus: 'Er-Raûf', adEn: 'Ar-Ra’uf', anlamTr: 'Çok şefkatli, kullarına karşı pek merhametli ve رأفت sahibi.', anlamEn: 'The Most Compassionate and Tender.', zikirSayisi: 287),
  EsmaModel(sira: 84, arapca: 'مَالِكُ الْمُلْكِ', okunus: 'Mâlikü’l-Mülk', adEn: 'Malik-ul-Mulk', anlamTr: 'Mülkün ebedî sahibi, mülkünde dilediği gibi tasarruf eden.', anlamEn: 'The Eternal Owner of All Sovereignty.', zikirSayisi: 212),
  EsmaModel(sira: 85, arapca: 'ذُو الْجَلَالِ وَالْإِكْرَامِ', okunus: 'Zü’l-Celâli ve’l-İkrâm', adEn: 'Dhul-Jalali wal-Ikram', anlamTr: 'Hem sonsuz büyüklük ve haşmet, hem de sonsuz kerem ve ikram sahibi.', anlamEn: 'The Lord of Majesty and Generosity.', zikirSayisi: 1100),
  EsmaModel(sira: 86, arapca: 'الْمُقْسِطُ', okunus: 'El-Muksit', adEn: 'Al-Muqsit', anlamTr: 'Bütün işlerini denk ve yerli yerinde yapan, mazlumun hakkını zalimden alan.', anlamEn: 'The Equitable, the Maintainer of Justice.', zikirSayisi: 209),
  EsmaModel(sira: 87, arapca: 'الْجَامِعُ', okunus: 'El-Câmi’', adEn: 'Al-Jami’', anlamTr: 'İstediğini istediği yerde toplayan, gönülleri birleştiren ve mahşerde insanları bir araya getiren.', anlamEn: 'The Gatherer of hearts and all humanity on the Day of Judgment.', zikirSayisi: 114),
  EsmaModel(sira: 88, arapca: 'الْغَنِيُّ', okunus: 'El-Ganiyy', adEn: 'Al-Ghaniyy', anlamTr: 'Gerçek zenginlik sahibi, hiçbir şeye ihtiyacı olmayan.', anlamEn: 'The Self-Sufficient, the All-Rich.', zikirSayisi: 1060),
  EsmaModel(sira: 89, arapca: 'الْمُغْنِي', okunus: 'El-Muğnî', adEn: 'Al-Mughni', anlamTr: 'Dilediği kulunu maddi ve manevi zenginliğe, gönül tokluğuna kavuşturan.', anlamEn: 'The Enricher who grants sufficiency and contentment.', zikirSayisi: 1100),
  EsmaModel(sira: 90, arapca: 'الْمَانِعُ', okunus: 'El-Mâni’', adEn: 'Al-Mani’', anlamTr: 'Dilediği şeyin meydana gelmesine engel olan, kullarını kötülüklerden koruyan.', anlamEn: 'The Preventer of harm, the Defender.', zikirSayisi: 161),
  EsmaModel(sira: 91, arapca: 'الضَّارُّ', okunus: 'Ed-Dârr', adEn: 'Ad-Darr', anlamTr: 'Hikmeti gereği imtihan için elem ve zarar verici şeyleri yaratan.', anlamEn: 'The Creator of adversity as a test and wisdom.', zikirSayisi: 1001),
  EsmaModel(sira: 92, arapca: 'النَّافِعُ', okunus: 'En-Nâfi’', adEn: 'An-Nafi’', anlamTr: 'Hayır, şifa ve menfaat verici şeyleri yaratan, kullarına fayda sağlayan.', anlamEn: 'The Creator of All Good, Healing, and Benefit.', zikirSayisi: 201),
  EsmaModel(sira: 93, arapca: 'النُّورُ', okunus: 'En-Nûr', adEn: 'An-Nur', anlamTr: 'Gökleri, yeri ve müminlerin kalplerini hidayet nuruyla aydınlatan.', anlamEn: 'The Divine Light that illuminates the heavens, earth, and hearts.', zikirSayisi: 256),
  EsmaModel(sira: 94, arapca: 'الْهَادِي', okunus: 'El-Hâdî', adEn: 'Al-Hadi', anlamTr: 'Kullarına doğru yolu gösteren, kalpleri iman ve hidayete ulaştıran.', anlamEn: 'The Guide to the Straight Path.', zikirSayisi: 20),
  EsmaModel(sira: 95, arapca: 'الْبَدِيعُ', okunus: 'El-Bedî’', adEn: 'Al-Badi’', anlamTr: 'Eşi ve benzeri olmayan harika âlemleri örneksiz olarak yaratan.', anlamEn: 'The Incomparable Originator of wonders.', zikirSayisi: 86),
  EsmaModel(sira: 96, arapca: 'الْبَاقِي', okunus: 'El-Bâkî', adEn: 'Al-Baqi', anlamTr: 'Varlığının sonu olmayan, ebediyen var kalacak olan.', anlamEn: 'The Everlasting who remains forever.', zikirSayisi: 113),
  EsmaModel(sira: 97, arapca: 'الْوَارِثُ', okunus: 'El-Vâris', adEn: 'Al-Warith', anlamTr: 'Bütün faniler göçüp gittikten sonra mülkün gerçek ve tek sahibi kalan.', anlamEn: 'The Supreme Inheritor of all things.', zikirSayisi: 707),
  EsmaModel(sira: 98, arapca: 'الرَّشِيدُ', okunus: 'Er-Reşîd', adEn: 'Ar-Rashid', anlamTr: 'Bütün işleri isabetli olan ve kullarını en doğru hedefe yönlendiren.', anlamEn: 'The Infallible Teacher and Guide to right conduct.', zikirSayisi: 514),
  EsmaModel(sira: 99, arapca: 'الصَّبُورُ', okunus: 'Es-Sabûr', adEn: 'As-Sabur', anlamTr: 'Çok sabırlı olan, asileri cezalandırmakta acele etmeyip tövbe kapısını açık tutan.', anlamEn: 'The Most Patient, who grants time for repentance.', zikirSayisi: 298),
];

// ============================================================================
// 2. DİJİTAL ZİKİRMATİK & TESBİHAT KALICI HAFIZA SERVİSİ
// ============================================================================

class ZikirSecenekModel {
  final String id;
  final String baslikTr;
  final String baslikEn;
  final String arapca;
  final String anlamTr;
  final int varsayilanHedef;
  final bool namazTesbihatiMi;

  const ZikirSecenekModel({
    required this.id,
    required this.baslikTr,
    required this.baslikEn,
    required this.arapca,
    required this.anlamTr,
    required this.varsayilanHedef,
    this.namazTesbihatiMi = false,
  });
}

const List<ZikirSecenekModel> kHazirZikirListesi = [
  ZikirSecenekModel(
    id: 'namaz_tesbihati',
    baslikTr: 'Namaz Tesbihatı (33+33+33 = 99)',
    baslikEn: 'Prayer Tasbihat (33+33+33 = 99)',
    arapca: 'سُبْحَانَ اللَّهِ • الْحَمْدُ لِلَّهِ • اللَّهُ أَكْبَرُ',
    anlamTr: '33 Sübhânallah, 33 Elhamdülillah, 33 Allâhü Ekber (Otomatik geçişli)',
    varsayilanHedef: 33,
    namazTesbihatiMi: true,
  ),
  ZikirSecenekModel(
    id: 'subhanallah',
    baslikTr: 'Sübhânallah (33)',
    baslikEn: 'SubhanAllah (33)',
    arapca: 'سُبْحَانَ اللَّهِ',
    anlamTr: 'Allah her türlü eksiklik ve noksanlıktan münezzehtir.',
    varsayilanHedef: 33,
  ),
  ZikirSecenekModel(
    id: 'elhamdulillah',
    baslikTr: 'Elhamdülillah (33)',
    baslikEn: 'Alhamdulillah (33)',
    arapca: 'الْحَمْدُ لِلَّهِ',
    anlamTr: 'Hamd ve şükür yalnızca âlemlerin Rabbi olan Allah’a mahsustur.',
    varsayilanHedef: 33,
  ),
  ZikirSecenekModel(
    id: 'allahu_ekber',
    baslikTr: 'Allâhü Ekber (33)',
    baslikEn: 'Allahu Akbar (33)',
    arapca: 'اللَّهُ أَكْبَرُ',
    anlamTr: 'Allah her şeyden yücedir, en büyüktür.',
    varsayilanHedef: 33,
  ),
  ZikirSecenekModel(
    id: 'kelime_i_tevhid',
    baslikTr: 'Lâ ilâhe illallah (100)',
    baslikEn: 'La ilaha illallah (100)',
    arapca: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
    anlamTr: 'Allah’tan başka hiçbir ilah yoktur (Zikirlerin en faziletlisi).',
    varsayilanHedef: 100,
  ),
  ZikirSecenekModel(
    id: 'estagfirullah',
    baslikTr: 'Estağfirullah (100)',
    baslikEn: 'Astaghfirullah (100)',
    arapca: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ',
    anlamTr: 'Azîm olan Allah’tan bağışlanma ve mağfiret dilerim.',
    varsayilanHedef: 100,
  ),
  ZikirSecenekModel(
    id: 'salavat',
    baslikTr: 'Salavat-ı Şerife (100)',
    baslikEn: 'Salawat upon the Prophet ﷺ (100)',
    arapca: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
    anlamTr: 'Allah’ım! Efendimiz Hz. Muhammed’e (s.a.v.) salât ve selâm eyle.',
    varsayilanHedef: 100,
  ),
  ZikirSecenekModel(
    id: 'subhanallahi_ve_bihamdihi',
    baslikTr: 'Sübhânallâhi ve bihamdihî (100)',
    baslikEn: 'SubhanAllahi wa bihamdihi (100)',
    arapca: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
    anlamTr: 'Dilde hafif, mizanda ağır, Rahmân’a sevimli iki kelime (Buhârî).',
    varsayilanHedef: 100,
  ),
  ZikirSecenekModel(
    id: 'serbest_zikir',
    baslikTr: 'Serbest Zikir (Özel Hedef)',
    baslikEn: 'Free Dhikr Counter',
    arapca: 'ذِكْرُ اللَّهِ اطْمِئْنَانُ الْقُلُوبِ',
    anlamTr: 'Kalpler ancak Allah’ı zikretmekle huzur bulur (Ra’d, 28).',
    varsayilanHedef: 99,
  ),
];

class ZikirmatikHafizaServisi {
  static const String _toplamKey = 'nur_huzur_zikirmatik_toplam_v1';

  static final ValueNotifier<int> toplamZikirNotifier =
      ValueNotifier<int>(_baslangicToplamYukle());

  static void hafifTitresim() {
    HapticFeedback.lightImpact();
    cihazTitretBridge(18);
  }

  static void belirginTitresim() {
    HapticFeedback.heavyImpact();
    cihazTitretBridge(120);
  }

  static int _baslangicToplamYukle() {
    try {
      final s = web.window.localStorage.getItem(_toplamKey);
      if (s != null) return int.tryParse(s) ?? 0;
    } catch (_) {}
    return 0;
  }

  static void toplamZikirArtir() {
    final yeni = toplamZikirNotifier.value + 1;
    toplamZikirNotifier.value = yeni;
    try {
      web.window.localStorage.setItem(_toplamKey, yeni.toString());
    } catch (_) {}
  }

  static void sesliOkut(String arapcaMetin) {
    try {
      web.window.speechSynthesis.cancel();
      final u = web.SpeechSynthesisUtterance(arapcaMetin);
      u.lang = 'ar-SA';
      u.rate = 0.85;
      web.window.speechSynthesis.speak(u);
    } catch (_) {}
  }
}

// ============================================================================
// 3. İNTERAKTİF DİJİTAL ZİKİRMATİK TAM EKRANI (TESBİHAT & ESMA ZİKRİ)
// ============================================================================

class ZikirmatikTamEkran extends StatefulWidget {
  final Color arkaPlan;
  final Color kartRengi;
  final Color vurguAltin;
  final Color yumusakAltin;
  final Color yaziRengi;
  final Color ikincilYazi;
  final String dil;
  final ZikirSecenekModel? baslangicZikri;

  const ZikirmatikTamEkran({
    super.key,
    required this.arkaPlan,
    required this.kartRengi,
    required this.vurguAltin,
    required this.yumusakAltin,
    required this.yaziRengi,
    required this.ikincilYazi,
    required this.dil,
    this.baslangicZikri,
  });

  @override
  State<ZikirmatikTamEkran> createState() => _ZikirmatikTamEkranState();
}

class _ZikirmatikTamEkranState extends State<ZikirmatikTamEkran>
    with SingleTickerProviderStateMixin {
  late List<ZikirSecenekModel> _secenekler;
  late ZikirSecenekModel _aktifZikir;
  int _sayac = 0;
  int _hedef = 33; // 0 = Sınırsız (∞)
  int _namazTesbihatAsamasi = 0; // 0: Sübhânallah, 1: Elhamdülillah, 2: Allâhü Ekber

  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  static const List<Map<String, String>> _namazAsamalari = [
    {
      'baslik': '1/3 • Sübhânallah (33)',
      'arapca': 'سُبْحَانَ اللَّهِ',
      'anlam': 'Allah her türlü eksiklikten münezzehtir (1. Devir: 33)',
    },
    {
      'baslik': '2/3 • Elhamdülillah (33)',
      'arapca': 'الْحَمْدُ لِلَّهِ',
      'anlam': 'Hamd âlemlerin Rabbi olan Allah’a mahsustur (2. Devir: 33)',
    },
    {
      'baslik': '3/3 • Allâhü Ekber (33)',
      'arapca': 'اللَّهُ أَكْبَرُ',
      'anlam': 'Allah en büyüktür (3. Devir: 33 — Toplam 99 Tesbihat)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _secenekler = List<ZikirSecenekModel>.from(kHazirZikirListesi);
    if (widget.baslangicZikri != null) {
      _secenekler.insert(0, widget.baslangicZikri!);
      _aktifZikir = widget.baslangicZikri!;
    } else {
      _aktifZikir = _secenekler.first;
    }
    _hedef = _aktifZikir.varsayilanHedef;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.94), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.03), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _zikirTikla() {
    HapticFeedback.lightImpact();
    ZikirmatikHafizaServisi.hafifTitresim();
    _animCtrl.forward(from: 0.0);
    ZikirmatikHafizaServisi.toplamZikirArtir();

    setState(() {
      _sayac++;

      if (_aktifZikir.namazTesbihatiMi) {
        if (_sayac >= 33) {
          HapticFeedback.heavyImpact();
          ZikirmatikHafizaServisi.belirginTitresim();
          if (_namazTesbihatAsamasi < 2) {
            _namazTesbihatAsamasi++;
            _sayac = 0;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: widget.kartRengi,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                content: Text(
                  '✨ 33 tamamlandı! Sıradaki: ${_namazAsamalari[_namazTesbihatAsamasi]['baslik']}',
                  style: TextStyle(color: widget.vurguAltin, fontWeight: FontWeight.bold),
                ),
              ),
            );
          } else {
            // 99 Namaz Tesbihatı Tamamlandı!
            _namazTesbihatAsamasi = 0;
            _sayac = 0;
            _tesbihatTamamlandiBildir(
              'Namaz Tesbihatı (99/99) Tamamlandı!',
              '33 Sübhânallah, 33 Elhamdülillah ve 33 Allâhü Ekber tesbihatınız tamamlandı. Allah kabul eylesin.',
            );
          }
        }
      } else if (_hedef > 0 && _sayac == _hedef) {
        HapticFeedback.heavyImpact();
        ZikirmatikHafizaServisi.belirginTitresim();
        _tesbihatTamamlandiBildir(
          'Zikir Hedefi ($_hedef) Tamamlandı!',
          '“${_aktifZikir.baslikTr}” zikriniz $_hedef adede ulaştı. Allah kabul eylesin.',
        );
      }
    });
  }

  void _tesbihatTamamlandiBildir(String baslik, String mesaj) {
    HapticFeedback.heavyImpact();
    ZikirmatikHafizaServisi.belirginTitresim();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.kartRengi,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: widget.vurguAltin, width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.verified_rounded, color: widget.vurguAltin, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                baslik,
                style: TextStyle(
                  fontFamily: 'Lora',
                  color: widget.vurguAltin,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                height: 1.65,
                color: widget.yumusakAltin,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              mesaj,
              textAlign: TextAlign.center,
              style: TextStyle(color: widget.yaziRengi, fontSize: 13.5, height: 1.45),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: widget.vurguAltin,
              foregroundColor: widget.arkaPlan,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Elhamdülillah • Devam Et', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dil = widget.dil;
    final namazModu = _aktifZikir.namazTesbihatiMi;
    final gosterilenArapca =
        namazModu ? _namazAsamalari[_namazTesbihatAsamasi]['arapca']! : _aktifZikir.arapca;
    final gosterilenAnlam =
        namazModu ? _namazAsamalari[_namazTesbihatAsamasi]['anlam']! : _aktifZikir.anlamTr;
    final gosterilenAltBaslik =
        namazModu ? _namazAsamalari[_namazTesbihatAsamasi]['baslik']! : _aktifZikir.baslikTr;

    final double ilerleme = _hedef > 0 ? (_sayac % (_hedef == 0 ? 1 : _hedef)) / _hedef : (_sayac % 33) / 33.0;
    final double tamIlerleme = (_hedef > 0 && _sayac >= _hedef) ? 1.0 : ilerleme;

    return Scaffold(
      backgroundColor: widget.arkaPlan,
      appBar: AppBar(
        backgroundColor: widget.arkaPlan,
        foregroundColor: widget.yumusakAltin,
        title: Text(
          dil == 'EN'
              ? 'Digital Tasbih & Dhikr Counter'
              : dil == 'AR'
                  ? 'المسبحة الإلكترونية والأذكار'
                  : 'Dijital Zikirmatik & Tesbihat',
          style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: 'Sesli Okut',
            onPressed: () => ZikirmatikHafizaServisi.sesliOkut(gosterilenArapca),
            icon: Icon(Icons.volume_up_rounded, color: widget.vurguAltin),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. ÜST HAZIR ZİKİR & TESBİHAT SEÇİCİ
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.kartRengi,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.45)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _aktifZikir.id,
                        isExpanded: true,
                        dropdownColor: widget.kartRengi,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: widget.vurguAltin),
                        items: _secenekler.map((z) {
                          return DropdownMenuItem<String>(
                            value: z.id,
                            child: Text(
                              dil == 'EN' ? z.baslikEn : z.baslikTr,
                              style: TextStyle(
                                color: widget.yaziRengi,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (secilenId) {
                          if (secilenId == null) return;
                          final bulunan = _secenekler.firstWhere((e) => e.id == secilenId);
                          setState(() {
                            _aktifZikir = bulunan;
                            _sayac = 0;
                            _namazTesbihatAsamasi = 0;
                            _hedef = bulunan.varsayilanHedef;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. AKTİF ZİKİR ARAPÇA METİN VE FAZİLET KARTI
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: widget.kartRengi,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.vurguAltin.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            gosterilenAltBaslik,
                            style: TextStyle(
                              color: widget.vurguAltin,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          gosterilenArapca,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 30,
                            height: 1.65,
                            color: widget.yumusakAltin,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gosterilenAnlam,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 13.5,
                            fontStyle: FontStyle.italic,
                            color: widget.ikincilYazi,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 3. ORTADA BÜYÜK İNTERAKTİF TESBİH / ZİKİRMATİK HALKASI
                  Center(
                    child: GestureDetector(
                      onTap: _zikirTikla,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: AnimatedBuilder(
                          animation: _animCtrl,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _TesbihTaneleriHalkaPainter(
                                sayac: _sayac,
                                hedef: _hedef > 0 ? _hedef : 33,
                                altinRenk: widget.vurguAltin,
                                parlama: _animCtrl.value,
                              ),
                              child: Container(
                                width: 245,
                                height: 245,
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 205,
                                      height: 205,
                                      child: CircularProgressIndicator(
                                        value: tamIlerleme,
                                        strokeWidth: 7,
                                        backgroundColor: widget.vurguAltin.withValues(alpha: 0.14),
                                        valueColor: AlwaysStoppedAnimation<Color>(widget.vurguAltin),
                                      ),
                                    ),
                                    Container(
                                      width: 184,
                                      height: 184,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            widget.vurguAltin.withValues(
                                              alpha: 0.18 + (_animCtrl.value * 0.15),
                                            ),
                                            widget.kartRengi,
                                          ],
                                        ),
                                        border: Border.all(
                                          color: widget.vurguAltin.withValues(alpha: 0.55),
                                          width: 1.6,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.vurguAltin.withValues(
                                              alpha: 0.18 + (_animCtrl.value * 0.2),
                                            ),
                                            blurRadius: 24,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$_sayac',
                                            style: TextStyle(
                                              fontSize: 52,
                                              fontWeight: FontWeight.w800,
                                              color: widget.yumusakAltin,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          Text(
                                            _hedef > 0 ? 'Hedef: $_hedef' : 'Hedef: Sınırsız (∞)',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: widget.vurguAltin,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.touch_app_rounded,
                                                size: 15,
                                                color: widget.ikincilYazi,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                dil == 'EN'
                                                    ? 'Tap to Count'
                                                    : dil == 'AR'
                                                        ? 'اضغط للتسبيح'
                                                        : 'Zikir İçin Dokunun',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: widget.ikincilYazi,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 4. HEDEF DEĞİŞTİR (33 / 99 / 100 / 1000 / SINIRSIZ) VE SIFIRLA BUTONLARI
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final h in [33, 99, 100, 1000, 0])
                        ChoiceChip(
                          label: Text(
                            h == 0 ? 'Sınırsız (∞)' : 'Hedef: $h',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _hedef == h ? widget.arkaPlan : widget.yaziRengi,
                            ),
                          ),
                          selected: _hedef == h,
                          selectedColor: widget.vurguAltin,
                          backgroundColor: widget.kartRengi,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _hedef = h),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 5. SIFIRLA VE TOPLAM ÇEKİLEN ZİKİR SAYISI KARTI
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.kartRengi,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: ZikirmatikHafizaServisi.toplamZikirNotifier,
                          builder: (context, toplam, _) {
                            return Row(
                              children: [
                                Icon(Icons.auto_awesome_rounded, color: widget.vurguAltin, size: 19),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dil == 'EN'
                                          ? 'Total Lifetime Dhikr'
                                          : dil == 'AR'
                                              ? 'إجمالي الأذكار'
                                              : 'Toplam Çekilen Zikir Sayısı',
                                      style: TextStyle(color: widget.ikincilYazi, fontSize: 11.5),
                                    ),
                                    Text(
                                      '$toplam Zikir',
                                      style: TextStyle(
                                        color: widget.vurguAltin,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.vurguAltin,
                            side: BorderSide(color: widget.vurguAltin.withValues(alpha: 0.5)),
                          ),
                          onPressed: () {
                            setState(() {
                              _sayac = 0;
                              _namazTesbihatAsamasi = 0;
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 17),
                          label: Text(
                            dil == 'EN' ? 'Reset' : dil == 'AR' ? 'تصفير' : 'Sayacı Sıfırla',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TesbihTaneleriHalkaPainter extends CustomPainter {
  final int sayac;
  final int hedef;
  final Color altinRenk;
  final double parlama;

  _TesbihTaneleriHalkaPainter({
    required this.sayac,
    required this.hedef,
    required this.altinRenk,
    required this.parlama,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const int taneSayisi = 33;
    final int aktifTane = sayac % taneSayisi;

    for (int i = 0; i < taneSayisi; i++) {
      final aci = (i * 2 * math.pi / taneSayisi) - (math.pi / 2);
      final pos = Offset(
        center.dx + radius * math.cos(aci),
        center.dy + radius * math.sin(aci),
      );
      final gecildi = i < aktifTane || (sayac > 0 && aktifTane == 0);
      final sonTaneMi = i == (aktifTane == 0 && sayac > 0 ? 32 : aktifTane - 1);

      final paint = Paint()
        ..color = gecildi
            ? altinRenk
            : altinRenk.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        pos,
        sonTaneMi ? (5.2 + parlama * 2.0) : (gecildi ? 4.2 : 3.2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TesbihTaneleriHalkaPainter oldDelegate) =>
      oldDelegate.sayac != sayac || oldDelegate.parlama != parlama;
}

// ============================================================================
// 4. 99 ESMAÜ'L HÜSNA LİSTE VE TAM EKRAN BİLEŞENİ (ARAMA + ZİKİR ÇEK + DİNLE + PAYLAŞ)
// ============================================================================

class EsmaulHusnaTamEkran extends StatelessWidget {
  final Color arkaPlan;
  final Color kartRengi;
  final Color vurguAltin;
  final Color yumusakAltin;
  final Color yaziRengi;
  final Color ikincilYazi;
  final String dil;

  const EsmaulHusnaTamEkran({
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: arkaPlan,
      appBar: AppBar(
        backgroundColor: arkaPlan,
        foregroundColor: yumusakAltin,
        title: Text(
          dil == 'EN'
              ? '99 Names of Allah (Asma-ul Husna)'
              : dil == 'AR'
                  ? 'أسماء الله الحسنى (٩٩)'
                  : '99 Esmaü’l Hüsna (Allah’ın Güzel İsimleri)',
          style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: EsmaulHusnaListeWidget(
            arkaPlan: arkaPlan,
            kartRengi: kartRengi,
            vurguAltin: vurguAltin,
            yumusakAltin: yumusakAltin,
            yaziRengi: yaziRengi,
            ikincilYazi: ikincilYazi,
            dil: dil,
          ),
        ),
      ),
    );
  }
}

class EsmaulHusnaListeWidget extends StatefulWidget {
  final Color arkaPlan;
  final Color kartRengi;
  final Color vurguAltin;
  final Color yumusakAltin;
  final Color yaziRengi;
  final Color ikincilYazi;
  final String dil;

  const EsmaulHusnaListeWidget({
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
  State<EsmaulHusnaListeWidget> createState() => _EsmaulHusnaListeWidgetState();
}

class _EsmaulHusnaListeWidgetState extends State<EsmaulHusnaListeWidget> {
  String _arama = '';

  void _esmaIleZikirAc(EsmaModel esma) {
    final ozelZikir = ZikirSecenekModel(
      id: 'esma_${esma.sira}',
      baslikTr: '${esma.sira}. ${esma.okunus} (${esma.zikirLafzi}) • Hedef: ${esma.zikirSayisi}',
      baslikEn: '${esma.sira}. ${esma.adEn} • Target: ${esma.zikirSayisi}',
      arapca: 'يَا ${esma.arapca}',
      anlamTr: esma.anlamTr,
      varsayilanHedef: esma.zikirSayisi,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZikirmatikTamEkran(
          arkaPlan: widget.arkaPlan,
          kartRengi: widget.kartRengi,
          vurguAltin: widget.vurguAltin,
          yumusakAltin: widget.yumusakAltin,
          yaziRengi: widget.yaziRengi,
          ikincilYazi: widget.ikincilYazi,
          dil: widget.dil,
          baslangicZikri: ozelZikir,
        ),
      ),
    );
  }

  void _esmaPaylas(EsmaModel esma) {
    final palet = kReelsArkaPlanPaletleri[esma.sira % kReelsArkaPlanPaletleri.length];
    final kart = DinamikReelsKart(
      id: 'esma_story_${esma.sira}',
      ayetMi: false,
      arapcaMetin: esma.arapca,
      konuTr: '99 Esmaü’l Hüsna • ${esma.sira}. İsm-i Şerif',
      konuEn: '99 Names of Allah • #${esma.sira}',
      mealTr: '${esma.okunus}: “${esma.anlamTr}”',
      mealEn: '${esma.adEn}: “${esma.anlamEn}”',
      kaynakKisaTr: 'Esmaü’l Hüsna (${esma.sira}/99) • Ebced / Zikir Adedi: ${esma.zikirSayisi}',
      kaynakKisaEn: 'Asma-ul Husna (${esma.sira}/99) • Dhikr Count: ${esma.zikirSayisi}',
      dogrulanmisTr: 'Doğrulanmış Kaynak: Kur’an-ı Kerim & Tirmizî, Daavât 82 (99 Esmaü’l Hüsna)',
      dogrulanmisEn: 'Verified Source: The Holy Qur’an & Tirmidhi, Da’awat 82 (99 Names of Allah)',
      tefsirTr: 'Önerilen Zikir: Günde ${esma.zikirSayisi} defa “${esma.zikirLafzi}”',
      tefsirEn: 'Recommended Dhikr: ${esma.zikirSayisi} times “Ya ${esma.adEn}”',
      arkaPlanRenkleri: palet,
      desenIndex: esma.sira % 8,
    );
    PaylasimStoryBottomSheet.goster(context, kart, widget.dil);
  }

  @override
  Widget build(BuildContext context) {
    final dil = widget.dil;
    final filtrelenmis = k99EsmaulHusna.where((e) {
      if (_arama.trim().isEmpty) return true;
      final q = _arama.toLowerCase();
      return e.sira.toString().contains(q) ||
          e.okunus.toLowerCase().contains(q) ||
          e.adEn.toLowerCase().contains(q) ||
          e.anlamTr.toLowerCase().contains(q) ||
          e.anlamEn.toLowerCase().contains(q) ||
          e.arapca.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _arama = v),
            style: TextStyle(color: widget.yaziRengi, fontSize: 14),
            decoration: InputDecoration(
              hintText: dil == 'EN'
                  ? 'Search among 99 Names of Allah (e.g. Ar-Rahman, Ash-Shafi)...'
                  : dil == 'AR'
                      ? 'ابحث في أسماء الله الحسنى (٩٩)...'
                      : '99 Esmaü’l Hüsna içinde ara (Örn: Er-Rahmân, Rezzâk, Vedûd)...',
              hintStyle: TextStyle(color: widget.ikincilYazi, fontSize: 12.5),
              prefixIcon: Icon(Icons.search_rounded, color: widget.vurguAltin),
              filled: true,
              fillColor: widget.kartRengi,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: filtrelenmis.length,
            itemBuilder: (context, idx) {
              final esma = filtrelenmis[idx];
              final anlam = dil == 'EN' ? esma.anlamEn : esma.anlamTr;
              final baslik = dil == 'EN' ? '${esma.okunus} (${esma.adEn})' : esma.okunus;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.kartRengi,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: widget.vurguAltin.withValues(alpha: 0.32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: widget.vurguAltin.withValues(alpha: 0.16),
                          child: Text(
                            '${esma.sira}',
                            style: TextStyle(
                              color: widget.vurguAltin,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                baslik,
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: widget.yaziRengi,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Zikir Adedi (Ebced): ${esma.zikirSayisi}',
                                style: TextStyle(
                                  color: widget.vurguAltin,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          esma.arapca,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 28,
                            color: widget.yumusakAltin,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      anlam,
                      style: TextStyle(
                        color: widget.yaziRengi.withValues(alpha: 0.92),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.vurguAltin,
                            foregroundColor: widget.arkaPlan,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _esmaIleZikirAc(esma),
                          icon: const Icon(Icons.touch_app_rounded, size: 16),
                          label: Text(
                            dil == 'EN'
                                ? 'Count Dhikr (${esma.zikirSayisi})'
                                : dil == 'AR'
                                    ? 'ابدأ التسبيح (${esma.zikirSayisi})'
                                    : 'Bu İsimle Zikir Çek (${esma.zikirSayisi})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: widget.vurguAltin,
                                side: BorderSide(color: widget.vurguAltin.withValues(alpha: 0.45)),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () =>
                                  ZikirmatikHafizaServisi.sesliOkut('يَا ${esma.arapca}'),
                              icon: const Icon(Icons.volume_up_rounded, size: 16),
                              label: Text(
                                dil == 'EN' ? 'Listen' : dil == 'AR' ? 'استمع' : 'Sesli Dinle',
                                style: const TextStyle(fontSize: 11.5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              tooltip: 'Paylaş (Story / WhatsApp)',
                              onPressed: () => _esmaPaylas(esma),
                              icon: Icon(Icons.ios_share_rounded, color: widget.vurguAltin, size: 19),
                            ),
                          ],
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
