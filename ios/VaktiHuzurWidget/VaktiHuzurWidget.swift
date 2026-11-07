import WidgetKit
import SwiftUI

private func istanbulVarsayilanVakitler() -> (imsak: String, gunes: String, ogle: String, ikindi: String, aksam: String, yatsi: String, siradaki: String, kalan: String) {
    let now = Date()
    let cal = Calendar.current
    let h = cal.component(.hour, from: now)
    let m = cal.component(.minute, from: now)
    let simdiDk = h * 60 + m
    // İstanbul güncel Diyanet vakitleri referansı
    let vakitler: [(ad: String, saat: String, dk: Int)] = [
        ("İmsak", "06:14", 6 * 60 + 14),
        ("Güneş", "07:40", 7 * 60 + 40),
        ("Öğle", "12:59", 12 * 60 + 59),
        ("İkindi", "15:39", 15 * 60 + 39),
        ("Akşam", "18:01", 18 * 60 + 1),
        ("Yatsı", "19:22", 19 * 60 + 22)
    ]
    var siradakiAd = "İmsak"
    var farkDk = (24 * 60 - simdiDk) + vakitler[0].dk
    for v in vakitler {
        if v.dk > simdiDk {
            siradakiAd = v.ad
            farkDk = v.dk - simdiDk
            break
        }
    }
    let ks = farkDk / 60
    let kd = farkDk % 60
    let kalanStr = String(format: "%02ds %02ddk", ks, kd)
    return ("06:14", "07:40", "12:59", "15:39", "18:01", "19:22", "Sıradaki: \(siradakiAd)", kalanStr)
}

// Zümrüt Yeşili & Altın Sarısı Tema Renkleri
private let zumrutKoyu = Color(red: 0.043, green: 0.133, blue: 0.098)   // #0B2219
private let zumrutKart = Color(red: 0.082, green: 0.227, blue: 0.169)   // #153A2B
private let vurguAltin = Color(red: 0.851, green: 0.714, blue: 0.314)   // #D9B650
private let yumusakAltin = Color(red: 0.949, green: 0.886, blue: 0.714) // #F2E2B6
private let naneBeyaz = Color(red: 0.718, green: 0.831, blue: 0.773)    // #B7D4C5

