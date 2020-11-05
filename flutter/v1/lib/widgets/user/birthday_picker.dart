import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:v1/services/spaces.dart';

class BirthdayPicker extends StatelessWidget {
  final DateTime initialValue;
  final Function onChange;

  BirthdayPicker({
    @required this.initialValue,
    @required this.onChange(DateTime date),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${initialValue.year} - ${initialValue.month} - ${initialValue.day}',
          style: TextStyle(
            fontSize: Space.lg,
            color: Color(0xFF707070)
          ),
        ),
        Spacer(),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.edit, size: Space.md, color: Color(0xFF909090),),
          onPressed: () async {
            var now = DateTime.now();

            final date = await showDatePicker(
              context: context,
              initialDate: initialValue,
              firstDate: DateTime(now.year - 70),
              lastDate: DateTime(now.year, now.month, 30),
            );
            if (date == null) return;
            onChange(date);
          },
        ),
      ],
    );
  }
}
