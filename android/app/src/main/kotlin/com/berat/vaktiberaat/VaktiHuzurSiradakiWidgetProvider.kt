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

class VaktiHuzurSiradakiWidgetProvider : HomeWidgetProvider() {
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
            val ids = mgr.getAppWidgetIds(ComponentName(context, VaktiHuzurSiradakiWidgetProvider::class.java))
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
            VaktiHuzurSiradakiWidgetProvider::class.java,
            siradakiBilgi.hedefEpochMs,
            702
        )

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.vakti_huzur_siradaki_widget)

            val konum = VaktiBeraatWidgetHelper.oku(widgetData, "widget_konum", "İstanbul")

            views.setTextViewText(R.id.tv_siradaki_konum_hicri, "Vakt-i Beraat • $konum")
            views.setTextViewText(R.id.tv_siradaki_ad, siradakiBilgi.baslik)
            views.setChronometerCountDown(R.id.tv_siradaki_kalan, true)
            views.setChronometer(
                R.id.tv_siradaki_kalan,
                SystemClock.elapsedRealtime() + canliKalanMs,
                null,
                true
            )

            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                3,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_siradaki_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
