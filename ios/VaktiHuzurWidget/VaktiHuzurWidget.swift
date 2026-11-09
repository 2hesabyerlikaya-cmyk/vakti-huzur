import WidgetKit
import SwiftUI

// ============================================================================
// VAKT-İ BERAAT — iOS 14+ ANA EKRAN & iOS 16+ KİLİT EKRANI WIDGET PAKETİ
// 5 AYRI WİDGET:
// 1. Günlük Namaz Vakitleri & Canlı Sayaç
// 2. Günün Ayeti (Her gece 00:00'da dayOfYear % listeUzunlugu ile otomatik yenilenir)
// 3. Günün Hadisi (Her gece 00:00'da dayOfYear % listeUzunlugu ile otomatik yenilenir)
// 4. Kilit Ekranı & Sıradaki Vakit Canlı Geri Sayım (Text(timerInterval:))
// 5. Günlük Zikir & Tesbih Sayacı
// ============================================================================

struct GunlukWidgetMetin {
    let arapca: String
    let tr: String
    let en: String
    let de: String
    let fr: String
    let kaynakTr: String
    let kaynakEn: String
    let kaynakDe: String
    let kaynakFr: String

    func meal(_ dil: String) -> String {
        switch dil.uppercased() {
        case "EN": return en
        case "DE": return de
        case "FR": return fr
        case "AR": return arapca
        default: return tr
        }
    }

    func kaynak(_ dil: String) -> String {
        switch dil.uppercased() {
        case "EN": return kaynakEn
        case "DE": return kaynakDe
        case "FR": return kaynakFr
        default: return kaynakTr
        }
    }
}

private let kGunlukAyetHavuzu: [GunlukWidgetMetin] = [
    GunlukWidgetMetin(
        arapca: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
        tr: "“Biliniz ki, kalpler ancak Allah’ı anmakla (zikirle) huzur bulur.”",
        en: "“Unquestionably, by the remembrance of Allah do hearts find rest.”",
        de: "„Wahrlich, im Gedenken Allahs finden die Herzen Ruhe.“",
        fr: "« N’est-ce point par l’évocation d’Allah que se tranquillisent les cœurs ? »",
        kaynakTr: "Ra’d Suresi, 28. Ayet",
        kaynakEn: "Surah Ar-Ra’d, 28",
        kaynakDe: "Sure Ar-Ra’d, Vers 28",
        kaynakFr: "Sourate Ar-Ra’d, 28"
    ),
    GunlukWidgetMetin(
        arapca: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا",
        tr: "“Şüphesiz güçlükle beraber bir kolaylık vardır. Gerçekten, güçlükle beraber bir kolaylık vardır.”",
        en: "“For indeed, with hardship comes ease. Indeed, with hardship comes ease.”",
        de: "„Wahrlich, mit der Erschwernis ist Erleichterung. Wahrlich, mit der Erschwernis ist Erleichterung.“",
        fr: "« Car vraiment, avec la difficulté il y a une facilité. Oui, avec la difficulté il y a une facilité. »",
        kaynakTr: "İnşirah Suresi, 5-6. Ayetler",
        kaynakEn: "Surah Ash-Sharh, 5-6",
        kaynakDe: "Sure Asch-Scharh, 5-6",
        kaynakFr: "Sourate Ach-Charh, 5-6"
    ),
    GunlukWidgetMetin(
        arapca: "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
        tr: "“Ey iman edenler! Sabır ve namaz ile Allah’tan yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.”",
        en: "“O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.”",
        de: "„O die ihr glaubt, sucht Hilfe in der Geduld und im Gebet! Gewiss, Allah ist mit den Standhaften.“",
        fr: "« Ô les croyants ! Cherchez secours dans l’endurance et la Salât. Car Allah est avec les endurants. »",
        kaynakTr: "Bakara Suresi, 153. Ayet",
        kaynakEn: "Surah Al-Baqarah, 153",
        kaynakDe: "Sure Al-Baqara, Vers 153",
        kaynakFr: "Sourate Al-Baqara, 153"
    ),
    GunlukWidgetMetin(
        arapca: "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا",
        tr: "“Allah hiçbir kimseye gücünün yettiğinden başkasını yüklemez.”",
        en: "“Allah does not charge a soul except within its capacity.”",
        de: "„Allah erlegt keiner Seele mehr auf, als sie zu leisten vermag.“",
        fr: "« Allah n’impose à aucune âme une charge supérieure à sa capacité. »",
        kaynakTr: "Bakara Suresi, 286. Ayet",
        kaynakEn: "Surah Al-Baqarah, 286",
        kaynakDe: "Sure Al-Baqara, Vers 286",
        kaynakFr: "Sourate Al-Baqara, 286"
    ),
    GunlukWidgetMetin(
        arapca: "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ",
        tr: "“Kullarım beni senden sorarlarsa, bilsinler ki gerçekten ben onlara çok yakınım. Bana dua edince dua edenin duasına icabet ederim.”",
        en: "“When My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant.”",
        de: "„Und wenn Meine Diener dich nach Mir fragen, so bin Ich nahe; Ich antworte dem Ruf des Bittenden, wenn er Mich anruft.“",
        fr: "« Et quand Mes serviteurs t’interrogent sur Moi, alors Je suis tout proche : Je réponds à l’appel de celui qui Me prie. »",
        kaynakTr: "Bakara Suresi, 186. Ayet",
        kaynakEn: "Surah Al-Baqarah, 186",
        kaynakDe: "Sure Al-Baqara, Vers 186",
        kaynakFr: "Sourate Al-Baqara, 186"
    ),
    GunlukWidgetMetin(
        arapca: "وَمَنْ يَتَّقِ اللَّهَ يَجْعَلْ لَهُ مَخْرَجًا ۝ وَيَرُزْقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ",
        tr: "“Kim Allah’tan korkup sakınırsa, Allah ona bir çıkış yolu ihsan eder ve onu ummadığı yerden rızıklandırır.”",
        en: "“Whoever fears Allah, He will make for him a way out and provide for him from where he does not expect.”",
        de: "„Und wer Allah fürchtet, dem schafft Er einen Ausweg und versorgt ihn, von wo er nicht damit rechnet.“",
        fr: "« Et quiconque craint Allah, Il lui donnera une issue favorable, et lui accordera Ses dons par des moyens insoupçonnés. »",
        kaynakTr: "Talâk Suresi, 2-3. Ayetler",
        kaynakEn: "Surah At-Talaq, 2-3",
        kaynakDe: "Sure At-Talaq, 2-3",
        kaynakFr: "Sourate At-Talaq, 2-3"
    ),
    GunlukWidgetMetin(
        arapca: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
        tr: "“Rabbimiz! Bize dünyada da iyilik ve güzellik ver, ahirette de iyilik ve güzellik ver; bizi ateş azabından koru.”",
        en: "“Our Lord! Grant us good in this world and good in the Hereafter, and protect us from the Fire.”",
        de: "„Unser Herr, gib uns im Diesseits Gutes und im Jenseits Gutes und bewahre uns vor der Strafe des Feuers!“",
        fr: "« Seigneur ! Accorde-nous belle part ici-bas, et belle part aussi dans l’au-delà ; et protège-nous du châtiment du Feu. »",
        kaynakTr: "Bakara Suresi, 201. Ayet",
        kaynakEn: "Surah Al-Baqarah, 201",
        kaynakDe: "Sure Al-Baqara, Vers 201",
        kaynakFr: "Sourate Al-Baqara, 201"
    )
]

