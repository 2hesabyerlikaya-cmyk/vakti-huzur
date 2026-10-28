import WidgetKit
import SwiftUI

private let appGroupId = "group.com.vaktihuzur.app"

struct VaktiHuzurEntry: TimelineEntry {
    let date: Date
    let konum: String
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
        let prefs = UserDefaults(suiteName: appGroupId)
        return VaktiHuzurEntry(
            date: Date(),
            konum: prefs?.string(forKey: "widget_konum") ?? "İstanbul",
            siradakiVakit: prefs?.string(forKey: "widget_siradaki_vakit") ?? "Sıradaki: Akşam",
            kalanSure: prefs?.string(forKey: "widget_kalan_sure") ?? "18:24",
            imsak: prefs?.string(forKey: "widget_imsak") ?? "05:48",
            gunes: prefs?.string(forKey: "widget_gunes") ?? "07:14",
            ogle: prefs?.string(forKey: "widget_ogle") ?? "12:56",
            ikindi: prefs?.string(forKey: "widget_ikindi") ?? "15:52",
            aksam: prefs?.string(forKey: "widget_aksam") ?? "18:24",
            yatsi: prefs?.string(forKey: "widget_yatsi") ?? "19:44",
            ayetBaslik: prefs?.string(forKey: "widget_ayet_baslik") ?? "✨ Vakt-i Huzur • Günün Ayeti",
            ayetArapca: prefs?.string(forKey: "widget_ayet_arapca") ?? "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
            ayetMeal: prefs?.string(forKey: "widget_ayet_meal") ?? "“Biliniz ki, kalpler ancak Allah’ı anmakla huzur bulur.”",
            ayetKaynak: prefs?.string(forKey: "widget_ayet_kaynak") ?? "Ra’d Suresi, 28",
            hadisBaslik: prefs?.string(forKey: "widget_hadis_baslik") ?? "☪ Vakt-i Huzur • Günün Hadisi",
            hadisArapca: prefs?.string(forKey: "widget_hadis_arapca") ?? "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ",
            hadisMeal: prefs?.string(forKey: "widget_hadis_meal") ?? "“Ameller niyetlere göredir.”",
            hadisKaynak: prefs?.string(forKey: "widget_hadis_kaynak") ?? "Sahih-i Buhârî, İman, 1",
            zikirArapca: prefs?.string(forKey: "widget_zikir_arapca") ?? "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
            zikirOkunus: prefs?.string(forKey: "widget_zikir_okunus") ?? "Sübhânallâhi ve bi-hamdihî",
            zikirAnlam: prefs?.string(forKey: "widget_zikir_anlam") ?? "Allah’ı hamd ile tesbih ederim.",
            zikirSayac: prefs?.string(forKey: "widget_zikir_sayac") ?? "33 / 100"
        )
    }
}

// 1. 6 VAKİT ÇİZELGESİ WİDGETI
struct VaktiHuzurNamazWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("☪ Vakt-i Huzur • \(entry.konum)").font(.caption2.bold())
                Text("\(entry.siradakiVakit) (\(entry.kalanSure))").font(.caption.bold())
                Text("İm:\(entry.imsak) Öğ:\(entry.ogle) İk:\(entry.ikindi) Ak:\(entry.aksam)").font(.caption2)
            }
        case .accessoryInline:
            Text("☪ \(entry.konum) • \(entry.siradakiVakit) \(entry.kalanSure)")
        default:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("☪ Vakt-i Huzur • \(entry.konum)")
                        .font(.caption.bold())
                        .foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
                    Spacer()
                    Text("\(entry.siradakiVakit) • \(entry.kalanSure)")
                        .font(.caption2.bold())
                        .foregroundColor(Color(red: 0.85, green: 0.71, blue: 0.31))
                }
                HStack {
                    vakitSutun("İmsak", entry.imsak)
                    Spacer()
                    vakitSutun("Güneş", entry.gunes)
                    Spacer()
                    vakitSutun("Öğle", entry.ogle)
                    Spacer()
                    vakitSutun("İkindi", entry.ikindi)
                    Spacer()
                    vakitSutun("Akşam", entry.aksam)
                    Spacer()
                    vakitSutun("Yatsı", entry.yatsi)
                }
            }
            .padding(12)
            .background(Color(red: 0.04, green: 0.13, blue: 0.10))
        }
    }

    private func vakitSutun(_ ad: String, _ saat: String) -> some View {
        VStack(spacing: 2) {
            Text(ad).font(.system(size: 9)).foregroundColor(.white.opacity(0.75))
            Text(saat).font(.system(size: 11, weight: .bold)).foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
        }
    }
}

