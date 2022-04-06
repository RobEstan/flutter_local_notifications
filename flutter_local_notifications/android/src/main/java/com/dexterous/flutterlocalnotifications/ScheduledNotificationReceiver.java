package com.dexterous.flutterlocalnotifications;

import android.app.Notification;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import androidx.annotation.Keep;
import androidx.core.app.NotificationManagerCompat;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.utils.StringUtils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.time.LocalDateTime;

/** Created by michaelbui on 24/3/18. */
@Keep
public class ScheduledNotificationReceiver extends BroadcastReceiver {

  @Override
  public void onReceive(final Context context, Intent intent) {
    String notificationDetailsJson =
        intent.getStringExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_DETAILS);
    if (StringUtils.isNullOrEmpty(notificationDetailsJson)) {
      // This logic is needed for apps that used the plugin prior to 0.3.4
      Notification notification = intent.getParcelableExtra("notification");
      notification.when = System.currentTimeMillis();
      int notificationId = intent.getIntExtra("notification_id", 0);
      NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
      notificationManager.notify(notificationId, notification);
      boolean repeat = intent.getBooleanExtra("repeat", false);
      if (!repeat) {
        FlutterLocalNotificationsPlugin.removeNotificationFromCache(context, notificationId);
      }
    } else {
      Gson gson = FlutterLocalNotificationsPlugin.buildGson();
      Type type = new TypeToken<NotificationDetails>() {}.getType();
      NotificationDetails notificationDetails = gson.fromJson(notificationDetailsJson, type);
      if (notificationDetails.showNotification) {
        FlutterLocalNotificationsPlugin.showNotification(context, notificationDetails);
      }
      if (notificationDetails.scheduledNotificationRepeatFrequency != null) {
        FlutterLocalNotificationsPlugin.zonedScheduleNextNotification(context, notificationDetails);
      } else if (notificationDetails.matchDateTimeComponents != null) {
        FlutterLocalNotificationsPlugin.zonedScheduleNextNotificationMatchingDateComponents(
            context, notificationDetails);
      } else if (notificationDetails.repeatInterval != null) {
        FlutterLocalNotificationsPlugin.scheduleNextRepeatingNotification(
            context, notificationDetails);
      } else {
        FlutterLocalNotificationsPlugin.removeNotificationFromCache(
            context, notificationDetails.id);
      }

      boolean locked = FlutterLocalNotificationsPlugin.isKeyguardLocked(context);
      boolean firstAlarm = firstAlarm(notificationDetails);
      boolean hasStartActivity = notificationDetails.startActivityClassName != null;
      if (hasStartActivity && (!locked || !firstAlarm)) {
        FlutterLocalNotificationsPlugin.startAlarmActivity(context, notificationDetails);
      }

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P &&
              !notificationDetails.showNotification &&
              notificationDetails.playSound) {
        FlutterLocalNotificationsPlugin.startAlarmSound(context, notificationDetails);
      }
    }
  }

  boolean firstAlarm(NotificationDetails notificationDetails) {
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
      return LocalDateTime.parse(notificationDetails.scheduledDateTime).getSecond() == 0;
    } else {
      return org.threeten.bp.LocalDateTime.parse(notificationDetails.scheduledDateTime).getSecond()
          == 0;
    }
  }
}
