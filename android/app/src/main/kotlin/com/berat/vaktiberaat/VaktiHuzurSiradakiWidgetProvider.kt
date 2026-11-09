package com.berat.vaktiberaat

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.SystemClock
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class VaktiHuzurSiradakiWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val siradakiBilgi = VaktiBeraatWidgetHelper.hesaplaSiradakiVakit(widgetData)
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
                SystemClock.elapsedRealtime() + siradakiBilgi.kalanMs,
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
