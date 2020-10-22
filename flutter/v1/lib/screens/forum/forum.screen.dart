import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/functions.dart';
import 'package:v1/services/models.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/confirm-dialog.dart';
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
          print('Post:');
          print(post.toString());
          print('Document change type:');
          print(documentChange.type);

          if (documentChange.type == DocumentChangeType.added) {
            // NOTE: by this time, createdAt is null.
            // then when the server finally added the servertimestamp on the post, it will emit a 'modified' event instead of 'added'.
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
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(Space.md),
                            title: Text(
                              posts[i].title,
                              style: TextStyle(fontSize: Space.xl),
                            ),
                            subtitle: Text(
                              posts[i].content,
                              style: TextStyle(fontSize: Space.lg),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.thumb_up),
                                onPressed: () {
                                  print('like');
                                },
                              ),
                              Text(posts[i].like.toString()),
                              IconButton(
                                icon: Icon(Icons.thumb_down),
                                onPressed: () {
                                  print('dislike');
                                },
                              ),
                              Text(posts[i].dislike.toString()),
                              if (Service.isMyPost(posts[i])) ...[
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => Get.toNamed(
                                    RouteNames.forumEdit,
                                    arguments: {'post': posts[i]},
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    bool confirm = await Get.dialog(
                                      ConfirmDialog(title: 'Delete Post?'.tr),
                                    );

                                    if (confirm != null && confirm) {
                                      colPosts.doc(posts[i].id).delete();
                                    }
                                  },
                                ),
                              ]
                            ],
                          )
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
