import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:v1/controllers/user.controller.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final user = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin screen'),
      ),
      body: Container(
        child: Column(
          children: [
            Text('Are you admin?'),
            GetBuilder<UserController>(builder: (_) {
              return Text(user.isAdmin ? 'yes' : 'no');
            })
          ],
        ),
      ),
    );
  }
}
