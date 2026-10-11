import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  static int newId() =>
      DateTime.now().millisecondsSinceEpoch.remainder(100000000);

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    await _requestPermission();
    _initialized = true;
  }

  Future<void> _requestPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    final canExact = await _android?.canScheduleExactNotifications() ?? true;
    if (!canExact) {
      await _android?.requestExactAlarmsPermission();
    }
  }

  static AndroidNotificationDetails _createAndroidDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
  }

  Future<void> showSimpleNotification({
    int id = 0,
    String title = 'Nhắc học từ vựng',
    String body = 'Bạn đã học 5 từ mới hôm nay chưa?',
  }) async {
    await showNow(
      id: id,
      title: title,
      body: body,
      channelId: 'learn_english_channel',
      channelName: 'Học Anh Văn',
    );
  }

  Future<void> showNow({
    int? id,
    required String title,
    required String body,
    String channelId = 'general_channel',
    String channelName = 'Thông báo chung',
    String? payload,
  }) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
    );
    await _plugin.show(
      id ?? newId(),
      title,
      body,
      NotificationDetails(android: details),
      payload: payload,
    );
  }

  Future<void> scheduleAt({
    int? id,
    required String title,
    required String body,
    required DateTime time,
    String channelId = 'reminder_channel',
    String channelName = 'Lịch nhắc',
    String? channelDescription,
    String? payload,
    DateTimeComponents? repeat,
  }) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );

    final canExact = await _android?.canScheduleExactNotifications() ?? true;
    final mode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    await _plugin.zonedSchedule(
      id ?? newId(),
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      NotificationDetails(android: details),
      androidScheduleMode: mode,
      payload: payload,
      matchDateTimeComponents: repeat,
    );
  }

  Future<void> scheduleNotificationAfter(
    Duration delay,
    String channelId,
    String channelName,
    String channelDescription, {
    int? id,
    String? payload,
  }) async {
    await scheduleAt(
      id: id,
      title: channelName,
      body: channelDescription,
      time: DateTime.now().add(delay),
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      payload: payload,
    );
  }

  Future<List<PendingNotificationRequest>> getPending() =>
      _plugin.pendingNotificationRequests();

  Future<void> cancel(int id) => _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
