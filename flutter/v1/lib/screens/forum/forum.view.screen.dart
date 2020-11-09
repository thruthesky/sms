import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/widgets/forum/post.dart';

class ForumViewScreen extends StatefulWidget {
  @override
  _ForumViewScreenState createState() => _ForumViewScreenState();
}

class _ForumViewScreenState extends State<ForumViewScreen> {
  Map<String, dynamic> post;

  @override
  void initState() {
    super.initState();
    String id = Get.arguments['id'];

    ff.postDocument(id).get().then((docSnapshot) {
      if (!docSnapshot.exists) return false;
      post = docSnapshot.data();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post View Screen'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: post != null ? Post(post: post) : Container(),
        ),
      ),
    );
  }
}
