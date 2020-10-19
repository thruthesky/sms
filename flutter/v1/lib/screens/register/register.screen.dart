import 'package:flutter/material.dart';
import 'package:v1/screens/register/register.from.dart';

class RegisterScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        child: RegisterForm(),
      ),
    );
  }
}
