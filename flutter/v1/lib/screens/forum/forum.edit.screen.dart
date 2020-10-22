import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/functions.dart';
import 'package:v1/services/models.dart';
import 'package:v1/services/service.dart';

class ForumEditScreen extends StatefulWidget {
  @override
  _ForumEditScreenState createState() => _ForumEditScreenState();
}

class _ForumEditScreenState extends State<ForumEditScreen>
    with AfterLayoutMixin {
  final UserController userController = Get.find<UserController>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final CollectionReference colPosts =
      FirebaseFirestore.instance.collection('posts');

  String category;
  PostModel post;

  @override
  void afterFirstLayout(BuildContext context) {
    final args = routerArguments(context);
    category = args['category'];
    post = args['post'];
    if (post != null) {
      titleController.text = post.title;
      contentController.text = post.content;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
      ),
      body: Container(
        child: Column(
          children: [
            TextFormField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'title'.tr)),
            TextFormField(
                controller: contentController,
                decoration: InputDecoration(hintText: 'content'.tr)),
            RaisedButton(
              onPressed: () async {
                try {
                  final Map<String, dynamic> data = {
                    'category': category,
                    'title': titleController.text,
                    'content': contentController.text,
                    'uid': userController.uid
                  };

                  // print('data: ');
                  // print(data);
                  if (post != null) {
                    data['category'] = post.category;
                    data['updatedAt'] = FieldValue.serverTimestamp();
                    await colPosts
                        .doc(post.id)
                        .set(data, SetOptions(merge: true));
                  } else {
                    // TODO: Let user can change category by giving 'more popmenu option'.
                    data['createdAt'] = FieldValue.serverTimestamp();
                    data['updatedAt'] = FieldValue.serverTimestamp();
                    await colPosts.add(data);
                  }
                  Get.back();
                } catch (e) {
                  Service.error(e);
                }
              },
              child: Text('submit'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
