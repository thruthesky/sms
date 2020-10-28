import 'package:flutter/material.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/forum/comment.edit.form.dart';

class Comments extends StatefulWidget {
  Comments({
    this.post,
  });
  final dynamic post;
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    // print('-------------------- comments');
    return widget.post['comments'] != null
        ? Column(
            children: [
              for (int i = 0; i < widget.post['comments'].length; i++)
                Comment(post: widget.post, commentIndex: i),
            ],
          )
        : SizedBox.shrink();
  }
}

class Comment extends StatefulWidget {
  final dynamic post;
  final int commentIndex;
  Comment({this.post, this.commentIndex, Key key}) : super(key: key);

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  @override
  Widget build(BuildContext context) {
    dynamic comment = widget.post['comments'][widget.commentIndex];
    // print('${comment.order} ${comment.content}');
    return Container(
      margin: EdgeInsets.only(
        left: Space.md * comment['depth'],
        bottom: Space.md,
      ),
      padding: EdgeInsets.all(Space.md),
      color: Colors.grey[100],
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Text("${comment['content']} ${comment['order']}"),
          ),
          CommentEditForm(
            post: widget.post,
            commentIndex: widget.commentIndex,
          ),
        ],
      ),
    );
  }
}
