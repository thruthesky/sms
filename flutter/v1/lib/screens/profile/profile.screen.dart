import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/app_drawer.dart';
import 'package:v1/widgets/commons/photo_picker_bottomsheet.dart';
import 'package:v1/widgets/user/birthday_picker.dart';
import 'package:v1/widgets/user/profile_image.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// users collection referrence
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final emailController = TextEditingController(text: ff.user.email);
  final displayNameController =
      TextEditingController(text: ff.user.displayName);

  final nicknameNode = FocusNode();

  String gender = ff.data['gender'];
  DateTime birthday = DateTime.now();

  bool loading = false;
  double uploadProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      endDrawer: CommonAppDrawer(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Touch and update your information'.tr,
                style: TextStyle(
                  fontSize: Space.sm,
                  color: Color(0xFF707070),
                ),
              ),
              SizedBox(height: Space.xxl),

              /// Profile image
              Center(
                child: Column(
                  children: [
                    ProfileImage(
                      size: Space.xxl,
                      onTap: () async {
                        /// choose upload option.
                        ImageSource source = await Get.bottomSheet(
                          PhotoPickerBottomSheet(),
                          backgroundColor: Colors.white,
                        );

                        /// do nothing when user cancel option selection.
                        if (source == null) return null;

                        try {
                          /// delete previous file to prevent having unused files in storage.
                          if (!ff.user.photoURL.isNullOrBlank) {
                            await ff.deleteFile(ff.user.photoURL);
                          }

                          /// upload picked file,
                          final url = await ff.uploadFile(
                            folder: 'user-profile-photos',
                            source: source,

                            /// upload progress
                            progress: (p) => setState(
                              () {
                                this.uploadProgress = p;
                              },
                            ),
                          );

                          // update image url of current user.
                          await ff.updatePhoto(url);
                          setState(() => uploadProgress = 0);
                          // print('url: $url');
                        } catch (e) {
                          // print('error on file pick: ');
                          print(e);
                          Service.error(e);
                        }
                      },
                    ),
                    if (uploadProgress != 0) Text('$uploadProgress%')
                  ],
                ),
              ),
              SizedBox(height: Space.md),
              Text('Email: ${ff.user.email}'),
              SizedBox(height: Space.md),
              Text('Mobile number: ${ff.user.phoneNumber}'),
              TextFormField(
                key: ValueKey('nickname'),
                controller: displayNameController,
                focusNode: nicknameNode,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Nickname"),
              ),
              SizedBox(height: Space.lg),
              Text('Birthday'),
              BirthdayPicker(
                initialValue: birthday,
                onChange: (date) {
                  setState(() {
                    this.birthday = date;
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
                child: loading ? CircularProgressIndicator() : Text("Submit"),
                onPressed: () async {
                  /// remove any input focus.
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() => loading = true);

                  try {
                    await ff.updateProfile({
                      'displayName': displayNameController.text,
                      'gender': gender,
                      'birthday': birthday,
                    });
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
