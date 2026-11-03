
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'due_date_reminders',
    'Due-date reminders',
    description: 'Reminders for debtor due dates',
    importance: Importance.high,
  );

  Future<void> init() async {
    tz.initializeTimeZones();
    final deviceTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTimezone.identifier));

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notifications.initialize(
      settings: initializationSettings,
    );
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<bool> requestPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await androidPlugin?.requestNotificationsPermission() ?? false;
  }

  Future<void> showTestNotification() async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'due_date_reminders',
        'Due-date reminders',
        channelDescription: 'Reminders for debtor due dates',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      id: 0,
      title: 'DebtorTrack',
      body: 'Notifications are working.',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> scheduleDueDateReminder({
    required int id,
    required String debtorName,
    required DateTime dueDate,
  }) async {
   final now = tz.TZDateTime.now(tz.local);

final dueAtNine = tz.TZDateTime(
  tz.local,
  dueDate.year,
  dueDate.month,
  dueDate.day,
  9,
);

// Keeps sending the user a reminder
final scheduledDate = dueAtNine.isAfter(now)
    ? dueAtNine
    : tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        9,
      );


    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'due_date_reminders',
        'Due-date reminders',
        channelDescription: 'Reminders for debtor due dates',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.zonedSchedule(
      id: id,
      title: 'Payment due today',
      body: '$debtorName still has an unpaid debt. Send a reminder.',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDueDateReminder(int id) => _notifications.cancel(id: id);
}
