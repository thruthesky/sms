import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/commons/app_drawer.dart';
import 'package:v1/widgets/miscellaneous/or_divider.dart';
import 'package:v1/widgets/user/birthday_picker.dart';
import 'package:v1/widgets/user/social_login_buttons.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();

  final passNode = FocusNode();
  final nicknameNode = FocusNode();

  DateTime birthday;
  String gender = 'M';

  bool loading = false;
  bool hidePassword = true;

  @override
  void initState() {
    final now = DateTime.now();
    birthday = now;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: CommonAppDrawer(),
      appBar: CommonAppBar(
        title: Text('register'.tr),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // RaisedButton(
              //   child: Text(
              //     'Social Login.\nYou can login with your SNS Accounts.',
              //   ),
              //   onPressed: () => Get.toNamed(RouteNames.login),
              // ),
              Text(
                'Fill in the form'.tr,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'register'.tr,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Space.xl),

              /// Email
              Text(
                'Email Address'.tr,
                style: TextStyle(color: Color(0xff717171)),
              ),
              TextFormField(
                key: ValueKey('email'),
                controller: emailController,
                onEditingComplete: passNode.requestFocus,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    FontAwesomeIcons.userAlt,
                  ),
                ),
              ),
              SizedBox(height: Space.lg),

              /// Password
              Text(
                'Password'.tr,
                style: TextStyle(color: Color(0xff717171)),
              ),
              TextFormField(
                key: ValueKey('password'),
                controller: passwordController,
                focusNode: passNode,
                obscureText: hidePassword,
                onEditingComplete: nicknameNode.requestFocus,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: FaIcon(
                      hidePassword
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      size: 25,
                      textDirection: TextDirection.rtl,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: Space.lg),

              /// nickname
              Text(
                'Nickname'.tr,
                style: TextStyle(color: Color(0xff717171)),
              ),
              TextFormField(
                key: ValueKey('nickname'),
                controller: displayNameController,
                focusNode: nicknameNode,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: Space.md),

              /// birthday
              Text(
                'Birthday'.tr,
                style: TextStyle(color: Color(0xff717171)),
              ),
              BirthdayPicker(
                initialValue: birthday,
                onChange: (date) {
                  setState(() {
                    this.birthday = date;
                  });
                },
              ),
              SizedBox(height: Space.md),

              /// gender
              Text(
                'Gender'.tr,
                style: TextStyle(color: Color(0xff717171)),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      value: 'M',
                      title: Text("Male".tr),
                      key: ValueKey('genderM'),
                      groupValue: gender,
                      onChanged: (str) {
                        setState(
                          () => gender = str,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      value: 'F',
                      title: Text("Female".tr),
                      key: ValueKey('genderF'),
                      groupValue: gender,
                      onChanged: (str) {
                        setState(
                          () => gender = str,
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: Space.xl),

              /// loader
              if (loading)
                Center(
                  child: CircularProgressIndicator(),
                ),

              /// Submit button
              if (!loading)
                FlatButton(
                  color: Color(0xff0098E1),
                  padding: EdgeInsets.all(Space.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "REGISTER",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () async {
                    /// remove any input focus.
                    FocusScope.of(context).requestFocus(new FocusNode());

                    setState(() {
                      loading = true;
                    });
                    try {
                      await ff.register(
                        {
                          'email': emailController.text,
                          'password': passwordController.text,
                          'displayName': displayNameController.text,
                          'gender': gender,
                          'birthday': birthday,
                        },
                      );
                      Service.redirectAfterLoginOrRegister();
                    } catch (e) {
                      setState(() => loading = false);
                      Service.error(e);
                    }
                  },
                ),

              SizedBox(height: Space.lg),
              OrDivider(),
              SizedBox(height: Space.md),

              /// Social buttons
              SocialLoginButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
