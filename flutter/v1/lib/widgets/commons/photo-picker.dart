// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:v1/services/spaces.dart';

// class PhotoPicker extends StatelessWidget {
//   final Function onFilePicked;
//   final double iconSize;
//   final double maxWidth;
//   final int imageQuality;

//   PhotoPicker({
//     @required this.onFilePicked(File file),
//     this.iconSize = 32,
//     this.maxWidth = 640,
//     this.imageQuality = 80,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: GestureDetector(
//         child: Icon(Icons.camera_alt, size: iconSize),
//         onTap: () => pickImage(context),
//       ),
//     );
//   }
// }
