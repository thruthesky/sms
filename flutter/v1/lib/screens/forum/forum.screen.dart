import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/functions.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/spaces.dart';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> with AfterLayoutMixin {
  final CollectionReference colPosts =
      FirebaseFirestore.instance.collection('posts');

  String category;
  List<Map<String, dynamic>> posts = [];

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
      /// TODO: give 200 distance from the bottom.
      var isEnd =
          scrollController.offset == scrollController.position.maxScrollExtent;
      print('isEnd: $isEnd');
      // If yes, then get more posts.
      if (isEnd) {
        fetchPosts();
      }
    });
    fetchPosts();
  }

  fetchPosts() {
    // if ( inLoading ) return;
    pageNo++;

    Query q = colPosts.where('category', isEqualTo: category);
    q = q.orderBy('createdAt', descending: true);
    if (posts.length > 0) {
      q = q.startAfter([posts.last['createdAt']]);
    }
    q = q.limit(10);

    q.snapshots().listen((QuerySnapshot snapshot) {
      print('>> docChanges: ');
      if (snapshot.size > 0) {
        snapshot.docChanges.forEach((DocumentChange documentChange) {
          if (documentChange.type == DocumentChangeType.added) {
            final data = documentChange.doc.data();
            data['id'] = documentChange.doc.id;

            /// TODO: Add a newly created post on top.
            if (pageNo == 1) {
              posts.add(data);
            } else {
              posts.insert(0, data);
            }
            print('added a new doc:');
            print(data);
          } else if (documentChange.type == DocumentChangeType.modified) {
            final data = documentChange.doc.data();
            data['id'] = documentChange.doc.id;
            print('A document is updated:');
            print(data);
            final int i = posts.indexWhere((p) => p['id'] == data['id']);
            posts[i] = data;
          } else if (documentChange.type == DocumentChangeType.removed) {
            print('Remove a post');
          }
          setState(() {});
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
                    return Container(
                      color: Colors.grey[300],
                      margin: EdgeInsets.all(Space.pageWrap),
                      child: Container(
                        padding: EdgeInsets.all(Space.md),
                        child: ListTile(
                          title: Text(
                            posts[i]['title'],
                            style: TextStyle(fontSize: Space.xl),
                          ),
                          subtitle: Text(
                            posts[i]['content'],
                            style: TextStyle(fontSize: Space.lg),
                          ),
                          trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => Get.toNamed(RouteNames.forumEdit,
                                  arguments: {'post': posts[i]})),
                        ),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
