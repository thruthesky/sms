import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/widgets/commons/app_drawer.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> results = [];

  ScrollController scrollController =
      ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  /// TODO make it as settings
  int hitsPerPage = 15;

  int pageNo = 0;

  bool loading = false;
  bool noMorePosts = false;
  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      var isEnd = scrollController.offset >
          (scrollController.position.maxScrollExtent - 200);
      if (isEnd) {
        search();
      }
    });
  }

  search() async {
    if (loading || noMorePosts) return;
    loading = true;
    List hits = await ff.search(searchController.text,
        hitsPerPage: hitsPerPage, pageNo: pageNo);
    if (hits == null || hits.length < hitsPerPage) {
      noMorePosts = true;
    }
    results = [...results, ...hits];
    loading = false;
    pageNo++;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      endDrawer: CommonAppDrawer(),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: searchController,
              ),
              RaisedButton(
                onPressed: () {
                  pageNo = 0;
                  results = [];
                  noMorePosts = false;
                  loading = false;
                  search();
                },
                child: Text('Search'),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, i) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(results[i]['title'] ?? ''),
                        subtitle: Text(results[i]['content'] ?? ''),
                        onTap: () {
                          String path = results[i]['path'];
                          if (path == null)
                            Service.alert('path does not exists'.tr);
                          String postId = path.split('/')[1];

                          print('postid: $postId from $path');
                          Get.toNamed(RouteNames.forumView,
                              arguments: {'id': postId});
                        },
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
              if (loading) CircularProgressIndicator(),
              if (noMorePosts)
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No more posts'.tr),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
