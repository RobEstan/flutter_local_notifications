import "dart:ffi";

import "package:ffi/ffi.dart";
import "package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart";
import "package:flutter_local_notifications_windows/src/plugin/base.dart";

import "bindings.dart";
import "../details.dart";

/// Helpful methods on native string maps.
extension NativeStringMapUtils on NativeStringMap {
  /// Converts this map to a typical Dart map.
  Map<String, String> toMap() => {
    for (var index = 0; index < size; index++)
      entries[index].key.toDartString(): entries[index].value.toDartString(),
  };
}

/// Helpful methods on integers.
extension IntUtils on int {
  /// Converts this integer into a boolean. Useful for return types of C functions.
  bool toBool() => this == 1;
}

/// Gets the [NotificationResponseType] from a [NativeLaunchType].
NotificationResponseType getResponseType(int launchType) {
  switch (NativeLaunchType.fromValue(launchType)) {
    case NativeLaunchType.notification: return NotificationResponseType.selectedNotification;
    case NativeLaunchType.action: return NotificationResponseType.selectedNotificationAction;
  }
}

/// Gets the [NotificationUpdateResult] from a [NativeUpdateResult].
NotificationUpdateResult getUpdateResult(NativeUpdateResult result) {
  switch (result) {
    case NativeUpdateResult.success: return NotificationUpdateResult.success;
    case NativeUpdateResult.failed: return NotificationUpdateResult.error;
    case NativeUpdateResult.notFound: return NotificationUpdateResult.notFound;
  }
}

/// Helpful methods on string maps.
extension MapToNativeMap on Map<String, String> {
  /// Allocates and returns a pointer to a [NativeStringMap] using the provided arena.
  NativeStringMap toNativeMap(Arena arena) {
    final pointer = arena<NativeStringMap>();
    pointer.ref.size = length;
    pointer.ref.entries = arena<StringMapEntry>(length);
    var index = 0;
    for (final entry in entries) {
      pointer.ref.entries[index].key = entry.key.toNativeUtf8(allocator: arena);
      pointer.ref.entries[index].value = entry.value.toNativeUtf8(allocator: arena);
      index++;
    }
    return pointer.ref;
  }
}

/// Helpful methods on native notification details.
extension NativeNotificationDetailsUtils on Pointer<NativeNotificationDetails> {
  /// Parses this array as a list of [ActiveNotification]s.
  List<ActiveNotification> asActiveNotifications(int length) => [
    for (var index = 0; index < length; index++)
      ActiveNotification(id: this[index].id),
  ];

  /// Parses this array os a list of [PendingNotificationRequest]s.
  List<PendingNotificationRequest> asPendingRequests(int length) => [
    for (var index = 0; index < length; index++)
      PendingNotificationRequest(this[index].id, null, null, null),
  ];
}
