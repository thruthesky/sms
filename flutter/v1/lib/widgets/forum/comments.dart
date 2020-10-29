import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/confirm-dialog.dart';
import 'package:v1/widgets/forum/comment.edit.form.dart';
import 'package:v1/widgets/forum/file.display.dart';

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
                Comment(
                    post: widget.post,
                    commentIndex: i,
                    comment: widget.post['comments'][i]),
            ],
          )
        : SizedBox.shrink();
  }
}

class Comment extends StatefulWidget {
  final dynamic post;
  final dynamic comment;
  final int commentIndex;
  Comment({
    this.post,
    this.comment,
    this.commentIndex,
    Key key,
  }) : super(key: key);

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool inEdit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: Space.md * widget.comment['depth'],
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
              children: !inEdit
                  ? [
                      Text("${widget.comment['content']}"),
                      SizedBox(height: Space.md),
                      FileDisplay(widget.comment['files']),
                      Divider(),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.thumb_up),
                            onPressed: () {
                              print('VOTE : like');
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.thumb_down),
                            onPressed: () {
                              print('VOTE : like');
                            },
                          ),
                          if (Service.isMine(widget.comment)) ...[
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

                                if (confirm == null || !confirm) return;

                                try {
                                  await ff.deleteComment(
                                    widget.post['id'],
                                    widget.comment['id'],
                                  );
                                } catch (e) {
                                  Service.error(e);
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
                    ]
                  : [
                      CommentEditForm(
                        key: ValueKey(widget.post['id'] + widget.comment['id']),
                        post: widget.post,
                        comment: widget.comment,
                        showCancelButton: true,
                        onCancel: () => setState(() => inEdit = false),
                        onSuccess: () => setState(() => inEdit = false),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