extension View {
    @ViewBuilder
    func vaktiHuzurWidgetArkaPlan() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(for: .widget) {
                LinearGradient(
                    colors: [zumrutKoyu, zumrutKart],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        } else {
            self.background(
                LinearGradient(
                    colors: [zumrutKoyu, zumrutKart],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
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

struct VaktiHuzurEntry: TimelineEntry {
    let date: Date
    let konum: String
    let hicriTarih: String
    let siradakiVakit: String
    let kalanSure: String
    let imsak: String
    let gunes: String
    let ogle: String
    let ikindi: String
    let aksam: String
    let yatsi: String
    let ayetBaslik: String
    let ayetArapca: String
    let ayetMeal: String
    let ayetKaynak: String
    let hadisBaslik: String
    let hadisArapca: String
    let hadisMeal: String
    let hadisKaynak: String
    let zikirArapca: String
    let zikirOkunus: String
    let zikirAnlam: String
    let zikirSayac: String
}

struct VaktiHuzurProvider: TimelineProvider {
    func placeholder(in context: Context) -> VaktiHuzurEntry {
        okuEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (VaktiHuzurEntry) -> Void) {
        completion(okuEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VaktiHuzurEntry>) -> Void) {
        let entry = okuEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func okuEntry() -> VaktiHuzurEntry {
        // Sideloadly (ücretsiz Apple ID) ve App Store uyumluluğu:
        // Standart UserDefaults.standard ve varsa App Group UserDefaults birlikte okunur.
        let std = UserDefaults.standard
        let grp = UserDefaults(suiteName: "group.com.vaktihuzur.app")
        let oto = istanbulVarsayilanVakitler()
        func str(_ key: String, _ varsayilan: String) -> String {
            if let v = std.string(forKey: "flutter.\(key)"), !v.isEmpty { return v }
            if let v = std.string(forKey: key), !v.isEmpty { return v }
            if let v = grp?.string(forKey: key), !v.isEmpty { return v }
            return varsayilan
        }
        return VaktiHuzurEntry(
            date: Date(),
            konum: str("widget_konum", "İstanbul"),
            hicriTarih: str("widget_hicri_tarih", "Diyanet Namaz Vakitleri"),
            siradakiVakit: str("widget_siradaki_vakit", oto.siradaki),
            kalanSure: str("widget_kalan_sure", oto.kalan),
            imsak: str("widget_imsak", oto.imsak),
            gunes: str("widget_gunes", oto.gunes),
            ogle: str("widget_ogle", oto.ogle),
            ikindi: str("widget_ikindi", oto.ikindi),
            aksam: str("widget_aksam", oto.aksam),
            yatsi: str("widget_yatsi", oto.yatsi),
            ayetBaslik: str("widget_ayet_baslik", "✨ Günün Ayeti"),
            ayetArapca: str("widget_ayet_arapca", "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ"),
            ayetMeal: str("widget_ayet_meal", "“Biliniz ki, kalpler ancak Allah’ı anmakla huzur bulur.”"),
            ayetKaynak: str("widget_ayet_kaynak", "Ra’d Suresi, 28"),
            hadisBaslik: str("widget_hadis_baslik", "☪ Günün Hadisi"),
            hadisArapca: str("widget_hadis_arapca", "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ"),
            hadisMeal: str("widget_hadis_meal", "“Ameller niyetlere göredir.”"),
            hadisKaynak: str("widget_hadis_kaynak", "Sahih-i Buhârî"),
            zikirArapca: str("widget_zikir_arapca", "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ"),
            zikirOkunus: str("widget_zikir_okunus", "Sübhânallâhi ve bi-hamdihî"),
            zikirAnlam: str("widget_zikir_anlam", "Allah’ı hamd ile tesbih ederim."),
            zikirSayac: str("widget_zikir_sayac", "33 / 100")
        )
    }
}

// ============================================================================
// 1. GÜNLÜK TÜM NAMAZ VAKİTLERİ + GERİ SAYIM WİDGETI (ANA EKRAN 2 BOYUT & KİLİT EKRANI)
// ============================================================================
struct VaktiHuzurNamazWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .accessoryRectangular:
                // Kilit Ekranı (Lock Screen): Sade, şık yazılı sıradaki vakit ve kalan süre
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text("☪ \(entry.konum)")
                            .font(.system(size: 11, weight: .semibold))
                            .lineLimit(1)
                    }
                    Text(entry.siradakiVakit)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Text("⏳ Kalan: \(entry.kalanSure)")
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vaktiHuzurKilitEkraniArkaPlan()

            case .accessoryInline:
                Text("☪ \(entry.siradakiVakit) • \(entry.kalanSure)")
                    .vaktiHuzurKilitEkraniArkaPlan()

            case .accessoryCircular:
                VStack(spacing: 1) {
                    Text("☪")
                        .font(.system(size: 11))
                    Text(entry.kalanSure)
                        .font(.system(size: 10, weight: .bold))
                        .minimumScaleFactor(0.7)
                }
                .vaktiHuzurKilitEkraniArkaPlan()

            case .systemSmall:
                kucukAnaEkranGorunumu
            default:
                ortaAnaEkranGorunumu
            }
        } else {
            switch family {
            case .systemSmall:
                kucukAnaEkranGorunumu
            default:
                ortaAnaEkranGorunumu
            }
        }
    }

    // Boyut 1 (Small): Sıradaki Vakit + Geri Sayım + Kompakt 6 Vakit Özeti
    private var kucukAnaEkranGorunumu: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("☪ \(entry.konum)")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(yumusakAltin)
                    .lineLimit(1)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.siradakiVakit)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor( vurguAltin)
                    .lineLimit(1)
                Text(entry.kalanSure)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(zumrutKoyu.opacity(0.65))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(vurguAltin.opacity(0.45), lineWidth: 1)
                    )
            )

            Spacer(minLength: 0)

            // 2 Satır x 3 Sütun 6 Vakit
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    kucukVakitHucre("İms", entry.imsak)
                    kucukVakitHucre("Gün", entry.gunes)
                    kucukVakitHucre("Öğl", entry.ogle)
                }
                HStack(spacing: 4) {
                    kucukVakitHucre("İkn", entry.ikindi)
                    kucukVakitHucre("Akş", entry.aksam)
                    kucukVakitHucre("Yat", entry.yatsi)
                }
            }
        }
        .padding(11)
        .vaktiHuzurWidgetArkaPlan()
    }

    // Boyut 2 (Medium): Zümrüt Yeşili & Altın Sarısı Günlük Tüm Namaz Vakitleri + Geri Sayım
    private var ortaAnaEkranGorunumu: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("☪ Vakt-i Huzur • \(entry.konum)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(yumusakAltin)
                        .lineLimit(1)
                    Text(entry.hicriTarih)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundColor(naneBeyaz)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text(entry.siradakiVakit)
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(vurguAltin)
                    Text("⏳ \(entry.kalanSure)")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(zumrutKoyu.opacity(0.75))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(vurguAltin.opacity(0.6), lineWidth: 1)
                        )
                )
            }

            Spacer(minLength: 0)

            HStack(spacing: 5) {
                vakitKutusu("İmsak", entry.imsak)
                vakitKutusu("Güneş", entry.gunes)
                vakitKutusu("Öğle", entry.ogle)
                vakitKutusu("İkindi", entry.ikindi)
                vakitKutusu("Akşam", entry.aksam)
                vakitKutusu("Yatsı", entry.yatsi)
            }
        }
        .padding(13)
        .vaktiHuzurWidgetArkaPlan()
    }

    private func kucukVakitHucre(_ ad: String, _ saat: String) -> some View {
        VStack(spacing: 1) {
            Text(ad)
                .font(.system(size: 8.5, weight: .medium))
                .foregroundColor(naneBeyaz)
            Text(saat)
                .font(.system(size: 9.5, weight: .bold))
                .foregroundColor(yumusakAltin)
        }
        .frame(maxWidth: .infinity)
    }

    private func vakitKutusu(_ ad: String, _ saat: String) -> some View {
        let aktifMi = entry.siradakiVakit.localizedCaseInsensitiveContains(ad)
        return VStack(spacing: 3) {
            Text(ad)
                .font(.system(size: 9.5, weight: aktifMi ? .bold : .medium))
                .foregroundColor(aktifMi ? vurguAltin : naneBeyaz)
            Text(saat)
                .font(.system(size: 11.5, weight: .bold))
                .foregroundColor(aktifMi ? .white : yumusakAltin)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(aktifMi ? vurguAltin.opacity(0.22) : zumrutKoyu.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(aktifMi ? vurguAltin : vurguAltin.opacity(0.22), lineWidth: aktifMi ? 1.3 : 0.7)
                )
        )
    }
}

