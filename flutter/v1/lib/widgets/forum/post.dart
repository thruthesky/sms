import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/models.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/confirm-dialog.dart';

class Post extends StatefulWidget {
  final PostModel post;

  Post({this.post});

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  final CollectionReference colPosts =
      FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      margin: EdgeInsets.all(Space.pageWrap),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(Space.md),
            title: Text(
              widget.post.title,
              style: TextStyle(fontSize: Space.xl),
            ),
            subtitle: Text(
              widget.post.content,
              style: TextStyle(fontSize: Space.lg),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up),
                onPressed: () {
                  print('like');
                },
              ),
              Text(widget.post.like.toString()),
              IconButton(
                icon: Icon(Icons.thumb_down),
                onPressed: () {
                  print('dislike');
                },
              ),
              Text(widget.post.dislike.toString()),
              if (Service.isMyPost(widget.post)) ...[
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

                    if (confirm != null && confirm) {
                      colPosts.doc(widget.post.id).delete();
                    }
                  },
                ),
              ]
            ],
          )
        ],
      ),
    );
  }
}
