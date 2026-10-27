package com.vaktihuzur.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class VaktiHuzurNamazWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.vakti_huzur_namaz_widget)

            val konum = widgetData.getString("widget_konum", "İstanbul") ?: "İstanbul"
            val hicri = widgetData.getString("widget_hicri_tarih", "Diyanet Namaz Vakitleri")
                ?: "Diyanet Namaz Vakitleri"
            val siradaki = widgetData.getString("widget_siradaki_vakit", "Sıradaki: Akşam")
                ?: "Sıradaki: Akşam"
            val kalan = widgetData.getString("widget_kalan_sure", "18:24") ?: "18:24"

            val imsak = widgetData.getString("widget_imsak", "05:48") ?: "05:48"
            val gunes = widgetData.getString("widget_gunes", "07:14") ?: "07:14"
            val ogle = widgetData.getString("widget_ogle", "12:56") ?: "12:56"
            val ikindi = widgetData.getString("widget_ikindi", "15:52") ?: "15:52"
            val aksam = widgetData.getString("widget_aksam", "18:24") ?: "18:24"
            val yatsi = widgetData.getString("widget_yatsi", "19:44") ?: "19:44"

            views.setTextViewText(R.id.tv_widget_baslik, "☪ Vakt-i Huzur • $konum")
            views.setTextViewText(R.id.tv_widget_hicri, hicri)
            views.setTextViewText(R.id.tv_siradaki_vakit, siradaki)
            views.setTextViewText(R.id.tv_kalan_sure, kalan)

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
