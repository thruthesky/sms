import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';

class KakaoLoginButton extends StatelessWidget {
  const KakaoLoginButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () async {
        /// 카카오톡 로그인을 경우, 상황에 따라 메일 주소가 없을 수 있다. 메일 주소가 필수 항목이 아닌 경우,
        /// 따라서, id 로 메일 주소를 만들어서, 자동 회원 가입을 한다.
        ///
        try {
          /// 카카오톡 앱이 핸드폰에 설치되었는가?
          final installed = await isKakaoTalkInstalled();

          print('installed: $installed');

          /// 카카오톡 앱이 설치 되었으면, 앱으로 로그인, 아니면 OAuth 로 로그인.
          final authCode = installed
              ? await AuthCodeClient.instance.requestWithTalk()
              : await AuthCodeClient.instance.request();
          // final authCode = await AuthCodeClient.instance.requestWithTalk();

          AccessTokenResponse token =
              await AuthApi.instance.issueAccessToken(authCode);

          /// Store access token in AccessTokenStore for future API requests.
          /// 이걸 해야지, 아래에서 UserApi.instance.me() 와 같이 호출을 할 수 있나??
          AccessTokenStore.instance.toStore(token);

          String refreshedToken = token.refreshToken;
          print('refreshedToken: $refreshedToken');

          User user = await UserApi.instance.me();

          print('user:');
          print(user);

          Map<String, String> data = {
            'email': 'kakaotalk${user.id}@kakao.com',
            'password': KakaoContext.clientId + ':${user.id}',
            'displayName':
                user.properties != null && user.properties['nickname'] != null
                    ? user.properties['nickname']
                    : '_',
            'photoURL': user.properties != null &&
                    user.properties['profile_image'] != null
                ? user.properties['profile_image']
                : '',
          };

          print('user data: $data');

          try {
            await ff.login(email: data['email'], password: data['password']);
            Get.toNamed(RouteNames.home);
          } catch (e) {
            if (e.code == 'user-not-found') {
              print('register...');
              await ff.register(data);
              Get.toNamed(RouteNames.home);
            } else {
              print('rethrow $e');
              rethrow;
            }
          }
        } catch (e) {
          /// 카카오톡 로그인에서 에러가 발생하는 경우,
          /// 에러 메시지가 로그인 창에 표시가 되므로, 상단 위젯에서는 에러를 무시를 해도 된다.
          /// 예를 들어, 비밀번호 오류나, 로그인 취소 등.
          print('error: =====> ');
          print(e);
          Service.error(e.toString());
          throw e;
        }
      },
      child: Text('Kakao Login'),
    );
  }
}
