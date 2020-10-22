import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/spaces.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final Widget content;

  ConfirmDialog({
    this.title = '',
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(Space.md),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          if (content != null) ...[SizedBox(height: Space.sm), content]
        ],
      ),
      children: [
        Divider(),
        Row(
          children: [
            FlatButton(
              color: Colors.red[400],
              child: Text('yes'.tr),
              onPressed: () {
                Get.back(result: true);
              },
            ),
            Spacer(),
            FlatButton(
              color: Colors.grey[200],
              child: Text('no'.tr),
              onPressed: () {
                Get.back(result: false);
              },
            ),
          ],
        )
      ],
    );
  }
}
