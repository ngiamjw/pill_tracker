import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pill_tracker/api/firebase_api.dart';
import 'package:pill_tracker/auth/auth.dart';
import 'package:pill_tracker/auth/login_or_register.dart';
import 'package:pill_tracker/classes/global_variables.dart';
import 'package:pill_tracker/firebase_options.dart';
import 'package:pill_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import "package:pill_tracker/services/light_storage.dart";

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize Firebase in background task
    await Firebase.initializeApp();

    // Firestore check
    bool conditionNotMet = await checkConditionInFirestore();

    if (conditionNotMet) {
      showNotification();
    }
    return Future.value(true);
  });
}

Future<bool> checkConditionInFirestore() async {
  // Fetch data from Firestore and check your condition here

  String? email = await getEmail();
  final snapshot =
      await FirebaseFirestore.instance.collection('users').doc(email!).get();

  // Replace with your actual condition
  return snapshot.exists && snapshot.data()?['yourField'] == false;
}

void showNotification() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'general_channel', // Channel ID
    'General Notifications', // Channel name
    importance: Importance.max,
    priority: Priority.high,
    icon: 'ic_notification',
  );

  const DarwinNotificationDetails iosPlatformChannelSpecifics =
      DarwinNotificationDetails();

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iosPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    'New Message',
    'Notification Body',
    platformChannelSpecifics,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotification();
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(AndroidNotificationChannel(
  //       'general_channel',
  //       'General Notifications',
  //     ));

  // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  // Workmanager().registerPeriodicTask(
  //   'checkFirestoreTask',
  //   'checkFirestoreTask',
  //   frequency: Duration(hours: 4),
  // );
  showNotification();
  runApp(MultiProvider(providers: [
    //theme provider
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
    ChangeNotifierProvider(create: (context) => CounterModel())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: AuthPage());
  }
}
