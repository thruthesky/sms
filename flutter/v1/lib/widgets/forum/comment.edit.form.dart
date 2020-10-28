
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/functions.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/models.dart';
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
  final user = Get.find<UserController>();

  dynamic parent;

  @override
  initState() {
    super.initState();
  }

  /// Returns the order string of the new comment
  ///
  /// @TODO: Move this method to `functions.dart`.
  ///
  getCommentOrderOf() {
    /// If it is the first depth of child.
    if (parent == null) {
      return getCommentOrder(
          order: widget.post['comments'].length > 0
              ? widget.post['comments'].last.order
              : null);
    }

    int depth = parent['depth'];
    String depthOrder = parent['order'].split('.')[depth];
    print('depthOrder: $depthOrder');

    int i;
    for (i = widget.commentIndex + 1; i < widget.post['comments'].length; i++) {
      dynamic c = widget.post['comments'][i];
      String findOrder = c['order'].split('.')[depth];
      if (depthOrder != findOrder) break;
    }

    final previousSiblingComment = widget.post['comments'][i - 1];
    print(
        'previousSiblingComment: ${previousSiblingComment['content']}, ${previousSiblingComment['order']}');
    return getCommentOrder(
      order: previousSiblingComment['order'],
      depth: parent['depth'] + 1,
      // previousSiblingComment.depth + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.commentIndex != null)
      parent = widget.post['comments'][widget.commentIndex];
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
              final commentCol = commentsCollection(widget.post['id']);
              print('ref.path: ' + commentCol.path.toString());
              String order = getCommentOrderOf();
              final data = {
                'uid': user.uid,
                'content': contentController.text,

                /// depth comes from parent.
                /// order comes from
                ///   - parent if there is no child of the parent.
                /// 	- last comment of siblings.

                'depth': parent != null ? parent['depth'] + 1 : 0,
                'order': order,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              };
              print(data);
              await commentCol.add(data);

              /// Comment is created by this time.
              ///
              ///
              List<String> uids = [];

              final CollectionReference colUsers =
                  FirebaseFirestore.instance.collection('users');

              // check post owner if he want to receive notification
              final docSnapshot = await colUsers
                  .doc(widget.post.uid)
                  .collection('meta')
                  .doc('public')
                  .get();

              Map<String, dynamic> postOwnerPublic = docSnapshot.data();
              if (!postOwnerPublic.isNull &&
                  postOwnerPublic['notifyPost'] == true) {
                uids.add(widget.post['uid']);
              }

              // get ancestors uid
              List<CommentModel> ancestors = getAncestors(
                widget.post['comments'],
                order,
              );

              // print('ancestors:');
              // print(ancestors);
              if (ancestors.isNotEmpty) {
                print('ancestors:before loop');
                for (dynamic c in ancestors) {
                  final docSnapshot = await colUsers
                      .doc(c.uid)
                      .collection('meta')
                      .doc('public')
                      .get();
                  Map<String, dynamic> ancestorDoc = docSnapshot.data();

                  if (ancestorDoc.isNull) continue;
                  if (ancestorDoc[
                              'notification_comment_' + widget.post['category']] !=
                          true &&
                      ancestorDoc['notifyComment'] == true) {
                    uids.add(c['uid']);
                  }
                }
                uids = uids.toSet().toList();
              }

              print(uids);
              List<String> tokens = [];
              for (var uid in uids) {
                final docSnapshot = await colUsers
                    .doc(uid)
                    .collection('meta')
                    .doc('tokens')
                    .get();
                Map<String, dynamic> tokensDoc = docSnapshot.data();
                if (tokensDoc.isNull) continue;
                for (var token in tokensDoc.keys) {
                  print(token);
                  tokens.add(token);
                }
              }

              print('tokens');
              print(tokens);

              // print(uids);

              // send notification with tokens and topic.
              ff.sendNotification(
                widget.post['title'],
                contentController.text,
                route: widget.post['category'],
                topic: "notification_comment_" + widget.post['category'],
                tokens: uids,
              );
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
