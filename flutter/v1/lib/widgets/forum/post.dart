import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
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
  final UserController userController = Get.find();
  final firestoreInstance = FirebaseFirestore.instance;

  StreamSubscription voteRefSubscription;

  @override
  dispose() {
    voteRefSubscription.cancel();
    super.dispose();
  }

  onVoteTap(String choice) async {
    print('onVoteTap::choice => $choice');
    String docID = widget.post.id + '-' + userController.uid;

    /// vote document reference from the `likes` collection
    DocumentReference voteRef = firestoreInstance.doc('likes/$docID');
    DocumentSnapshot docSnapshot = await voteRef.get();
    Map<String, dynamic> docData = docSnapshot.data();

    /// TODO: Vote document set/update/delete
    ///
    /// Scenario:
    /// 3. CREATE if the document DO NOT exists.
    /// 2. UPDATE if the document exists but the choice is NOT the same.
    /// 1. DELETE if the document exists and the choice is the same, .
    if (!docData.isNull && docData['vote'] == choice) {
      print('delete');
      voteRef.delete();
    } else {
      print('create/update');
      voteRef.set({
        'uid': userController.uid,
        'id': widget.post.id,
        'vote': choice,
      });
    }

    /// TODO: updating like and dislike property of post document.
    voteRefSubscription = voteRef.snapshots().listen((snapshot) async {
      Map<String, dynamic> data = {
        'uid': widget.post.uid,
        'like': widget.post.like,
        'dislike': widget.post.dislike,
      };

      /// if not null, then the user may have just voted or changed their choice.
      ///
      /// TODO: determine if the user just voted or they changed their choice.
      if (!snapshot.isNull) {
        data[choice]++;

        /// if docData is not null, it contains the previous choice of the user's vote.
        /// meaning the user is changing their vote choice.
        if (!docData.isNull) {
          data[docData['vote']]--;
        }
      }

      /// if null then the user have chosen a vote already and then remove their choice.
      else {
        data[choice]--;
      }

      /// TODO: make sure to update have permission to update the post's data.
      /// NOTE: This is not working with error: `cloud_firestore/permission-denied`
      /// Firestore security rules must be considered.
      // firestoreInstance.doc('posts/${widget.post.id}').set(
      //       data,
      //       SetOptions(merge: true),
      //     );
    });
  }

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
                onPressed: () => onVoteTap('like'),
              ),
              Text(widget.post.like.toString()),
              IconButton(
                icon: Icon(Icons.thumb_down),
                onPressed: () => onVoteTap('dislike'),
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
                      firestoreInstance.doc('posts/${widget.post.id}').delete();
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
