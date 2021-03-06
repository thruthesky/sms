import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route_names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/app_bar.dart';
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

  bool canNavigateBack = false;

  @override
  void initState() {
    dynamic args = Get.arguments;
    if (args != null) {
      canNavigateBack = args['canNavigateBack'] ?? false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text('Mobile Auth'),
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
                'Mobile Number Verification',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Verification',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Please verify your country & number and submit',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff5F5F5F),
                ),
              ),
              SizedBox(height: Space.xxl),
              Text(
                'Select Country Code',
                style: TextStyle(
                  color: Color(0xff5f5f5f),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Space.xxs),
              CountryCodeSelector(
                fontWeight: FontWeight.w500,
                padding: EdgeInsets.all(Space.md),
                iconSize: Space.lg,
                enabled: !loading,
                initialSelection: countryCode,
                onChanged: (_) {
                  countryCode = _.dialCode;
                },
              ),
              SizedBox(height: Space.xxl),
              Text(
                'Mobile Number',
                style: TextStyle(
                  color: Color(0xff5f5f5f),
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: mobileNumberController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: Space.lg,
                ),
                decoration: InputDecoration(
                  hintText: '000-000-000',
                  hintStyle: TextStyle(
                    fontSize: Space.lg,
                    color: Color(0x95959599),
                  ),
                ),
              ),
              SizedBox(height: Space.xxl),
              if (loading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              if (!loading)
                FlatButton(
                  color: Color(0xff0098E1),
                  padding: EdgeInsets.all(Space.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "SEND CODE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    if (loading) return;
                    setState(() => loading = true);
                    ff.mobileAuthSendCode(
                      internationalNo,
                      onCodeSent: (verificationID, codeResendToken) {
                        setState(() => loading = false);
                        Get.toNamed(
                          RouteNames.mobileCodeVerification,
                          arguments: {
                            'verificationID': verificationID,
                            'internationalNo': internationalNo,
                            'codeResendToken': codeResendToken
                          },
                        );
                      },
                      onError: (e) {
                        setState(() => loading = false);
                        Service.error(e);
                      },
                    );
                  },
                ),
              SizedBox(height: Space.lg),
              FlatButton(
                child: Text(
                  canNavigateBack ? 'cancel'.tr : 'skip'.tr,
                  style: TextStyle(
                    fontSize: Space.md,
                  ),
                ),
                color: Color(0x11000000),
                padding: EdgeInsets.all(Space.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Space.xxs),
                ),
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  if (canNavigateBack) {
                    Get.back();
                  } else {
                    Get.toNamed(RouteNames.home);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