// 2. GÜNÜN AYETİ WİDGETI
struct VaktiHuzurAyetWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.ayetBaslik).font(.caption2.bold())
                Text(entry.ayetMeal).font(.caption2).lineLimit(2)
            }
        default:
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    Text(entry.ayetBaslik)
                        .font(.caption2.bold())
                        .foregroundColor(Color(red: 0.85, green: 0.71, blue: 0.31))
                    Spacer()
                    Text(entry.ayetKaynak)
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
                }
                Text(entry.ayetArapca)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
                    .lineLimit(1)
                Text(entry.ayetMeal)
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(12)
            .background(Color(red: 0.04, green: 0.13, blue: 0.10))
        }
    }
}

// 3. GÜNÜN HADİSİ WİDGETI
struct VaktiHuzurHadisWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.hadisBaslik).font(.caption2.bold())
                Text(entry.hadisMeal).font(.caption2).lineLimit(2)
            }
        default:
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    Text(entry.hadisBaslik)
                        .font(.caption2.bold())
                        .foregroundColor(Color(red: 0.85, green: 0.71, blue: 0.31))
                    Spacer()
                    Text(entry.hadisKaynak)
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
                }
                Text(entry.hadisArapca)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
                    .lineLimit(1)
                Text(entry.hadisMeal)
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(12)
            .background(Color(red: 0.04, green: 0.13, blue: 0.10))
        }
    }
}

// 4. SIRADAKİ NAMAZ ODAKLI WİDGET
struct VaktiHuzurSiradakiWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(spacing: 4) {
            Text("☪ Vakt-i Huzur • \(entry.konum)")
                .font(.caption2.bold())
                .foregroundColor(Color(red: 0.85, green: 0.71, blue: 0.31))
            Text(entry.siradakiVakit)
                .font(.subheadline.bold())
                .foregroundColor(.white)
            Text(entry.kalanSure)
                .font(.title2.bold())
                .foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
            Text("Kalan Süre")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(12)
        .background(Color(red: 0.04, green: 0.13, blue: 0.10))
    }
}

// 5. GÜNLÜK ZİKİR WİDGETI
struct VaktiHuzurZikirWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(spacing: 3) {
            HStack {
                Text("📿 Günlük Zikir")
                    .font(.caption2.bold())
                    .foregroundColor(Color(red: 0.85, green: 0.71, blue: 0.31))
                Spacer()
                Text(entry.zikirSayac)
                    .font(.caption2.bold())
                    .foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
            }
            Text(entry.zikirArapca)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
                .lineLimit(1)
            Text(entry.zikirOkunus)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(red: 0.85, green: 0.71, blue: 0.31))
                .lineLimit(1)
            Text(entry.zikirAnlam)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
        }
        .padding(12)
        .background(Color(red: 0.04, green: 0.13, blue: 0.10))
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
        .configurationDisplayName("Vakt-i Huzur: 6 Vakit Çizelgesi")
        .description("Günün 6 namaz vaktini ana ekran ve kilit ekranında gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

struct VaktiHuzurAyetWidget: Widget {
    let kind: String = "VaktiHuzurAyetWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaktiHuzurProvider()) { entry in
            VaktiHuzurAyetWidgetView(entry: entry)
        }
        .configurationDisplayName("Vakt-i Huzur: Günün Ayeti")
        .description("Seçkin Kur’an ayetini Arapça ve mealiyle gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct VaktiHuzurHadisWidget: Widget {
    let kind: String = "VaktiHuzurHadisWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaktiHuzurProvider()) { entry in
            VaktiHuzurHadisWidgetView(entry: entry)
        }
        .configurationDisplayName("Vakt-i Huzur: Günün Hadisi")
        .description("Sahih hadis-i şerifi Arapça ve tercümesiyle gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct VaktiHuzurSiradakiWidget: Widget {
    let kind: String = "VaktiHuzurSiradakiWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaktiHuzurProvider()) { entry in
            VaktiHuzurSiradakiWidgetView(entry: entry)
        }
        .configurationDisplayName("Vakt-i Huzur: Sıradaki Namaz")
        .description("Sıradaki vakti ve kalan süreyi canlı gösterir.")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryInline])
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
    }
}
