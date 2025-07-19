import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ex_date/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

FirebaseMessaging messaging = FirebaseMessaging.instance;

//Schedules notifications for items expiring in the next 7 days.
//only works when isOn is true, which can be adjusted according to user's need from toggling in the app
Future<void> scheduleNotification(bool isOn) async {
  //cancel all the available notifications if notifications are off from the app
  if (!isOn) {
    await flutterLocalNotificationsPlugin.cancelAll();
    return;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final itemsRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('items');
  final snapshot = await itemsRef.get();

  final now = DateTime.now();
  final next7Days = now.add(const Duration(days: 7));

  //traversing all the items from the list and checking if in the next 7 days they are going to expire
  for (final doc in snapshot.docs) {
    final data = doc.data();
    final expiryDate = DateTime.parse(data['expiryDate']);
    final itemName = data['name'];

    //if exp. date is between today and next7days then schedule the time to get notified
    if (expiryDate.isAfter(now) && expiryDate.isBefore(next7Days)) {
      //here, I have adjusted the time to be notified as 12:30 p.m.
      //this is so as whenever the items are added, by default the time(for both purchase and expiry) is considered as 00:00 (12 am)
      final scheduledTime =
          expiryDate.subtract(const Duration(hours: 11, minutes: 30));

      //if the scheduled time has been passed, do nothing and continue
      if (scheduledTime.isBefore(now)) continue;

      //otherwise, schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        doc.id.hashCode, //id
        'Expiry Reminder', //title
        '$itemName is expiring soon!', //body
        //constructs a new date time instance from given date in the specified location
        tz.TZDateTime.from(scheduledTime, tz.local), //schedule date
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'expiry_channel', //channel id
            'Expiry Notifications', //channel name
            channelDescription: 'Reminders for expiring items',
            icon: 'logo',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        //notification is shown at roughly specified time and will execute even when device is in low power idle mode
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        //schedules notification at date&time relative to a specific time zone
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,//date is interpreted as absolute GMT time
        //schedule a recurring notification if specified date&time matches
        matchDateTimeComponents: DateTimeComponents.time, //daily notification at same time
      );
    }
  }
}

/// Sets up foreground/background push notification behavior.
Future<void> setupPushNotifications() async {
  await messaging.requestPermission();

  String? token = await messaging.getToken();
  if (kDebugMode) {
    print("FCM Token: $token");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message: ${message.notification?.title}');
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if(kDebugMode){
      print("Notification opened from background");
    }
  });

  await _setupFcmNotificationSettings();
}

///jab app foreground mein ho tab hi notifications are allowed
Future<void> _setupFcmNotificationSettings() async {
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    sound: true,
    badge: true,
  );
}
