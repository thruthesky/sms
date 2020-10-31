import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/confirm-dialog.dart';
import 'package:v1/widgets/forum/comment.edit.form.dart';
import 'package:v1/widgets/forum/comment_list.dart';
import 'package:v1/widgets/forum/file.display.dart';

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
  final UserController userController = Get.find();

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
            child: Text(
              widget.post['title'],
              style: TextStyle(fontSize: Space.xl),
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
                if (ff.isShowForumVote(widget.post['category'], 'like')) ...[
                  TextButton(
                    child: Text('Likes ${widget.post['likes'] ?? 0}'),
                    onPressed: () async {
                      try {
                        await ff.likePost(widget.post['id']);
                      } catch (e) {
                        Service.error(e);
                      }
                    },
                  ),
                ],
                if (ff.isShowForumVote(widget.post['category'], 'dislike')) ...[
                  TextButton(
                    child: Text('Dislikes ${widget.post['dislikes'] ?? 0}'),
                    onPressed: () async {
                      try {
                        await ff.dislikePost(widget.post['id']);
                      } catch (e) {
                        Service.error(e);
                      }
                    },
                  ),
                ],
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
