class Utils {
  static String getImgPath(String name, {String format: 'png'}) {
    return 'assets/images/$name.$format';
  }
}

//class Toast {
//  static show(String msg, {duration = 2000}) {
//    Fluttertoast.showToast(
//        msg:msg,
//
//    );
//  }
//
//  static cancelToast() {
//    dismissAllToast();
//  }
//}
