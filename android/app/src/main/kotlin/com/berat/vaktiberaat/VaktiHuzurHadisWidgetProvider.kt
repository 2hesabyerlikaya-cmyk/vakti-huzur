package com.berat.vaktiberaat

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
        val hadis = VaktiBeraatWidgetHelper.gunlukHadisGetir(widgetData)
        VaktiBeraatWidgetHelper.zamanlayiciKur(
            context,
            VaktiHuzurHadisWidgetProvider::class.java,
            VaktiBeraatWidgetHelper.geceYarisiMs(),
            704
        )

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.vakti_huzur_hadis_widget)

            views.setTextViewText(R.id.tv_hadis_widget_baslik, hadis[0])
            views.setTextViewText(R.id.tv_hadis_widget_arapca, hadis[1])
            views.setTextViewText(R.id.tv_hadis_widget_meal, hadis[2])
            views.setTextViewText(R.id.tv_hadis_widget_kaynak, hadis[3])

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
