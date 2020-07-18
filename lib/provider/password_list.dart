import 'package:lalia/utils/bmob_util.dart';
import 'package:flutter/material.dart';
import 'package:lalia/application.dart';
import 'package:lalia/params/config.dart';

import 'package:lpinyin/lpinyin.dart';
import 'package:lalia/params/runtime_data.dart';
import 'package:lalia/dao/password_dao.dart';
import 'package:lalia/model/password_bean.dart';

/// 保存程序中的所有的Password
class PasswordList with ChangeNotifier {
  List<PasswordBean> _passwordList = [];
  PasswordDao _dao = PasswordDao();

  List<PasswordBean> get passwordList => _passwordList ?? [];

  PasswordList() {
    init();
  }

  Future<Null> init() async {
    _passwordList = await _dao.getlaliawordBeanList() ?? [];
    if (_passwordList.length == 0) {
      _passwordList = await BmobUtil.queryPass();
      _passwordList = await _dao.insertList(_passwordList);
    }
    if (Config.passSort) sortByAlphabeticalOrder();
    notifyListeners();
  }

  Future<Null> refresh() async {
    _passwordList.clear();
    _passwordList = await _dao.getlaliawordBeanList();
    if (Config.passSort) sortByAlphabeticalOrder();
    RuntimeData.newPasswordOrCardCount = 0;
    notifyListeners();
  }

  void sortByAlphabeticalOrder() {
    _passwordList.sort((one, two) {
      return PinyinHelper.getShortPinyin(one.name, defPinyin: one.name)
          .toLowerCase()
          .compareTo(PinyinHelper.getShortPinyin(two.name, defPinyin: two.name)
              .toLowerCase());
    });
  }

  Future<Null> insertPassword(PasswordBean bean) async {
    _passwordList?.add(bean);
    bean.author = Application.sp.getString("author");
    if (Config.cloud) {
      bean.objectId = await BmobUtil.insert(bean);
      print(bean.objectId);
    }
    bean.uniqueKey = await _dao.insert(bean);
    sortByAlphabeticalOrder();
    RuntimeData.newPasswordOrCardCount++;
    notifyListeners();
  }

  Future<Null> deletePassword(PasswordBean bean) async {
    _passwordList?.remove(bean);
    await _dao.deletePasswordBeanById(bean.uniqueKey);
    notifyListeners();
  }

  Future<Null> updatePassword(PasswordBean bean, {bool up = true}) async {
    int index = -1;
    for (int i = 0; i < _passwordList.length; i++) {
      if (_passwordList[i].uniqueKey == bean.uniqueKey) {
        index = i;
        break;
      }
    }
    String oldName = _passwordList[index].name;
    _passwordList[index] = bean;
    if (oldName[0] != bean.name[0]) {
      sortByAlphabeticalOrder();
    }
    print(bean);
    if (Config.cloud && bean.objectId != null && up)
      await BmobUtil.update(bean);
    await _dao.updatePasswordBean(bean);
    notifyListeners();
  }

  Future<Null> clear() async {
    _passwordList?.clear();
    await _dao.deleteContent();
    notifyListeners();
  }
}
