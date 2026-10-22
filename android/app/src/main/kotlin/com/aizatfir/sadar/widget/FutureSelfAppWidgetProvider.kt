package com.aizatfir.sadar.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import com.aizatfir.sadar.MainActivity
import com.aizatfir.sadar.R
import org.json.JSONObject

class FutureSelfAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            updateWidget(context, appWidgetManager, appWidgetId, options)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        updateWidget(context, appWidgetManager, appWidgetId, newOptions)
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_UPDATE_WIDGET || intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, FutureSelfAppWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            onUpdate(context, appWidgetManager, allWidgetIds)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        options: Bundle
    ) {
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val snapshotRaw = prefs.getString(KEY_SNAPSHOT_JSON, null)

        var goal = "Membangun Kehidupan Mandiri & Berakhlak"
        var ratioText = "3/5"
        var subtitle = "SELESAI"
        var item1 = "✓ 📖 Belajar Coding"
        var item2 = "✓ 🕌 1 Ayat Al-Quran"
        var item3 = "○ 🏃 Olahraga 30m"
        var item4 = "○ 🪽 Kalaam Harian"
        var gratitude = "🙏 Bersyukur atas ketenangan & fokus hari ini"

        if (snapshotRaw != null) {
            try {
                val json = JSONObject(snapshotRaw)
                goal = json.optString("futureSelfGoal", goal)
                val total = json.optInt("totalActivities", 5)
                val completed = json.optInt("completedActivities", 3)
                ratioText = "$completed/$total"
                subtitle = if (total > 0 && completed >= total) "FULFILLED" else "SELESAI"

                val activities = json.optJSONArray("activities")
                if (activities != null) {
                    if (activities.length() > 0) {
                        val a0 = activities.getJSONObject(0)
                        val icon = if (a0.optBoolean("isCompleted")) "✓" else "○"
                        item1 = "$icon ${a0.optString("iconKey")} ${a0.optString("title")}"
                    }
                    if (activities.length() > 1) {
                        val a1 = activities.getJSONObject(1)
                        val icon = if (a1.optBoolean("isCompleted")) "✓" else "○"
                        item2 = "$icon ${a1.optString("iconKey")} ${a1.optString("title")}"
                    }
                    if (activities.length() > 2) {
                        val a2 = activities.getJSONObject(2)
                        val icon = if (a2.optBoolean("isCompleted")) "✓" else "○"
                        item3 = "$icon ${a2.optString("iconKey")} ${a2.optString("title")}"
                    }
                    if (activities.length() > 3) {
                        val a3 = activities.getJSONObject(3)
                        val icon = if (a3.optBoolean("isCompleted")) "✓" else "○"
                        item4 = "$icon ${a3.optString("iconKey")} ${a3.optString("title")}"
                    }
                }
                val grat = json.optString("gratitudeSnippet", "")
                if (grat.isNotEmpty()) {
                    gratitude = "🙏 $grat"
                }
            } catch (_: Exception) {}
        }

        // Tap to open application
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            data = Uri.parse("sadar://future-self")
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Select responsive layout
        val views: RemoteViews
        if (minWidth < 140 && minHeight < 140) {
            // Small 2x2
            views = RemoteViews(context.packageName, R.layout.widget_future_self_small)
            views.setTextViewText(R.id.widget_small_ratio, ratioText)
            views.setTextViewText(R.id.widget_small_subtitle, subtitle)
            views.setTextViewText(R.id.widget_small_goal, goal)
            views.setOnClickPendingIntent(R.id.widget_small_root, pendingIntent)
        } else if (minHeight < 170) {
            // Medium 4x2
            views = RemoteViews(context.packageName, R.layout.widget_future_self_medium)
            views.setTextViewText(R.id.widget_medium_ratio, ratioText)
            views.setTextViewText(R.id.widget_medium_status, subtitle)
            views.setTextViewText(R.id.widget_medium_goal, goal)
            views.setTextViewText(R.id.widget_item_1, item1)
            views.setTextViewText(R.id.widget_item_2, item2)
            views.setTextViewText(R.id.widget_item_3, item3)
            views.setOnClickPendingIntent(R.id.widget_medium_root, pendingIntent)
        } else {
            // Large 4x4
            views = RemoteViews(context.packageName, R.layout.widget_future_self_large)
            views.setTextViewText(R.id.widget_large_goal, goal)
            views.setTextViewText(R.id.widget_large_ratio, "$ratioText $subtitle")
            views.setTextViewText(R.id.widget_large_item_1, item1)
            views.setTextViewText(R.id.widget_large_item_2, item2)
            views.setTextViewText(R.id.widget_large_item_3, item3)
            views.setTextViewText(R.id.widget_large_item_4, item4)
            views.setTextViewText(R.id.widget_large_gratitude, gratitude)
            views.setOnClickPendingIntent(R.id.widget_large_root, pendingIntent)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    companion object {
        const val PREFS_NAME = "future_self_widget_prefs"
        const val KEY_SNAPSHOT_JSON = "snapshot_json"
        const val ACTION_UPDATE_WIDGET = "com.aizatfir.sadar.widget.ACTION_UPDATE_WIDGET"

        fun updateAllWidgets(context: Context) {
            val intent = Intent(context, FutureSelfAppWidgetProvider::class.java).apply {
                action = ACTION_UPDATE_WIDGET
            }
            context.sendBroadcast(intent)
        }
    }
}
