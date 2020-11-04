import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route_names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/confirm_dialog.dart';
import 'package:v1/widgets/forum/comment.edit.form.dart';
import 'package:v1/widgets/forum/comment_list.dart';
import 'package:v1/widgets/forum/file.display.dart';
import 'package:v1/widgets/forum/vote_button.dart';

class Post extends StatefulWidget {
  final dynamic post;

  Post({
    this.post,
    Key key,
  }) : super(key: key);

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  bool showContent = true;

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      margin: EdgeInsets.all(Space.pageWrap),
      padding: EdgeInsets.all(Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            child: Row(
              children: [
                if (ff.isAdmin) ...[
                  IconButton(
                    icon: Icon(Icons.online_prediction),
                    onPressed: () {
                      Get.toNamed(RouteNames.adminPushNotification,
                          arguments: {'id': widget.post['id']});
                    },
                  )
                ],
                Expanded(
                  child: Text(
                    widget.post['title'],
                    style: TextStyle(fontSize: Space.xl),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            onTap: () => setState(() {
              showContent = !showContent;
            }),
          ),
          if (showContent) ...[
            /// content
            if (widget.post['content'] != null)
              Padding(
                child: Text(
                  widget.post['content'],
                  style: TextStyle(fontSize: Space.lg),
                ),
                padding: EdgeInsets.only(top: Space.md),
              ),

            /// Files display
            FileDisplay(widget.post['files']),

            /// buttons
            Row(
              children: [
                /// TODO when `setState` is being called, it will redraw post and its comments.
                /// If the two `VoteButton` goes into a separate widget, it won't draw its whole post.
                VoteButton(
                    post: widget.post,
                    choice: VoteChoice.like,
                    state: setState),
                VoteButton(
                    post: widget.post,
                    choice: VoteChoice.dislike,
                    padding: EdgeInsets.only(left: 2),
                    state: setState),
                if (Service.isMine(widget.post)) ...[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => Get.toNamed(
                      RouteNames.forumEdit,
                      arguments: {'post': widget.post},
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool confirm = await Get.dialog(
                        ConfirmDialog(title: 'Delete Post?'.tr),
                      );

                      if (confirm == null || !confirm) return;
                      try {
                        await ff.deletePost(widget.post['id']);
                      } catch (e) {
                        Service.error(e);
                      }
                    },
                  ),
                ]
              ],
            ),

            /// comment box
            CommentEditForm(post: widget.post),

            /// comment list
            CommentsList(post: widget.post),
          ],
        ],
      ),
    );
  }
}
