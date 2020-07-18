import 'package:flutter/material.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';

import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:lalia/params/runtime_data.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/widgets/common/add_category_dialog.dart';
import 'package:lalia/widgets/setting/edit_category_dialog.dart';
import 'package:lalia/widgets/common/confirm_dialog.dart';
import 'package:lalia/provider/card_list.dart';
import 'package:lalia/provider/password_list.dart';

/// 属性管理页
/// 通过指定[name]来指定属性页的名称，属性页中是[ListView]
/// 点击每一个[ListTile]弹出模态菜单，菜单中有编辑与删除选项
class CategoryManagerPage extends StatefulWidget {
  final String name;

  CategoryManagerPage(this.name);

  @override
  State<StatefulWidget> createState() {
    return _CategoryManagerPage();
  }
}

class _CategoryManagerPage extends State<CategoryManagerPage> {
  String categoryName;

  @override
  void initState() {
    categoryName = widget.name;
    super.initState();
  }

  @override
  void didUpdateWidget(CategoryManagerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    categoryName = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "$categoryName管理",
            style: laliaTextUI.titleBarStyle,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: _getAllWidget(),
              ),
            )
          ],
        ),
        floatingActionButton: NeuomorphicContainer(
          borderRadius: BorderRadius.circular(30.0),
          color: Theme.of(context).scaffoldBackgroundColor,
          style: NeuomorphicStyle.Concave,
          intensity: 0.1,
          offset: Offset(1, 1),
          blur: 1,
          child: FloatingActionButton(
            heroTag: "add$categoryName",
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(
              Icons.add,
              color: laliaColorUI.allColor[8],
              size: 40,
            ),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AddCategoryDialog(categoryName);
                },
              ).then((_) {
                setState(() {});
              });
            },
          ),
        ));
  }

  List<Widget> _getAllWidget() {
    List<Widget> widgets = List();
    List<String> list = List();
    if (categoryName == "标签")
      list = RuntimeData.labelList;
    else
      list = RuntimeData.folderList;
    for (int currIndex = 0; currIndex < list.length; currIndex++) {
      String currCategoryName = list[currIndex];
      widgets.add(Container(
        child: ListTile(
          // TODO 增加trailing属性显示有多少个密码账号含有此标签
          title: Text(
            currCategoryName,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Icon(Icons.list),
          onTap: () {
            if (categoryName == "文件夹" && currCategoryName == "默认") {
              Fluttertoast.showToast(msg: "此文件夹不允许修改！");
              return;
            }
            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(laliaUI.smallBorderRadius),
                        topRight: Radius.circular(laliaUI.smallBorderRadius))),
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: laliaEdgeInsets.listInset,
                        child: ListTile(
                          title: Text("编辑$categoryName"),
                          leading: Icon(
                            Icons.edit_attributes,
                            color: Colors.blue,
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => EditCategoryDialog(
                                    categoryName, currIndex)).then((changed) {
                              if (changed) {
                                setState(() {});
                              }
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: laliaEdgeInsets.listInset,
                        child: ListTile(
                          title: Text("删除$categoryName"),
                          leading: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onTap: () async {
                            if (categoryName == '标签') {
                              showDialog(
                                      context: context,
                                      builder: (context) => ConfirmDialog(
                                          "确认删除", "拥有此标签的密码或卡片将删除此标签，确认吗？"))
                                  .then((delete) async {
                                if (delete) {
                                  await deleteLabelAndUpdate(currCategoryName);
                                }
                              });
                            } else {
                              showDialog(
                                      context: context,
                                      builder: (context) => ConfirmDialog(
                                          "确认删除",
                                          "此操作将会移动此文件夹下的所有密码及卡片到‘默认’文件夹中，确认吗？"))
                                  .then((delete) async {
                                if (delete) {
                                  await deleteFolderAndUpdate(currCategoryName);
                                }
                              });
                            }
                          },
                        ),
                      )
                    ],
                  );
                });
          },
        ),
        padding: EdgeInsets.only(right: 20, left: 20),
      ));
    }
    return widgets;
  }

  deleteLabelAndUpdate(String label) async {
    for (var bean in Provider.of<PasswordList>(context).passwordList) {
      if (bean.label.contains(label)) {
        bean.label.remove(label);
        Provider.of<PasswordList>(context).updatePassword(bean);
      }
    }
    for (var bean in Provider.of<CardList>(context).cardList) {
      if (bean.label.contains(label)) {
        bean.label.remove(label);
        Provider.of<CardList>(context).updateCard(bean);
      }
    }
    setState(() {
      RuntimeData.labelList.remove(label);
    });
    RuntimeData.labelParamsPersistence();
    Navigator.pop(context);
  }

  deleteFolderAndUpdate(String folder) async {
    for (var bean in Provider.of<PasswordList>(context).passwordList) {
      if (folder == bean.folder) {
        bean.folder = "默认";
        Provider.of<PasswordList>(context).updatePassword(bean);
      }
    }
    for (var bean in Provider.of<CardList>(context).cardList) {
      if (folder == bean.folder) {
        bean.folder = "默认";
        Provider.of<CardList>(context).updateCard(bean);
      }
    }
    setState(() {
      RuntimeData.folderList.remove(folder);
    });
    RuntimeData.folderParamsPersistence();
    Navigator.pop(context);
  }
}
