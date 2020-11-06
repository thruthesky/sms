import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/commons/app_drawer.dart';
import 'package:v1/widgets/commons/photo_picker_bottomsheet.dart';
import 'package:v1/widgets/user/birthday_picker.dart';
import 'package:v1/widgets/user/profile_image.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final emailController = TextEditingController(text: ff.user.email);
  final displayNameController = TextEditingController(
    text: ff.user.displayName,
  );
  final nicknameNode = FocusNode();

  String gender = ff.userData['gender'];
  DateTime birthday = DateTime.now();

  bool loading = false;
  double uploadProgress = 0;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text('Profile'),
      ),
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
              SizedBox(height: Space.xl),

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
              SizedBox(height: Space.xl),

              Container(
                color: Color(0xFFF5F5F5),
                padding: EdgeInsets.all(Space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Email
                    Text(
                      'Email Address',
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: Space.sm,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ff.user.email,
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: Space.md,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.edit,
                            size: Space.md,
                            color: Color(0xFF909090),
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                    SizedBox(height: Space.md),

                    /// Nickanme
                    Text(
                      'Nickname',
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: Space.sm,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ff.user.displayName.isNullOrBlank
                              ? Text(
                                  'Update nickname',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: Space.md,
                                  ),
                                )
                              : Text(
                                  ff.user.displayName,
                                  style: TextStyle(
                                    color: Color(0xFF707070),
                                    fontSize: Space.lg,
                                  ),
                                ),
                        ),
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.edit,
                            size: Space.md,
                            color: Color(0xFF909090),
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                    SizedBox(height: Space.lg),
                    // TextFormField(
                    //   key: ValueKey('nickname'),
                    //   controller: displayNameController,
                    //   focusNode: nicknameNode,
                    //   textInputAction: TextInputAction.done,
                    //   keyboardType: TextInputType.text,
                    //   decoration: InputDecoration(labelText: "Nickname"),
                    // ),

                    /// Mobile
                    Text(
                      'Mobile No.',
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: Space.sm,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ff.user.phoneNumber.isNullOrBlank
                              ? Text(
                                  'Update Mobile Number',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: Space.md,
                                  ),
                                )
                              : Text(
                                  ff.user.phoneNumber,
                                  style: TextStyle(
                                    color: Color(0xFF707070),
                                    fontSize: Space.lg,
                                  ),
                                ),
                        ),
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.edit,
                            size: Space.md,
                            color: Color(0xFF909090),
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                    SizedBox(height: Space.md),

                    /// Birthday
                    Text(
                      'Birthday',
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: Space.sm,
                      ),
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

                    /// Gender
                    Text(
                      'Gender',
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: Space.sm,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gender == 'M' ? 'Male' : 'Female',
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: Space.lg,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.edit,
                            color: Color(0xFF909090),
                            size: Space.md,
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: RadioListTile(
                    //         value: 'M',
                    //         title: Text("Male"),
                    //         key: ValueKey('genderM'),
                    //         groupValue: gender,
                    //         onChanged: (str) {
                    //           setState(() => gender = str);
                    //         },
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: RadioListTile(
                    //         value: 'F',
                    //         title: Text("Female"),
                    //         key: ValueKey('genderF'),
                    //         groupValue: gender,
                    //         onChanged: (str) {
                    //           setState(() => gender = str);
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
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
