package com.berat.vaktiberaat

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import java.util.Calendar
import kotlin.math.abs

data class GunlukMetin(
    val arapca: String,
    val tr: String,
    val en: String,
    val de: String,
    val fr: String,
    val kaynakTr: String,
    val kaynakEn: String,
    val kaynakDe: String,
    val kaynakFr: String
) {
    fun meal(dil: String): String = when (dil.uppercase()) {
        "EN" -> en
        "DE" -> de
        "FR" -> fr
        "AR" -> arapca
        else -> tr
    }

    fun kaynak(dil: String): String = when (dil.uppercase()) {
        "EN" -> kaynakEn
        "DE" -> kaynakDe
        "FR" -> kaynakFr
        else -> kaynakTr
    }
}

data class SiradakiVakitBilgisi(
    val baslik: String,
    val kalanMs: Long,
    val hedefEpochMs: Long
)

object VaktiBeraatWidgetHelper {
    private val emojiler = listOf("✨", "☪️", "☪", "⏳", "📿", "🕌", "🔊")

    val ayetHavuzu = listOf(
        GunlukMetin(
            arapca = "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
            tr = "“Biliniz ki, kalpler ancak Allah’ı anmakla (zikirle) huzur bulur.”",
            en = "“Unquestionably, by the remembrance of Allah do hearts find rest.”",
            de = "„Wahrlich, im Gedenken Allahs finden die Herzen Ruhe.“",
            fr = "« N’est-ce point par l’évocation d’Allah que se tranquillisent les cœurs ? »",
            kaynakTr = "Ra’d Suresi, 28. Ayet",
            kaynakEn = "Surah Ar-Ra’d, 28",
            kaynakDe = "Sure Ar-Ra’d, Vers 28",
            kaynakFr = "Sourate Ar-Ra’d, 28"
        ),
        GunlukMetin(
            arapca = "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا",
            tr = "“Şüphesiz güçlükle beraber bir kolaylık vardır. Gerçekten, güçlükle beraber bir kolaylık vardır.”",
            en = "“For indeed, with hardship comes ease. Indeed, with hardship comes ease.”",
            de = "„Wahrlich, mit der Erschwernis ist Erleichterung. Wahrlich, mit der Erschwernis ist Erleichterung.“",
            fr = "« Car vraiment, avec la difficulté il y a une facilité. Oui, avec la difficulté il y a une facilité. »",
            kaynakTr = "İnşirah Suresi, 5-6. Ayetler",
            kaynakEn = "Surah Ash-Sharh, 5-6",
            kaynakDe = "Sure Asch-Scharh, 5-6",
            kaynakFr = "Sourate Ach-Charh, 5-6"
        ),
        GunlukMetin(
            arapca = "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
            tr = "“Ey iman edenler! Sabır ve namaz ile Allah’tan yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.”",
            en = "“O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.”",
            de = "„O die ihr glaubt, sucht Hilfe in der Geduld und im Gebet! Gewiss, Allah ist mit den Standhaften.“",
            fr = "« Ô les croyants ! Cherchez secours dans l’endurance et la Salât. Car Allah est avec les endurants. »",
            kaynakTr = "Bakara Suresi, 153. Ayet",
            kaynakEn = "Surah Al-Baqarah, 153",
            kaynakDe = "Sure Al-Baqara, Vers 153",
            kaynakFr = "Sourate Al-Baqara, 153"
        ),
        GunlukMetin(
            arapca = "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا",
            tr = "“Allah hiçbir kimseye gücünün yettiğinden başkasını yüklemez.”",
            en = "“Allah does not charge a soul except within its capacity.”",
            de = "„Allah erlegt keiner Seele mehr auf, als sie zu leisten vermag.“",
            fr = "« Allah n’impose à aucune âme une charge supérieure à sa capacité. »",
            kaynakTr = "Bakara Suresi, 286. Ayet",
            kaynakEn = "Surah Al-Baqarah, 286",
            kaynakDe = "Sure Al-Baqara, Vers 286",
            kaynakFr = "Sourate Al-Baqara, 286"
        ),
        GunlukMetin(
            arapca = "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ",
            tr = "“Kullarım beni senden sorarlarsa, bilsinler ki gerçekten ben onlara çok yakınım. Bana dua edince dua edenin duasına icabet ederim.”",
            en = "“When My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant.”",
            de = "„Und wenn Meine Diener dich nach Mir fragen, so bin Ich nahe; Ich antworte dem Ruf des Bittenden, wenn er Mich anruft.“",
            fr = "« Et quand Mes serviteurs t’interrogent sur Moi, alors Je suis tout proche : Je réponds à l’appel de celui qui Me prie. »",
            kaynakTr = "Bakara Suresi, 186. Ayet",
            kaynakEn = "Surah Al-Baqarah, 186",
            kaynakDe = "Sure Al-Baqara, Vers 186",
            kaynakFr = "Sourate Al-Baqara, 186"
        ),
        GunlukMetin(
            arapca = "وَمَنْ يَتَّقِ اللَّهَ يَجْعَلْ لَهُ مَخْرَجًا ۝ وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ",
            tr = "“Kim Allah’tan korkup sakınırsa, Allah ona bir çıkış yolu ihsan eder ve onu ummadığı yerden rızıklandırır.”",
            en = "“Whoever fears Allah, He will make for him a way out and provide for him from where he does not expect.”",
            de = "„Und wer Allah fürchtet, dem schafft Er einen Ausweg und versorgt ihn, von wo er nicht damit rechnet.“",
            fr = "« Et quiconque craint Allah, Il lui donnera une issue favorable, et lui accordera Ses dons par des moyens insoupçonnés. »",
            kaynakTr = "Talâk Suresi, 2-3. Ayetler",
            kaynakEn = "Surah At-Talaq, 2-3",
            kaynakDe = "Sure At-Talaq, 2-3",
            kaynakFr = "Sourate At-Talaq, 2-3"
        ),
        GunlukMetin(
            arapca = "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
            tr = "“Rabbimiz! Bize dünyada da iyilik ve güzellik ver, ahirette de iyilik ve güzellik ver; bizi ateş azabından koru.”",
            en = "“Our Lord! Grant us good in this world and good in the Hereafter, and protect us from the Fire.”",
            de = "„Unser Herr, gib uns im Diesseits Gutes und im Jenseits Gutes und bewahre uns vor der Strafe des Feuers!“",
            fr = "« Seigneur ! Accorde-nous belle part ici-bas, et belle part aussi dans l’au-delà ; et protège-nous du châtiment du Feu. »",
            kaynakTr = "Bakara Suresi, 201. Ayet",
            kaynakEn = "Surah Al-Baqarah, 201",
            kaynakDe = "Sure Al-Baqara, Vers 201",
            kaynakFr = "Sourate Al-Baqara, 201"
        )
    )

