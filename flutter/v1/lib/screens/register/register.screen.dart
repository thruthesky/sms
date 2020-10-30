import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/user/birthday_picker.dart';

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

  @override
  void initState() {
    final now = DateTime.now();
    birthday = now;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RaisedButton(
                child: Text(
                    'Social Login.\nYou can login with your SNS Accounts.'),
                onPressed: () => Get.toNamed(RouteNames.login),
              ),
              SizedBox(height: Space.xl),
              TextFormField(
                key: ValueKey('email'),
                controller: emailController,
                onEditingComplete: passNode.requestFocus,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email Address"),
              ),
              TextFormField(
                key: ValueKey('password'),
                controller: passwordController,
                focusNode: passNode,
                obscureText: true,
                onEditingComplete: nicknameNode.requestFocus,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Password"),
              ),
              TextFormField(
                key: ValueKey('nickname'),
                controller: displayNameController,
                focusNode: nicknameNode,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Nickname"),
              ),
              SizedBox(height: Space.md),
              Text('Birthday'),
              BirthdayPicker(
                initialValue: birthday,
                onChange: (date) {
                  setState(() {
                    this.birthday = date;
                  });
                },
              ),
              SizedBox(height: Space.md),
              Text('Gender - $gender'),
              RadioListTile(
                value: 'M',
                title: Text("Male"),
                key: ValueKey('genderM'),
                groupValue: gender,
                onChanged: (str) {
                  setState(() => gender = str);
                },
              ),
              RadioListTile(
                value: 'F',
                title: Text("Female"),
                key: ValueKey('genderF'),
                groupValue: gender,
                onChanged: (str) {
                  setState(() => gender = str);
                },
              ),
              SizedBox(height: Space.xl),
              RaisedButton(
                child: loading ? CircularProgressIndicator() : Text("Submit"),
                onPressed: () async {
                  /// remove any input focus.
                  FocusScope.of(context).requestFocus(new FocusNode());

                  setState(() {
                    loading = true;
                  });
                  try {
                    User user = await ff.register(
                      {
                        'email': emailController.text,
                        'password': passwordController.text,
                        'displayName': displayNameController.text,
                        'gender': gender,
                        'birthday': birthday,
                      },
                      meta: {
                        'public': {
                          "notifyPost": true,
                          "notifyComment": true,
                        },
                        // "tokens": {
                        //   '${ff.firebaseMessagingToken}': true,
                        // },
                      },
                    );
                    ff.onLogin(user);
                    Get.toNamed(RouteNames.mobileAuth);
                  } catch (e) {
                    setState(() => loading = false);
                    Service.error(e);
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
