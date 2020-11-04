import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';

class MobileCodeVerificationScreen extends StatefulWidget {
  @override
  _MobileCodeVerificationScreenState createState() =>
      _MobileCodeVerificationScreenState();
}

class _MobileCodeVerificationScreenState
    extends State<MobileCodeVerificationScreen> {
  final codeController = TextEditingController();

  String verificationID;
  String internationalNo;
  int codeResendToken;

  @override
  void initState() {
    dynamic args = Get.arguments;
    verificationID = args['verificationID'];
    internationalNo = args['internationalNo'];
    codeResendToken = args['codeResendToken'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Code Verification'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: EdgeInsets.all(Space.pageWrap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Space.xl),
            Text('Verification Code sent to: $internationalNo'),
            SizedBox(height: Space.xl),
            TextFormField(
              controller: codeController,
              decoration: InputDecoration(labelText: 'inputCode'.tr),
            ),
            RaisedButton(
              child: Text('submit'),
              onPressed: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                try {
                  await ff.mobileAuthVerifyCode(
                    code: codeController.text,
                    verificationId: verificationID,
                  );
                  Get.toNamed(RouteNames.home);
                } catch (e) {
                  Service.error(e);
                }
              },
            ),
            Row(
              children: [
                RaisedButton(
                  child: Text('changeNumber'.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
                Spacer(),
                RaisedButton(
                  child: Text('resendCode'.tr),
                  onPressed: () {
                    ff.mobileAuthSendCode(
                      internationalNo,
                      resendToken: codeResendToken,
                      onCodeSent: (verID, resendToken) {
                        setState(() {
                          verificationID = verID;
                          codeResendToken = resendToken;
                        });
                      },
                      onError: (e) => Service.error(e),
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
