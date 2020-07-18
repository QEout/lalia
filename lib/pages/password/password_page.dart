import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lalia/application.dart';
import 'package:lalia/services/authentication_service.dart';
import 'package:lalia/widgets/robot_widget.dart';
import 'package:lalia/widgets/setting/input_main_password_dialog.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:lalia/params/config.dart';
import 'package:lalia/params/runtime_data.dart';
import 'package:lalia/params/lalia_type.dart';
import 'package:lalia/pages/password/edit_password_page.dart';
import 'package:lalia/pages/password/password_widget_item.dart';
import 'package:lalia/pages/search/search_page.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/screen_util.dart';
import 'package:lalia/widgets/common/search_button_widget.dart';
import 'package:lalia/widgets/common/confirm_dialog.dart';
import 'package:lalia/widgets/common/select_item_dialog.dart';
import 'package:lalia/provider/password_list.dart';

/// 密码页面
class PasswordPage extends StatefulWidget {
  @override
  _PasswordPageState createState() {
    return _PasswordPageState();
  }
}

class _PasswordPageState extends State<PasswordPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller;

  bool get isAutofillSelector =>
      WidgetsBinding.instance.window.defaultRouteName == '/autofill';

//  bool get isAutofillSelector=>true;
  double _opacity = 0;
  String _toggle = "reposo";
  WidgetsBinding widgetsBinding = WidgetsBinding.instance;

  @override
  void initState() {
    _initData();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Null> _query() async {
    await Provider.of<PasswordList>(context).init();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    if (isAutofillSelector)
      ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: laliaEdgeInsets.smallLPadding,
            child: InkWell(
              splashColor: Colors.transparent,
              child: Text(
                "密码",
                style: laliaTextUI.titleBarStyle,
              ),
              onTap: () {
                _controller.animateTo(0,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.linear);
              },
            ),
          ),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Config.multiSelected
                ? Row(
                    children: <Widget>[
                      PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case "删除":
                                _deletePassword(context);
                                break;
                              case "移动":
                                _movePassword(context);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                                PopupMenuItem(value: "移动", child: Text("移动")),
                                PopupMenuItem(value: "删除", child: Text("删除")),
                              ]),
                      Padding(
                        padding: laliaEdgeInsets.smallLPadding,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        child: Icon(Icons.select_all),
                        onTap: () {
                          if (RuntimeData.multiPasswordList.length !=
                              Provider.of<PasswordList>(context)
                                  .passwordList
                                  .length) {
                            RuntimeData.multiPasswordList.clear();
                            setState(() {
                              RuntimeData.multiPasswordList.addAll(
                                  Provider.of<PasswordList>(context)
                                      .passwordList);
                            });
                          } else {
                            setState(() {
                              RuntimeData.multiPasswordList.clear();
                            });
                          }
                        },
                      ),
                    ],
                  )
                : Container(),
            Padding(
              padding: laliaEdgeInsets.smallLPadding,
            ),
            InkWell(
              splashColor: Colors.transparent,
              child: Icon(
                Icons.sort_by_alpha,
                color: Config.passSort
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
              ),
              onTap: () {
                setState(() {
                  Config.passSort = !Config.passSort;
                  Provider.of<PasswordList>(context).refresh();
                });
              },
            ),
            Padding(
              padding: laliaEdgeInsets.smallLPadding,
            ),
            InkWell(
              splashColor: Colors.transparent,
              child:
                  Config.multiSelected ? Icon(Icons.clear) : Icon(Icons.menu),
              onTap: () {
                setState(() {
                  RuntimeData.multiPasswordList.clear();
                  Config.multiSelected = !Config.multiSelected;
                });
              },
            ),
            Padding(
              padding: laliaEdgeInsets.smallLPadding,
            ),
            Padding(
              padding: laliaEdgeInsets.smallLPadding,
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // 搜索框 按钮
                SearchButtonWidget(_searchPress, "密码"),
                !isAutofillSelector
                    ? Padding(
                        padding: EdgeInsets.only(
                            bottom: laliaScreenUtil.setWidth(50)),
                      )
                    : SizedBox(
                        width: 1,
                      ),
                isAutofillSelector
                    ? Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Card(
//                color: Colors.lightGreen,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '请点击需要的密码卡片',
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 1,
                      ),
                // 密码列表
                Expanded(
                  child: RefreshIndicator(
                      onRefresh: _query,
                      child: Scrollbar(
                          child: Provider.of<PasswordList>(context)
                                      .passwordList
                                      .length >=
                                  999
                              ? Config.multiSelected
                                  ? ListView.builder(
                                      controller: _controller,
                                      itemBuilder: (context, index) =>
                                          MultiPasswordWidgetItem(index),
                                      itemCount:
                                          Provider.of<PasswordList>(context)
                                              .passwordList
                                              .length,
                                    )
                                  : ListView.builder(
                                      controller: _controller,
                                      itemBuilder: (context, index) =>
                                          PasswordWidgetItem(
                                        index,
                                        autofill: isAutofillSelector,
                                      ),
                                      itemCount:
                                          Provider.of<PasswordList>(context)
                                              .passwordList
                                              .length,
                                    )
                              : RobotWidget())),
                ),
              ],
            ),
            _opacity == 0
                ? SizedBox(
                    width: 1,
                  )
                : ClipRect(
                    //可裁切的矩形
                    child: BackdropFilter(
                    //背景过滤器
                    //引入图片过虑器（blur:模糊设置）
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Opacity(
                        //设置透明度
                        opacity: _opacity, //半透明
                        child: GestureDetector(
                          child: Container(
                            width: Screen.width,
                            height: Screen.height,
                            decoration:
                                BoxDecoration(color: Colors.white), //盒子修饰器
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => InputMainPasswordDialog(),
                              barrierDismissible: false,
                            ).then((right) async {
                              if (right ?? false) {
                                setState(() {
                                  _opacity = 0;
                                });
                              }
                            });
                          },
                        )),
                  ))
          ],
        ),
        // 添加 按钮
        floatingActionButton: Consumer<PasswordList>(
            builder: (context, model, _) => NeuomorphicContainer(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  style: NeuomorphicStyle.Concave,
                  intensity: 0.1,
                  offset: Offset(1, 1),
                  blur: 1,
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Icon(
                      Icons.add,
                      color: laliaColorUI.allColor[8],
                      size: 40,
                    ),
                    onPressed: () {
                      Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      EditPasswordPage(null, "添加密码")))
                          .then((resData) async {
                        if (resData != null) {
                          model.insertPassword(resData);
                          if (RuntimeData.newPasswordOrCardCount >= 3) {
                            await Provider.of<PasswordList>(context).refresh();
                          }
                        }
                      });
                    },
                    heroTag: "password",
                  ),
                )));
  }

  _searchPress() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchPage(laliaType.PASSWORD)));
  }

  void _deletePassword(BuildContext context) {
    if (RuntimeData.multiPasswordList.length == 0) {
      Fluttertoast.showToast(msg: "请选择至少一项密码");
    } else {
      showDialog<bool>(
              context: context,
              builder: (context) => ConfirmDialog("确认删除",
                  "您将删除${RuntimeData.multiPasswordList.length}项密码，确认吗？"))
          .then((confirm) {
        if (confirm) {
          for (var item in RuntimeData.multiPasswordList) {
            Provider.of<PasswordList>(context).deletePassword(item);
          }
          RuntimeData.multiPasswordList.clear();
        }
      });
    }
  }

  void _movePassword(BuildContext context) {
    if (RuntimeData.multiPasswordList.length == 0) {
      Fluttertoast.showToast(msg: "请选择至少一项密码");
    } else {
      showDialog(context: context, builder: (context) => SelectItemDialog())
          .then((value) async {
        if (value != null) {
          for (int i = 0; i < RuntimeData.multiPasswordList.length; i++) {
            RuntimeData.multiPasswordList[i].folder = value;
            await Provider.of<PasswordList>(context)
                .updatePassword(RuntimeData.multiPasswordList[i]);
          }
          Fluttertoast.showToast(
              msg: "已移动${RuntimeData.multiPasswordList.length}项密码至 $value 文件夹");
          setState(() {
            RuntimeData.multiPasswordList.clear();
          });
        }
      });
    }
  }

  void _initData() async {
    if (isAutofillSelector) {
      _opacity = 0.7;
      if (Application.sp.getBool('biometrics') ?? false) {
        AuthenticationService _localAuthService =
            Application.getIt<AuthenticationService>();
        var authSucceed = await _localAuthService.authenticate();
        if (authSucceed) {
          Fluttertoast.showToast(msg: "验证成功");
          setState(() {
            _opacity = 0;
          });
        }
      } else {
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (context) => InputMainPasswordDialog(),
            barrierDismissible: false,
          ).then((right) async {
            if (right ?? false) {
              setState(() {
                _opacity = 0;
              });
            }
          });
        });
      }
      _controller = ScrollController();
    }
  }
}