private let kGunlukHadisHavuzu: [GunlukWidgetMetin] = [
    GunlukWidgetMetin(
        arapca: "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ",
        tr: "“Ameller niyetlere göredir; herkes için ancak niyet ettiği şey vardır.”",
        en: "“Actions are judged by intentions, and every person shall have what they intended.”",
        de: "„Die Taten sind entsprechend den Absichten, und jedem Menschen gebührt das, was er beabsichtigt hat.“",
        fr: "« Les actes ne valent que par les intentions, et chacun n’a pour lui que ce qu’il a eu réellement l’intention de faire. »",
        kaynakTr: "Sahih-i Buhârî, İman, 1",
        kaynakEn: "Sahih al-Bukhari, 1",
        kaynakDe: "Sahih al-Buchari, 1",
        kaynakFr: "Sahih al-Boukhari, 1"
    ),
    GunlukWidgetMetin(
        arapca: "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
        tr: "“Sizin en hayırlınız, Kur’an’ı öğrenen ve onu başkalarına öğretendir.”",
        en: "“The best among you are those who learn the Qur’an and teach it.”",
        de: "„Der Beste unter euch ist derjenige, der den Koran lernt und ihn lehrt.“",
        fr: "« Le meilleur d’entre vous est celui qui apprend le Coran et l’enseigne. »",
        kaynakTr: "Sahih-i Buhârî, Fedâilü’l-Kur’ân, 21",
        kaynakEn: "Sahih al-Bukhari, 5027",
        kaynakDe: "Sahih al-Buchari, 5027",
        kaynakFr: "Sahih al-Boukhari, 5027"
    ),
    GunlukWidgetMetin(
        arapca: "يَسِّرُوا وَلَا تُعَسِّرُوا وَبَشِّرُوا وَلَا تُنَفِّرُوا",
        tr: "“Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.”",
        en: "“Make things easy and do not make them difficult; give glad tidings and do not repel people.”",
        de: "„Erleichtert und erschwert nicht; verkündet frohe Botschaft und schreckt nicht ab.“",
        fr: "« Facilitez les choses et ne les rendez pas difficiles ; annoncez la bonne nouvelle et ne faites pas fuir. »",
        kaynakTr: "Sahih-i Buhârî, İlim, 11",
        kaynakEn: "Sahih al-Bukhari, 69",
        kaynakDe: "Sahih al-Buchari, 69",
        kaynakFr: "Sahih al-Boukhari, 69"
    ),
    GunlukWidgetMetin(
        arapca: "الطُّهُورُ شَطْرُ الْإِيمَانِ",
        tr: "“Temizlik imanın yarısıdır; Elhamdülillah mizanı doldurur.”",
        en: "“Cleanliness is half of faith, and Alhamdulillah fills the scale.”",
        de: "„Die Reinheit ist die Hälfte des Glaubens, und Alhamdulillah füllt die Waagschale.“",
        fr: "« La pureté est la moitié de la foi, et Alhamdoulillah remplit la balance. »",
        kaynakTr: "Sahih-i Müslim, Tahâret, 1",
        kaynakEn: "Sahih Muslim, 223",
        kaynakDe: "Sahih Muslim, 223",
        kaynakFr: "Sahih Mouslim, 223"
    ),
    GunlukWidgetMetin(
        arapca: "تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ",
        tr: "“Kardeşinin yüzüne tebessüm etmen senin için bir sadakadır.”",
        en: "“Your smiling in the face of your brother is charity for you.”",
        de: "„Dein Lächeln in das Gesicht deines Bruders ist eine Sadaqa (Almosen) für dich.“",
        fr: "« Ton sourire à ton frère est une aumône (Sadaqa) pour toi. »",
        kaynakTr: "Sünen-i Tirmizî, Birr, 36",
        kaynakEn: "Jami at-Tirmidhi, 1956",
        kaynakDe: "Dschami at-Tirmidhi, 1956",
        kaynakFr: "Jami at-Tirmidhi, 1956"
    ),
    GunlukWidgetMetin(
        arapca: "مَنْ لَا يَرْحَمْ لَا يُرْحَمْ",
        tr: "“Merhamet etmeyene merhamet olunmaz.”",
        en: "“Whoever does not show mercy will not be shown mercy.”",
        de: "„Wer keine Barmherzigkeit zeigt, dem wird keine Barmherzigkeit erwiesen.“",
        fr: "« Celui qui ne fait pas miséricorde, on ne lui fera pas miséricorde. »",
        kaynakTr: "Sahih-i Buhârî, Edeb, 18",
        kaynakEn: "Sahih al-Bukhari, 5997",
        kaynakDe: "Sahih al-Buchari, 5997",
        kaynakFr: "Sahih al-Boukhari, 5997"
    ),
    GunlukWidgetMetin(
        arapca: "الدُّعَاءُ هُوَ الْعِبَادَةُ",
        tr: "“Dua ibadetin ta kendisidir.”",
        en: "“Supplication (Dua) is the essence of worship.”",
        de: "„Das Bittgebet (Dua) ist der Kern des Gottesdienstes.“",
        fr: "« L’invocation (Doua) est l’essence même de l’adoration. »",
        kaynakTr: "Sünen-i Tirmizî, Daavât, 1",
        kaynakEn: "Jami at-Tirmidhi, 3372",
        kaynakDe: "Dschami at-Tirmidhi, 3372",
        kaynakFr: "Jami at-Tirmidhi, 3372"
    )
]

