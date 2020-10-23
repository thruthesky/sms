import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:v1/services/functions.dart';
import 'package:v1/services/models.dart';
import 'package:v1/services/spaces.dart';

class CommentList extends StatefulWidget {
  final PostModel post;
  CommentList({this.post});

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  CollectionReference commentCol;
  List<Map<String, dynamic>> comments = [];
  StreamSubscription subscription;
  bool loadingComments = false;

  @override
  void initState() {
    loadComments();
    super.initState();
  }

  @override
  void dispose() {
    if (subscription != null) subscription.cancel();
    super.dispose();
  }

  loadComments() {
    final commentCol = commentsCollection(widget.post.id);
    loadingComments = true;
    setState(() {});

    subscription = commentCol.snapshots().listen((QuerySnapshot snapshot) {
      snapshot.docChanges.forEach((change) {
        final data = change.doc.data();
        data['id'] = change.doc.id;

        if (change.type == DocumentChangeType.added) {
          comments.add(data);
        } else if (change.type == DocumentChangeType.modified) {
          // comment update
        } else if (change.type == DocumentChangeType.removed) {
          // comment delete
        }
      });
      setState(() => loadingComments = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loadingComments
          ? Text('loading comments...')
          : Column(
              children: [
                SizedBox(height: Space.md),
                for (var comment in comments)
                  Container(
                    color: Colors.grey[100],
                    margin: EdgeInsets.only(bottom: Space.md),
                    padding: EdgeInsets.all(Space.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment['content'],
                          style: TextStyle(fontSize: Space.lg),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.thumb_up),
                              onPressed: () {
                                print('comment vote');
                              },
                            ),
                            Text(widget.post.like.toString()),
                            IconButton(
                              icon: Icon(Icons.thumb_down),
                              onPressed: () {
                                print('comment vote');
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                print('comment edit');
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                print('comment delete');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
              ],
            ),
    );
  }
}
