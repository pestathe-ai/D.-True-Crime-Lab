import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../story/engine.dart';

/// Notifiche locali: tutto parte dal telefono, nessun server.
class Notifier {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channelId = 'storia';
  static const _channelName = 'Arrivi dal telefono ereditato';

  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      _ready = true;
    } catch (e) {
      debugPrint('Notifiche non disponibili: $e');
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<bool> requestPermission() async {
    await init();
    try {
      final ok = await _android?.requestNotificationsPermission();
      return ok ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _exactAllowed() async {
    try {
      return await _android?.canScheduleExactNotifications() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Cancella tutto e riprogramma il piano attuale.
  Future<void> reschedule(List<PlannedNotification> plan) async {
    await init();
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
    final exact = await _exactAllowed();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription:
            'Note, messaggi e vocali che arrivano sul telefono di Marta',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFFFFD21F),
      ),
    );
    for (final p in plan) {
      try {
        await _plugin.zonedSchedule(
          id: p.id,
          title: '◆ D. True Crime Lab',
          body: p.text,
          scheduledDate: tz.TZDateTime.from(p.at.toUtc(), tz.UTC),
          notificationDetails: details,
          androidScheduleMode: exact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          payload: p.dropId,
        );
      } catch (e) {
        debugPrint('Notifica ${p.id} non programmata: $e');
      }
    }
  }

  Future<void> cancelAll() async {
    await init();
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
