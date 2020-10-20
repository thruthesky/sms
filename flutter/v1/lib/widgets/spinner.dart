import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonSpinner extends StatelessWidget {
  const CommonSpinner({
    Key key,
    this.size = 24,
    this.isCentered = false,
  }) : super(key: key);

  final double size;
  final bool isCentered;

  @override
  Widget build(BuildContext context) {
    final spinner = SizedBox(
      width: size,
      height: size,
      child: Platform.isAndroid
          ? CircularProgressIndicator()
          : CupertinoActivityIndicator(),
    );

    return isCentered ? Center(child: spinner) : spinner;
  }
}
