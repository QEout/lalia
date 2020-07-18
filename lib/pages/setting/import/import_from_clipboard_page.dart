import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lalia/model/password_bean.dart';
import 'package:lalia/provider/theme_provider.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/encrypt_util.dart';
import 'package:lalia/utils/screen_util.dart';
import 'package:lalia/widgets/common/none_border_circular_textfield.dart';
import 'package:lalia/widgets/gadge.dart';
import 'package:provider/provider.dart';

class RobotWidget extends StatefulWidget {
  const RobotWidget({
    Key key,
  }) : super(key: key);

  @override
  _RobotWidgetState createState() => _RobotWidgetState();
}

class _RobotWidgetState extends State<RobotWidget> {
  String _toggle = "reposo";
  TextEditingController _nameController;
  TextEditingController _usernameController;
  TextEditingController _passwordController;
  bool _passwordVisible = false;
  Color _mainColor;

  @override
  void dispose() {
    _nameController?.dispose();
    _usernameController?.dispose();
    _passwordController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _nameController = TextEditingController();
    _usernameController = TextEditingController();

    _passwordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainColor = Provider
          .of<ThemeProvider>(context)
          .currTheme
          .primaryColor;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: laliaScreenUtil.setHeight(100)),
        ),
        Container(
            height: 100,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    _toggle = "buscando";
                  });
                },
                onLongPress: () {
                  setState(() {
                    _toggle = "Cargando";
                  });
                },
                onLongPressUp: () {
                  setState(() {
                    _toggle = "reposo";
                  });
                },
                child: FlareActor(
                  "assets/flrs/robot.flr",
                  animation: _toggle,
                  fit: BoxFit.contain,
                  callback: (animation) {
                    setState(() {
                      _toggle = "reposo";
                    });
                  },
                ))),

        Padding(
          padding: laliaEdgeInsets.smallTBPadding,
        ),

//        Divider(height: 5,),
        Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),

                ///圆角
                border: Border.all(color: Colors.grey, width: 1)

              ///边框颜色、宽
            ),
            child: Column(children: <Widget>[
              ListTile(
                title: Text(
                  '快速新建密码',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.27,
                  ),
                ),
                subtitle: GestureDetector(
                  child: Text(
                    "您想查看一下功能说明吗？",
                    style: TextStyle(color: Theme
                        .of(context)
                        .accentColor),
                  ),
                ),
                onTap: () {},
                trailing: FlatButton(
                  color: Theme
                      .of(context)
                      .accentColor,
                  child: Text('保存', style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
//                    color: laliaColorUI.allColor[8],
                    letterSpacing: 0.27,
                  ),),
                  onPressed: () async {
                    if (_usernameController.text.length >= 1 &&
                        _passwordController.text.length >= 1) {
                      String pw = EncryptUtil.encrypt(_passwordController.text);
                      PasswordBean tempData = PasswordBean(
                          username: _usernameController.text,
                          password: pw,
                          url: null,
                          name: _nameController.text,
                          color: getRandomColor());
                      Navigator.pop<PasswordBean>(context, tempData);
                    } else {
                      Fluttertoast.showToast(msg: "账号和密码不允许为空！");
                    }
                  },
                ),
              ),

//              Padding(
//                  padding: laliaEdgeInsets.forCardInset,
//                  child: ),

              NoneBorderCircularTextField(
                  _nameController, "应用名称，例如：知乎", Icon(Icons.apps), true, null),

              NoneBorderCircularTextField(
                  _usernameController, "用户名", Icon(Icons.person), true, null),
              Container(
                margin: laliaEdgeInsets.smallTBPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                suffix: InkWell(
                                    child: Icon(
                                      Icons.cancel,
                                      size: 20,
                                      color: Colors.black26,
                                    ),
                                    onTap: () {
                                      // 保证在组件build的第一帧时才去触发取消清空内容，防止报错
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) =>
                                          _passwordController.clear());
                                    }),
                                prefixIcon: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, bottom: 10.0),
                                  margin: const EdgeInsets.only(right: 8.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30.0),
                                          bottomLeft: Radius.circular(30.0),
                                          topRight: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0))),
                                  child: Icon(Icons.person),
                                ),
                                hintText: '密码',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(
                                      laliaUI.bigBorderRadius),
                                ),
                                filled: true,
                                fillColor: Colors.grey[300],
                                contentPadding: EdgeInsets.only(
                                    left: 10, right: 10, top: 0, bottom: 0)),
                            textAlign: TextAlign.center,
                            controller: _passwordController,
                          ),
//                      TextField(
//                        controller: _passwordController,
//                        obscureText: !_passwordVisible,
//                        decoration: InputDecoration(
//                            suffix: InkWell(
//                          child: Icon(
//                            Icons.cancel,
//                            size: 20,
//                            color: Colors.black26,
//                          ),
//                          onTap: () {
//                            // 保证在组件build的第一帧时才去触发取消清空内容，防止报错
//                            WidgetsBinding.instance.addPostFrameCallback(
//                                (_) => _passwordController.clear());
//                          },
//                        )),
//                      ),
                        ),
                        IconButton(
                          icon: _passwordVisible == true
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                          onPressed: () {
                            this.setState(() {
                              if (_passwordVisible == false)
                                _passwordVisible = true;
                              else
                                _passwordVisible = false;
                            });
                          },
                        )
                      ],
                    ),
                  ],
                ),
              )
            ])),

//        Padding(
//          child: Center(
//            child: Text("空荡荡的房间，赶快点击右下角的加号加点东西吧"),
//          ),
//          padding: laliaEdgeInsets.forCardInset,
//        ),
//        Padding(
//          padding: laliaEdgeInsets.smallTBPadding,
//        ),
//        Padding(
//          child: Center(
//            child: Text(
//              "这里存储你的密码信息，例如\n微博账号、网站账号等",
//              textAlign: TextAlign.center,
//            ),
//          ),
//          padding: laliaEdgeInsets.forCardInset,
//        )
      ],
    );
  }
}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
 
 
 
 
 
 
 