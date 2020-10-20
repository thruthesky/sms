import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:v1/services/spaces.dart';
import 'package:get/get.dart';

/// photo picker bottomsheet.
class PhotoPickerBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(Space.md),
              child: Text('Choose photo'.tr),
            ),
            FlatButton(
              child: Text('camera'.tr),
              onPressed: () {
                Get.back(result: ImageSource.camera);
              },
            ),
            FlatButton(
              child: Text('gallery'.tr),
              onPressed: () {
                Get.back(result: ImageSource.gallery);
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
