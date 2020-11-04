import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/services/route_names.dart';

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

  List<Map<String, dynamic>> categoryName = [
    {'name': 'All Topic', 'code': 'allTopic'}
  ];
  String selectedItem = 'allTopic';

  Map<String, dynamic> post;
  String id;

  @override
  void initState() {
    id = Get.arguments['id'];

    ff.postDocument(id).get().then((docSnapshot) {
      if (!docSnapshot.exists) return false;
      post = docSnapshot.data();
      titleController.text = post['title'];
      bodyController.text = post['content'];
      setState(() {});
    });

    categories = db.collection('categories');
    categories.snapshots().listen((QuerySnapshot snapshot) {
      if (snapshot.size == 0) return;
      snapshot.docs.forEach((DocumentSnapshot document) {
        final data = document.data();
        categoryName.add(
            {'name': data['id'], 'code': 'notification_post_' + data['id']});
      });
      setState(() {});
    });
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
            ? SingleChildScrollView(
                child: Container(
                  child: Column(children: [
                    Text('Send notification via Topic!'),
                    Row(
                      children: [
                        Text('Topic'),
                        SizedBox(
                          width: Space.lg,
                        ),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedItem,
                            onChanged: (String string) =>
                                setState(() => selectedItem = string),
                            items:
                                categoryName.map((Map<String, dynamic> item) {
                              return DropdownMenuItem<String>(
                                child: Text(item['name']),
                                value: item['code'],
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                    id != null ? Text('Post ID #' + id) : Container(),
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
                        ff.sendNotification(
                            titleController.text, bodyController.text,
                            topic: selectedItem,
                            id: id ?? '',
                            screen: id != null ? RouteNames.forumView : '');
                      },
                    )
                  ]),
                ),
              )
            : Text('You are not admin!'),
      ),
    );
  }
}
