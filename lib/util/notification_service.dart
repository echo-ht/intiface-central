import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loggy/loggy.dart';

/// 本地通知服务 — 设备连接/断开等事件通知
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'device_events';
  static const String _channelName = '设备事件';
  static const String _channelDesc = '设备连接和断开通知';

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@drawable/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        logInfo("Notification tapped: ${response.payload}");
      },
    );
    _initialized = true;
    logInfo("NotificationService initialized");
  }

  Future<void> showDeviceConnected(String deviceName) async {
    if (!_initialized) return;
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(
      0,
      '设备已连接',
      '$deviceName 已连接到闪动',
      details,
      payload: deviceName,
    );
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }
}
