import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';

import 'package:lalia/application.dart';
import 'package:lalia/look_img_page.dart';
import 'package:lalia/route/routes.dart';
import 'package:lalia/model/password_bean.dart';
import 'package:lalia/route/transparent_route.dart';

class NavigationUtil {
  static _navigateTo(BuildContext context, String path,
      {bool replace: false,
      bool clearStack: false,
      Duration transitionDuration: const Duration(milliseconds: 250),
      RouteTransitionsBuilder transitionBuilder}) {
    Application.router.navigateTo(context, path,
        replace: replace,
        clearStack: clearStack,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        transition: TransitionType.material);
  }

  static void goLoginPage(BuildContext context) {
    _navigateTo(context, Routes.login, clearStack: true);
  }

  static void goAuthLoginPage(BuildContext context) {
    _navigateTo(context, Routes.authLogin, clearStack: true);
  }

  static void goHomePage(BuildContext context) {
    _navigateTo(context, Routes.home, clearStack: true);
  }

  static void goPasswordPage(BuildContext context) {
    _navigateTo(context, Routes.password);
  }

  static void goCardPage(BuildContext context) {
    _navigateTo(context, Routes.card);
  }

  static void goSettingPage(BuildContext context) {
    _navigateTo(context, Routes.setting);
  }

  static void goViewPasswordPage(BuildContext context,
      {@required PasswordBean data}) {
    _navigateTo(context, Routes.viewPassword);
  }

  /// 查看图片页面
  static void goLookImgPage(
      BuildContext context, List<String> imgs, int index) {
//    Application.router.navigateTo(context, '${Routes.lookImg}?imgs=${FluroConvertUtils.object2string(imgs.join(','))}&index=$index', transitionBuilder: (){});
//    _navigateTo(context, '${Routes.lookImg}?imgs=${FluroConvertUtils.object2string(imgs.join(','))}&index=$index');
//    _navigateTo(context, '${Routes.lookImg}');
    Navigator.push(
      context,
      TransparentRoute(
        builder: (_) => LookImgPage(imgs, index),
      ),
    );
  }
}
