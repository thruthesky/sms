import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/confirm-dialog.dart';
import 'package:v1/widgets/forum/comment.edit.form.dart';
import 'package:v1/widgets/forum/file.display.dart';

class CommentsList extends StatefulWidget {
  final dynamic post;
  CommentsList({this.post});
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<CommentsList> {
  @override
  void initState() {
    if (widget.post['comments'] == null) {
      widget.post['comments'] = [];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.post['comments'].length > 0
        ? Column(
            children: [
              for (int i = 0; i < widget.post['comments'].length; i++)
                Comment(
                  key: ValueKey(widget.post['comments'][i]['id']),
                  post: widget.post,
                  commentIndex: i,
                  comment: widget.post['comments'][i],
                ),
            ],
          )
        : Padding(
            padding: EdgeInsets.all(Space.md),
            child: Text('No comments yet..'),
          );
    ;
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
              children: inEdit

                  /// show when in edit mode
                  ? [
                      CommentEditForm(
                        key: ValueKey(widget.post['id'] + widget.comment['id']),
                        post: widget.post,
                        comment: widget.comment,
                        showCancelButton: true,
                        onCancel: () => setState(() => inEdit = false),
                        onSuccess: () => setState(() => inEdit = false),
                      ),
                    ]

                  /// show when NOT in edit mode
                  : [
                      /// content
                      Text("${widget.comment['content']}"),

                      /// files display
                      FileDisplay(widget.comment['files']),
                      Divider(),

                      /// buttons
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

                      /// reply box
                      CommentEditForm(
                        post: widget.post,
                        parentIndex: widget.commentIndex,
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
