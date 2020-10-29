import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:v1/services/spaces.dart';

class FileDisplay extends StatelessWidget {
  FileDisplay(this.files);
  final List<dynamic> files;

  @override
  Widget build(BuildContext context) {
    return files != null && files.length > 0
        ? Column(
            children: [
              SizedBox(height: Space.md),
              for (String url in files)
                CachedNetworkImage(
                  imageUrl: url,
                )
            ],
          )
        : SizedBox.shrink();
  }
}
