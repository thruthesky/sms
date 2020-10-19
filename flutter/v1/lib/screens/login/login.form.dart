import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  final passNode = FocusNode();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      child: Form(
        key: _formKey,
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
              controller: passController,
              focusNode: passNode,
              obscureText: true,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 30),
            RaisedButton(
              child: Text("Submit"),
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());

                if (_formKey.currentState.validate()) {
                  setState(() => loading = true);

                  print(emailController.text);
                  print(passController.text);

                  setState(() => loading = false);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
