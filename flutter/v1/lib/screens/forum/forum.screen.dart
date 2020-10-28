import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:v1/widgets/commons/spinner.dart';
import 'package:v1/widgets/forum/post.dart';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
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
    forum.leave();
    super.dispose();
  }

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
              if (forum.inLoading)
                Padding(
                  padding: EdgeInsets.all(Space.md),
                  child: CommonSpinner(),
                ),
              if (forum.noMorePosts)
                Padding(
                  padding: EdgeInsets.all(Space.md),
                  child: Text('No more posts..'),
                ),
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
