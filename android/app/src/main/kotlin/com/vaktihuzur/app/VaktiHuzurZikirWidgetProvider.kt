package com.vaktihuzur.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class VaktiHuzurZikirWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.vakti_huzur_zikir_widget)

            val arapca = widgetData.getString("widget_zikir_arapca", "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ")
                ?: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ"
            val okunus = widgetData.getString("widget_zikir_okunus", "Sübhânallâhi ve bi-hamdihî")
                ?: "Sübhânallâhi ve bi-hamdihî"
            val anlam = widgetData.getString("widget_zikir_anlam", "“Allah’ı hamd ile noksan sıfatlardan tenzih ederim.”")
                ?: "“Allah’ı hamd ile noksan sıfatlardan tenzih ederim.”"
            val sayac = widgetData.getString("widget_zikir_sayac", "33 / 100")
                ?: "33 / 100"

            views.setTextViewText(R.id.tv_zikir_widget_arapca, arapca)
            views.setTextViewText(R.id.tv_zikir_widget_okunus, okunus)
            views.setTextViewText(R.id.tv_zikir_widget_anlam, anlam)
            views.setTextViewText(R.id.tv_zikir_widget_sayac, sayac)

            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                4,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_zikir_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