    val hadisHavuzu = listOf(
        GunlukMetin(
            arapca = "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ",
            tr = "“Ameller niyetlere göredir; herkes için ancak niyet ettiği şey vardır.”",
            en = "“Actions are judged by intentions, and every person shall have what they intended.”",
            de = "„Die Taten sind entsprechend den Absichten, und jedem Menschen gebührt das, was er beabsichtigt hat.“",
            fr = "« Les actes ne valent que par les intentions, et chacun n’a pour lui que ce qu’il a eu réellement l’intention de faire. »",
            kaynakTr = "Sahih-i Buhârî, İman, 1",
            kaynakEn = "Sahih al-Bukhari, 1",
            kaynakDe = "Sahih al-Buchari, 1",
            kaynakFr = "Sahih al-Boukhari, 1"
        ),
        GunlukMetin(
            arapca = "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
            tr = "“Sizin en hayırlınız, Kur’an’ı öğrenen ve onu başkalarına öğretendir.”",
            en = "“The best among you are those who learn the Qur’an and teach it.”",
            de = "„Der Beste unter euch ist derjenige, der den Koran lernt und ihn lehrt.“",
            fr = "« Le meilleur d’entre vous est celui qui apprend le Coran et l’enseigne. »",
            kaynakTr = "Sahih-i Buhârî, Fedâilü’l-Kur’ân, 21",
            kaynakEn = "Sahih al-Bukhari, 5027",
            kaynakDe = "Sahih al-Buchari, 5027",
            kaynakFr = "Sahih al-Boukhari, 5027"
        ),
        GunlukMetin(
            arapca = "يَسِّرُوا وَلَا تُعَسِّرُوا وَبَشِّرُوا وَلَا تُنَفِّرُوا",
            tr = "“Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.”",
            en = "“Make things easy and do not make them difficult; give glad tidings and do not repel people.”",
            de = "„Erleichtert und erschwert nicht; verkündet frohe Botschaft und schreckt nicht ab.“",
            fr = "« Facilitez les choses et ne les rendez pas difficiles ; annoncez la bonne nouvelle et ne faites pas fuir. »",
            kaynakTr = "Sahih-i Buhârî, İlim, 11",
            kaynakEn = "Sahih al-Bukhari, 69",
            kaynakDe = "Sahih al-Buchari, 69",
            kaynakFr = "Sahih al-Boukhari, 69"
        ),
        GunlukMetin(
            arapca = "الطُّهُورُ شَطْرُ الْإِيمَانِ",
            tr = "“Temizlik imanın yarısıdır; Elhamdülillah mizanı doldurur.”",
            en = "“Cleanliness is half of faith, and Alhamdulillah fills the scale.”",
            de = "„Die Reinheit ist die Hälfte des Glaubens, und Alhamdulillah füllt die Waagschale.“",
            fr = "« La pureté est la moitié de la foi, et Alhamdoulillah remplit la balance. »",
            kaynakTr = "Sahih-i Müslim, Tahâret, 1",
            kaynakEn = "Sahih Muslim, 223",
            kaynakDe = "Sahih Muslim, 223",
            kaynakFr = "Sahih Mouslim, 223"
        ),
        GunlukMetin(
            arapca = "تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ",
            tr = "“Kardeşinin yüzüne tebessüm etmen senin için bir sadakadır.”",
            en = "“Your smiling in the face of your brother is charity for you.”",
            de = "„Dein Lächeln in das Gesicht deines Bruders ist eine Sadaqa (Almosen) für dich.“",
            fr = "« Ton sourire à ton frère est une aumône (Sadaqa) pour toi. »",
            kaynakTr = "Sünen-i Tirmizî, Birr, 36",
            kaynakEn = "Jami at-Tirmidhi, 1956",
            kaynakDe = "Dschami at-Tirmidhi, 1956",
            kaynakFr = "Jami at-Tirmidhi, 1956"
        ),
        GunlukMetin(
            arapca = "مَنْ لَا يَرْحَمْ لَا يُرْحَمْ",
            tr = "“Merhamet etmeyene merhamet olunmaz.”",
            en = "“Whoever does not show mercy will not be shown mercy.”",
            de = "„Wer keine Barmherzigkeit zeigt, dem wird keine Barmherzigkeit erwiesen.“",
            fr = "« Celui qui ne fait pas miséricorde, on ne lui fera pas miséricorde. »",
            kaynakTr = "Sahih-i Buhârî, Edeb, 18",
            kaynakEn = "Sahih al-Bukhari, 5997",
            kaynakDe = "Sahih al-Buchari, 5997",
            kaynakFr = "Sahih al-Boukhari, 5997"
        ),
        GunlukMetin(
            arapca = "الدُّعَاءُ هُوَ الْعِبَادَةُ",
            tr = "“Dua ibadetin ta kendisidir.”",
            en = "“Supplication (Dua) is the essence of worship.”",
            de = "„Das Bittgebet (Dua) ist der Kern des Gottesdienstes.“",
            fr = "« L’invocation (Doua) est l’essence même de l’adoration. »",
            kaynakTr = "Sünen-i Tirmizî, Daavât, 1",
            kaynakEn = "Jami at-Tirmidhi, 3372",
            kaynakDe = "Dschami at-Tirmidhi, 3372",
            kaynakFr = "Jami at-Tirmidhi, 3372"
        )
    )

