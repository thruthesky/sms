import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';

class ForumEditScreen extends StatefulWidget {
  @override
  _ForumEditScreenState createState() => _ForumEditScreenState();
}

class _ForumEditScreenState extends State<ForumEditScreen> {
  final UserController userController = Get.find<UserController>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final CollectionReference colPosts =
      FirebaseFirestore.instance.collection('posts');

  String category;
  dynamic post;

  @override
  void initState() {
    super.initState();
    category = Get.arguments['category'];
    post = Get.arguments['post'];
    print('post');
    print(post);

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
                  await ff.editPost({
                    'id': post == null ? null : post['id'],
                    'category': category,
                    'title': titleController.text,
                    'content': contentController.text,
                    'uid': userController.uid
                  });
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
