package com.vaktihuzur.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class VaktiHuzurAyetWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.vakti_huzur_ayet_widget)

            val baslik = widgetData.getString(
                "widget_ayet_baslik",
                "✨ Vakt-i Huzur • Günün Ayeti"
            ) ?: "✨ Vakt-i Huzur • Günün Ayeti"
            val arapca = widgetData.getString(
                "widget_ayet_arapca",
                "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ"
            ) ?: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ"
            val meal = widgetData.getString(
                "widget_ayet_meal",
                "“Biliniz ki, kalpler ancak Allah’ı anmakla (zikirle) huzur bulur.”"
            ) ?: "“Biliniz ki, kalpler ancak Allah’ı anmakla (zikirle) huzur bulur.”"
            val kaynak = widgetData.getString(
                "widget_ayet_kaynak",
                "Ra’d Suresi, 28. Ayet"
            ) ?: "Ra’d Suresi, 28. Ayet"

            views.setTextViewText(R.id.tv_ayet_widget_baslik, baslik)
            views.setTextViewText(R.id.tv_ayet_widget_arapca, arapca)
            views.setTextViewText(R.id.tv_ayet_widget_meal, meal)
            views.setTextViewText(R.id.tv_ayet_widget_kaynak, kaynak)

            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                1,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_ayet_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
