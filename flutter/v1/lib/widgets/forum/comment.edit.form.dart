import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';

class CommentEditForm extends StatefulWidget {
  const CommentEditForm({
    this.post,
    this.commentIndex,
    Key key,
  }) : super(key: key);

  final dynamic post;
  final int commentIndex;

  @override
  _CommentEditFormState createState() => _CommentEditFormState();
}

class _CommentEditFormState extends State<CommentEditForm> {
  final contentController = TextEditingController();

  @override
  initState() {
    super.initState();
  }

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
              await ff.editComment({
                'post': widget.post,
                'parentIndex': widget.commentIndex,
                'content': contentController.text
              });
            } catch (e) {
              print(e);
              Service.error(e);
            }
          },
          child: Text('submit'),
        )
      ],
    );
  }
}
