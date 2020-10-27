import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/spaces.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final passNode = FocusNode();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Space.md),
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
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Password"),
              ),
              SizedBox(height: 32),
              RaisedButton(
                child: loading ? CircularProgressIndicator() : Text("Submit"),
                onPressed: () async {
                  /// remove any input focus.
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() => loading = true);

                  try {
                    /// Sign in with registered Firebase credentials.
                    // UserCredential user =
                    //     await FirebaseAuth.instance.signInWithEmailAndPassword(
                    //   email: emailController.text,
                    //   password: passwordController.text,
                    // );

                    await ff.login(
                      email: emailController.text,
                      password: passwordController.text,
                      meta: {
                        'tokens': {
                          'and-another-token': true,
                        },
                      },
                    );

                    Service.onLogin(ff.user);
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
