package com.berat.vaktiberaat

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
        val ayet = VaktiBeraatWidgetHelper.gunlukAyetGetir(widgetData)
        VaktiBeraatWidgetHelper.zamanlayiciKur(
            context,
            VaktiHuzurAyetWidgetProvider::class.java,
            VaktiBeraatWidgetHelper.geceYarisiMs(),
            703
        )

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.vakti_huzur_ayet_widget)

            views.setTextViewText(R.id.tv_ayet_widget_baslik, ayet[0])
            views.setTextViewText(R.id.tv_ayet_widget_arapca, ayet[1])
            views.setTextViewText(R.id.tv_ayet_widget_meal, ayet[2])
            views.setTextViewText(R.id.tv_ayet_widget_kaynak, ayet[3])

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