    fun temizMetin(metin: String?): String {
        if (metin.isNullOrBlank()) return ""
        var s = metin
        for (e in emojiler) {
            s = s?.replace(e, "")
        }
        return s?.trim() ?: ""
    }

    fun oku(prefs: SharedPreferences, key: String, varsayilan: String): String {
        val raw = prefs.getString(key, null)
        val temiz = temizMetin(raw)
        return if (temiz.isNotEmpty()) temiz else temizMetin(varsayilan)
    }

    private fun saatParcala(saat: String): Pair<Int, Int>? {
        val parcalar = saat.trim().split(":")
        if (parcalar.size < 2) return null
        val h = parcalar[0].take(2).toIntOrNull() ?: return null
        val m = parcalar[1].take(2).toIntOrNull() ?: return null
        return Pair(h.coerceIn(0, 23), m.coerceIn(0, 59))
    }

    fun hesaplaSiradakiVakit(prefs: SharedPreferences): SiradakiVakitBilgisi {
        val dil = oku(prefs, "widget_dil", "TR").uppercase()
        val onEk = when (dil) {
            "EN" -> "Next:"
            "DE" -> "Nächstes:"
            "FR" -> "Suivante :"
            else -> "Sıradaki:"
        }

        val imsak = oku(prefs, "widget_imsak", "05:48")
        val gunes = oku(prefs, "widget_gunes", "07:14")
        val ogle = oku(prefs, "widget_ogle", "12:56")
        val ikindi = oku(prefs, "widget_ikindi", "15:52")
        val aksam = oku(prefs, "widget_aksam", "18:24")
        val yatsi = oku(prefs, "widget_yatsi", "19:44")

        val etImsak = oku(prefs, "widget_etiket_imsak", "İmsak")
        val etGunes = oku(prefs, "widget_etiket_gunes", "Güneş")
        val etOgle = oku(prefs, "widget_etiket_ogle", "Öğle")
        val etIkindi = oku(prefs, "widget_etiket_ikindi", "İkindi")
        val etAksam = oku(prefs, "widget_etiket_aksam", "Akşam")
        val etYatsi = oku(prefs, "widget_etiket_yatsi", "Yatsı")

        val vakitler = listOf(
            Pair(etImsak, imsak),
            Pair(etGunes, gunes),
            Pair(etOgle, ogle),
            Pair(etIkindi, ikindi),
            Pair(etAksam, aksam),
            Pair(etYatsi, yatsi)
        )

        val simdi = Calendar.getInstance()
        val simdiMs = simdi.timeInMillis

        for ((ad, saatStr) in vakitler) {
            val hm = saatParcala(saatStr) ?: continue
            val aday = (simdi.clone() as Calendar).apply {
                set(Calendar.HOUR_OF_DAY, hm.first)
                set(Calendar.MINUTE, hm.second)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            if (aday.timeInMillis > simdiMs) {
                val farkMs = (aday.timeInMillis - simdiMs).coerceAtLeast(1000L)
                return SiradakiVakitBilgisi("$onEk $ad", farkMs, aday.timeInMillis)
            }
        }

        val ilkHm = saatParcala(imsak) ?: Pair(5, 48)
        val yarinImsak = (simdi.clone() as Calendar).apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, ilkHm.first)
            set(Calendar.MINUTE, ilkHm.second)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val farkMs = (yarinImsak.timeInMillis - simdiMs).coerceAtLeast(1000L)
        return SiradakiVakitBilgisi("$onEk $etImsak", farkMs, yarinImsak.timeInMillis)
    }

