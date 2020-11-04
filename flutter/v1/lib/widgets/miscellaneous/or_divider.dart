import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final defaultColor = Color(0xffAFAFAF);

  @override
  Widget build(BuildContext context) {
    Widget line = Expanded(
      child: Divider(
        color: Color(0xffAFAFAF),
        thickness: 1,
      ),
    );

    return Row(
      children: [
        line,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w300,
              color: Color(0xffAFAFAF),
            ),
          ),
        ),
        line
      ],
    );
  }
}
