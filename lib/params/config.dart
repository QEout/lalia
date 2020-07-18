import 'package:lalia/application.dart';
import 'package:lalia/params/runtime_data.dart';

/// 存储系统参数
class Config {
  Config._();

  static String username; // 当前使用者用户名
  static String password; // 使用者密码
  static bool enabledBiometrics; // 是否启用生物识别
  static bool longPressCopy; // 是否开启长按复制，否则为长按多选
  static bool multiSelected; // 是否点击了多选按钮
  static bool cloud;

  static bool autofill;

  static bool passSort;
  static bool cardSort;
  static String theme; // 主题名

  /// 参数初始化
  static configInit() async {
    RuntimeData.initData();
    if (Application.sp == null) {
      await Application.initSp();
    }
    // 初始化当前用户名与密码
    username = Application.sp.getString("username") ?? "";
    password = Application.sp.getString("password") ?? "";
    // 判断是否开启生物识别
    enabledBiometrics = Application.sp.getBool("biometrics") ?? false;
    // 判断长按功能
    longPressCopy = Application.sp.getBool("longPressCopy") ?? true;
    // 判断云备份
    cloud = Application.sp.getBool("cloud") ?? true;
    autofill = Application.sp.getBool("autofill") ?? false;
    // 判断密码排序
    passSort = Application.sp.getBool("passSort") ?? true;
    // 判断卡片排序
    cardSort = Application.sp.getBool("cardSort") ?? true;
    // 初始化主题
    theme = Application.sp.getString("theme") ?? "blue";
    // 是否点击了多选按钮
    multiSelected = false;
  }

  /// 清空参数
  static configClear() async {
    username = "";
    password = "";
    enabledBiometrics = false;
    RuntimeData.clearData();
  }
}
