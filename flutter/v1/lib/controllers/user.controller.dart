import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class UserController extends GetxController {
  User user;

  bool get isLoggedIn {
    return user != null;
  }

  bool get isNotLoggedIn {
    return !isLoggedIn;
  }

  String get uid {
    return user?.uid;
  }

  @override
  void onInit() {
    // print('==>>  UserController::onInit()');

    /// authStateChanges() firebase twcie on boot. This seems to be normal.
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        // print('User is currently signed out!');
      } else {
        // print('==>> print user: ');
        // print(user);
      }
      this.user = user;
      update();
    });

    super.onInit();
  }
}
