import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

// ignore_for_file: public_member_api_docs

void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();

  const EventChannel backgroundChannel =
      EventChannel('dexterous.com/flutter/local_notifications/actions');

  const MethodChannel channel =
      MethodChannel('dexterous.com/flutter/local_notifications');

  channel.invokeMethod<int>('getCallbackHandle').then((handle) {
    final NotificationActionCallback? callback = handle == null
        ? null
        : PluginUtilities.getCallbackFromHandle(
                CallbackHandle.fromRawHandle(handle))
            as NotificationActionCallback?;

    backgroundChannel
        .receiveBroadcastStream()
        .map<Map<dynamic, dynamic>>((event) => event)
        .map<Map<String, dynamic>>(
            (Map<dynamic, dynamic> event) => Map.castFrom(event))
        .listen((Map<String, dynamic> event) {
      callback?.call(event['id'], event['input'], event['payload']);
    });
  });
}