// ============================================================================
// 2. GÜNÜN AYETİ / HADİSİ WİDGETI (2 FARKLI BOYUT: SMALL & MEDIUM/LARGE)
// ============================================================================
struct VaktiHuzurAyetWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 2) {
                    Text("✨ Günün Ayeti • \(entry.ayetKaynak)")
                        .font(.system(size: 10.5, weight: .bold))
                        .lineLimit(1)
                    Text(entry.ayetMeal)
                        .font(.system(size: 11))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vaktiHuzurKilitEkraniArkaPlan()
            case .systemSmall:
                kucukAyetGorunumu
            default:
                genisAyetHadisGorunumu
            }
        } else {
            switch family {
            case .systemSmall:
                kucukAyetGorunumu
            default:
                genisAyetHadisGorunumu
            }
        }
    }

    private var kucukAyetGorunumu: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("✨ Günün Ayeti")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(vurguAltin)
                Spacer()
            }
            Spacer(minLength: 0)
            Text(entry.ayetMeal)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(4)
            Spacer(minLength: 0)
            Text(entry.ayetKaynak)
                .font(.system(size: 9.5, weight: .bold))
                .foregroundColor(yumusakAltin)
                .lineLimit(1)
        }
        .padding(12)
        .vaktiHuzurWidgetArkaPlan()
    }

    private var genisAyetHadisGorunumu: some View {
        VStack(alignment: .center, spacing: 6) {
            HStack {
                Text(entry.ayetBaslik)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(vurguAltin)
                Spacer()
                Text(entry.ayetKaynak)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(yumusakAltin)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(zumrutKoyu.opacity(0.7))
                            .overlay(Capsule().stroke(vurguAltin.opacity(0.45), lineWidth: 0.8))
                    )
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
// 3. GÜNÜN HADİSİ WİDGETI (SMALL & MEDIUM)
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
// 4. KİLİT EKRANI & SIRADAKİ VAKİT GERİ SAYIM WİDGETI
// ============================================================================
struct VaktiHuzurSiradakiWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 3) {
                    Text("☪ Vakt-i Huzur • \(entry.konum)")
                        .font(.system(size: 10.5, weight: .semibold))
                        .lineLimit(1)
                    Text(entry.siradakiVakit)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                    Text("⏳ Kalan Süre: \(entry.kalanSure)")
                        .font(.system(size: 12, weight: .bold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vaktiHuzurKilitEkraniArkaPlan()

            case .accessoryInline:
                Text("☪ \(entry.siradakiVakit) • \(entry.kalanSure)")
                    .vaktiHuzurKilitEkraniArkaPlan()

            case .accessoryCircular:
                VStack(spacing: 1) {
                    Text("☪")
                        .font(.system(size: 11))
                    Text(entry.kalanSure)
                        .font(.system(size: 10, weight: .bold))
                        .minimumScaleFactor(0.7)
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
            Text("☪ \(entry.konum)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(vurguAltin)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(entry.siradakiVakit)
                .font(.system(size: 13.5, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            Text(entry.kalanSure)
                .font(.system(size: 24, weight: .heavy))
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
                Text("📿 Günlük Zikir")
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
        .configurationDisplayName("Vakt-i Huzur: Günlük Vakitler & Sayaç")
        .description("Zümrüt yeşili ve altın sarısı temada tüm namaz vakitlerini ve geri sayımı gösterir.")
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
        .configurationDisplayName("Vakt-i Huzur: Günün Ayeti")
        .description("2 farklı boyutta seçkin Kur’an ayetini Arapça ve mealiyle gösterir.")
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
        .configurationDisplayName("Vakt-i Huzur: Günün Hadisi")
        .description("2 farklı boyutta sahih hadis-i şerifi Arapça ve tercümesiyle gösterir.")
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
        .configurationDisplayName("Vakt-i Huzur: Kilit Ekranı & Sıradaki Vakit")
        .description("Kilit ekranında ve ana ekranda sıradaki vakti ve kalan süreyi gösterir.")
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
        .configurationDisplayName("Vakt-i Huzur: Günlük Zikir")
        .description("Günün zikrini ve tesbih sayacını gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .vaktiHuzurKenarBosluksuz()
    }
}
