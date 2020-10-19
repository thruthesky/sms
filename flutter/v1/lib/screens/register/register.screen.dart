import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/route-names.dart';

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

    emailController.text = "abc1@gmail.com";
    passwordController.text = "12345a";
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
              SizedBox(height: 20),
              Text('Birthday'),
              Row(
                children: [
                  Text(
                      '${birthDate.year} - ${birthDate.month} - ${birthDate.day}'),
                  Spacer(),
                  RaisedButton(
                    child: Text('Change'),
                    onPressed: () async {
                      var now = DateTime.now();

                      final date = await showDatePicker(
                        context: context,
                        initialDate: birthDate,
                        firstDate: DateTime(now.year - 70),
                        lastDate: DateTime(now.year, now.month, 30),
                      );
                      if (date == null) return;
                      setState(() {
                        birthDate = date;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 30),
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

                    /// Login Success
                    CollectionReference users =
                        FirebaseFirestore.instance.collection('users');

                    /// Update other user information
                    await users.doc(userCredential.user.uid).set({
                      "nickname": nicknameController.text,
                      "gender": gender,
                      "birthday": birthDate,
                    });

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
