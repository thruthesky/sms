import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/user/country_code_selector.dart';

class MobileAuthScreen extends StatefulWidget {
  @override
  _MobileAuthScreenState createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<MobileAuthScreen> {
  final mobileNumberController = TextEditingController();

  bool loading = false;
  String countryCode = '+82';
  String get internationalNo => '$countryCode${mobileNumberController.text}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Auth'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: EdgeInsets.all(Space.pageWrap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select country code',
              style: TextStyle(
                color: Color(0xff5f5f5f),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Space.xxs),
            CountryCodeSelector(
              enabled: !loading,
              initialSelection: countryCode,
              onChanged: (_) {
                countryCode = _.dialCode;
              },
            ),
            SizedBox(height: Space.xl),
            TextFormField(
              controller: mobileNumberController,
              decoration: InputDecoration(labelText: 'mobileNo'.tr),
            ),
            RaisedButton(
              child: Text('submit'.tr),
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                ff.mobileAuthSendCode(
                  internationalNo,
                  onCodeSent: (verificationID, codeResendToken) {
                    Get.toNamed(RouteNames.mobileCodeVerification, arguments: {
                      'verificationID': verificationID,
                      'internationalNo': internationalNo,
                      'codeResendToken': codeResendToken
                    });
                  },
                  onError: (e) => Service.error(e),
                );
              },
            ),
            Divider(),
            RaisedButton(
              child: Text('skip'.tr),
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                Get.toNamed(RouteNames.home);
              },
            )
          ],
        ),
      ),
    );
  }
}
