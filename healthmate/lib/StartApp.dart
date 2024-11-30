import 'package:flutter/material.dart';

import 'LoginPage.dart';

class StartApp extends StatelessWidget {
  const StartApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