private func temizMetin(_ metin: String) -> String {
    let emojiler = ["✨", "☪️", "☪", "⏳", "📿", "🕌", "🔊"]
    var sonuc = metin
    for e in emojiler {
        sonuc = sonuc.replacingOccurrences(of: e, with: "")
    }
    return sonuc.trimmingCharacters(in: .whitespacesAndNewlines)
}

struct VaktiHuzurEntry: TimelineEntry {
    let date: Date
    let hedefTarih: Date
    let konum: String
    let hicriTarih: String
    let siradakiVakit: String
    let siradakiVakitKisa: String
    let kalanSure: String
    let imsak: String
    let gunes: String
    let ogle: String
    let ikindi: String
    let aksam: String
    let yatsi: String
    let etImsak: String
    let etGunes: String
    let etOgle: String
    let etIkindi: String
    let etAksam: String
    let etYatsi: String

    // Ayet Widget Verileri
    let ayetBaslik: String
    let ayetArapca: String
    let ayetMeal: String
    let ayetKaynak: String

    // Hadis Widget Verileri
    let hadisBaslik: String
    let hadisArapca: String
    let hadisMeal: String
    let hadisKaynak: String

    // Zikir Widget Verileri
    let zikirArapca: String
    let zikirOkunus: String
    let zikirAnlam: String
    let zikirSayac: String
}

struct VaktiHuzurProvider: TimelineProvider {
    let appGroupId = "group.com.berat.vaktiberaat"
    let legacyGroupId1 = "group.com.vaktiberaat.app"
    let legacyGroupId2 = "group.com.vaktihuzur.app"

    func placeholder(in context: Context) -> VaktiHuzurEntry {
        ornekEntry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (VaktiHuzurEntry) -> Void) {
        completion(kayitliVeridenEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VaktiHuzurEntry>) -> Void) {
        let simdi = Date()
        let ilkEntry = kayitliVeridenEntry(for: simdi)
        var entries: [VaktiHuzurEntry] = [ilkEntry]

        // Sıradaki vakit geçiş anında ve gece 00:00'da (günlük Ayet & Hadis değişimi için) otomatik yenile
        let takvim = Calendar.current
        let geceYarisi = takvim.startOfDay(for: simdi.addingTimeInterval(86400))

        if ilkEntry.hedefTarih > simdi && ilkEntry.hedefTarih < geceYarisi {
            let gecisTarihi = ilkEntry.hedefTarih.addingTimeInterval(1)
            entries.append(kayitliVeridenEntry(for: gecisTarihi))
        }
        entries.append(kayitliVeridenEntry(for: geceYarisi))

        let sonrakiYenileme = min(ilkEntry.hedefTarih.addingTimeInterval(1), geceYarisi)
        let timeline = Timeline(entries: entries, policy: .after(sonrakiYenileme))
        completion(timeline)
    }

