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
  final mobileNumberController = TextEditingController(text: '9654101043');

  bool loading = false;
  String countryCode = '+63';
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
              child: Text('submit'),
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                ff.mobileAuthSendCode(
                  internationalNo,
                  codeSent: (verificationID) {
                    print('verificationID');
                    print(verificationID);

                    Get.toNamed(RouteNames.mobileCodeVerification, arguments: {
                      'verificationID': verificationID,
                      'internationalNo': internationalNo,
                    });
                  },
                  onError: (e) => Service.error(e),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
