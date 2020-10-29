import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FileDisplay extends StatelessWidget {
  FileDisplay(this.files);
  final List<dynamic> files;

  @override
  Widget build(BuildContext context) {
    return files != null && files.length > 0
        ? Column(
            children: [
              for (String url in files)
                CachedNetworkImage(
                  imageUrl: url,
                )
            ],
          )
        : SizedBox.shrink();
  }
}
