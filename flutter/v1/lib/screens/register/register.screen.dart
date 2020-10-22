import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/user/birthday-picker.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nicknameController = TextEditingController();

  final passNode = FocusNode();
  final nicknameNode = FocusNode();

  DateTime birthDate;
  String gender = 'M';

  bool loading = false;

  @override
  void initState() {
    final now = DateTime.now();
    birthDate = now;
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
                child: Text('Google Sign-in'),
                onPressed: Service.signInWithGoogle,
              ),
              RaisedButton(
                child: Text('Facebook Sign-in'),
                onPressed: Service.signInWithFacebook,
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
                controller: nicknameController,
                focusNode: nicknameNode,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Nickname"),
              ),
              SizedBox(height: Space.md),
              Text('Birthday'),
              BirthdayPicker(
                initialValue: birthDate,
                onChange: (date) {
                  setState(() {
                    this.birthDate = date;
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
                child: Text("Submit"),
                onPressed: () async {
                  /// remove any input focus.
                  FocusScope.of(context).requestFocus(new FocusNode());

                  try {
                    /// Log into Firebase with email/password
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    print(userCredential.user);

                    await userCredential.user
                        .updateProfile(displayName: nicknameController.text);

                    /// Login Success
                    CollectionReference users =
                        FirebaseFirestore.instance.collection('users');

                    /// Update other user information
                    await users.doc(userCredential.user.uid).set({
                      "gender": gender,
                      "birthday": birthDate,
                      "notifyPost": true,
                      "notifyComment": true,
                    }, SetOptions(merge: true));
                    Service.onLogin(userCredential);
                    Get.toNamed(RouteNames.home);
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