    private func saatDakikaParcala(_ saatStr: String) -> (Int, Int)? {
        let temiz = saatStr.trimmingCharacters(in: .whitespacesAndNewlines)
        let parcalar = temiz.split(separator: ":")
        guard parcalar.count >= 2,
              let h = Int(parcalar[0].prefix(2)),
              let m = Int(parcalar[1].prefix(2)) else {
            return nil
        }
        return (max(0, min(23, h)), max(0, min(59, m)))
    }

    private func hesaplaSiradakiVakit(
        refDate: Date,
        dil: String,
        vakitler: [(ad: String, saat: String)]
    ) -> (baslik: String, kisaAd: String, hedefTarih: Date, kalanMetin: String) {
        let takvim = Calendar.current
        let onEk: String
        switch dil.uppercased() {
        case "EN": onEk = "Next:"
        case "DE": onEk = "Nächstes:"
        case "FR": onEk = "Suivante :"
        default: onEk = "Sıradaki:"
        }

        for v in vakitler {
            if let (h, m) = saatDakikaParcala(v.saat),
               let aday = takvim.date(bySettingHour: h, minute: m, second: 0, of: refDate),
               aday > refDate {
                let farkSn = max(60, Int(aday.timeIntervalSince(refDate)))
                let saatFark = farkSn / 3600
                let dkFark = (farkSn % 3600) / 60
                let kalanStr = String(format: "%02ds %02ddk", saatFark, dkFark)
                return ("\(onEk) \(v.ad)", v.ad, aday, kalanStr)
            }
        }

        // Tüm vakitler geçtiyse yarının İmsak vakti
        let ilk = vakitler.first ?? ("İmsak", "05:48")
        let yarin = takvim.date(byAdding: .day, value: 1, to: refDate) ?? refDate.addingTimeInterval(86400)
        let (ih, im) = saatDakikaParcala(ilk.saat) ?? (5, 48)
        let hedef = takvim.date(bySettingHour: ih, minute: im, second: 0, of: yarin)
            ?? refDate.addingTimeInterval(3600)
        let farkSn = max(60, Int(hedef.timeIntervalSince(refDate)))
        let saatFark = farkSn / 3600
        let dkFark = (farkSn % 3600) / 60
        let kalanStr = String(format: "%02ds %02ddk", saatFark, dkFark)
        return ("\(onEk) \(ilk.ad)", ilk.ad, hedef, kalanStr)
    }

    private func kayitliVeridenEntry(for entryDate: Date) -> VaktiHuzurEntry {
        let groupDefaults = UserDefaults(suiteName: appGroupId)
            ?? UserDefaults(suiteName: legacyGroupId1)
            ?? UserDefaults(suiteName: legacyGroupId2)
        let stdDefaults = UserDefaults.standard

        func oku(_ anahtar: String, varsayilan: String) -> String {
            if let v = groupDefaults?.string(forKey: anahtar), !v.isEmpty {
                return temizMetin(v)
            }
            if let v = stdDefaults.string(forKey: "flutter.\(anahtar)"), !v.isEmpty {
                return temizMetin(v)
            }
            if let v = stdDefaults.string(forKey: anahtar), !v.isEmpty {
                return temizMetin(v)
            }
            return temizMetin(varsayilan)
        }

        let dil = oku("widget_dil", varsayilan: "TR")
        let offset = Int(oku("widget_offset", varsayilan: "0")) ?? 0
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: entryDate) ?? 1

        let imsak = oku("widget_imsak", varsayilan: "05:48")
        let gunes = oku("widget_gunes", varsayilan: "07:14")
        let ogle = oku("widget_ogle", varsayilan: "12:56")
        let ikindi = oku("widget_ikindi", varsayilan: "15:52")
        let aksam = oku("widget_aksam", varsayilan: "18:24")
        let yatsi = oku("widget_yatsi", varsayilan: "19:44")

        let etImsak = oku("widget_etiket_imsak", varsayilan: "İmsak")
        let etGunes = oku("widget_etiket_gunes", varsayilan: "Güneş")
        let etOgle = oku("widget_etiket_ogle", varsayilan: "Öğle")
        let etIkindi = oku("widget_etiket_ikindi", varsayilan: "İkindi")
        let etAksam = oku("widget_etiket_aksam", varsayilan: "Akşam")
        let etYatsi = oku("widget_etiket_yatsi", varsayilan: "Yatsı")

        let vakitListesi: [(ad: String, saat: String)] = [
            (etImsak, imsak),
            (etGunes, gunes),
            (etOgle, ogle),
            (etIkindi, ikindi),
            (etAksam, aksam),
            (etYatsi, yatsi)
        ]

        let canliSiradaki = hesaplaSiradakiVakit(refDate: entryDate, dil: dil, vakitler: vakitListesi)

