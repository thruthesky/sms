import 'package:flutter/material.dart';

class GenderSelect extends StatefulWidget {
  final String defaultValue;
  final Function onChanged;

  GenderSelect({
    this.defaultValue = 'M',
    this.onChanged(String gender),
  });

  @override
  _GenderSelectState createState() => _GenderSelectState();
}

class _GenderSelectState extends State<GenderSelect> {
  String gender;

  changed(String g) {
    if (mounted) {
      setState(() {
        gender = g;
        widget.onChanged(g);
      });
    }
  }

  @override
  initState() {
    gender = widget.defaultValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          RadioListTile(
            value: 'M',
            title: Text("Male"),
            key: ValueKey('genderM'),
            groupValue: gender,
            onChanged: changed,
          ),
          RadioListTile(
            value: 'F',
            title: Text("Female"),
            key: ValueKey('genderF'),
            groupValue: gender,
            onChanged: changed,
          ),
        ],
      ),
    );
  }
}
