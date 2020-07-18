import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'gadge.dart';

class StateLayout extends StatefulWidget {
  const StateLayout({Key key, @required this.type, this.hintText})
      : super(key: key);

  final StateType type;
  final String hintText;

  @override
  _StateLayoutState createState() => _StateLayoutState();
}

class _StateLayoutState extends State<StateLayout> {
  String _img;
  String _hintText;

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case StateType.order:
        _img = "zwdd";
        _hintText = "暂无帖子";
        break;
      case StateType.goods:
        _img = "zwsp";
        _hintText = "暂无加入的小组";
        break;
      case StateType.network:
        _img = "zwwl";
        _hintText = "无网络连接";
        break;
      case StateType.message:
        _img = "zwxx";
        _hintText = "暂无消息";
        break;
      case StateType.account:
        _img = "zwzh";
        _hintText = "马上添加提现账号吧";
        break;
      case StateType.loading:
        _img = "";
        _hintText = "";
        break;
      case StateType.empty:
        _img = "";
        _hintText = "一座空城";
        break;
      case StateType.admire:
        _img = "admire";
        _hintText = "您的支持是我最大的动力";
        break;
      case StateType.activity:
        _img = "zwhd";
        _hintText = "暂无活动";
        break;
    }
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          widget.type == StateType.loading
              ? CupertinoActivityIndicator(radius: 16.0)
              : (widget.type == StateType.empty
                  ? SizedBox()
                  : Container(
                      height: 80.0,
                      width: 80.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/state/$_img.png"),
                        ),
                      ),
                    )),
          VEmptyView(5),
          widget.hintText == ""
              ? Gaps.hGap4
              : Text(
                  widget.hintText ?? _hintText,
                  style: TextStyle(color: Colors.grey),
                ),
//          Gaps.vGap50,
        ],
      ),
    );
  }
}

enum StateType {
  /// 帖子
  order,

  /// 小组
  goods,

  /// 无网络
  network,

  /// 消息
  message,

  /// 无提现账号
  account,

  /// 加载中
  loading,

  /// 空
  empty,

  ///打赏
  admire,

  ///活动
  activity
}