        // Yılın gününe göre (dayOfYear % listeUzunlugu) her gece 00:00'da otomatik değişen Ayet ve Hadis
        let ayetIdx = abs(dayOfYear + offset) % kGunlukAyetHavuzu.count
        let hadisIdx = abs(dayOfYear + offset) % kGunlukHadisHavuzu.count
        let gunlukAyet = kGunlukAyetHavuzu[ayetIdx]
        let gunlukHadis = kGunlukHadisHavuzu[hadisIdx]

        let varsayilanAyetBaslik: String
        let varsayilanHadisBaslik: String
        switch dil.uppercased() {
        case "EN":
            varsayilanAyetBaslik = "Vakt-i Beraat • Verse of the Day"
            varsayilanHadisBaslik = "Vakt-i Beraat • Hadith of the Day"
        case "DE":
            varsayilanAyetBaslik = "Vakt-i Beraat • Vers des Tages"
            varsayilanHadisBaslik = "Vakt-i Beraat • Hadith des Tages"
        case "FR":
            varsayilanAyetBaslik = "Vakt-i Beraat • Verset du Jour"
            varsayilanHadisBaslik = "Vakt-i Beraat • Hadith du Jour"
        default:
            varsayilanAyetBaslik = "Vakt-i Beraat • Günün Ayeti"
            varsayilanHadisBaslik = "Vakt-i Beraat • Günün Hadisi"
        }

        // Eğer bugün uygulama içinden senkronize edilmişse onu, gün değişmişse (00:00 sonrası) dayOfYear içeriğini göster
        let sonSenkronGun = Int(oku("widget_son_gun", varsayilan: "0")) ?? 0
        let ayniGunMu = (sonSenkronGun == dayOfYear)

        let ayetBaslik = ayniGunMu ? oku("widget_ayet_baslik", varsayilan: varsayilanAyetBaslik) : varsayilanAyetBaslik
        let ayetArapca = ayniGunMu ? oku("widget_ayet_arapca", varsayilan: gunlukAyet.arapca) : gunlukAyet.arapca
        let ayetMeal = ayniGunMu ? oku("widget_ayet_meal", varsayilan: gunlukAyet.meal(dil)) : gunlukAyet.meal(dil)
        let ayetKaynak = ayniGunMu ? oku("widget_ayet_kaynak", varsayilan: gunlukAyet.kaynak(dil)) : gunlukAyet.kaynak(dil)

        let hadisBaslik = ayniGunMu ? oku("widget_hadis_baslik", varsayilan: varsayilanHadisBaslik) : varsayilanHadisBaslik
        let hadisArapca = ayniGunMu ? oku("widget_hadis_arapca", varsayilan: gunlukHadis.arapca) : gunlukHadis.arapca
        let hadisMeal = ayniGunMu ? oku("widget_hadis_meal", varsayilan: gunlukHadis.meal(dil)) : gunlukHadis.meal(dil)
        let hadisKaynak = ayniGunMu ? oku("widget_hadis_kaynak", varsayilan: gunlukHadis.kaynak(dil)) : gunlukHadis.kaynak(dil)

        return VaktiHuzurEntry(
            date: entryDate,
            hedefTarih: canliSiradaki.hedefTarih,
            konum: oku("widget_konum", varsayilan: "İstanbul"),
            hicriTarih: oku("widget_hicri_tarih", varsayilan: "Diyanet Namaz Vakitleri"),
            siradakiVakit: canliSiradaki.baslik,
            siradakiVakitKisa: canliSiradaki.kisaAd,
            kalanSure: canliSiradaki.kalanMetin,
            imsak: imsak,
            gunes: gunes,
            ogle: ogle,
            ikindi: ikindi,
            aksam: aksam,
            yatsi: yatsi,
            etImsak: etImsak,
            etGunes: etGunes,
            etOgle: etOgle,
            etIkindi: etIkindi,
            etAksam: etAksam,
            etYatsi: etYatsi,
            ayetBaslik: ayetBaslik,
            ayetArapca: ayetArapca,
            ayetMeal: ayetMeal,
            ayetKaynak: ayetKaynak,
            hadisBaslik: hadisBaslik,
            hadisArapca: hadisArapca,
            hadisMeal: hadisMeal,
            hadisKaynak: hadisKaynak,
            zikirArapca: oku("widget_zikir_arapca", varsayilan: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ"),
            zikirOkunus: oku("widget_zikir_okunus", varsayilan: "Sübhânallâhi ve bi-hamdihî"),
            zikirAnlam: oku("widget_zikir_anlam", varsayilan: "“Allah’ı hamd ile noksan sıfatlardan tenzih ederim.”"),
            zikirSayac: oku("widget_zikir_sayac", varsayilan: "33 / 100")
        )
    }

