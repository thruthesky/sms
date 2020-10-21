import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/user/birthday-picker.dart';
import 'package:v1/widgets/user/profile-image.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userController = Get.find<UserController>();

  /// users collection referrence
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final emailController = TextEditingController();
  final nicknameController = TextEditingController();

  final nicknameNode = FocusNode();

  String gender;
  DateTime birthDate;

  bool loading = false;

  @override
  void initState() {
    birthDate = DateTime.now();
    this.emailController.text = userController.user.email;
    this.nicknameController.text = userController.displayName;

    /// get document with current logged in user's uid.
    users.doc(userController.user.uid).get().then(
      (DocumentSnapshot doc) {
        if (!doc.exists) {
          // It's not an error. User may not have documentation. see README
          print('User has no document. fine.');
          return;
        }
        final data = doc.data();
        print(data);
        this.gender = data['gender'];
        Timestamp date = data['birthday'];
        this.birthDate =
            DateTime.fromMillisecondsSinceEpoch(date.seconds * 1000);
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Space.pageWrap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  child: ProfileImage(
                    size: Space.xxxl,
                  ),
                  onTap: () async {
                    try {
                      File file = await Service.pickImage();
                      print('success: file picked: ${file.path}');
                    } catch (e) {
                      print('error on file pick: ');
                      print(e);
                      Service.error(e);
                    }
                  },
                ),
              ),
              SizedBox(height: Space.md),
              Text('Email: ${userController.user.email}'),
              TextFormField(
                key: ValueKey('nickname'),
                controller: nicknameController,
                focusNode: nicknameNode,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Nickname"),
              ),
              SizedBox(height: Space.lg),
              Text('Birthday'),
              BirthdayPicker(
                initialValue: birthDate,
                onChange: (date) {
                  setState(() {
                    this.birthDate = date;
                  });
                },
              ),
              SizedBox(height: 20),
              Text('Gender'),
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
                  setState(() => loading = true);

                  try {
                    await userController.user
                        .updateProfile(displayName: nicknameController.text);
                    await userController.reload();

                    final userDoc = users.doc(userController.user.uid);
                    await userDoc.set({
                      "gender": gender,
                      "birthday": birthDate,
                    }, SetOptions(merge: true));
                    Get.snackbar('Update', 'Profile updated!');
                  } catch (e) {
                    Service.error(e);
                  } finally {
                    setState(() => loading = false);
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
