import 'package:firebase_auth/firebase_auth.dart';
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
          GetBuilder<UserController>(builder: (user) {
            // print('user:');
            // print(userController.user);
            return Column(
              children: [
                Text("UserName: ${user.uid}"),
                if (user.isNotLoggedIn) ...[
                  RaisedButton(
                    onPressed: () => Get.toNamed(RouteNames.login),
                    child: Text('Login'),
                  ),
                  RaisedButton(
                    onPressed: () => Get.toNamed(RouteNames.register),
                    child: Text('Register'),
                  ),
                ],
                if (user.isLoggedIn) ...[
                  RaisedButton(
                    onPressed: () => Get.toNamed(RouteNames.profile),
                    child: Text('Profile'),
                  ),
                  RaisedButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: Text('Logout'),
                  ),
                ]
              ],
            );
          }),
        ],
      ),
    );
  }
}