    private func ornekEntry(for refDate: Date) -> VaktiHuzurEntry {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: refDate) ?? 1
        let ayet = kGunlukAyetHavuzu[dayOfYear % kGunlukAyetHavuzu.count]
        let hadis = kGunlukHadisHavuzu[dayOfYear % kGunlukHadisHavuzu.count]
        return VaktiHuzurEntry(
            date: refDate,
            hedefTarih: refDate.addingTimeInterval(5040),
            konum: "İstanbul",
            hicriTarih: "14 Cemâziyelevvel 1448",
            siradakiVakit: "Sıradaki: Akşam",
            siradakiVakitKisa: "Akşam",
            kalanSure: "01s 24dk",
            imsak: "05:48",
            gunes: "07:14",
            ogle: "12:56",
            ikindi: "15:52",
            aksam: "18:24",
            yatsi: "19:44",
            etImsak: "İmsak",
            etGunes: "Güneş",
            etOgle: "Öğle",
            etIkindi: "İkindi",
            etAksam: "Akşam",
            etYatsi: "Yatsı",
            ayetBaslik: "Vakt-i Beraat • Günün Ayeti",
            ayetArapca: ayet.arapca,
            ayetMeal: ayet.tr,
            ayetKaynak: ayet.kaynakTr,
            hadisBaslik: "Vakt-i Beraat • Günün Hadisi",
            hadisArapca: hadis.arapca,
            hadisMeal: hadis.tr,
            hadisKaynak: hadis.kaynakTr,
            zikirArapca: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
            zikirOkunus: "Sübhânallâhi ve bi-hamdihî",
            zikirAnlam: "“Allah’ı hamd ile noksan sıfatlardan tenzih ederim.”",
            zikirSayac: "33 / 100"
        )
    }
}

// MARK: - Ortak Zümrüt & Altın Tema Renkleri
private let zumrutKoyu = Color(red: 0.04, green: 0.13, blue: 0.09)
private let zumrutOrta = Color(red: 0.07, green: 0.21, blue: 0.15)
private let vurguAltin = Color(red: 0.85, green: 0.71, blue: 0.31)
private let yumusakAltin = Color(red: 0.95, green: 0.89, blue: 0.71)
private let naneBeyaz = Color(red: 0.72, green: 0.83, blue: 0.77)

// MARK: - Canlı Geri Sayım Yardımcı Görünümü (iOS 16+ timerInterval & iOS 14+ .timer)
@ViewBuilder
private func canliGeriSayimMetni(_ entry: VaktiHuzurEntry) -> some View {
    if #available(iOSApplicationExtension 16.0, *) {
        Text(timerInterval: entry.date...entry.hedefTarih, countsDown: true)
            .monospacedDigit()
    } else {
        Text(entry.hedefTarih, style: .timer)
            .monospacedDigit()
    }
}

// MARK: - iOS 17+ containerBackground Uyumluluk Eklentisi
extension View {
    @ViewBuilder
    func vaktiHuzurWidgetArkaPlan() -> some View {
        let grad = LinearGradient(
            gradient: Gradient(colors: [zumrutOrta, zumrutKoyu]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(for: .widget) {
                grad
            }
        } else {
            self.background(grad)
        }
    }

    @ViewBuilder
    func vaktiHuzurKilitEkraniArkaPlan() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(for: .widget) {
                Color.clear
            }
        } else {
            self
        }
    }
}

extension WidgetConfiguration {
    func vaktiHuzurKenarBosluksuz() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

// ============================================================================
// 1. GÜNLÜK NAMAZ VAKİTLERİ WİDGETI (ANA EKRAN + KİLİT EKRANI CANLI SAYAÇ)
// ============================================================================
struct VaktiHuzurNamazWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vakt-i Beraat • \(entry.konum)")
                        .font(.system(size: 11, weight: .bold))
                        .lineLimit(1)
                    Text(entry.siradakiVakit)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Text("Kalan:")
                            .font(.system(size: 11, weight: .medium))
                        Text(timerInterval: entry.date...entry.hedefTarih, countsDown: true)
                            .font(.system(size: 11.5, weight: .bold))
                            .monospacedDigit()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vaktiHuzurKilitEkraniArkaPlan()

            case .accessoryInline:
                Text("\(entry.siradakiVakit) • \(entry.kalanSure)")
                    .vaktiHuzurKilitEkraniArkaPlan()

