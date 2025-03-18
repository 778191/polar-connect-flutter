import 'package:fluttertoast/fluttertoast.dart';
import 'package:polar_connect/widgets/custom_colors.dart';

class CustomToast {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: CustomColors.tertiary,
      textColor: CustomColors.background,
      fontSize: 14.0,
    );
  }
}
