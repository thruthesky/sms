import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';

class MobileCodeVerificationScreen extends StatefulWidget {
  @override
  _MobileCodeVerificationScreenState createState() => _MobileCodeVerificationScreenState();
}

class _MobileCodeVerificationScreenState extends State<MobileCodeVerificationScreen> {
  final codeController = TextEditingController();

  String verificationID;
  String internationalNo;

  @override
  void initState() {
    dynamic args = Get.arguments;
    verificationID = args['verificationID'];
    internationalNo = args['internationalNo'];

    print('verificationID');
    print(verificationID);
    print('internationalNo');
    print(internationalNo);
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
            TextFormField(
              controller: codeController,
              decoration: InputDecoration(labelText: 'inputCode'.tr),
            ),
            RaisedButton(
              child: Text('submit'),
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                print('Code:');
                print(codeController.text);

                /// TODO: Code verification
                Service.error('TODO: Code verification');
              },
            )
          ],
        ),
      ),
    );
  }
}
