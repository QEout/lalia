import 'package:flutter/material.dart';
import 'package:lalia/params/config.dart';
import 'package:lalia/utils/bmob_util.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:lalia/params/runtime_data.dart';
import 'package:lalia/dao/card_dao.dart';
import 'package:lalia/model/card_bean.dart';

import '../application.dart';

/// 保存程序中所有的Card
class CardList with ChangeNotifier {
  List<CardBean> _cardList = [];

  CardDao _dao = CardDao();

  List<CardBean> get cardList => _cardList ?? [];

  CardList() {
    init();
  }

  Future<Null> init() async {
    _cardList = await _dao.getAllCardBeanList() ?? [];
    if (_cardList.length == 0) {
      _cardList = await BmobUtil.queryCard();
      _cardList = await _dao.insertList(_cardList);
    }
    sortByAlphabeticalOrder();
    notifyListeners();
  }

  Future<Null> refresh() async {
    _cardList.clear();
    _cardList = await _dao.getAllCardBeanList();
    if (Config.cardSort) sortByAlphabeticalOrder();
    RuntimeData.newPasswordOrCardCount = 0;
    notifyListeners();
  }

  void sortByAlphabeticalOrder() {
    _cardList.sort((one, two) {
      return PinyinHelper.getShortPinyin(one.name, defPinyin: one.name)
          .toLowerCase()
          .compareTo(PinyinHelper.getShortPinyin(two.name, defPinyin: two.name)
              .toLowerCase());
    });
  }

  Future<Null> insertCard(CardBean bean) async {
    _cardList?.add(bean);
    bean.author = Application.sp.getString("author");
    if (Config.cloud) {
      bean.objectId = await BmobUtil.insert(bean);
    }
    bean.uniqueKey = await _dao.insert(bean);
    sortByAlphabeticalOrder();
    notifyListeners();
  }

  Future<Null> deleteCard(CardBean bean) async {
    _cardList?.remove(bean);
    await _dao.deleteCardBeanById(bean.uniqueKey);
    notifyListeners();
  }

  Future<Null> updateCard(CardBean bean, {bool up = true}) async {
    int index = -1;
    for (int i = 0; i < _cardList.length; i++) {
      if (_cardList[i].uniqueKey == bean.uniqueKey) {
        index = i;
        break;
      }
    }
    String oldName = _cardList[index].name;
    _cardList[index] = bean;
    if (oldName[0] != bean.name[0]) {
      sortByAlphabeticalOrder();
    }
    if (Config.cloud && bean.objectId != null && up)
      await BmobUtil.update(bean);
    await _dao.updatePasswordBean(bean);
    notifyListeners();
  }

  Future<Null> clear() async {
    _cardList?.clear();
    await _dao.deleteContent();
    notifyListeners();
  }
}
