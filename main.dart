import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:pill_tracker/api/firebase_api.dart';
import 'package:pill_tracker/auth/auth.dart';
import 'package:pill_tracker/auth/login_or_register.dart';
import 'package:pill_tracker/classes/global_variables.dart';
import 'package:pill_tracker/components/camera.dart';
import 'package:pill_tracker/firebase_options.dart';
import 'package:pill_tracker/pages/choice_page.dart';
import 'package:pill_tracker/pages/home_page.dart';
import 'package:pill_tracker/pages/info_page.dart';
import 'package:pill_tracker/pages/login_page.dart';
import 'package:pill_tracker/pages/monitor_page.dart';
import 'package:pill_tracker/pages/notification_page.dart';
import 'package:pill_tracker/pages/opening_screen.dart';
import 'package:pill_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotification();
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
        home: HomePage(email: 'ngiamjw@gmail.com'));
  }
}
