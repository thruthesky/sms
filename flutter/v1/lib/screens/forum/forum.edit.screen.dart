import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';

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

  double uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    category = Get.arguments['category'];
    post = Get.arguments['post'];

    if (post != null) {
      titleController.text = post['title'];
      contentController.text = post['content'];
      category = post['category'];
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Space.pageWrap),
          child: Column(
            children: [
              TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: 'title'.tr)),
              TextFormField(
                  controller: contentController,
                  decoration: InputDecoration(hintText: 'content'.tr)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () async {
                      // try {
                      //   File file = await Service.pickImage(
                      //     maxWidth: Space.xxxl,
                      //   );

                      //   if (file == null) return;
                      //   // print('success: file picked: ${file.path}');

                      //   /// upload picked file,
                      //   final url = await ff.uploadFile(
                      //     collection: 'forum-images',
                      //     file: file,

                      //     /// upload progress
                      //     progress: (p) => setState(
                      //       () {
                      //         this.uploadProgress = p;
                      //       },
                      //     ),
                      //   );

                      /// TODO: add images to post `files` collection.
                      ///  how?
                      ///     option 1: everytime user pick an image, we connect to database and update the collection.
                      ///           - Problem is when the post is not yet created. we don't have a reference to a post document.
                      ///             this may only work on updating a post.
                      ///
                      ///     option 2: inside ff.editPost() function, after creating a post, we update the `files` collection with files.
                      ///           - Side effect: since the app is listening for collection changes on posts collection,
                      ///             `modified` event will be fired for each file we add to post's `files` collection.
                      ///
                      ///     option 3: `files` is a text-based instead of collection where we save file URLs as string seperated with comma.
                      ///
                      ///     other options .... nothing comes to mind yet.

                      // } catch (e) {
                      //   Service.error(e);
                      // }
                    },
                  ),
                  Spacer(),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
