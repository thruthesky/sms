import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/commons/app_drawer.dart';
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
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();

    category = Get.arguments['category'];

    forum = ForumData(
      category: category,
      render: (RenderType x) {
        if (mounted) setState(() => null);
      },
    );

    /// Scroll event handler
    scrollController.addListener(() {
      // Check if the screen is scrolled to the bottom.
      var isEnd = scrollController.offset >
          (scrollController.position.maxScrollExtent - 200);
      // If yes, then get more posts.
      if (isEnd) {
        ff.fetchPosts(forum);
      }
    });

    /// fetch posts for the first time.
    ff.fetchPosts(forum);

    if (ff.loggedIn) {
      ff.publicDoc.get().then(
        (DocumentSnapshot doc) {
          if (!doc.exists) {
            // It's not an error. User may not have documentation. see README
            print('User has no document. fine.');
            return;
          }
          final data = doc.data();

          this.notificationPost =
              data[NotificationOptions.post(category)] ?? false;
          this.notificationComment =
              data[NotificationOptions.comment(category)] ?? false;
          setState(() {});
        },
      );
    }
  }

  @override
  dispose() {
    // unsubscribe from the stream subscription to avoid having memory leak..
    forum.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text(category.tr),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Service.openForumEditScreen(category),
          ),
          IconButton(
            icon: notificationPost == true
                ? Icon(Icons.notifications_active)
                : Icon(Icons.notifications_off),
            onPressed: () {
              if (ff.notLoggedIn) {
                return Service.alert(
                  'Must Login to subscribe to ' + category,
                );
              }
              setState(() {
                notificationPost = !notificationPost;
              });
              final topic = NotificationOptions.post(category);
              if (notificationPost) {
                ff.subscribeTopic(topic);
              } else {
                ff.unsubscribeTopic(topic);
              }

              // TODO @lancelynyrd
              // ff.updateProfile({}, meta: {'public': {topic: notificationPost}});
              Service.usersRef
                  .doc(ff.user.uid)
                  .collection('meta')
                  .doc('public')
                  .set({
                "$topic": notificationPost,
              }, SetOptions(merge: true));
            },
          ),
          IconButton(
            icon: notificationComment == true
                ? Icon(Icons.notifications_active)
                : Icon(Icons.notifications_off),
            onPressed: () {
              if (ff.notLoggedIn) {
                return Service.alert('Must Login to subscribe to $category');
              }
              setState(() {
                notificationComment = !notificationComment;
              });
              final topic = NotificationOptions.comment(category);
              if (notificationComment) {
                ff.subscribeTopic(topic);
              } else {
                ff.unsubscribeTopic(topic);
              }
              Service.usersRef
                  .doc(ff.user.uid)
                  .collection('meta')
                  .doc('public')
                  .set({
                "$topic": notificationComment,
              }, SetOptions(merge: true));
            },
          ),
        ],
      ),
      endDrawer: CommonAppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Container(
            child: Column(
              children: [
                // post list
                PostList(posts: forum.posts),

                // loader
                if (forum.inLoading)
                  Padding(
                    padding: EdgeInsets.all(Space.md),
                    child: CommonSpinner(),
                  ),
                if (forum.status == ForumStatus.noPosts)
                  Padding(
                    padding: EdgeInsets.all(Space.md),
                    child: Text('No posts yet..'),
                  ),
                if (forum.status == ForumStatus.noMorePosts)
                  Padding(
                    padding: EdgeInsets.all(Space.md),
                    child: Text('No more posts..'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostList extends StatelessWidget {
  final List<dynamic> posts;
  PostList({this.posts});

  @override
  Widget build(BuildContext context) {
    return posts.length > 0
        ? Column(
            children: [
              for (dynamic post in posts) Post(post: post),
            ],
          )
        : SizedBox.shrink();
  }
}
