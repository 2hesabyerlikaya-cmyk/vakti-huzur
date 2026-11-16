package com.berat.vaktiberaat

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.SystemClock
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

class VaktiHuzurNamazWidgetProvider : HomeWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val act = intent.action ?: return
        if (act == VaktiBeraatWidgetHelper.ACTION_WIDGET_TICK ||
            act == Intent.ACTION_USER_PRESENT ||
            act == Intent.ACTION_SCREEN_ON ||
            act == Intent.ACTION_TIME_CHANGED ||
            act == Intent.ACTION_TIMEZONE_CHANGED ||
            act == Intent.ACTION_DATE_CHANGED ||
            act == Intent.ACTION_BOOT_COMPLETED
        ) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, VaktiHuzurNamazWidgetProvider::class.java))
            if (ids.isNotEmpty()) {
                onUpdate(context, mgr, ids, HomeWidgetPlugin.getData(context))
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // Hedef namaz vaktinin timestamp'inden mevcut sistem saatini (System.currentTimeMillis()) çıkararak hesapla
        val siradakiBilgi = VaktiBeraatWidgetHelper.hesaplaSiradakiVakit(widgetData)
        val canliKalanMs = (siradakiBilgi.hedefEpochMs - System.currentTimeMillis()).coerceAtLeast(1000L)

        VaktiBeraatWidgetHelper.zamanlayiciKur(
            context,
            VaktiHuzurNamazWidgetProvider::class.java,
            siradakiBilgi.hedefEpochMs,
            701
        )

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.vakti_huzur_namaz_widget)

            val konum = VaktiBeraatWidgetHelper.oku(widgetData, "widget_konum", "İstanbul")
            val hicri = VaktiBeraatWidgetHelper.oku(widgetData, "widget_hicri_tarih", "Diyanet Namaz Vakitleri")

            val imsak = VaktiBeraatWidgetHelper.oku(widgetData, "widget_imsak", "05:48")
            val gunes = VaktiBeraatWidgetHelper.oku(widgetData, "widget_gunes", "07:14")
            val ogle = VaktiBeraatWidgetHelper.oku(widgetData, "widget_ogle", "12:56")
            val ikindi = VaktiBeraatWidgetHelper.oku(widgetData, "widget_ikindi", "15:52")
            val aksam = VaktiBeraatWidgetHelper.oku(widgetData, "widget_aksam", "18:24")
            val yatsi = VaktiBeraatWidgetHelper.oku(widgetData, "widget_yatsi", "19:44")

            val etImsak = VaktiBeraatWidgetHelper.oku(widgetData, "widget_etiket_imsak", "İmsak")
            val etGunes = VaktiBeraatWidgetHelper.oku(widgetData, "widget_etiket_gunes", "Güneş")
            val etOgle = VaktiBeraatWidgetHelper.oku(widgetData, "widget_etiket_ogle", "Öğle")
            val etIkindi = VaktiBeraatWidgetHelper.oku(widgetData, "widget_etiket_ikindi", "İkindi")
            val etAksam = VaktiBeraatWidgetHelper.oku(widgetData, "widget_etiket_aksam", "Akşam")
            val etYatsi = VaktiBeraatWidgetHelper.oku(widgetData, "widget_etiket_yatsi", "Yatsı")

            views.setTextViewText(R.id.tv_widget_baslik, "Vakt-i Beraat • $konum")
            views.setTextViewText(R.id.tv_widget_hicri, hicri)
            views.setTextViewText(R.id.tv_siradaki_vakit, siradakiBilgi.baslik)
            views.setChronometerCountDown(R.id.tv_kalan_sure, true)
            views.setChronometer(
                R.id.tv_kalan_sure,
                SystemClock.elapsedRealtime() + canliKalanMs,
                null,
                true
            )

            views.setTextViewText(R.id.tv_etiket_imsak, etImsak)
            views.setTextViewText(R.id.tv_etiket_gunes, etGunes)
            views.setTextViewText(R.id.tv_etiket_ogle, etOgle)
            views.setTextViewText(R.id.tv_etiket_ikindi, etIkindi)
            views.setTextViewText(R.id.tv_etiket_aksam, etAksam)
            views.setTextViewText(R.id.tv_etiket_yatsi, etYatsi)

            views.setTextViewText(R.id.tv_vakit_imsak, imsak)
            views.setTextViewText(R.id.tv_vakit_gunes, gunes)
            views.setTextViewText(R.id.tv_vakit_ogle, ogle)
            views.setTextViewText(R.id.tv_vakit_ikindi, ikindi)
            views.setTextViewText(R.id.tv_vakit_aksam, aksam)
            views.setTextViewText(R.id.tv_vakit_yatsi, yatsi)

            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_namaz_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
