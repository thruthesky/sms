import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/user/gender_select.dart';

class GenderSelectDialog extends StatefulWidget {
  final String defaultValue;
  final Function onChanged;

  GenderSelectDialog({ this.defaultValue = 'M', this.onChanged(String gender) });

  @override
  _GenderSelectDialogState createState() => _GenderSelectDialogState();
}

class _GenderSelectDialogState extends State<GenderSelectDialog> {
  String newGender;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(Space.md),
      children: [
        Text('Select Gender'),
        GenderSelect(
          defaultValue: widget.defaultValue,
          onChanged: widget.onChanged,
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
