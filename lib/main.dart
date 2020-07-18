import 'dart:io' show Platform;

import 'package:data_plugin/bmob/bmob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:fluro/fluro.dart';
import 'package:lalia/pages/intro_page.dart';
import 'package:lalia/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:device_info/device_info.dart';

import 'package:lalia/params/config.dart';
import 'package:lalia/params/param.dart';
import 'package:lalia/application.dart';
import 'package:lalia/route/routes.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/provider/card_list.dart';
import 'package:lalia/provider/password_list.dart';
import 'package:lalia/provider/theme_provider.dart';
import 'package:lalia/pages/login/login_page.dart';
import 'package:lalia/pages/login/auth_login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Router router = Router();
  Routes.configureRoutes(router);
  Application.router = router;
  Application.setupLocator();
  await Application.initSp();
  Application.initChannelAndHandle();
  await Config.configInit();

  if (Platform.isAndroid) {
    //设置Android头部的导航栏透明
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  // 自定义报错页面
  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            child: Text("App出现错误，快去反馈给作者!"),
            padding: laliaEdgeInsets.smallTBPadding,
          ),
          Padding(
            padding: laliaEdgeInsets.smallTBPadding,
          ),
          Padding(
            child: Text("以下是出错信息，请截图发到QQ2674754050"),
            padding: laliaEdgeInsets.smallTBPadding,
          ),
          Padding(
            child: Text(flutterErrorDetails.toString()),
            padding: laliaEdgeInsets.smallTBPadding,
          ),
        ],
      ),
    );
  };

  registerUser();

  final PasswordList passwords = PasswordList()..init();
  final CardList cards = CardList()..init();
  final ThemeProvider theme = ThemeProvider()..init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<PasswordList>.value(
        value: passwords,
      ),
      ChangeNotifierProvider<UserProvider>.value(
        value: UserProvider(),
      ),
      ChangeNotifierProvider<CardList>.value(
        value: cards,
      ),
      ChangeNotifierProvider<ThemeProvider>.value(value: theme)
    ],
    child: lalia(),
  ));
}

class lalia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Bmob.initMasterKey(
        "https://api2.bmob.cn",
        "15fbf4822fab8c694e1a4934bf83f95d",
        "db2d9720dfdb3a96dd6634763eda9c43",
        "b19f00cac79b5454bca1bde9ee910c95");
    return MaterialApp(
      title: '密语',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).currTheme,
      home: Config.enabledBiometrics
          ? AuthLoginPage()
          : Application.sp.getBool("FIRST_RUN") ? IntroPage() : LoginPage(),
//      home: IntroPage(),
      onGenerateRoute: Application.router.generator,
    );
  }
}

void registerUser() async {
  if (Application.sp.getBool("NEED_REGISTER") ?? true) {
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    String identification;
    String systemInfo;
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await infoPlugin.androidInfo;
      identification = info.androidId;
      systemInfo = "${info.model} android${info.version.release}";
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await infoPlugin.iosInfo;
      identification = info.identifierForVendor;
      systemInfo = "${info.model} IOS${info.systemVersion}";
    } else {
      return;
    }
    try {
      Response response = await Dio().get(
          "$laliaUrl/register?identification=$identification&systemInfo=$systemInfo");
      if ((response.data["result"] ?? '0') == "1") {
        Application.sp.setBool("NEED_REGISTER", false);
      } else {
        Application.sp.setBool("NEED_REGISTER", true);
      }
    } catch (e) {
      print("网络连接失败");
    }
  }
}
