import 'package:flutter/material.dart';

class BirthdayPicker extends StatefulWidget {
  final DateTime initialValue;
  final Function onChange;

  BirthdayPicker({
    @required this.initialValue,
    @required this.onChange(DateTime date),
  });

  @override
  _BirthdayPickerState createState() => _BirthdayPickerState();
}

class _BirthdayPickerState extends State<BirthdayPicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${widget.initialValue.year} - ${widget.initialValue.month} - ${widget.initialValue.day}',
        ),
        Spacer(),
        RaisedButton(
          child: Text('Change'),
          onPressed: () async {
            var now = DateTime.now();

            final date = await showDatePicker(
              context: context,
              initialDate: widget.initialValue,
              firstDate: DateTime(now.year - 70),
              lastDate: DateTime(now.year, now.month, 30),
            );
            if (date == null) return;
            widget.onChange(date);
          },
        ),
      ],
    );
  }
}
