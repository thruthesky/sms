import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final nicknameController = TextEditingController();

  final passNode = FocusNode();
  final nicknameNode = FocusNode();

  DateTime birthDate;
  String gender = 'M';

  bool loading = false;

  @override
  void initState() {
    final now = DateTime.now();
    birthDate = now;
    super.initState();
  }

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
              onEditingComplete: nicknameNode.requestFocus,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: "Password"),
            ),
            TextFormField(
              key: ValueKey('nickname'),
              controller: nicknameController,
              focusNode: nicknameNode,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: "Nickname"),
            ),
            SizedBox(height: 20),
            Text('Birthday'),
            Row(
              children: [
                Text(
                    '${birthDate.year} - ${birthDate.month} - ${birthDate.day}'),
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
            Text('Gender - $gender'),
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
              onPressed: () {
                // remove any input focus.

                FocusScope.of(context).requestFocus(new FocusNode());

                if (_formKey.currentState.validate()) {
                  setState(() => loading = true);

                  print(emailController.text);
                  print(passController.text);
                  print(nicknameController.text);
                  print(birthDate.toString());
                  print(gender);

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
