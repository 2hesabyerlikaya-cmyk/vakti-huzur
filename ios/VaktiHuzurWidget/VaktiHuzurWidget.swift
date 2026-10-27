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
    let icerikBaslik: String
    let icerikArapca: String
    let icerikMeal: String
    let icerikKaynak: String
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
            icerikBaslik: prefs?.string(forKey: "widget_icerik_baslik") ?? "✨ Vakt-i Huzur • Günün Ayeti",
            icerikArapca: prefs?.string(forKey: "widget_icerik_arapca") ?? "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
            icerikMeal: prefs?.string(forKey: "widget_icerik_meal") ?? "“Biliniz ki, kalpler ancak Allah’ı anmakla huzur bulur.”",
            icerikKaynak: prefs?.string(forKey: "widget_icerik_kaynak") ?? "Ra’d Suresi, 28"
        )
    }
}

struct VaktiHuzurNamazWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("☪ Vakt-i Huzur • \(entry.konum)")
                    .font(.caption2.bold())
                Text("\(entry.siradakiVakit) (\(entry.kalanSure))")
                    .font(.caption.bold())
                Text("İm:\(entry.imsak) Öğ:\(entry.ogle) İk:\(entry.ikindi) Ak:\(entry.aksam)")
                    .font(.caption2)
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

struct VaktiHuzurAyetWidgetView: View {
    var entry: VaktiHuzurProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.icerikBaslik).font(.caption2.bold())
                Text(entry.icerikMeal).font(.caption2).lineLimit(2)
            }
        default:
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    Text(entry.icerikBaslik)
                        .font(.caption2.bold())
                        .foregroundColor(Color(red: 0.85, green: 0.71, blue: 0.31))
                    Spacer()
                    Text(entry.icerikKaynak)
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
                }
                Text(entry.icerikArapca)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.89, blue: 0.71))
                    .lineLimit(1)
                Text(entry.icerikMeal)
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

@main
struct VaktiHuzurWidgetBundle: WidgetBundle {
    var body: some Widget {
        VaktiHuzurNamazWidget()
        VaktiHuzurAyetHadisWidget()
    }
}

struct VaktiHuzurNamazWidget: Widget {
    let kind: String = "VaktiHuzurNamazWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaktiHuzurProvider()) { entry in
            VaktiHuzurNamazWidgetView(entry: entry)
        }
        .configurationDisplayName("Vakt-i Huzur: Namaz Vakitleri")
        .description("Sıradaki namaz vaktini, kalan süreyi ve 6 vakti ana ekran ve kilit ekranında gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

struct VaktiHuzurAyetHadisWidget: Widget {
    let kind: String = "VaktiHuzurAyetHadisWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VaktiHuzurProvider()) { entry in
            VaktiHuzurAyetWidgetView(entry: entry)
        }
        .configurationDisplayName("Vakt-i Huzur: Günün Ayeti & Hadisi")
        .description("Her gün seçkin bir Kur’an-ı Kerim ayeti veya Sahih Hadis-i Şerifi gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
