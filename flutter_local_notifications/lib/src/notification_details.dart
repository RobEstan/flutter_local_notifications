import 'dart:io';

import 'package:timezone/timezone.dart';

import 'platform_specifics/android/method_channel_mappers.dart';
import 'platform_specifics/android/notification_details.dart';
import 'platform_specifics/ios/enums.dart';
import 'platform_specifics/ios/enums.dart';
import 'platform_specifics/ios/method_channel_mappers.dart';
import 'platform_specifics/ios/notification_details.dart';
import 'platform_specifics/macos/method_channel_mappers.dart';
import 'platform_specifics/macos/notification_details.dart';
import 'types.dart';
import 'tz_datetime_mapper.dart';

/// Contains notification details specific to each platform.
class NotificationDetails {
  const NotificationDetails({
    this.android,
    this.iOS,
    this.macOS,
  });

  /// Notification details for Android.
  final AndroidNotificationDetails android;

  /// Notification details for iOS.
  final IOSNotificationDetails iOS;

  /// Notification details for macOS.
  final MacOSNotificationDetails macOS;
}

class NotificationData {
  NotificationData(
    this.id,
    this.title,
    this.body,
    this.scheduledDate,
    this.platformSpecifics, {
    this.payload,
    this.androidAllowWhileIdle = false,
    this.scheduledNotificationRepeatFrequency,
    this.uiLocalNotificationDateInterpretation =
        UILocalNotificationDateInterpretation.absoluteTime,
  });

  final int id;
  final String title;
  final String body;
  final TZDateTime scheduledDate;
  final NotificationDetails platformSpecifics;
  final String payload;
  final bool androidAllowWhileIdle;
  final ScheduledNotificationRepeatFrequency
      scheduledNotificationRepeatFrequency;
  final UILocalNotificationDateInterpretation
      uiLocalNotificationDateInterpretation;

  Map<String, dynamic> get _platformSpecifics {
    Map<String, dynamic> _specs;

    if (Platform.isAndroid) {
      _specs = platformSpecifics?.android?.toMap();
    }
    if (Platform.isIOS) {
      _specs = platformSpecifics?.iOS?.toMap();
    }
    if (Platform.isMacOS) {
      _specs = platformSpecifics?.macOS?.toMap();
    }
    return _specs ?? <String, dynamic>{};
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _m = <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'platformSpecifics': _platformSpecifics,
      'payload': payload ?? '',
    }..addAll(scheduledDate.toMap());

    if (Platform.isAndroid) {
      _m['allowWhileIdle'] = androidAllowWhileIdle;
    }

    if (Platform.isIOS) {
      _m['uiLocalNotificationDateInterpretation'] =
          uiLocalNotificationDateInterpretation.index;
    }

    if (scheduledNotificationRepeatFrequency != null) {
      _m['scheduledNotificationRepeatFrequency'] =
          scheduledNotificationRepeatFrequency.index;
    }

    return _m;
  }
}
