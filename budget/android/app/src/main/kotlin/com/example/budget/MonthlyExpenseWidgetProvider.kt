package com.example.budget

import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import androidx.core.graphics.ColorUtils
import com.home_widget.HomeWidgetProvider

import es.antonborri.home_widget.R

class MonthlyExpenseWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->

            val views = RemoteViews(context.packageName, R.layout.monthly_expense_widget_layout).apply {
                try {
                  setTextViewText(R.id.monthly_expense_title, widgetData.getString("monthlyExpenseTitle", null)
                  ?: "Monthly Expense")

                  setTextViewText(R.id.monthly_expense_amount, widgetData.getString("monthlyExpenseAmount", null)
                  ?: "0.00")

                  setTextViewText(R.id.monthly_expense_transactions_number, widgetData.getString("monthlyExpenseTransactionsNumber", null)
                  ?: "0 transactions")
                }catch (e: Exception){}

                try {
                  setInt(R.id.widget_background, "setColorFilter",  android.graphics.Color.parseColor(widgetData.getString("widgetColorBackground", null)
                  ?: "#FFFFFF"));
                }catch (e: Exception){}

                try {
                  val alpha = Integer.parseInt(widgetData.getString("widgetAlpha", null)?: "255")
                  setInt(R.id.widget_background, "setImageAlpha",  alpha);
                }catch (e: Exception){}

                try {
                  setInt(R.id.monthly_expense_title, "setTextColor",  android.graphics.Color.parseColor(widgetData.getString("widgetColorText", null)
                  ?: "#FFFFFF"))
                  setInt(R.id.monthly_expense_amount, "setTextColor",  android.graphics.Color.parseColor(widgetData.getString("widgetColorText", null)
                  ?: "#FFFFFF"))
                  setInt(R.id.monthly_expense_transactions_number, "setTextColor",  android.graphics.Color.parseColor(widgetData.getString("widgetColorText", null)
                  ?: "#FFFFFF"))
                }catch (e: Exception){}

                try {
                  val pendingIntentWithData = HomeWidgetLaunchIntent.getActivity(
                          context,
                          MainActivity::class.java,
                          Uri.parse("monthlyExpenseLaunchWidget"))
                  setOnClickPendingIntent(R.id.widget_container, pendingIntentWithData)
                }catch (e: Exception){}

            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
