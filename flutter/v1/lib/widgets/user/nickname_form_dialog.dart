import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/spaces.dart';

class NickNameFormDialog extends StatelessWidget {
  final TextEditingController textEditingController;

  NickNameFormDialog(this.textEditingController);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(Space.md),
      children: [
        Text('Input Nickname'),
        TextFormField(
          key: ValueKey('nickname'),
          controller: textEditingController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: Space.sm),
        Row(
          children: [
            RaisedButton(
              onPressed: Get.back,
              child: Text('Cancel'),
            ),
            Spacer(),
            RaisedButton(
              child: Text('Update'),
              onPressed: Get.back,
            )
          ],
        ),
      ],
    );
  }
}
