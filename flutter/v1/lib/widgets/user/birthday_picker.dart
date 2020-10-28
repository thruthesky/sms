import 'package:flutter/material.dart';

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
        ),
        Spacer(),
        RaisedButton(
          child: Text('Select'),
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
