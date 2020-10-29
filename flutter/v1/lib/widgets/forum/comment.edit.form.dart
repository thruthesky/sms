import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';

/// [post] is required
/// [commentIndex] is optional and used only when creating a new comment.
/// [comment] is optional and used only when updatedin a comment.
class CommentEditForm extends StatefulWidget {
  const CommentEditForm({
    @required this.post,
    this.commentIndex,
    this.comment,
    this.showCancelButton = false,
    this.onCancel,
    this.onSuccess,
    Key key,
  }) : super(key: key);

  final dynamic post;
  final dynamic comment;
  final int commentIndex;
  final bool showCancelButton;

  final Function onCancel;
  final Function onSuccess;

  @override
  _CommentEditFormState createState() => _CommentEditFormState();
}

class _CommentEditFormState extends State<CommentEditForm> {
  final contentController = TextEditingController();

  @override
  initState() {
    /// NOTE: this will not work.
    // if (widget.comment != null) {
    //   contentController.text = widget.comment['content'];
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// TODO: remove this from here.
    /// find another way to make it work.
    if (widget.comment != null) {
      contentController.text = widget.comment['content'];
    }

    return Column(
      children: [
        TextFormField(
          controller: contentController,
          decoration: InputDecoration(hintText: 'input comment'.tr),
        ),
        Row(
          children: [
            if (widget.showCancelButton) ...[
              RaisedButton(
                onPressed: () {
                  if (widget.onCancel != null) widget.onCancel();
                },
                child: Text('cancel'),
              )
            ],
            Spacer(),
            RaisedButton(
              onPressed: () async {
                if (contentController.text.trim().length == 0) return;

                final data = {
                  'post': widget.post,
                  'content': contentController.text,
                };

                if (widget.comment != null) {
                  data['id'] = widget.comment['id'];
                  data['depth'] = widget.comment['depth'];
                  data['order'] = widget.comment['order'];
                } else {
                  data['parentIndex'] = widget.commentIndex;
                }

                try {
                  await ff.editComment(data);
                  if (widget.onSuccess != null) widget.onSuccess();
                  contentController.text = '';
                } catch (e) {
                  print(e);
                  Service.error(e);
                }
              },
              child: Text('submit'),
            )
          ],
        )
      ],
    );
  }
}
