import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/confirm-dialog.dart';
import 'package:v1/widgets/commons/photo-picker-bottom-sheet.dart';

/// [post] is required
/// [commentIndex] is optional and used only when creating a new comment.
/// [comment] is optional and used only when updatedin a comment.
class CommentEditForm extends StatefulWidget {
  const CommentEditForm({
    @required this.post,
    this.commentIndex,
    this.comment,
    this.showCancelButton = false,
    this.onCancel,
    this.onSuccess,
    Key key,
  }) : super(key: key);

  final dynamic post;
  final dynamic comment;
  final int commentIndex;
  final bool showCancelButton;

  final Function onCancel;
  final Function onSuccess;

  @override
  _CommentEditFormState createState() => _CommentEditFormState();
}

class _CommentEditFormState extends State<CommentEditForm> {
  final contentController = TextEditingController();

  List<dynamic> files = [];
  double uploadProgress = 0;

  @override
  initState() {
    /// TODO: this is not working here.
    if (widget.comment != null) {
      files = widget.comment['files'] ?? [];
      contentController.text = widget.comment['content'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// TODO: this is working here yet it is not ideal to put it here.
    /// find a way to make it work without putting this code here.
    // if (widget.comment != null) {
    //   files = widget.comment['files'] ?? [];
    //   contentController.text = widget.comment['content'];
    // }

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () async {
                try {
                  /// choose upload option.
                  ImageSource source = await Get.bottomSheet(
                    PhotoPickerBottomSheet(),
                    backgroundColor: Colors.white,
                  );

                  /// do nothing when user cancel option selection.
                  if (source == null) return null;

                  /// upload picked file,
                  final url = await ff.uploadFile(
                    folder: 'forum-photos',
                    source: source,

                    /// upload progress
                    progress: (p) => setState(() => uploadProgress = p),
                  );

                  files.add(url);
                  setState(() {
                    uploadProgress = 0;
                  });
                } catch (e) {
                  Service.error(e);
                }
              },
            ),
            Expanded(
              child: TextFormField(
                controller: contentController,
                decoration: InputDecoration(hintText: 'input comment'.tr),
              ),
            ),
          ],
        ),
        if (uploadProgress != 0) LinearProgressIndicator(value: uploadProgress),
        Row(
          children: [
            if (widget.showCancelButton) ...[
              RaisedButton(
                onPressed: () {
                  if (widget.onCancel != null) widget.onCancel();
                },
                child: Text('cancel'),
              )
            ],
            Spacer(),
            RaisedButton(
              onPressed: () async {
                if (contentController.text.trim().length == 0) return;

                final data = {
                  'post': widget.post,
                  'content': contentController.text,
                  'files': files
                };

                if (widget.comment != null) {
                  data['id'] = widget.comment['id'];
                  data['depth'] = widget.comment['depth'];
                  data['order'] = widget.comment['order'];
                } else {
                  data['parentIndex'] = widget.commentIndex;
                }

                try {
                  await ff.editComment(data);
                  if (widget.onSuccess != null) widget.onSuccess();
                  contentController.text = '';
                  files = [];
                } catch (e) {
                  print(e);
                  Service.error(e);
                }
              },
              child: Text('submit'),
            )
          ],
        ),
        for (int i = 0; i < files.length; i++)
          Stack(
            children: [
              CachedNetworkImage(imageUrl: files[i]),
              Positioned(
                top: Space.sm,
                right: Space.sm,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: Space.xl,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    bool confirm = await Get.dialog(
                      ConfirmDialog(title: 'Delete Image?'.tr),
                    );

                    if (confirm == null || !confirm) return;

                    files.removeAt(i);
                    setState(() {});
                  },
                ),
              ),
            ],
          )
      ],
    );
  }
}
