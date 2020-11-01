import 'package:flutter/material.dart';
import 'package:v1/services/global_variables.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: searchController,
              ),
              RaisedButton(
                onPressed: () async {
                  results = await ff.search(searchController.text);
                  setState(() {});
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
                      ),
                      Divider(),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
