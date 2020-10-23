import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/functions.dart';
import 'package:v1/services/models.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/spinner.dart';
import 'package:v1/widgets/forum/post.dart';

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
    if (!subscription.isNull) subscription.cancel();
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
        snapshot.docChanges.forEach((DocumentChange documentChange) {
          final data = documentChange.doc.data();
          data['id'] = documentChange.doc.id;
          final post = PostModel.fromBackendData(data);
          // print('Post:');
          // print(post.toString());
          // print('Document change type:');
          // print(documentChange.type);

          if (documentChange.type == DocumentChangeType.added) {
            // NOTE: by this time, createdAt is null.
            // then when the server finally added the server timestamp on the post, it will emit a 'modified' event instead of 'added'.
            if (post.createdAt != null) {
              posts.add(post);
            }
            inLoading = false;
          } else if (documentChange.type == DocumentChangeType.modified) {
            final int i = posts.indexWhere((p) => p.id == post.id);
            if (i != -1) {
              print('A document is updated:');
              posts[i] = post;
            } else {
              print('A new document is added on top:');
              if (posts.first.createdAt.seconds < post.createdAt.seconds) {
                posts.insert(0, post);
              }
            }
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
                  return Post(post: post);
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
