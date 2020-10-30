import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:v1/services/spaces.dart';

class CountryCodeSelector extends StatelessWidget {
  final Function onChanged;

  final String initialSelection;
  final bool withBorder;
  final Color borderColor;
  final bool enabled;

  final double fontSize;
  final Color fontColor;
  final FontWeight fontWeight;
  final double iconSize;
  final Color iconColor;
  final EdgeInsets padding;

  CountryCodeSelector({
    @required this.onChanged(CountryCode code),
    this.initialSelection = '',
    this.withBorder = true,
    this.borderColor,
    this.enabled = true,
    this.fontSize,
    this.fontColor,
    this.fontWeight = FontWeight.w400,
    this.iconSize,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CountryCodePicker(
      builder: (_) {
        return Container(
          padding:
              padding ?? EdgeInsets.symmetric(vertical: Space.md, horizontal: Space.xs),
          width: double.infinity,
          child: Row(
            children: [
              Text(
                _.name + ' ' + '(${_.dialCode})',
                style: TextStyle(
                  fontSize: fontSize ?? Space.md,
                  color: fontColor ?? Color(0x99000000),
                  fontWeight: fontWeight,
                ),
              ),
              Spacer(),
              Icon(
                Icons.more_vert,
                size: iconSize ?? Space.md,
                color: iconColor ?? Color(0xff656565),
              ),
            ],
          ),
          decoration: withBorder
              ? BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: borderColor ?? Color(0x1f000000),
                  ),
                )
              : null,
        );
      },
      enabled: enabled,
      flagWidth: 50,
      textStyle: TextStyle(fontSize: 30),
      onChanged: onChanged,
      initialSelection: initialSelection,
      showCountryOnly: false,
      showOnlyCountryWhenClosed: false,
    );
  }
}
