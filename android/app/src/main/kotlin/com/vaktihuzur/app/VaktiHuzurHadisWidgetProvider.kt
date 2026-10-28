package com.vaktihuzur.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class VaktiHuzurHadisWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.vakti_huzur_hadis_widget)

            val baslik = widgetData.getString(
                "widget_hadis_baslik",
                "☪ Vakt-i Huzur • Günün Hadisi"
            ) ?: "☪ Vakt-i Huzur • Günün Hadisi"
            val arapca = widgetData.getString(
                "widget_hadis_arapca",
                "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ"
            ) ?: "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ"
            val meal = widgetData.getString(
                "widget_hadis_meal",
                "“Ameller niyetlere göredir; herkes için ancak niyet ettiği şey vardır.”"
            ) ?: "“Ameller niyetlere göredir; herkes için ancak niyet ettiği şey vardır.”"
            val kaynak = widgetData.getString(
                "widget_hadis_kaynak",
                "Sahih-i Buhârî, İman, 1"
            ) ?: "Sahih-i Buhârî, İman, 1"

            views.setTextViewText(R.id.tv_hadis_widget_baslik, baslik)
            views.setTextViewText(R.id.tv_hadis_widget_arapca, arapca)
            views.setTextViewText(R.id.tv_hadis_widget_meal, meal)
            views.setTextViewText(R.id.tv_hadis_widget_kaynak, kaynak)

            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                2,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_hadis_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
