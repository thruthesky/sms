import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/route_names.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
      ),
      body: Container(
        child: Column(
          children: [
            RaisedButton(
              onPressed: () => Get.toNamed(RouteNames.adminCategory),
              child: Text('Category'),
            ),
            RaisedButton(
              onPressed: () => Get.toNamed(RouteNames.adminPushNotification),
              child: Text('Push Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
