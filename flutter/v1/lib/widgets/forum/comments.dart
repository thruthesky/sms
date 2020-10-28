import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/confirm-dialog.dart';
import 'package:v1/widgets/forum/comment.edit.form.dart';

class Comments extends StatefulWidget {
  Comments({
    this.post,
  });
  final dynamic post;
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    // print('-------------------- comments');
    return widget.post['comments'] != null
        ? Column(
            children: [
              for (int i = 0; i < widget.post['comments'].length; i++)
                Comment(post: widget.post, commentIndex: i),
            ],
          )
        : SizedBox.shrink();
  }
}

class Comment extends StatefulWidget {
  final dynamic post;
  final int commentIndex;
  Comment({
    this.post,
    this.commentIndex,
    Key key,
  }) : super(key: key);

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool inEdit = false;
  dynamic comment;

  @override
  void initState() {
    comment = widget.post['comments'][widget.commentIndex];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('${comment.order} ${comment.content}');
    return Container(
      margin: EdgeInsets.only(
        left: Space.md * comment['depth'],
        bottom: Space.md,
      ),
      padding: EdgeInsets.all(Space.md),
      color: Colors.grey[100],
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!inEdit) ...[
                  Text("${comment['content']}"),
                  Divider(),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: () {},
                      ),
                      if (widget.post['like'] != null)
                        Text(widget.post['like'].toString()),
                      IconButton(
                        icon: Icon(Icons.thumb_down),
                        onPressed: () {},
                      ),
                      if (widget.post['dislike'] != null)
                        Text(widget.post['dislike'].toString()),
                      if (Service.isMine(comment)) ...[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() => inEdit = true);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            bool confirm = await Get.dialog(
                              ConfirmDialog(title: 'Delete Comment?'.tr),
                            );

                            if (confirm != null && confirm) {
                              ff.deleteComment(
                                widget.post['id'],
                                comment['id'],
                              );
                            }
                          },
                        ),
                      ]
                    ],
                  ),
                  CommentEditForm(
                    post: widget.post,
                    commentIndex: widget.commentIndex,
                  ),
                ],
                if (inEdit) ...[
                  CommentEditForm(
                    post: widget.post,
                    comment: comment,
                    showCancelButton: true,
                    onCancel: () {
                      setState(() => inEdit = false);
                    },
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
