import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'StartApp.dart';
import 'package:provider/provider.dart';
import 'shared_data.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); 

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: 'AIzaSyCKuB8fG5bCvxCW-6vI3Ka8uwAqCrWTszE',
    appId: '1:53675007158:android:9176e63fd4b1cf95d39a17',
    messagingSenderId: '53675007158',
    projectId: 'healthmate-efd14',
    storageBucket: 'healthmate-efd14.appspot.com',
  ));
  runApp(
      ChangeNotifierProvider(
          create: (context) => SharedData(),
      child: const StartApp()
      ),
  );
}

