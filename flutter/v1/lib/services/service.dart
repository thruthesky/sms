import 'package:get/get.dart';

class Service {
  static error(dynamic e) {
    print('e.runtimeType: ${e.runtimeType}');
    print("${e.message} (${e.code})");
    String msg = '';

    /// For firebase error object
    if (e.code != null && e.message != null) {
      if (e.code == 'weak-password') {
        msg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'The account already exists for that email.';
      } else if (e.code == 'permission-denied') {
        msg = 'Permission denied. You do not have permission.';
      } else {
        msg = "${e.message} (${e.code})";
      }
    } else {
      msg = 'Unknown error';
    }
    Get.snackbar('Error', msg);
  }
}
