import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lalia/application.dart';
import 'package:lalia/model/card_bean.dart';
import 'package:lalia/utils/bmob_util.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:lalia/params/runtime_data.dart';
import 'package:lalia/provider/card_list.dart';
import 'package:lalia/pages/card/view_card_page.dart';
import 'package:lalia/params/config.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/route/animation_routes.dart';

class CardWidgetItem extends StatelessWidget {
  final int index;

  CardWidgetItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Consumer<CardList>(
      builder: (context, model, _) {
        return SizedBox(
          height: 100,
          child: NeuomorphicContainer(
            margin: laliaEdgeInsets.listInsetN,
            borderRadius: BorderRadius.circular(15.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            style: NeuomorphicStyle.Concave,
            intensity: 0.1,
            offset: Offset(2, 2),
            blur: 4,
            height: 100,
            child: GestureDetector(
              onPanDown: (details) => RuntimeData.updateTapPosition(details),
              onTap: () => Navigator.push(
                      context,
                      ExtendRoute(
                          page: ViewCardPage(model.cardList[index]),
                          tapPosition: RuntimeData.tapVerticalPosition))
                  .then((bean) {
                if (bean != null) {
                  // 改变了就更新，没改变就删除
                  if (bean.isChanged) {
                    model.updateCard(bean);
                  } else {
                    model.deleteCard(model.cardList[index]);
                  }
                }
              }),
              onLongPress: () async {
                if (Config.longPressCopy) {
                  Clipboard.setData(
                      ClipboardData(text: model.cardList[index].cardId));
                  Fluttertoast.showToast(msg: "已复制卡号");
                }
              },
              child: ListTile(
                title: Text(
                  model.cardList[index].name,
                  style: TextStyle(
                    color: model.cardList[index].color,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  "ID: ${model.cardList[index].cardId}",
                  style: TextStyle(
                      color: Colors.blueGrey, letterSpacing: 1, height: 1.7),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                trailing: GestureDetector(
                  child: Image.asset(
//                  "assets/images/chip.png",
                    model.cardList[index].objectId != null
                        ? "assets/images/chip.png"
                        : "assets/images/chip_g.png",
                  ),
                  onTap: () async {
                    CardBean bean = model.cardList[index];
                    if (bean.objectId != null) {
                      await BmobUtil.delete(bean);
                      bean.objectId = null;
                    } else {
                      bean.author = Application.sp.getString("author");
                      bean.objectId = await BmobUtil.insert(bean);
                      Fluttertoast.showToast(msg: '数据已备份到云端');
                    }
                    model.updateCard(bean, up: false);
                  },
                ),
//                Image.asset(
//                  "assets/images/chip.png",
//                ),
                contentPadding: EdgeInsets.only(left: 30, top: 5),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SimpleCardWidgetItem extends StatelessWidget {
  final int index;

  SimpleCardWidgetItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Consumer<CardList>(
      builder: (context, model, _) {
        return Container(
          margin: laliaEdgeInsets.listInset,
          child: GestureDetector(
            onPanDown: (details) => RuntimeData.updateTapPosition(details),
            child: ListTile(
              leading: Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(laliaUI.smallBorderRadius),
                    color: model.cardList[index].color),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Text(
                    model.cardList[index].name.substring(0, 1),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              title: Text(model.cardList[index].name),
              subtitle: Text(model.cardList[index].ownerName),
              onTap: () => Navigator.push(
                  context,
                  ExtendRoute(
                    page: ViewCardPage(model.cardList[index]),
                    tapPosition: RuntimeData.tapVerticalPosition,
                  )).then((bean) {
                if (bean != null) {
                  // 改变了就更新，没改变就删除
                  if (bean.isChanged) {
                    model.updateCard(bean);
                  } else {
                    model.deleteCard(model.cardList[index]);
                  }
                }
              }),
            ),
          ),
        );
      },
    );
  }
}

class MultiCardWidgetItem extends StatefulWidget {
  final int index;

  MultiCardWidgetItem(this.index);

  @override
  State<StatefulWidget> createState() {
    return _MultiCardWidgetItem(index);
  }
}

class _MultiCardWidgetItem extends State<StatefulWidget> {
  final int index;

  _MultiCardWidgetItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Consumer<CardList>(
      builder: (context, model, child) {
        return Container(
          margin: laliaEdgeInsets.listInset,
          child: CheckboxListTile(
            value: RuntimeData.multiCardList.contains(model.cardList[index]),
            onChanged: (value) {
              setState(() {
                if (value) {
                  RuntimeData.multiCardList.add(model.cardList[index]);
                } else {
                  RuntimeData.multiCardList.remove(model.cardList[index]);
                }
              });
            },
            secondary: Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(laliaUI.smallBorderRadius),
                  color: model.cardList[index].color),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Text(
                  model.cardList[index].name.substring(0, 1),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            title: Text(
              model.cardList[index].name,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              model.cardList[index].cardId,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
