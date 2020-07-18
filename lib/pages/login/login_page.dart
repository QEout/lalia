import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lalia/utils/bmob_util.dart';
import 'package:lalia/utils/request.dart';
import 'package:lalia/widgets/gadge.dart';
import 'package:lalia/widgets/state_layout.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';
import 'package:provider/provider.dart';

import 'package:lalia/application.dart';
import 'package:lalia/params/config.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/navigation_util.dart';
import 'package:lalia/utils/encrypt_util.dart';
import 'package:lalia/utils/screen_util.dart';
import 'package:lalia/provider/card_list.dart';
import 'package:lalia/provider/password_list.dart';
import 'package:lalia/pages/login/register_page.dart';
import 'package:lalia/pages/about_page.dart';
import 'package:lalia/widgets/common/none_border_circular_textfield.dart';
import 'package:url_launcher/url_launcher.dart';

/// 登陆页面
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  var _usernameController;
  var _passwordController;

  int inputErrorTimes = 0; // 超过五次自动清除所有内容
  Map zhihuDaily = {'title': ''};

  @override
  void initState() {
    _usernameController = TextEditingController(text: Config.username);
    _passwordController = TextEditingController();
    if (Application.sp.getBool("FIRST_RUN") ?? true) {
      WidgetsBinding.instance.addPostFrameCallback((callback) {
        showDialog(
            context: context,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(laliaUI.smallBorderRadius),
              ),
              title: Text("服务条款"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AboutPage.serviceContent,
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("同意并继续"),
                  onPressed: () async {
                    initAppFirstRun();
                    await Config.configInit();
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("取消"),
                  onPressed: () => exit(0),
                )
              ],
            ));
      });
    }
    zhihu();
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: laliaScreenUtil.setHeight(100)),
        child: Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(150),
              right: ScreenUtil().setWidth(150)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              zhihuDaily["images"] == null
                  ? Container(height: 70)
                  : NeuomorphicContainer(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      style: NeuomorphicStyle.Flat,
                      intensity: 0.15,
                      offset: Offset(3, 3),
                      blur: 2,
                      height: 70,
                      width: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ExtendedImage.network(
                          zhihuDaily["images"][0],
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      )),
//              Padding(
//                padding: EdgeInsets.only(top: laliaScreenUtil.setHeight(50)),
//              ),
              Padding(
                child: Text(
                  "登录",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                padding: laliaEdgeInsets.smallTBPadding,
              ),
              Padding(
                padding: EdgeInsets.only(top: laliaScreenUtil.setHeight(50)),
              ),
              NoneBorderCircularTextField(_usernameController, "请输入用户名",
                  Icon(Icons.person), false, null),
              NoneBorderCircularTextField(
                _passwordController,
                "请输入密码",
                Icon(Icons.lock),
                true,
                login,
              ),
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
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(laliaUI.bigBorderRadius)),
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                  child: Text("登录",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => login(),
                ),
//                padding: laliaEdgeInsets.smallTBPadding,
              ),
              Padding(
                padding: EdgeInsets.only(top: laliaScreenUtil.setHeight(200)),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text("注册"),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage())),
                  ),
                  Text("|"),
                  FlatButton(
                    child: Text("使用生物识别"),
                    onPressed: () {
                      if (Config.enabledBiometrics)
                        NavigationUtil.goAuthLoginPage(context);
                      else
                        Fluttertoast.showToast(msg: "您还未开启生物识别");
                    },
                  )
                ],
              ),

              _buildZhihu(),
//              Padding(
//                padding: EdgeInsets.only(bottom: laliaScreenUtil.setHeight(80)),
//              )
            ],
          ),
        ),
      ),
    );
  }

  void login() async {
    if (_usernameController.text == "" || _passwordController.text == "") {
      Fluttertoast.showToast(msg: "请输入用户名或密码");
      return;
    }
    String _password = EncryptUtil.encrypt(_passwordController.text);
    if (inputErrorTimes >= 5) {
      await Provider.of<PasswordList>(context).clear();
      await Provider.of<CardList>(context).clear();
      await Application.sp.clear();
      Config.configClear();
      Fluttertoast.showToast(msg: "连续错误超过五次！已清除所有数据，请重新注册");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterPage()));
    } else {
      if (Config.username != "" && Config.password != "") {
        if (Config.username == _usernameController.text &&
            _passwordController.text == EncryptUtil.decrypt(Config.password)) {
          NavigationUtil.goHomePage(context);
          Fluttertoast.showToast(msg: "登录成功");
        } else if (_usernameController.text == "" ||
            _passwordController.text == "") {
          Fluttertoast.showToast(msg: "请输入用户名或密码");
        } else {
          if (await BmobUtil.login(_usernameController.text,
              EncryptUtil.encrypt(_passwordController.text), context)) {
            NavigationUtil.goHomePage(context);
            Application.sp.setString("username", _usernameController.text);
            Application.sp.setString("password", _password);
            Config.username = Application.sp.getString("username");
            Config.password = Application.sp.getString("password");
            Fluttertoast.showToast(msg: "登录成功");
          } else {
            inputErrorTimes++;
            Fluttertoast.showToast(
                msg: "用户名或密码错误，已错误$inputErrorTimes次，连续超过五次将删除所有数据！");
          }
        }
      } else if (await BmobUtil.login(_usernameController.text,
          EncryptUtil.encrypt(_passwordController.text), context)) {
        NavigationUtil.goHomePage(context);
        Application.sp.setString("username", _usernameController.text);
        Application.sp.setString("password", _password);
        Config.username = Application.sp.getString("username");
        Config.password = Application.sp.getString("password");
        Fluttertoast.showToast(msg: "登录成功");
      } else {
        Fluttertoast.showToast(msg: "当前不存在用户，请先注册！");
      }
    }
  }

  zhihu() async {
    String url = "https://news-at.zhihu.com/api/4/news/latest";
    String body = await Request.get(url);
    Map data = json.decode(body);
    List stories = data['stories'];
    stories.addAll(data['top_stories']);
    int index = new Random().nextInt(8);
    Map repo = stories[index];
    setState(() {
      zhihuDaily = repo;
    });
  }

  _buildZhihu() {
    return zhihuDaily['title'] == ''
        ? SizedBox(
            height: 30,
          )
        : GestureDetector(
            child: ListTile(
              title: Text(
                zhihuDaily["title"],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                zhihuDaily["hint"],
                style: TextStyle(fontSize: 14.0),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
            onTap: () => launch('https://daily.zhihu.com/story/' +
                zhihuDaily["id"].toString()));
  }
}