            case .accessoryCircular:
                VStack(spacing: 1) {
                    Text(entry.siradakiVakitKisa)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                    Text(timerInterval: entry.date...entry.hedefTarih, countsDown: true)
                        .font(.system(size: 10, weight: .bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.65)
                        .multilineTextAlignment(.center)
                }
                .vaktiHuzurKilitEkraniArkaPlan()

            case .systemSmall:
                kucukNamazGorunumu

            default:
                ortaNamazGorunumu
            }
        } else {
            switch family {
            case .systemSmall:
                kucukNamazGorunumu
            default:
                ortaNamazGorunumu
            }
        }
    }

    private var kucukNamazGorunumu: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(entry.konum)
                .font(.system(size: 11.5, weight: .bold))
                .foregroundColor(vurguAltin)
                .lineLimit(1)

            Spacer(minLength: 0)

            Text(entry.siradakiVakit)
                .font(.system(size: 13.5, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)

            canliGeriSayimMetni(entry)
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(yumusakAltin)
                .lineLimit(1)

            Spacer(minLength: 0)

            Text(entry.hicriTarih)
                .font(.system(size: 9.5))
                .foregroundColor(naneBeyaz)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .vaktiHuzurWidgetArkaPlan()
    }

    private var ortaNamazGorunumu: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vakt-i Beraat • \(entry.konum)")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(yumusakAltin)
                        .lineLimit(1)
                    Text(entry.hicriTarih)
                        .font(.system(size: 10))
                        .foregroundColor(naneBeyaz)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(entry.siradakiVakit)
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(vurguAltin)
                        .lineLimit(1)
                    canliGeriSayimMetni(entry)
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(vurguAltin.opacity(0.18))
                .cornerRadius(8)
            }

            HStack(spacing: 4) {
                vakitKutusu(ad: entry.etImsak, saat: entry.imsak)
                vakitKutusu(ad: entry.etGunes, saat: entry.gunes)
                vakitKutusu(ad: entry.etOgle, saat: entry.ogle)
                vakitKutusu(ad: entry.etIkindi, saat: entry.ikindi)
                vakitKutusu(ad: entry.etAksam, saat: entry.aksam)
                vakitKutusu(ad: entry.etYatsi, saat: entry.yatsi)
            }
        }
        .padding(12)
        .vaktiHuzurWidgetArkaPlan()
    }

    private func vakitKutusu(ad: String, saat: String) -> some View {
        let aktifMi = entry.siradakiVakit.localizedCaseInsensitiveContains(ad)
        return VStack(spacing: 2) {
            Text(ad)
                .font(.system(size: 9.5, weight: aktifMi ? .bold : .regular))
                .foregroundColor(aktifMi ? vurguAltin : naneBeyaz)
                .lineLimit(1)
            Text(saat)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(aktifMi ? .white : yumusakAltin)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(aktifMi ? vurguAltin.opacity(0.22) : Color.clear)
        .cornerRadius(6)
    }
}

// ============================================================================
// 2. GÜNÜN AYETİ WİDGETI (HER GECE 00:00'DA OTOMATİK YENİLENİR)
// ============================================================================
struct VaktiHuzurAyetWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.ayetBaslik)
                        .font(.system(size: 10.5, weight: .bold))
                        .lineLimit(1)
                    Text(entry.ayetMeal)
                        .font(.system(size: 11))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vaktiHuzurKilitEkraniArkaPlan()
            default:
                ayetAnaGorunum
            }
        } else {
            ayetAnaGorunum
        }
    }

    private var ayetAnaGorunum: some View {
        VStack(alignment: .center, spacing: 6) {
            HStack {
                Text(entry.ayetBaslik)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(vurguAltin)
                    .lineLimit(1)
                Spacer()
                Text(entry.ayetKaynak)
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundColor(yumusakAltin)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Text(entry.ayetArapca)
                .font(.system(size: 14.5, weight: .bold))
                .foregroundColor(yumusakAltin)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            Text(entry.ayetMeal)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            Spacer(minLength: 0)
        }
        .padding(13)
        .vaktiHuzurWidgetArkaPlan()
    }
}

// ============================================================================
// 3. GÜNÜN HADİSİ WİDGETI (HER GECE 00:00'DA OTOMATİK YENİLENİR)
// ============================================================================
struct VaktiHuzurHadisWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.hadisBaslik)
                        .font(.system(size: 10.5, weight: .bold))
                        .lineLimit(1)
                    Text(entry.hadisMeal)
                        .font(.system(size: 11))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vaktiHuzurKilitEkraniArkaPlan()
            default:
                hadisAnaGorunum
            }
        } else {
            hadisAnaGorunum
        }
    }

    private var hadisAnaGorunum: some View {
        VStack(alignment: .center, spacing: 6) {
            HStack {
                Text(entry.hadisBaslik)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(vurguAltin)
                    .lineLimit(1)
                Spacer()
                Text(entry.hadisKaynak)
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundColor(yumusakAltin)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Text(entry.hadisArapca)
                .font(.system(size: 13.5, weight: .bold))
                .foregroundColor(yumusakAltin)
                .lineLimit(1)
            Text(entry.hadisMeal)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            Spacer(minLength: 0)
        }
        .padding(13)
        .vaktiHuzurWidgetArkaPlan()
    }
}

// ============================================================================
// 4. KİLİT EKRANI & SIRADAKİ VAKİT CANLI GERİ SAYIM WİDGETI
// ============================================================================
struct VaktiHuzurSiradakiWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 3) {
                    Text("Vakt-i Beraat • \(entry.konum)")
                        .font(.system(size: 10.5, weight: .semibold))
                        .lineLimit(1)
                    Text(entry.siradakiVakit)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Text("Kalan:")
                            .font(.system(size: 11.5, weight: .semibold))
                        Text(timerInterval: entry.date...entry.hedefTarih, countsDown: true)
                            .font(.system(size: 12, weight: .bold))
                            .monospacedDigit()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vaktiHuzurKilitEkraniArkaPlan()

            case .accessoryInline:
                Text("\(entry.siradakiVakit) • \(entry.kalanSure)")
                    .vaktiHuzurKilitEkraniArkaPlan()

