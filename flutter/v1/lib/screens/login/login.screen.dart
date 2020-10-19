import 'package:flutter/material.dart';
import 'package:v1/screens/login/login.form.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        child: LoginForm()
      ),
    );
  }
}
