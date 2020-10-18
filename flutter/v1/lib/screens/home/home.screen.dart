import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/RouteNames.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home screen'),
      ),
      body: Column(
        children: [
          Container(
            child: Text('Menus'),
          ),
          RaisedButton(
            onPressed: () => Get.toNamed(RouteNames.login),
            child: Text('Login'),
          )
        ],
      ),
    );
  }
}
