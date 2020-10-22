import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  String category;
  List<PostModel> posts = [];

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
    print('category ??: $category');

    /// Scroll event handler
    scrollController.addListener(() {
      // Check if the screen is scrolled to the bottom.
      var isEnd = scrollController.offset >
          (scrollController.position.maxScrollExtent - 200);
      // If yes, then get more posts.
      if (isEnd) {
        fetchPosts();
      }
    });

    /// fetch posts for the first time.
    fetchPosts();
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

    postsQuery.snapshots().listen((QuerySnapshot snapshot) {
      // print('>> docChanges: ');
      if (snapshot.size > 0) {
        snapshot.docChanges.forEach((DocumentChange documentChange) {
          final data = documentChange.doc.data();
          data['id'] = documentChange.doc.id;
          final post = PostModel.fromBackendData(data);
          print(post.toString());
          print('Document change type');
          print(documentChange.type);

          if (documentChange.type == DocumentChangeType.added) {
            /// if post is not empty and first post's createdAt value is less than the incoming post's createdAt, add on top.
            print('added a new doc:');
            print(post.toString());
            if (posts.isNotEmpty &&
                posts.first.createdAt.seconds < post.createdAt.seconds) {
              posts.insert(0, post);
            } else {
              /// else, simply add the post to bottom, it may be an older post.
              posts.add(post);
            }
            inLoading = false;
          } else if (documentChange.type == DocumentChangeType.modified) {
            print('A document is updated:');
            final int i = posts.indexWhere((p) => p.id == post.id);
            if (i != -1) posts[i] = post;
          } else if (documentChange.type == DocumentChangeType.removed) {
            print('Removing post');
            posts.retainWhere((p) => p.id == post.id);
          }
        });
        setState(() {});
      } else {
        setState(() {
          noMorePost = true;
          inLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  itemCount: posts.length,
                  itemBuilder: (c, i) {
                    return Container(
                      color: Colors.grey[300],
                      margin: EdgeInsets.all(Space.pageWrap),
                      child: Container(
                        padding: EdgeInsets.all(Space.md),
                        child: ListTile(
                          title: Text(
                            posts[i].title,
                            style: TextStyle(fontSize: Space.xl),
                          ),
                          subtitle: Text(
                            posts[i].content,
                            style: TextStyle(fontSize: Space.lg),
                          ),
                          trailing: Service.isMyPost(posts[i])
                              ? Wrap(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => Get.toNamed(
                                        RouteNames.forumEdit,
                                        arguments: {'post': posts[i]},
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        /// TODO: confirm message
                                        colPosts.doc(posts[i].id).delete();
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
