import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:get/get.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';

enum Mode { create, update, delete }

class AdminPushNotificationScreen extends StatefulWidget {
  @override
  _AdminPushNotificationScreenState createState() =>
      _AdminPushNotificationScreenState();
}

class _AdminPushNotificationScreenState
    extends State<AdminPushNotificationScreen> {
  final user = Get.find<UserController>();

  final db = FirebaseFirestore.instance;
  CollectionReference categories;

  final topicController = TextEditingController(text: 'allTopic');
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  Mode mode = Mode.create;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Push Notification'),
      ),
      body: Container(
        padding: EdgeInsets.all(Space.pageWrap),
        child: user.isAdmin
            ? Container(
                child: Column(children: [
                  Text('Send notification via Topic!'),
                  TextFormField(
                    key: ValueKey('topic'),
                    controller: topicController,
                    decoration: InputDecoration(labelText: "Topic"),
                  ),
                  TextFormField(
                    key: ValueKey('title'),
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Title"),
                  ),
                  TextFormField(
                    key: ValueKey('body'),
                    controller: bodyController,
                    decoration: InputDecoration(labelText: "Body"),
                  ),
                  RaisedButton(
                    child: Text("Submit"),
                    onPressed: () async {
                      /// send notification here
                      Service().sendNotification(
                        titleController.text,
                        bodyController.text,
                        topic: topicController.text,
                      );
                    },
                  )
                ]),
              )
            : Text('You are not admin!'),
      ),
    );
  }
}
