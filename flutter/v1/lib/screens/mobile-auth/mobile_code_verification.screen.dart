import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route_names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/miscellaneous/or_divider.dart';

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

  bool loading = false;

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
      appBar: CommonAppBar(
        title: Text('Code Verification'),
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: Space.xl),
              Text(
                'Input Verification Code',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Verify',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Verification Code sent to: $internationalNo',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff5F5F5F),
                ),
              ),
              SizedBox(height: Space.xxl),

              // Code Input
              Text(
                'Input Code',
                style: TextStyle(
                  color: Color(0xff5f5f5f),
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextFormField(
                controller: codeController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 43,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'XXXXXX',
                  hintStyle: TextStyle(
                      fontSize: 43,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB7B7B7)),
                ),
              ),
              SizedBox(height: Space.xxl),

              if (loading)
                Center(
                  child: CircularProgressIndicator(),
                ),

              // Verify button
              if (!loading)
                FlatButton(
                  color: Color(0xff0098E1),
                  padding: EdgeInsets.all(Space.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "VERIFY",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    if (loading) return;
                    setState(() => loading = true);
                    try {
                      await ff.mobileAuthVerifyCode(
                        code: codeController.text,
                        verificationId: verificationID,
                      );
                      setState(() => loading = false);
                      Get.toNamed(RouteNames.home);
                    } catch (e) {
                      setState(() => loading = false);
                      Service.error(e);
                    }
                  },
                ),

              SizedBox(height: Space.xxl),
              OrDivider(),
              SizedBox(height: Space.md),

              // change number & resend code button.
              Row(
                children: [
                  FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Text(
                      'Resend Code'.tr,
                      style: TextStyle(
                        color: Color(0xFF032674),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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
                  ),
                  Spacer(),
                  FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Text(
                      'Change Number'.tr,
                      style: TextStyle(
                        color: Color(0xFF032674),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
