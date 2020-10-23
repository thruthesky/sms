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

  bool notification = false;

  // 무제한 스크롤은 ScrollController 로 감지하고
  // 스크롤이 맨 밑으로 될 때, Listener 핸들러를 실행한다.
  ScrollController scrollController =
      ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  @override
  void afterFirstLayout(BuildContext context) async {
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

    if (Service.userController.isLoggedIn) {
      Service.usersRef.doc(Service.userController.user.uid).get().then(
        (DocumentSnapshot doc) {
          if (!doc.exists) {
            // It's not an error. User may not have documentation. see README
            print('User has no document. fine.');
            return;
          }
          final data = doc.data();

          print(data);
          this.notification = data['notification_post_' + category] ?? false;
          setState(() {});
        },
      );
    }
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

      // TODO: do we really need to handle for snapshot.size == 0?
      // if (snapshot.size == 0) { // return;

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
          /// [createdAt] will not be null on other's app and will have the biggest value among other posts.
          /// `modified` event will be fired right after with proper timestamp.
          /// This will not be null on other's app and there will be no `modified` event on other's app.
          ///
          if (post.createdAt == null) {
            posts.insert(0, post);
          } else if (posts.isNotEmpty &&
              post.createdAt.microsecondsSinceEpoch >
                  posts[0].createdAt.microsecondsSinceEpoch) {
            posts.insert(0, post);
          } else {
            posts.add(post);
          }

          /// Realtime update for the comments of the post
          /// @TODO: Make sure this will run only one time.
          /// Or ... unsubscribe listener when it will listen again
          commentsCollection(post.id)
              .orderBy('order', descending: true)
              .snapshots()
              .listen((QuerySnapshot snapshot) {
            snapshot.docChanges.forEach((DocumentChange commentsChange) {
              // TODO: Do `CommentModel.fromDocument()`.
              final commentData = commentsChange.doc.data();
              print('commentData: $commentData');
              post.comments.add(commentData);
              setState(() {});
            });
          });

          inLoading =
              false; // will be set to false many times. but does't matter.

        } else if (documentChange.type == DocumentChangeType.modified) {
          final int i = posts.indexWhere((p) => p.id == post.id);
          if (i > 0) {
            posts[i] = post;
          }
        } else if (documentChange.type == DocumentChangeType.removed) {
          print('Removing post');
          posts.removeWhere((p) => p.id == post.id);
        }
      });
      setState(() {});
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
          ),
          IconButton(
              icon: notification == true
                  ? Icon(Icons.notifications_active)
                  : Icon(Icons.notifications_off),
              onPressed: () {
                if (Service.userController.isNotLoggedIn) {
                  Service.alert('Must Login to subscribe to ' + category);
                }
                setState(() {
                  notification = !notification;
                });
                final topic = "notification_post_" + category;
                if (notification) {
                  Service.subscribeTopic(topic);
                } else {
                  Service.unsubscribeTopic(topic);
                }
                Service.usersRef.doc(Service.userController.user.uid).set({
                  "$topic": notification,
                }, SetOptions(merge: true));
              })
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
                        Comments(post: post),
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

                /// depth comes from parent.
                /// order comes from
                ///   - parent if there is no child of the parent.
                /// 	- last comment of siblings.

                'order': getCommentOrder(
                    order: widget.post.comments.length > 0
                        ? widget.post.comments.last['order']
                        : null),
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

class Comments extends StatefulWidget {
  Comments({
    this.post,
  });
  final PostModel post;
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.post.comments.length; i++)
          Comment(post: widget.post, index: i),
      ],
    );
  }
}

class Comment extends StatefulWidget {
  final PostModel post;
  final int index;
  Comment({this.post, this.index, Key key}) : super(key: key);

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final contentController = TextEditingController();
  final user = Get.find<UserController>();
  var parent;

  @override
  void initState() {
    parent = widget.post.comments[widget.index];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text("${widget.post.comments[widget.index]['content']}"),
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

                  /// depth comes from parent.
                  /// order comes from
                  ///   - parent if there is no child of the parent.
                  /// 	- last comment of siblings.

                  'order': getCommentOrder(
                    order: parent['order'],
                    depth: parent['depth'] + 1,
                  ),
                  'depth': parent['depth'] + 1,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                };
                print(data);
                await commentCol.add(data);
              } catch (e) {
                Service.error(e);
              }
            },
            child: Text('submit'.tr),
          ),
        ],
      ),
    );
  }
}
