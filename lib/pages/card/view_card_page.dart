import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';

import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lalia/model/card_bean.dart';
import 'package:lalia/pages/card/edit_card_page.dart';
import 'package:lalia/pages/common/detail_text_page.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/encrypt_util.dart';
import 'package:lalia/utils/screen_util.dart';
import 'package:lalia/widgets/common/label_chip.dart';
import 'package:lalia/widgets/common/confirm_dialog.dart';
import 'package:lalia/provider/theme_provider.dart';

class ViewCardPage extends StatefulWidget {
  final CardBean oldData;

  ViewCardPage(this.oldData);

  @override
  _ViewCardPage createState() {
    return _ViewCardPage();
  }
}

class _ViewCardPage extends State<ViewCardPage> {
  CardBean _bean;
  bool _cardIdVisible = false;
  bool _passwordVisible = false;
  String _password = "";
  var _futureHelper;
  Color _mainColor;

  Future<Null> _decryptPassword() async {
    _password = EncryptUtil.decrypt(_bean.password);
  }

  @override
  void initState() {
    CardBean data = widget.oldData;
    _bean = CardBean(
        ownerName: data.ownerName,
        cardId: data.cardId,
        key: data.uniqueKey,
        name: data.name,
        password: data.password,
        objectId: data.objectId,
        folder: data.folder,
        telephone: data.telephone,
        notes: data.notes,
        fav: data.fav,
        label: data.label,
        color: data.color);

    _futureHelper = _decryptPassword();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainColor = Provider.of<ThemeProvider>(context).currTheme.primaryColor;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (_bean.isChanged) {
            Navigator.pop<CardBean>(context, _bean);
          } else {
            Navigator.pop<CardBean>(context, null);
          }
          return Future<bool>.value(false);
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                "查看卡片",
                style: laliaTextUI.titleBarStyle,
              ),
              centerTitle: true,
              actions: <Widget>[
                _bean.fav == 1
                    ? Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                      )
                    : Icon(
                        Icons.favorite_border,
                      ),
                Padding(
                  padding: laliaEdgeInsets.smallLPadding,
                ),
                Padding(
                  padding: laliaEdgeInsets.smallLPadding,
                )
              ],
            ),
            body: FutureBuilder(
              future: _futureHelper,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: laliaEdgeInsets.forViewCardInset,
                            child: NeuomorphicContainer(
                                borderRadius: BorderRadius.circular(11),
                                intensity: 0.1,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                offset: Offset(2, 2),
                                blur: 4,
                                style: NeuomorphicStyle.Flat,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 23, horizontal: 0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                laliaUI.smallBorderRadius),
                                            color: _bean.color,
                                          ),
                                          child: CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Colors.transparent,
                                            child: Text(
                                              _bean.name.substring(0, 1),
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )),
                                    Padding(
                                      padding: laliaEdgeInsets.smallLPadding,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(left: 5),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth: laliaScreenUtil
                                                      .setWidth(450)),
                                              child: Text(
                                                _bean.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 19,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )),
                                        Container(
                                            margin: EdgeInsets.only(
                                                left: 0,
                                                right: 5,
                                                top: 3,
                                                bottom: 0),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(Icons.folder_open),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 5),
                                                  color: Colors.grey[250],
                                                  child: Container(
                                                    child: Text(
                                                      _bean.folder,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    width: 50,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                    )
                                  ],
                                )),
                          ),
                          Padding(
                            padding: laliaEdgeInsets.forViewCardInset,
                            child: NeuomorphicContainer(
                                borderRadius: BorderRadius.circular(11),
                                intensity: 0.1,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                offset: Offset(2, 2),
                                blur: 4,
                                style: NeuomorphicStyle.Flat,
                                child: SizedBox(
                                  width: ScreenUtil.screenWidth * 0.8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: laliaEdgeInsets.smallTBPadding,
                                      ),
                                      // 拥有者姓名标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(10)),
                                        child: Text(
                                          "拥有者姓名",
                                          style: TextStyle(
                                              fontSize: 16, color: _mainColor),
                                        ),
                                      ),
                                      // 拥有者姓名主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(50)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                _bean.ownerName,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    laliaTextUI.firstTitleStyle,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  laliaEdgeInsets.smallLPadding,
                                            ),
                                            InkWell(
                                              child: Text(
                                                "复制",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: _mainColor),
                                              ),
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: _bean.ownerName));
                                                Fluttertoast.showToast(
                                                    msg: "已复制姓名");
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      // 卡号标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(10)),
                                        child: Text(
                                          "卡号",
                                          style: TextStyle(
                                              fontSize: 16, color: _mainColor),
                                        ),
                                      ),
                                      // 卡号主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(30)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                _cardIdVisible
                                                    ? _bean.cardId
                                                    : "*" * _bean.cardId.length,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    laliaTextUI.firstTitleStyle,
                                              ),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                InkWell(
                                                  child: _cardIdVisible
                                                      ? Icon(Icons.visibility)
                                                      : Icon(
                                                          Icons.visibility_off),
                                                  onTap: () {
                                                    setState(() {
                                                      _cardIdVisible =
                                                          !_cardIdVisible;
                                                    });
                                                  },
                                                ),
                                                Padding(
                                                  padding: laliaEdgeInsets
                                                      .smallLPadding,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Clipboard.setData(
                                                        ClipboardData(
                                                            text:
                                                                _bean.cardId));
                                                    Fluttertoast.showToast(
                                                        msg: "已复制卡号");
                                                  },
                                                  child: Text(
                                                    "复制",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: _mainColor),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      // 密码标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(10)),
                                        child: Text("密码",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: _mainColor)),
                                      ),
                                      // 密码主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(30)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                _passwordVisible
                                                    ? _password
                                                    : "*" * _password.length,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    laliaTextUI.firstTitleStyle,
                                              ),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                InkWell(
                                                  child: _passwordVisible
                                                      ? Icon(Icons.visibility)
                                                      : Icon(
                                                          Icons.visibility_off),
                                                  onTap: () {
                                                    setState(() {
                                                      _passwordVisible =
                                                          !_passwordVisible;
                                                    });
                                                  },
                                                ),
                                                Padding(
                                                  padding: laliaEdgeInsets
                                                      .smallLPadding,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Clipboard.setData(
                                                        ClipboardData(
                                                            text: _password));
                                                    Fluttertoast.showToast(
                                                        msg: "已复制密码");
                                                  },
                                                  child: Text(
                                                    "复制",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: _mainColor),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      // 绑定手机号标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(10)),
                                        child: Text(
                                          "绑定手机号",
                                          style: TextStyle(
                                              fontSize: 16, color: _mainColor),
                                        ),
                                      ),
                                      // 绑定手机号主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(50)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                _bean.telephone,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    laliaTextUI.firstTitleStyle,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  laliaEdgeInsets.smallLPadding,
                                            ),
                                            InkWell(
                                              child: Text(
                                                "复制",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: _mainColor),
                                              ),
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: _bean.telephone));
                                                Fluttertoast.showToast(
                                                    msg: "已复制手机号");
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      // 备注标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(10)),
                                        child: Text(
                                          "备注",
                                          style: TextStyle(
                                              fontSize: 16, color: _mainColor),
                                        ),
                                      ),
                                      // 备注主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(50)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                                child: InkWell(
                                              onTap: () {
                                                if (_bean.notes.length >= 1) {
                                                  Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                        builder: (context) =>
                                                            DetailTextPage(
                                                                "备注",
                                                                _bean.notes,
                                                                false),
                                                      ));
                                                }
                                              },
                                              child: Text(
                                                _bean.notes.length < 1
                                                    ? "无备注"
                                                    : _bean.notes,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: _bean.notes.length < 1
                                                    ? laliaTextUI.hintTextStyle
                                                    : laliaTextUI
                                                        .firstTitleStyle,
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                      // 标签标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(10)),
                                        child: Text(
                                          "标签",
                                          style: TextStyle(
                                              fontSize: 16, color: _mainColor),
                                        ),
                                      ),
                                      // 标签主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: laliaScreenUtil.setWidth(100),
                                            right:
                                                laliaScreenUtil.setWidth(100),
                                            bottom:
                                                laliaScreenUtil.setHeight(50)),
                                        child: Wrap(
                                          children: _getTag(),
                                          spacing: 5,
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          ),
                          Padding(
                            padding: laliaEdgeInsets.smallTBPadding,
                          ),
                          // 最下面一行点击按钮
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              NeuomorphicContainer(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  style: NeuomorphicStyle.Convex,
                                  intensity: 0.15,
                                  offset: Offset(3, 3),
                                  blur: 3,
                                  child: FloatingActionButton(
                                    heroTag: "edit",
                                    backgroundColor: Colors.blueAccent,
                                    elevation: 0,
                                    onPressed: () {
                                      Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      EditCardPage(
                                                          _bean, "编辑卡片")))
                                          .then((bean) {
                                        if (bean != null) {
                                          setState(() {
                                            _bean = bean;
                                            _decryptPassword();
                                          });
                                        }
                                      });
                                    },
                                    child: Icon(Icons.edit),
                                  )),
                              Padding(
                                padding: laliaEdgeInsets.smallLPadding,
                              ),
                              NeuomorphicContainer(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  style: NeuomorphicStyle.Convex,
                                  intensity: 0.15,
                                  offset: Offset(3, 3),
                                  blur: 3,
                                  child: FloatingActionButton(
                                    heroTag: "delete",
                                    elevation: 0,
                                    backgroundColor: Colors.redAccent,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => ConfirmDialog(
                                              "确认删除", "你将删除此卡片，确认吗？")).then(
                                          (delete) {
                                        if (delete) {
                                          // 如果想删除，则先将isChanged属性改为false
                                          // 否则如果先修改再删除会导致card页不删除
                                          _bean.isChanged = false;
                                          Navigator.pop<CardBean>(
                                              context, _bean);
                                        }
                                      });
                                    },
                                    child: Icon(Icons.delete),
                                  )),
                            ],
                          ),
                          Padding(
                            padding: laliaEdgeInsets.smallTBPadding,
                          )
                        ],
                      ),
                    );
                  default:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                }
              },
            )));
  }

  List<Widget> _getTag() {
    List<Widget> labelChoices = List();
    _bean.label.forEach((item) {
      labelChoices
          .add(LabelChip(text: item, selected: true, onSelected: (_) {}));
    });
    if (labelChoices.length == 0) {
      labelChoices.add(Text(
        "无标签",
        style: laliaTextUI.hintTextStyle,
      ));
    }
    return labelChoices;
  }
}
