import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/route_manager.dart';
import 'package:v1/screens/home/home.screen.dart';
import 'package:v1/screens/login/login.screen.dart';
import 'package:v1/screens/register/register.screen.dart';
import 'package:v1/services/route-names.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize
      // This may cause `No Firebase App has been created` since it is asyncronously initialized.
      await Firebase.initializeApp();
      print("App is connected to Firebase!");
      // setState(() {}); // App is connected to Firebase. App can do something by re-rendering.
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      // setState(() {});
      print("Error: failed to connect to Firebase!");
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SMS Version 1',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: RouteNames.register,
      getPages: [
        GetPage(name: RouteNames.home, page: () => HomeScreen()),
        GetPage(name: RouteNames.login, page: () => LoginScreen()),
        GetPage(name: RouteNames.register, page: () => RegisterScreen()),
      ],
    );
  }
}
