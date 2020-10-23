
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/functions.dart';
import 'package:v1/services/models.dart';
import 'package:v1/services/service.dart';

class CommentEditForm extends StatefulWidget {
  const CommentEditForm({
    this.post,
    Key key,
  }) : super(key: key);

  final PostModel post;

  @override
  _CommentEditFormState createState() => _CommentEditFormState();
}

class _CommentEditFormState extends State<CommentEditForm> {
  final contentController = TextEditingController();
  final user = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: contentController,
          decoration: InputDecoration(hintText: 'input comment'.tr),
        ),
        RaisedButton(
          onPressed: () async {
            try {
              // final postDoc = postDocument(widget.post.id);
              final commentCol = commentsCollection(widget.post.id);
              print('ref.path: ' + commentCol.path.toString());
              final data = {
                'uid': user.uid,
                'content': contentController.text,
                'order': '00001.001.000.000.000.000.000.000.000.000.000.000',
                'depth': 0,
              };
              print(data);
              await commentCol.add(data);
            } catch (e) {
              Service.error(e);
            }
          },
          child: Text('submit'),
        )
      ],
    );
  }
}
