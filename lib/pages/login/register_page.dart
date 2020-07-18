import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lalia/application.dart';
import 'package:lalia/params/config.dart';
import 'package:lalia/utils/bmob_util.dart';
import 'package:lalia/utils/encrypt_util.dart';
import 'package:lalia/utils/navigation_util.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/screen_util.dart';
import 'package:lalia/widgets/common/none_border_circular_textfield.dart';
import 'package:lalia/pages/login/login_page.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: laliaScreenUtil.setHeight(500)),
        child: Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(150),
              right: ScreenUtil().setWidth(150)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                child: Text(
                  "注册密语",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                padding: laliaEdgeInsets.smallTBPadding,
              ),
              NoneBorderCircularTextField(_usernameController, "请输入用户名",
                  Icon(Icons.person), false, null),
              NoneBorderCircularTextField(
                  _passwordController, "请输入密码", Icon(Icons.lock), true, null),
              NoneBorderCircularTextField(_secondController, "请再输入一遍",
                  Icon(Icons.lock_outline), true, null),
              Padding(
                padding: EdgeInsets.only(top: laliaScreenUtil.setHeight(100)),
              ),
              NeuomorphicContainer(
                borderRadius: BorderRadius.circular(laliaUI.bigBorderRadius),
                color: Theme.of(context).scaffoldBackgroundColor,
                style: NeuomorphicStyle.Convex,
                intensity: 0.1,
                offset: Offset(3, 3),
                blur: 4,
                child: FlatButton(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(laliaUI.bigBorderRadius))),
                  child: Text(
                    "注册",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => register(context),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: laliaScreenUtil.setHeight(300)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text("已有账号？登录"),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage())),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: laliaScreenUtil.setHeight(80)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> register(BuildContext context) async {
    if (_passwordController.text != _secondController.text) {
      Fluttertoast.showToast(msg: "两次密码输入不一致！");
      return;
    }
    // 判断是否已有账号存在
//    if (Application.sp.getString("username") == null) {
    // 判断用户名和密码长度
    if (_usernameController.text.length >= 6 &&
        _passwordController.text.length >= 6) {
      String _password = EncryptUtil.encrypt(_passwordController.text);
      if (!await BmobUtil.register(_usernameController.text, _password)) {
        return;
      }
      Application.sp.setString("username", _usernameController.text);
      Application.sp.setString("password", _password);
      Config.username = _usernameController.text;
      Config.password = _password;
      Config.enabledBiometrics = false;

      Fluttertoast.showToast(msg: "注册成功");
      NavigationUtil.goLoginPage(context);
    } else {
      Fluttertoast.showToast(msg: "用户名或密码长度必须大于等于6！");
    }
//    } else {
//      Fluttertoast.showToast(msg: "已有账号注册过，只允许单账号");
//    }
  }
}
