import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/commons/app_drawer.dart';
import 'package:v1/widgets/miscellaneous/or_divider.dart';
import 'package:v1/widgets/user/social_login_buttons.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final passNode = FocusNode();

  bool loading = false;
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text('login'.tr),
      ),
      endDrawer: CommonAppDrawer(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: Space.xl),
              Text(
                'Proceed with your',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Space.xxl),

              /// Email Input
              Text(
                'Email Address',
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
              SizedBox(height: Space.xl),

              /// Password Input
              Text(
                'Password',
                style: TextStyle(color: Color(0xff717171)),
              ),
              TextFormField(
                key: ValueKey('password'),
                controller: passwordController,
                focusNode: passNode,
                obscureText: hidePassword,
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
              SizedBox(height: Space.xxl),

              if (loading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              /// Submit button
              if (!loading)
                FlatButton(
                  color: Color(0xff0098E1),
                  padding: EdgeInsets.all(Space.md),
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () async {
                    /// remove any input focus.
                    FocusScope.of(context).requestFocus(new FocusNode());
                    setState(() => loading = true);

                    try {
                      await ff.login(
                        email: emailController.text,
                        password: passwordController.text,
                        meta: {
                          'tokens': {
                            'and-another-token': true,
                          },
                        },
                      );

                      Service.redirectAfterLoginOrRegister();
                    } catch (e) {
                      setState(() => loading = false);
                      Service.error(e);
                    }
                  },
                ),

              /// forgot password & Register Redirect buttons
              Row(
                children: [
                  FlatButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                  Spacer(),
                  FlatButton(
                    minWidth: 0,
                    onPressed: () {
                      Service.openScreen(RouteNames.register);
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    padding: EdgeInsets.all(0),
                  )
                ],
              ),

              SizedBox(height: Space.md),
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
