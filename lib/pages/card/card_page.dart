import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:lalia/params/config.dart';
import 'package:lalia/params/runtime_data.dart';
import 'package:lalia/pages/card/card_widget_item.dart';
import 'package:lalia/pages/card/edit_card_page.dart';
import 'package:lalia/pages/search/search_page.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/screen_util.dart';
import 'package:lalia/params/lalia_type.dart';
import 'package:lalia/widgets/common/search_button_widget.dart';
import 'package:lalia/widgets/common/confirm_dialog.dart';
import 'package:lalia/widgets/common/select_item_dialog.dart';
import 'package:lalia/provider/card_list.dart';

/// 卡片页面
class CardPage extends StatefulWidget {
  @override
  _CardPageState createState() {
    return _CardPageState();
  }
}

class _CardPageState extends State<CardPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  // 查询
  Future<Null> _query() async {
    await Provider.of<CardList>(context).init();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: laliaEdgeInsets.smallLPadding,
            child: InkWell(
              splashColor: Colors.transparent,
              child: Text(
                "卡片",
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
                                _deleteCard(context);
                                break;
                              case "移动":
                                _moveCard(context);
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
                          if (RuntimeData.multiCardList.length !=
                              Provider.of<CardList>(context).cardList.length) {
                            RuntimeData.multiCardList.clear();
                            setState(() {
                              RuntimeData.multiCardList.addAll(
                                  Provider.of<CardList>(context).cardList);
                            });
                          } else {
                            setState(() {
                              RuntimeData.multiCardList.clear();
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
                color: Config.cardSort
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
              ),
              onTap: () {
                setState(() {
                  Config.cardSort = !Config.cardSort;
                  Provider.of<CardList>(context).refresh();
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
                  RuntimeData.multiCardList.clear();
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
        body: Column(
          children: <Widget>[
            // 搜索框 按钮
            SearchButtonWidget(_searchPress, "卡片"),
            Padding(
              padding: EdgeInsets.only(bottom: laliaScreenUtil.setWidth(50)),
            ),
            // 卡片列表
            Expanded(
              child: RefreshIndicator(
                  onRefresh: _query,
                  child: Scrollbar(
                      child: Provider.of<CardList>(context).cardList.length >= 1
                          ? Config.multiSelected
                              ? ListView.builder(
                                  controller: _controller,
                                  itemBuilder: (context, index) =>
                                      MultiCardWidgetItem(index),
                                  itemCount: Provider.of<CardList>(context)
                                      .cardList
                                      .length,
                                )
                              : ListView.builder(
                                  controller: _controller,
                                  itemBuilder: (context, index) =>
                                      CardWidgetItem(index),
                                  itemCount: Provider.of<CardList>(context)
                                      .cardList
                                      .length,
                                )
                          : ListView(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: laliaScreenUtil.setHeight(400)),
                                ),
                                Padding(
                                  child: Center(
                                    child: Text("什么也没有，赶快添加吧"),
                                  ),
                                  padding: laliaEdgeInsets.forCardInset,
                                ),
                                Padding(
                                  padding: laliaEdgeInsets.smallTBPadding,
                                ),
                                Padding(
                                  child: Center(
                                    child: Text(
                                      "这里存储你的卡片信息，例如\n身份证，银行卡或贵宾卡等",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  padding: laliaEdgeInsets.forCardInset,
                                )
                              ],
                            ))),
            )
          ],
        ),
        // 添加按钮
        floatingActionButton: Consumer<CardList>(
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
                                      EditCardPage(null, "添加卡片")))
                          .then((resData) async {
                        if (resData != null) {
                          model.insertCard(resData);
                          if (RuntimeData.newPasswordOrCardCount >= 3) {
                            await Provider.of<CardList>(context).refresh();
                          }
                        }
                      });
                    },
                    heroTag: "card",
                  ),
                )));
  }

  _searchPress() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SearchPage(laliaType.CARD)));
  }

  void _deleteCard(BuildContext context) {
    if (RuntimeData.multiCardList.length == 0) {
      Fluttertoast.showToast(msg: "请选择至少一项卡片");
    } else {
      showDialog<bool>(
              context: context,
              builder: (context) => ConfirmDialog(
                  "确认删除", "您将删除${RuntimeData.multiCardList.length}项卡片，确认吗？"))
          .then((confirm) {
        if (confirm) {
          for (var item in RuntimeData.multiCardList) {
            Provider.of<CardList>(context).deleteCard(item);
          }
          RuntimeData.multiCardList.clear();
        }
      });
    }
  }

  void _moveCard(BuildContext context) {
    if (RuntimeData.multiCardList.length == 0) {
      Fluttertoast.showToast(msg: "请选择至少一项卡片");
    } else {
      showDialog(context: context, builder: (context) => SelectItemDialog())
          .then((value) async {
        if (value != null) {
          for (int i = 0; i < RuntimeData.multiCardList.length; i++) {
            RuntimeData.multiCardList[i].folder = value;
            await Provider.of<CardList>(context)
                .updateCard(RuntimeData.multiCardList[i]);
          }
          Fluttertoast.showToast(
              msg: "已移动${RuntimeData.multiCardList.length}项密码至 $value 文件夹");
          setState(() {
            RuntimeData.multiCardList.clear();
          });
        }
      });
    }
  }
}
