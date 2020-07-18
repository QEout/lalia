import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lalia/params/param.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lalia/application.dart';
import 'package:lalia/params/config.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/provider/theme_provider.dart';
import 'package:lalia/services/authentication_service.dart';
import 'package:lalia/pages/about_page.dart';
import 'package:lalia/pages/setting/account_manager_page.dart';
import 'package:lalia/pages/setting/category_manager_page.dart';
import 'package:lalia/pages/setting/import/import_export_page.dart';
import 'package:lalia/widgets/setting/input_main_password_dialog.dart';
import 'package:lalia/widgets/setting/check_update_dialog.dart';
import 'package:share/share.dart';
import 'package:autofill_service/autofill_service.dart';

/// 设置页面
class SettingPage extends StatefulWidget {
  @override
  _SettingPage createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage>
    with AutomaticKeepAliveClientMixin {
  AuthenticationService _localAuthService;

  ScrollController _controller;

  AutofillServiceStatus _autofillStatus;
  AutofillPreferences _autofillPrefs;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _localAuthService = Application.getIt<AuthenticationService>();
    _controller = ScrollController();
    _doInit();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _doInit() async {
    final autoFill = AutofillService();
    _autofillStatus = await autoFill.status();
    if (_autofillStatus != AutofillServiceStatus.unsupported) {
      _autofillPrefs = await autoFill.getPreferences();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          splashColor: Colors.transparent,
          child: Text(
            "设置",
            style: laliaTextUI.titleBarStyle,
          ),
          onTap: () {
            _controller.animateTo(0,
                duration: Duration(milliseconds: 200), curve: Curves.linear);
          },
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              controller: _controller,
              children: <Widget>[
                Container(
                  child: ListTile(
                    title: Text("主账号管理"),
                    leading: Icon(
                      Icons.account_circle,
                      color: laliaColorUI.allColor[8],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => AccountManagerPage()));
                    },
                  ),
                  padding: laliaEdgeInsets.listInset,
                ),

                Container(
                    child: ListTile(
                      title: Text("长按复制密码或卡号"),
//                      subtitle: Text('按复制密码或卡'),
                      leading: Icon(Icons.present_to_all,
                          color: laliaColorUI.allColor[8]),
                      // subtitle: Params.longPressCopy
                      //     ?Text("当前长按为复制密码或卡号")
                      //     :Text("当前长按为多选"),
                      trailing: Switch(
                        value: Config.longPressCopy,
                        activeColor: laliaColorUI.allColor[8],
                        onChanged: (sw) async {
                          Application.sp.setBool("longPressCopy", sw);
                          setState(() {
                            Config.longPressCopy = sw;
                          });
                        },
                      ),
                    ),
                    padding: laliaEdgeInsets.listInset),
                Container(
                    child: ListTile(
                      title: Text("自动填充密码"),
                      subtitle:
                          _autofillStatus == AutofillServiceStatus.unsupported
                              ? const Text('您的系统版本过低（需要安卓8.0及更高）')
                              : null,
                      leading:
                          Icon(Icons.title, color: laliaColorUI.allColor[8]),
                      trailing: Switch(
                        value: _autofillStatus == AutofillServiceStatus.enabled,
                        activeColor: laliaColorUI.allColor[8],
                        onChanged:
                            _autofillStatus == AutofillServiceStatus.unsupported
                                ? null
                                : (val) async {
                                    if (val) {
                                      await AutofillService()
                                          .requestSetAutofillService();
                                    } else {
                                      await AutofillService()
                                          .disableAutofillServices();
                                    }
                                    await _doInit();
                                  },
                      ),
                    ),
                    padding: laliaEdgeInsets.listInset),
                Container(
                    child: ListTile(
                      title: Text("生物识别"),
                      leading: Icon(Icons.fingerprint,
                          color: laliaColorUI.allColor[8]),
                      trailing: Switch(
                        activeColor: laliaColorUI.allColor[8],
                        value: Config.enabledBiometrics,
                        onChanged: (sw) async {
                          if (await LocalAuthentication().canCheckBiometrics) {
                            showDialog(
                              context: context,
                              builder: (context) => InputMainPasswordDialog(),
                            ).then((right) async {
                              if (right) {
                                var auth =
                                    await _localAuthService.authenticate();
                                if (auth) {
                                  await _localAuthService.stopAuthenticate();
                                  Application.sp.setBool("biometrics", sw);
                                  Config.enabledBiometrics = sw;
                                  setState(() {});
                                } else {
                                  Fluttertoast.showToast(msg: "授权失败");
                                }
                              }
                            });
                          } else {
                            Application.sp.setBool("biometrics", false);
                            Config.enabledBiometrics = false;
                            Fluttertoast.showToast(msg: "您的设备似乎不支持生物识别");
                          }
                        },
                      ),
                    ),
                    padding: laliaEdgeInsets.listInset),
                Container(
                    child: ListTile(
                      title: Text("云备份"),
                      leading: Icon(Icons.cloud_done,
                          color: laliaColorUI.allColor[8]),
                      // subtitle: Params.longPressCopy
                      //     ?Text("当前长按为复制密码或卡号")
                      //     :Text("当前长按为多选"),
                      trailing: Switch(
                        value: Config.cloud,
                        activeColor: laliaColorUI.allColor[8],
                        onChanged: (sw) async {
                          Application.sp.setBool("cloud", sw);
                          setState(() {
                            Config.cloud = sw;
                          });
                        },
                      ),
                    ),
                    padding: laliaEdgeInsets.listInset),

                Container(
                    child: ListTile(
                      title: Text("主题颜色"),
                      leading: Icon(Icons.color_lens,
                          color: laliaColorUI.allColor[8]),
                      onTap: () {
                        showDialog(
                            context: context,
                            child: AlertDialog(
                              title: Text("修改主题"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      laliaUI.smallBorderRadius)),
                              content: SingleChildScrollView(
                                  child: Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 50),
                                      color: Colors.blue,
                                      child: Center(
                                        child: Text(
                                          "蓝天",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(context)
                                          .changeTheme("blue");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 50),
                                      color: Color.fromRGBO(225, 193, 150, 1),
                                      child: Center(
                                        child: Text(
                                          "流金",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(context)
                                          .changeTheme("gold");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 50),
                                      color: Colors.red,
                                      child: Center(
                                        child: Text(
                                          "正红",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(context)
                                          .changeTheme("red");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 50),
                                      color: Colors.teal,
                                      child: Center(
                                        child: Text(
                                          "烟青",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(context)
                                          .changeTheme("teal");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 50),
                                      color: Colors.deepPurple,
                                      child: Center(
                                        child: Text(
                                          "紫罗兰",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(context)
                                          .changeTheme("deepPurple");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 50),
                                      color: Colors.orange,
                                      child: Center(
                                        child: Text(
                                          "大橙",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(context)
                                          .changeTheme("orange");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 50),
                                      color: Colors.pink,
                                      child: Center(
                                        child: Text(
                                          "亮粉",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(context)
                                          .changeTheme("pink");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 50),
                                      color: Colors.blueGrey,
                                      child: Center(
                                        child: Text(
                                          "蓝灰",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(context)
                                          .changeTheme("blueGrey");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 50),
                                      color: Colors.black,
                                      child: Center(
                                        child: Text(
                                          "夜间",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(context)
                                          .changeTheme("dark");
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              )),
                            ));
                      },
                    ),
                    padding: laliaEdgeInsets.listInset),
                Container(
                  padding: laliaEdgeInsets.dividerInset,
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Container(
                    child: ListTile(
                      title: Text("标签管理"),
                      leading: Icon(Icons.label_outline,
                          color: laliaColorUI.allColor[0]),
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    CategoryManagerPage("标签")));
                      },
                    ),
                    padding: laliaEdgeInsets.listInset),
                Container(
                    child: ListTile(
                      title: Text("文件夹管理"),
                      leading: Icon(Icons.folder_open,
                          color: laliaColorUI.allColor[0]),
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    CategoryManagerPage("文件夹")));
                      },
                    ),
                    padding: laliaEdgeInsets.listInset),
                Container(
                  padding: laliaEdgeInsets.dividerInset,
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Container(
                    child: ListTile(
                      title: Text("导入/导出"),
                      leading: Icon(Icons.import_export,
                          color: laliaColorUI.allColor[5]),
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ImportExportPage(),
                            ));
                      },
                    ),
                    padding: laliaEdgeInsets.listInset),

                NeuomorphicContainer(
                    margin: laliaEdgeInsets.listInset,
                    borderRadius: BorderRadius.circular(11),
                    intensity: 0.1,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    offset: Offset(2, 2),
                    blur: 4,
                    style: NeuomorphicStyle.Flat,
                    child: Container(
                      child: ListTile(
                          title: Text("推荐给好友"),
                          leading: Icon(Icons.share,
                              color: laliaColorUI.allColor[2]),
                          onTap: () async => await _recommend()),
//                    padding: laliaEdgeInsets.listInset
                    )),
                Container(
                  padding: laliaEdgeInsets.dividerInset,
                  child: Divider(
                    thickness: 1,
                  ),
                ),
//                Container(
//                    child: ListTile(
//                        title: Text("留言区"),
//                        leading: Icon(Icons.feedback, color: laliaColorUI.allColor[7]),
//                        onTap: () => Navigator.push(context, CupertinoPageRoute(
//                          builder: (context) => FeedbackPage(),
//                        ))
//                    ),
//                    padding: laliaEdgeInsets.listInset
//                ),
                Container(
                    child: ListTile(
                        title: Text("检查更新"),
                        leading:
                            Icon(Icons.update, color: laliaColorUI.allColor[7]),
                        onTap: () {
                          showDialog(
                              context: context, child: CheckUpdateDialog());
                        }),
                    padding: laliaEdgeInsets.listInset),
                Container(
                    child: ListTile(
                      title: Text("关于"),
                      leading:
                          Icon(Icons.details, color: laliaColorUI.allColor[7]),
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AboutPage(),
                            ));
                      },
                    ),
                    padding: laliaEdgeInsets.listInset),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<Null> _recommend() async {
    try {
      Response<Map> response = await Dio(BaseOptions(connectTimeout: 10))
          .get("$laliaUrl/update?version=1.0.0");
      if (response.data['have_update'] == "1") {
        Share.share(
            "【lalia】我发现了一款应用，快来下载吧！下载地址：${response.data['download_url']}",
            subject: "软件推荐——密语");
      } else {
        Share.share(
            "【lalia】我发现了一款应用，快来下载吧！下载地址：https://www.caolv.top/assets/app/lalia_V${Application.version}_signed.apk");
      }
    } catch (e) {
      Share.share(
          "【lalia】我发现了一款应用，快来下载吧！下载地址：https://www.caolv.top/assets/app/lalia_V${Application.version}_signed.apk");
    }
  }
}
