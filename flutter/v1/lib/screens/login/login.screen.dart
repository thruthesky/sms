import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/user/kakao_login_button.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final passNode = FocusNode();

  bool loading = false;

  String _createNonce(int length) {
    final random = Random();
    final charCodes = List<int>.generate(length, (_) {
      int codeUnit;

      switch (random.nextInt(3)) {
        case 0:
          codeUnit = random.nextInt(10) + 48;
          break;
        case 1:
          codeUnit = random.nextInt(26) + 65;
          break;
        case 2:
          codeUnit = random.nextInt(26) + 97;
          break;
      }

      return codeUnit;
    });

    return String.fromCharCodes(charCodes);
  }

  Future<OAuthCredential> _createAppleOAuthCred() async {
    final nonce = _createNonce(32);
    print('nonce: $nonce');

    final nativeAppleCred = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: sha256.convert(utf8.encode(nonce)).toString(),
    );
    return new OAuthCredential(
      providerId: "apple.com", // MUST be "apple.com"
      signInMethod: "oauth", // MUST be "oauth"
      accessToken: nativeAppleCred
          .identityToken, // propagate Apple ID token to BOTH accessToken and idToken parameters
      idToken: nativeAppleCred.identityToken,
      rawNonce: nonce,
    );
  }

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
              SignInWithAppleButton(
                onPressed: () async {
                  try {
                    final oauthCred = await _createAppleOAuthCred();
                    print(oauthCred);

                    UserCredential userCredential = await FirebaseAuth.instance
                        .signInWithCredential(oauthCred);
                    print(userCredential.user);
                  } catch (e) {
                    Service.error(e);
                    print(e);
                  }
                },
              ),
              RaisedButton(
                child: Text('Google Sign-in'),
                onPressed: () async {
                  try {
                    await ff.signInWithGoogle();
                    Get.toNamed(RouteNames.home);
                  } catch (e) {
                    Service.error(e);
                  }
                },
              ),
              RaisedButton(
                child: Text('Facebook Sign-in'),
                onPressed: () async {
                  try {
                    await ff.signInWithFacebook();
                    Get.toNamed(RouteNames.home);
                  } catch (e) {
                    Service.error(e);
                  }
                },
              ),
              KakaoLoginButton(),
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
                    await ff.login(
                      email: emailController.text,
                      password: passwordController.text,
                      meta: {
                        'tokens': {
                          'and-another-token': true,
                        },
                      },
                    );

                    ff.onLogin(ff.user);
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
