package com.vaktihuzur.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class VaktiHuzurSiradakiWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.vakti_huzur_siradaki_widget)

            val konum = widgetData.getString("widget_konum", "İstanbul") ?: "İstanbul"
            val siradaki = widgetData.getString("widget_siradaki_vakit", "İkindi Vakti") ?: "İkindi Vakti"
            val kalan = widgetData.getString("widget_kalan_sure", "01s 24dk") ?: "01s 24dk"

            views.setTextViewText(R.id.tv_siradaki_konum_hicri, "☪ Vakt-i Huzur • $konum")
            views.setTextViewText(R.id.tv_siradaki_ad, siradaki)
            views.setTextViewText(R.id.tv_siradaki_kalan, kalan)

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
