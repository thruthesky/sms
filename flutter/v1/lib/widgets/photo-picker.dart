import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:v1/services/spaces.dart';

class PhotoPicker extends StatelessWidget {
  final Function onFilePicked;
  final double iconSize;
  final double maxWidth;
  final int imageQuality;

  PhotoPicker({
    @required this.onFilePicked(File file),
    this.iconSize = 32,
    this.maxWidth = 640,
    this.imageQuality = 80,
  });

  final pickerOptions = [
    PickerOptions(
      title: 'camera'.tr,
      source: ImageSource.camera,
      permission: Permission.camera,
    ),
    PickerOptions(
      title: 'gallery'.tr,
      source: ImageSource.gallery,
      permission: Permission.photos,
    ),
  ];

  pickImage(context) async {
    /// instantiate image picker.
    final picker = ImagePicker();

    /// choose upload option.
    final PickerOptions option = await Get.bottomSheet(
      PhotoPickerBottomSheet(title: 'Choose source', options: pickerOptions),
      backgroundColor: Colors.white,
    );

    /// do nothing when user cancel option selection.
    if (option == null) return;

    /// get permission status.
    PermissionStatus permissionStatus = await option.permission.status;

    /// if permission is permanently denied,
    /// the only way to grant permission is changing in AppSettings.
    if (permissionStatus.isPermanentlyDenied) {
      openAppSettings();
    }

    /// check if the app have the permission to access camera or photos
    if (!permissionStatus.isUndetermined || !permissionStatus.isGranted) {
      /// request permission if not granted, or user haven't chosen permission yet.
      await option.permission.request();
    }

    PickedFile pickedFile = await picker.getImage(
      source: option.source,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );

    /// do nothing when user cancel photo selection.
    if (pickedFile == null) return null;
    File file = File(pickedFile.path);

    /// compress file and also fix orientation issue when taking images with camera.
    var fileAsBytes = await file.readAsBytes();
    await file.delete();
    final compressedImageBytes =
        await FlutterImageCompress.compressWithList(fileAsBytes);
    await file.writeAsBytes(compressedImageBytes);

    onFilePicked(file);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: Icon(Icons.camera_alt, size: iconSize),
        onTap: () => pickImage(context),
      ),
    );
  }
}

/// picker option class.
class PickerOptions {
  String title;
  ImageSource source;
  Permission permission;

  PickerOptions({this.title, this.source, this.permission});
}

/// photo picker bottomsheet.
class PhotoPickerBottomSheet extends StatelessWidget {
  final String title;
  final List<PickerOptions> options;

  PhotoPickerBottomSheet({@required this.title, @required this.options});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: context.height * .4,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(Space.md),
              child: Text(title),
            ),
            for (var option in options)
              FlatButton(
                child: Text(option.title),
                onPressed: () {
                  Get.back(result: option);
                },
              ),
            FlatButton(
              child: Text('cancel'.tr),
              onPressed: () {
                Get.back();
              },
            )
          ],
        ),
      ),
    );
  }
}
