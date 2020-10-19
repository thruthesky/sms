import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/app-service.dart';
import 'package:v1/services/route-names.dart';

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
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Password"),
              ),
              SizedBox(height: 30),
              RaisedButton(
                child: Text("Submit"),
                onPressed: () async {
                  /// remove any input focus.
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() => loading = true);

                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    Get.toNamed(RouteNames.home);
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
