import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/confirm-dialog.dart';

class FileDisplay extends StatefulWidget {
  FileDisplay(
    this.files, {
    this.inEdit = false,
  });
  final List<dynamic> files;
  final bool inEdit;

  @override
  _FileDisplayState createState() => _FileDisplayState();
}

class _FileDisplayState extends State<FileDisplay> {
  @override
  Widget build(BuildContext context) {
    return widget.files != null && widget.files.length > 0
        ? Column(
            children: [
              for (int i = 0; i < widget.files.length; i++)
                Stack(
                  children: [
                    CachedNetworkImage(imageUrl: widget.files[i]),

                    /// show only when in edit mode
                    if (widget.inEdit)
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

                            try {
                              await ff.deleteFile(widget.files[i]);
                              widget.files.removeAt(i);
                              setState(() {});
                            } catch (e) {
                              Service.error(e);
                            }
                          },
                        ),
                      ),
                  ],
                )
            ],
          )
        : SizedBox.shrink();
  }
}
