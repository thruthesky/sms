import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/widgets/miscellaneous/icon_text_button.dart';
import 'package:v1/widgets/user/kakao_login_button.dart';

// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLoginButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Flexible(
        //   child: SignInWithAppleButton(
        //     text: '',
        //     borderRadius: BorderRadius.circular(50),
        //     onPressed: () async {
        //       try {
        //         await ff.signInWithApple();
        //         Get.toNamed(RouteNames.home);
        //       } catch (e) {
        //         Service.error(e);
        //       }
        //     },
        //   ),
        // ),

        IconTextButton(
          icon: FaIcon(
            FontAwesomeIcons.apple,
            size: 55,
          ),
          text: 'Apple',
          onTap: () async {
            try {
              await ff.signInWithApple();
              Get.toNamed(RouteNames.home);
            } catch (e) {
              Service.error(e);
            }
          },
        ),
        IconTextButton(
          icon: FaIcon(
            FontAwesomeIcons.google,
            size: 52,
            color: Colors.red[700],
          ),
          text: 'Google',
          onTap: () async {
            try {
              await ff.signInWithGoogle();
              Get.toNamed(RouteNames.home);
            } catch (e) {
              Service.error(e);
            }
          },
        ),
        IconTextButton(
          icon: FaIcon(
            FontAwesomeIcons.facebook,
            size: 52,
            color: Colors.blue[700],
          ),
          text: 'Facebook',
          onTap: () async {
            try {
              await ff.signInWithFacebook();
              Get.toNamed(RouteNames.home);
            } catch (e) {
              Service.error(e);
            }
          },
        ),
        KakaoLoginButton(),
      ],
    );
  }
}
