import 'package:flutter/material.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:get/get.dart';

class VoteButton extends StatefulWidget {
  VoteButton({
    this.post,
    this.comment,
    this.choice,
    this.padding = const EdgeInsets.all(0),
    this.state,
  });
  final Map post;
  final Map comment;
  final String choice;
  final EdgeInsetsGeometry padding;
  final Function state;

  @override
  _VoteButtonState createState() => _VoteButtonState();
}

class _VoteButtonState extends State<VoteButton> {
  @override
  Widget build(BuildContext context) {
    bool voteOption = ff.isShowForumVote(widget.post['category'], 'like');
    if (!voteOption) return SizedBox.shrink();

    /// To show `likes` of post or comment.
    Map obj = widget.comment == null ? widget.post : widget.comment;
    int count = obj[widget.choice + 's'] == null ? 0 : obj[widget.choice + 's'];
    String caption = (widget.choice + 's').tr;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: widget.padding,
        child: Text(
          '$caption $count',
          style: TextStyle(
              color: obj['voteDisabled'] == true ? Colors.grey : Colors.black),
        ),
      ),
      onTap: () async {
        if (obj['voteDisabled'] == true) return;
        widget.state(() => obj['voteDisabled'] = true);
        try {
          await ff.vote(
            postId: widget.post['id'],
            commentId: widget.comment == null ? null : widget.comment['id'],
            choice: widget.choice,
          );
        } catch (e) {
          Service.error(e);
        }
      },
    );
  }
}
