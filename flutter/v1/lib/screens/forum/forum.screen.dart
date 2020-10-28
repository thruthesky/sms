import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:v1/widgets/commons/spinner.dart';
import 'package:v1/widgets/forum/comment.edit.form.dart';
import 'package:v1/widgets/forum/comments.dart';
import 'package:v1/widgets/forum/post.dart';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  // final CollectionReference colPosts =
  //     FirebaseFirestore.instance.collection('posts');

  // StreamSubscription subscription;

  // String category;
  // List<PostModel> posts = [];

  // bool noPostsYet = false;
  // bool noMorePost = false;
  // bool inLoading = false;
  // int pageNo = 0;

  ForumData forum;
  String category;

  bool notificationPost = false;
  bool notificationComment = false;

  // 무제한 스크롤은 ScrollController 로 감지하고
  // 스크롤이 맨 밑으로 될 때, Listener 핸들러를 실행한다.
  ScrollController scrollController =
      ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  @override
  void initState() {
    super.initState();

    category = Get.arguments['category'];

    forum = ForumData(
      category: category,
      render: (x) => setState(() => null),
    );

    // final args = routerArguments(context);
    // category = args['category'];
    // print('category ??: $category');

    /// Scroll event handler
    scrollController.addListener(() {
      // Check if the screen is scrolled to the bottom.
      var isEnd = scrollController.offset >
          (scrollController.position.maxScrollExtent - 200);
      // If yes, then get more posts.
      if (isEnd) ff.fetchPosts(forum);
    });

    /// fetch posts for the first time.
    ff.fetchPosts(forum);

    if (Service.userController.isLoggedIn) {
      // final dynamic data = Service.userController.user;

      // this.notification = data['notificationPost_' + category] ?? false;

      Service.usersRef
          .doc(Service.userController.user.uid)
          .collection('meta')
          .doc('public')
          .get()
          .then(
        (DocumentSnapshot doc) {
          if (!doc.exists) {
            // It's not an error. User may not have documentation. see README
            print('User has no document. fine.');
            return;
          }
          final data = doc.data();

          print(data);
          this.notificationPost =
              data['notification_post_' + category] ?? false;
          this.notificationComment =
              data['notification_comment_' + category] ?? false;
          setState(() {});
        },
      );
    }
  }

  @override
  dispose() {
    /// unsubscribe from the stream to avoid having memory leak..
    // subscription.cancel();
    forum.leave();
    super.dispose();
  }

  // fetchPosts() {
  //   if (inLoading || noMorePost) return;
  //   setState(() => inLoading = true);
  //   pageNo++;

  //   Query postsQuery = colPosts.where('category', isEqualTo: category);
  //   postsQuery = postsQuery.orderBy('createdAt', descending: true);
  //   postsQuery = postsQuery.limit(10);

  //   if (posts.isNotEmpty) {
  //     postsQuery = postsQuery.startAfter([posts.last.createdAt]);
  //   }

  //   subscription = postsQuery.snapshots().listen((QuerySnapshot snapshot) {
  //     // print('>> docChanges: ');

  //     // TODO: do we really need to handle for snapshot.size == 0?
  //     // if (snapshot.size == 0) { // return;

  //     /// TODO: this produce `Unhandled Exception: Unimplemented handling of missing static target` exception seldomly.
  //     snapshot.docChanges.forEach((DocumentChange documentChange) {
  //       final data = documentChange.doc.data();
  //       data['id'] = documentChange.doc.id;
  //       final post = PostModel.fromDocument(data);

  //       // print('Post:');
  //       // print(post.toString());
  //       // print('Document change type:');
  //       // print(documentChange.type);

  //       if (documentChange.type == DocumentChangeType.added) {
  //         /// [createdAt] is null only on author's app since it is cached locally.
  //         /// [createdAt] will not be null on other's app and will have the biggest value among other posts.
  //         /// `modified` event will be fired right after with proper timestamp.
  //         /// This will not be null on other's app and there will be no `modified` event on other's app.
  //         ///
  //         if (post.createdAt == null) {
  //           posts.insert(0, post);
  //         } else if (posts.isNotEmpty &&
  //             post.createdAt.microsecondsSinceEpoch >
  //                 posts[0].createdAt.microsecondsSinceEpoch) {
  //           posts.insert(0, post);
  //         } else {
  //           posts.add(post);
  //         }

  //         /// Realtime update for the comments of the post
  //         /// This will do only one time subscription since it is listening inside `added` event.
  //         /// TODO Unsubscribe the comments of post.id or there will be double event firing when the user visit the forum and load the same comments of the post again.
  //         commentsCollection(post.id)
  //             .orderBy('order', descending: true)
  //             .snapshots()
  //             .listen((QuerySnapshot snapshot) {
  //           snapshot.docChanges.forEach((DocumentChange commentsChange) {
  //             // TODO: Do `CommentModel.fromDocument()`.
  //             final commentData = commentsChange.doc.data();
  //             final newComment = CommentModel.fromDocument(commentData);
  //             if (commentsChange.type == DocumentChangeType.added) {
  //               /// TODO For comments loading on post view, it does not need to loop.
  //               /// TODO Only for newly created comment needs to have loop and find a position to insert.
  //               int found = post.comments
  //                   .indexWhere((c) => c.order.compareTo(newComment.order) < 0);
  //               if (found == -1) {
  //                 post.comments.add(newComment);
  //               } else {
  //                 post.comments.insert(found, newComment);
  //               }
  //             }
  //             setState(() {});
  //           });
  //         });

  //         inLoading =
  //             false; // will be set to false many times. but does't matter.

  //       } else if (documentChange.type == DocumentChangeType.modified) {
  //         final int i = posts.indexWhere((p) => p.id == post.id);
  //         if (i > 0) {
  //           posts[i] = post;
  //         }
  //       } else if (documentChange.type == DocumentChangeType.removed) {
  //         print('Removing post');
  //         posts.removeWhere((p) => p.id == post.id);
  //       }
  //     });
  //     setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.tr),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Get.toNamed(
              RouteNames.forumEdit,
              arguments: {'category': category},
            ),
          ),
          IconButton(
              icon: notificationPost == true
                  ? Icon(Icons.notifications_active)
                  : Icon(Icons.notifications_off),
              onPressed: () {
                if (Service.userController.isNotLoggedIn) {
                  return Service.alert(
                      'Must Login to subscribe to ' + category);
                }
                setState(() {
                  notificationPost = !notificationPost;
                });
                final topic = "notification_post_" + category;
                if (notificationPost) {
                  ff.subscribeTopic(topic);
                } else {
                  ff.unsubscribeTopic(topic);
                }
                Service.usersRef
                    .doc(Service.userController.user.uid)
                    .collection('meta')
                    .doc('public')
                    .set({
                  "$topic": notificationPost,
                }, SetOptions(merge: true));
              }),
          IconButton(
              icon: notificationComment == true
                  ? Icon(Icons.notifications_active)
                  : Icon(Icons.notifications_off),
              onPressed: () {
                if (Service.userController.isNotLoggedIn) {
                  return Service.alert('Must Login to subscribe to $category');
                }
                setState(() {
                  notificationComment = !notificationComment;
                });
                final topic = "notification_comment_$category";
                if (notificationComment) {
                  ff.subscribeTopic(topic);
                } else {
                  ff.unsubscribeTopic(topic);
                }
                Service.usersRef
                    .doc(Service.userController.user.uid)
                    .collection('meta')
                    .doc('public')
                    .set({
                  "$topic": notificationComment,
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
                onPressed: () => Get.toNamed(
                  RouteNames.forumEdit,
                  arguments: {'category': category},
                ),
                child: Text('Create'),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: forum.posts.length,
                itemBuilder: (c, i) {
                  final post = forum.posts[i];

                  return Post(post: post);
                },
              ),

              if (!forum.inLoading)
                Padding(
                  padding: EdgeInsets.all(Space.md),
                  child: CommonSpinner(),
                ),
              // if (noMorePost)
              //   Padding(
              //     padding: EdgeInsets.all(Space.md),
              //     child: Text('No more posts..'),
              //   ),
              // if (noPostsYet)
              //   Padding(
              //     padding: EdgeInsets.all(Space.md),
              //     child: Text('No posts yet..'),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
