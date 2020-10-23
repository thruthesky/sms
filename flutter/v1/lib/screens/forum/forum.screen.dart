import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/functions.dart';
import 'package:v1/services/models.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/spinner.dart';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> with AfterLayoutMixin {
  final CollectionReference colPosts =
      FirebaseFirestore.instance.collection('posts');

  StreamSubscription subscription;

  String category;
  List<PostModel> posts = [];

  bool noPostsYet = false;
  bool noMorePost = false;
  bool inLoading = false;
  int pageNo = 0;

  // 무제한 스크롤은 ScrollController 로 감지하고
  // 스크롤이 맨 밑으로 될 때, Listener 핸들러를 실행한다.
  ScrollController scrollController =
      ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  @override
  void afterFirstLayout(BuildContext context) {
    final args = routerArguments(context);
    category = args['category'];
    // print('category ??: $category');

    /// Scroll event handler
    scrollController.addListener(() {
      // Check if the screen is scrolled to the bottom.
      var isEnd = scrollController.offset >
          (scrollController.position.maxScrollExtent - 200);
      // If yes, then get more posts.
      if (isEnd) fetchPosts();
    });

    /// fetch posts for the first time.
    fetchPosts();
  }

  @override
  dispose() {
    /// unsubscribe from the stream to avoid having memory leak..
    subscription.cancel();
    super.dispose();
  }

  fetchPosts() {
    if (inLoading || noMorePost) return;
    setState(() => inLoading = true);
    pageNo++;

    Query postsQuery = colPosts.where('category', isEqualTo: category);
    postsQuery = postsQuery.orderBy('createdAt', descending: true);
    postsQuery = postsQuery.limit(10);

    if (posts.isNotEmpty) {
      postsQuery = postsQuery.startAfter([posts.last.createdAt]);
    }

    subscription = postsQuery.snapshots().listen((QuerySnapshot snapshot) {
      // print('>> docChanges: ');
      if (snapshot.size > 0) {
        /// TODO: this produce `Unhandled Exception: Unimplemented handling of missing static target` exception seldomly.
        snapshot.docChanges.forEach((DocumentChange documentChange) {
          final data = documentChange.doc.data();
          data['id'] = documentChange.doc.id;
          final post = PostModel.fromDocument(data);

          // print('Post:');
          // print(post.toString());
          // print('Document change type:');
          // print(documentChange.type);

          if (documentChange.type == DocumentChangeType.added) {
            /// [createdAt] is null only on author's app since it is cached locally.
            /// `modified` event will be fired right after with proper timestamp.
            /// This will not be null on other's app and there will be no `modified` event on other's app.

            if (post.createdAt == null) {
              posts.insert(0, post);
            } else if (posts.isNotEmpty &&
                post.createdAt.nanoseconds > posts[0].createdAt.nanoseconds) {
              posts.insert(0, post);
            } else {
              posts.add(post);
            }

            // if (post.createdAt != null) {
            //   print('Crated AT: ${post.createdAt}');
            //   posts.add(post);
            // }

            inLoading = false;
          } else if (documentChange.type == DocumentChangeType.modified) {
            final int i = posts.indexWhere((p) => p.id == post.id);
            if (i > 0) {
              posts[i] = post;
            }

            // if (i != -1) {
            //   print('A document is updated:');
            //   posts[i] = post;
            // } else {
            //   print('A new document is added on top:');
            //   if (posts.first.createdAt.seconds < post.createdAt.seconds) {
            //     posts.insert(0, post);
            //   }
            // }

          } else if (documentChange.type == DocumentChangeType.removed) {
            print('Removing post');
            posts.removeWhere((p) => p.id == post.id);
          }
        });
        setState(() {});
      } else {
        if (pageNo == 1) {
          noPostsYet = true;
        } else {
          noMorePost = true;
        }

        inLoading = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Get.toNamed(
              RouteNames.forumEdit,
              arguments: {'category': category},
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Container(
          child: Column(
            children: [
              RaisedButton(
                  onPressed: () => Get.toNamed(RouteNames.forumEdit,
                      arguments: {'category': category}),
                  child: Text('Create')),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: posts.length,
                itemBuilder: (c, i) {
                  final post = posts[i];

                  return Container(
                    margin: EdgeInsets.all(Space.pageWrap),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.grey[300],
                          padding: EdgeInsets.all(Space.md),
                          child: ListTile(
                            title: Text(
                              post.title,
                              style: TextStyle(fontSize: Space.xl),
                            ),
                            subtitle: Text(
                              post.content,
                              style: TextStyle(fontSize: Space.lg),
                            ),
                            trailing: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => Get.toNamed(
                                    RouteNames.forumEdit,
                                    arguments: {'post': post})),
                          ),
                        ),
                        Row(
                          children: [
                            RaisedButton(
                              onPressed: () {},
                              child: Text('edit'),
                            ),
                            RaisedButton(
                              onPressed: () {},
                              child: Text('delete'),
                            ),
                            RaisedButton(
                              onPressed: () {},
                              child: Text('like'),
                            ),
                            RaisedButton(
                              onPressed: () {},
                              child: Text('dislike'),
                            ),
                          ],
                        ),
                        CommentEditForm(post: post),
                      ],
                    ),
                  );
                },
              ),
              if (inLoading)
                Padding(
                  padding: EdgeInsets.all(Space.md),
                  child: CommonSpinner(),
                ),
              if (noMorePost)
                Padding(
                  padding: EdgeInsets.all(Space.md),
                  child: Text('No more posts..'),
                ),
              if (noPostsYet)
                Padding(
                  padding: EdgeInsets.all(Space.md),
                  child: Text('No posts yet..'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentEditForm extends StatefulWidget {
  const CommentEditForm({
    this.post,
    Key key,
  }) : super(key: key);

  final PostModel post;

  @override
  _CommentEditFormState createState() => _CommentEditFormState();
}

class _CommentEditFormState extends State<CommentEditForm> {
  final contentController = TextEditingController();
  final user = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
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
              final commentCol = commentsCollection(widget.post.id);
              print('ref.path: ' + commentCol.path.toString());
              final data = {
                'uid': user.uid,
                'content': contentController.text,
                'order': getCommentOrder(),
                'depth': 0,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              };
              print(data);
              await commentCol.add(data);
            } catch (e) {
              Service.error(e);
            }
          },
          child: Text('submit'),
        )
      ],
    );
  }
}