    fun gunlukAyetGetir(prefs: SharedPreferences): Array<String> {
        val dil = oku(prefs, "widget_dil", "TR")
        val offset = oku(prefs, "widget_offset", "0").toIntOrNull() ?: 0
        val dayOfYear = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)
        val sonSenkronGun = oku(prefs, "widget_son_gun", "0").toIntOrNull() ?: 0

        val varsayilanBaslik = when (dil.uppercase()) {
            "EN" -> "Vakt-i Beraat • Verse of the Day"
            "DE" -> "Vakt-i Beraat • Vers des Tages"
            "FR" -> "Vakt-i Beraat • Verset du Jour"
            else -> "Vakt-i Beraat • Günün Ayeti"
        }

        val secili = ayetHavuzu[abs(dayOfYear + offset) % ayetHavuzu.size]
        val ayniGun = (sonSenkronGun == dayOfYear)

        val baslik = if (ayniGun) oku(prefs, "widget_ayet_baslik", varsayilanBaslik) else varsayilanBaslik
        val arapca = if (ayniGun) oku(prefs, "widget_ayet_arapca", secili.arapca) else secili.arapca
        val meal = if (ayniGun) oku(prefs, "widget_ayet_meal", secili.meal(dil)) else secili.meal(dil)
        val kaynak = if (ayniGun) oku(prefs, "widget_ayet_kaynak", secili.kaynak(dil)) else secili.kaynak(dil)

