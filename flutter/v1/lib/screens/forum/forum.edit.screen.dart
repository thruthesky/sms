import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/confirm-dialog.dart';
import 'package:v1/widgets/commons/photo-picker-bottom-sheet.dart';
import 'package:v1/widgets/forum/file.display.dart';

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

  List<dynamic> files = [];
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
      files = post['files'] ?? [];
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
                decoration: InputDecoration(hintText: 'title'.tr),
              ),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(hintText: 'content'.tr),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () async {
                      try {
                        ImageSource source = await Get.bottomSheet(
                          PhotoPickerBottomSheet(),
                          backgroundColor: Colors.white,
                        );
                        if (source == null) return null;
                        final url = await ff.uploadFile(
                          folder: 'forum-photos',
                          source: source,
                          progress: (p) => setState(() => uploadProgress = p),
                        );

                        files.add(url);
                        setState(() => uploadProgress = 0);
                      } catch (e) {
                        Service.error(e);
                      }
                    },
                  ),
                  Expanded(
                    child: uploadProgress != 0
                        ? LinearProgressIndicator(
                            value: uploadProgress,
                          )
                        : SizedBox.shrink(),
                  ),
                  SizedBox(width: Space.md),
                  RaisedButton(
                    onPressed: () async {
                      try {
                        await ff.editPost({
                          'id': post == null ? null : post['id'],
                          'category': category,
                          'title': titleController.text,
                          'content': contentController.text,
                          'uid': userController.uid,
                          'files': files
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
              FileDisplay(files, inEdit: true)
            ],
          ),
        ),
      ),
    );
  }
}