            case .accessoryCircular:
                VStack(spacing: 1) {
                    Text(entry.siradakiVakitKisa)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                    Text(timerInterval: entry.date...entry.hedefTarih, countsDown: true)
                        .font(.system(size: 10, weight: .bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.65)
                        .multilineTextAlignment(.center)
                }
                .vaktiHuzurKilitEkraniArkaPlan()

            default:
                siradakiAnaEkranGorunumu
            }
        } else {
            siradakiAnaEkranGorunumu
        }
    }

    private var siradakiAnaEkranGorunumu: some View {
        VStack(spacing: 6) {
            Text(entry.konum)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(vurguAltin)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(entry.siradakiVakit)
                .font(.system(size: 13.5, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            canliGeriSayimMetni(entry)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(yumusakAltin)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text("Vaktine Kalan Süre • Diyanet")
                .font(.system(size: 9.5, weight: .medium))
                .foregroundColor(naneBeyaz)
        }
        .padding(12)
        .vaktiHuzurWidgetArkaPlan()
    }
}

// ============================================================================
// 5. GÜNLÜK ZİKİR WİDGETI
// ============================================================================
struct VaktiHuzurZikirWidgetView: View {
    var entry: VaktiHuzurProvider.Entry

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Günlük Zikir")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(vurguAltin)
                Spacer()
                Text(entry.zikirSayac)
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(yumusakAltin)
            }
            Spacer(minLength: 0)
            Text(entry.zikirArapca)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(yumusakAltin)
                .lineLimit(1)
            Text(entry.zikirOkunus)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(vurguAltin)
                .lineLimit(1)
            Text(entry.zikirAnlam)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Spacer(minLength: 0)
        }
        .padding(12)
        .vaktiHuzurWidgetArkaPlan()
    }
}

@main
struct VaktiHuzurWidgetBundle: WidgetBundle {
    var body: some Widget {
        VaktiHuzurNamazWidget()
        VaktiHuzurAyetWidget()
        VaktiHuzurHadisWidget()
        VaktiHuzurSiradakiWidget()
        VaktiHuzurZikirWidget()
    }
}

struct VaktiHuzurNamazWidget: Widget {
    let kind: String = "VaktiHuzurNamazWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaktiHuzurProvider()) { entry in
            VaktiHuzurNamazWidgetView(entry: entry)
        }
        .configurationDisplayName("Vakt-i Beraat: Günlük Vakitler & Sayaç")
        .description("Zümrüt yeşili ve altın sarısı temada tüm namaz vakitlerini ve canlı geri sayımı gösterir.")
        .supportedFamilies(desteklenenAilelerNamaz())
        .vaktiHuzurKenarBosluksuz()
    }

    private func desteklenenAilelerNamaz() -> [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline, .accessoryCircular]
        } else {
            return [.systemSmall, .systemMedium]
        }
    }
}

struct VaktiHuzurAyetWidget: Widget {
    let kind: String = "VaktiHuzurAyetWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaktiHuzurProvider()) { entry in
            VaktiHuzurAyetWidgetView(entry: entry)
        }
        .configurationDisplayName("Vakt-i Beraat: Günün Ayeti")
        .description("Her gece 00:00'da otomatik değişen seçkin Kur’an ayetini Arapça ve mealiyle gösterir.")
        .supportedFamilies(desteklenenAilelerAyet())
        .vaktiHuzurKenarBosluksuz()
    }

    private func desteklenenAilelerAyet() -> [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .accessoryRectangular]
        } else {
            return [.systemSmall, .systemMedium]
        }
    }
}

struct VaktiHuzurHadisWidget: Widget {
    let kind: String = "VaktiHuzurHadisWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaktiHuzurProvider()) { entry in
            VaktiHuzurHadisWidgetView(entry: entry)
        }
        .configurationDisplayName("Vakt-i Beraat: Günün Hadisi")
        .description("Her gece 00:00'da otomatik değişen sahih hadis-i şerifi Arapça ve tercümesiyle gösterir.")
        .supportedFamilies(desteklenenAilelerHadis())
        .vaktiHuzurKenarBosluksuz()
    }

    private func desteklenenAilelerHadis() -> [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .accessoryRectangular]
        } else {
            return [.systemSmall, .systemMedium]
        }
    }
}

struct VaktiHuzurSiradakiWidget: Widget {
    let kind: String = "VaktiHuzurSiradakiWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaktiHuzurProvider()) { entry in
            VaktiHuzurSiradakiWidgetView(entry: entry)
        }
        .configurationDisplayName("Vakt-i Beraat: Kilit Ekranı & Sıradaki Vakit")
        .description("Kilit ekranında ve ana ekranda sıradaki vakti ve canlı geri sayımı gösterir.")
        .supportedFamilies(desteklenenAilelerSiradaki())
        .vaktiHuzurKenarBosluksuz()
    }

    private func desteklenenAilelerSiradaki() -> [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .accessoryRectangular, .accessoryInline, .accessoryCircular]
        } else {
            return [.systemSmall]
        }
    }
}

struct VaktiHuzurZikirWidget: Widget {
    let kind: String = "VaktiHuzurZikirWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaktiHuzurProvider()) { entry in
            VaktiHuzurZikirWidgetView(entry: entry)
        }
        .configurationDisplayName("Vakt-i Beraat: Günlük Zikir")
        .description("Günün zikrini ve tesbih sayacını gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .vaktiHuzurKenarBosluksuz()
    }
}