        return arrayOf(baslik, arapca, meal, kaynak)
    }

    fun gunlukHadisGetir(prefs: SharedPreferences): Array<String> {
        val dil = oku(prefs, "widget_dil", "TR")
        val offset = oku(prefs, "widget_offset", "0").toIntOrNull() ?: 0
        val dayOfYear = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)
        val sonSenkronGun = oku(prefs, "widget_son_gun", "0").toIntOrNull() ?: 0

        val varsayilanBaslik = when (dil.uppercase()) {
            "EN" -> "Vakt-i Beraat • Hadith of the Day"
            "DE" -> "Vakt-i Beraat • Hadith des Tages"
            "FR" -> "Vakt-i Beraat • Hadith du Jour"
            else -> "Vakt-i Beraat • Günün Hadisi"
        }

        val secili = hadisHavuzu[abs(dayOfYear + offset) % hadisHavuzu.size]
        val ayniGun = (sonSenkronGun == dayOfYear)

        val baslik = if (ayniGun) oku(prefs, "widget_hadis_baslik", varsayilanBaslik) else varsayilanBaslik
        val arapca = if (ayniGun) oku(prefs, "widget_hadis_arapca", secili.arapca) else secili.arapca
        val meal = if (ayniGun) oku(prefs, "widget_hadis_meal", secili.meal(dil)) else secili.meal(dil)
        val kaynak = if (ayniGun) oku(prefs, "widget_hadis_kaynak", secili.kaynak(dil)) else secili.kaynak(dil)

        return arrayOf(baslik, arapca, meal, kaynak)
    }

    fun zamanlayiciKur(context: Context, providerClass: Class<*>, hedefMs: Long, requestCode: Int) {
        try {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, providerClass))
            if (ids.isEmpty()) return

            val intent = Intent(context, providerClass).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            val pi = PendingIntent.getBroadcast(context, requestCode, intent, flags)
            val alarm = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            alarm.set(AlarmManager.RTC, hedefMs + 1500L, pi)
        } catch (_: Exception) {
        }
    }

    fun geceYarisiMs(): Long {
        val cal = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 2)
            set(Calendar.MILLISECOND, 0)
        }
        return cal.timeInMillis
    }
}
