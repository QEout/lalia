import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/provider/card_list.dart';
import 'package:lalia/provider/password_list.dart';
import 'package:lalia/pages/card/card_widget_item.dart';
import 'package:lalia/pages/password/password_widget_item.dart';

class FavoritePage extends StatelessWidget {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          splashColor: Colors.transparent,
          child: Text(
            "收藏",
            style: laliaTextUI.titleBarStyle,
          ),
          onTap: () {
            _controller.animateTo(0,
                duration: Duration(milliseconds: 200), curve: Curves.linear);
          },
        ),
        centerTitle: true,
      ),
      body: ListView(
        controller: _controller,
        children: _getFavWidgets(context),
      ),
    );
  }

  List<Widget> _getFavWidgets(BuildContext context) {
    List<Widget> list = List();
    for (int index = 0;
        index < Provider.of<PasswordList>(context).passwordList.length;
        index++) {
      try {
        list.add(Consumer<PasswordList>(
          builder: (context, model, _) {
            if (model.passwordList[index].fav == 1) {
              return PasswordWidgetItem(index);
            } else {
              return Container();
            }
          },
        ));
      } catch (e) {}
    }
    list.add(Container(
      child: Divider(
        thickness: 1.5,
      ),
      padding: laliaEdgeInsets.dividerInset,
    ));
    for (int index = 0;
        index < Provider.of<CardList>(context).cardList.length;
        index++) {
      try {
        list.add(Consumer<CardList>(
          builder: (context, model, _) {
            if (model.cardList[index].fav == 1) {
              return SimpleCardWidgetItem(index);
            } else {
              return Container();
            }
          },
        ));
      } catch (e) {
        print(e.toString());
      }
    }
    return list;
  }
}
