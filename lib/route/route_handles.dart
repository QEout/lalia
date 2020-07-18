import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:lalia/model/card_bean.dart';
import 'package:lalia/model/password_bean.dart';
import 'package:lalia/pages/login/login_page.dart';
import 'package:lalia/pages/login/auth_login_page.dart';
import 'package:lalia/pages/password/password_page.dart';
import 'package:lalia/pages/card/card_page.dart';
import 'package:lalia/pages/setting/setting_page.dart';
import 'package:lalia/pages/home_page.dart';
import 'package:lalia/pages/card/edit_card_page.dart';
import 'package:lalia/pages/card/view_card_page.dart';
import 'package:lalia/pages/password/edit_password_page.dart';
import 'package:lalia/pages/password/view_password_page.dart';
import 'package:lalia/pages/setting/category_manager_page.dart';

/// 登录页
var loginHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) =>
        LoginPage());

/// 生物识别登录页
var authLoginHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) =>
        AuthLoginPage());

/// 主页
var homeHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) =>
        HomePage());

/// 密码页
var passwordHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) =>
        PasswordPage());

/// 卡片页
var cardHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) =>
        CardPage());

/// 设置页
var settingHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) =>
        SettingPage());

/// 查看密码页面
var viewPasswordHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  PasswordBean data = params["data"].first;
  return ViewPasswordPage(data);
});

/// 编辑密码页面
var editPasswordHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  PasswordBean data = params["data"].first;
  return EditPasswordPage(data, "编辑密码");
});

/// 新增密码页面
var newPasswordHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  PasswordBean data = params["data"].first;
  return EditPasswordPage(data, "添加密码");
});

/// 查看卡片页面
var viewCardHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  CardBean data = params["data"].first;
  return ViewCardPage(data);
});

/// 编辑卡片页面
var editCardHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  CardBean data = params["data"].first;
  return EditCardPage(data, "编辑卡片");
});

/// 添加卡片页面
var newCardHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  CardBean data = params["data"].first;
  return EditCardPage(data, "添加卡片");
});

/// 属性管理页
var categoryManagerHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  String name = params['data'].first;
  return CategoryManagerPage(name);
});
