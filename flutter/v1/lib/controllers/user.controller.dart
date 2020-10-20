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

  String get displayName {
    return user?.displayName;
  }

  String get photoUrl {
    return user?.photoURL;
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
      print('this.user = user:');
      this.user = user;
      update();
    });

    super.onInit();
  }

  reload() async {
    await user.reload();
    user = FirebaseAuth.instance.currentUser;
    update();
  }
}
