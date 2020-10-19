import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/route-names.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

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
          ),
          RaisedButton(
            onPressed: () => Get.toNamed(RouteNames.register),
            child: Text('Register'),
          ),
          GetBuilder<UserController>(builder: (userController) {
            print('user:');
            print(userController.user);
            return Text("UserName: ${userController.user?.uid}");
          }),
        ],
      ),
    );
  }
}
