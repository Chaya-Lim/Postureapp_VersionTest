import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_config.dart';
import 'home_page.dart';
import 'connect_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseConfig.webOptions,
  );

  final prefs = await SharedPreferences.getInstance();
  final savedDevice = prefs.getString("deviceName");

  runApp(MyApp(savedDevice: savedDevice));
}

class MyApp extends StatelessWidget {
  final String? savedDevice;

  const MyApp({super.key, this.savedDevice});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: savedDevice != null
          ? HomePage(deviceName: savedDevice!)
          : const ConnectPage(),
    );
  }
}