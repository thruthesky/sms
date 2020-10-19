import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/app-service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userController = Get.put(UserController());

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

    /// get document with current logged in user's uid.
    users.doc(userController.user.uid).get().then(
      (DocumentSnapshot doc) {
        if (doc.exists) {
          final data = doc.data();
          print(data);
          this.nicknameController.text = data['nickname'];
          this.gender = data['gender'];
          Timestamp date = data['birthday'];
          this.birthDate =
              DateTime.fromMillisecondsSinceEpoch(date.seconds * 1000);
          setState(() {});
        }
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
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${userController.user.email}'),
              TextFormField(
                key: ValueKey('nickname'),
                controller: nicknameController,
                focusNode: nicknameNode,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Nickname"),
              ),
              SizedBox(height: 20),
              Text('Birthday'),
              Row(
                children: [
                  Text(
                    '${birthDate.year} - ${birthDate.month} - ${birthDate.day}',
                  ),
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
                    await users.doc(userController.user.uid).set({
                      "nickname": nicknameController.text,
                      "gender": gender,
                      "birthday": birthDate,
                    });
                    Get.snackbar('Update', 'Profile updated!');
                    setState(() => loading = false);
                  } catch (e) {
                    setState(() => loading = false);
                    AppService.error(e);
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
