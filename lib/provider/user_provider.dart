import 'package:flutter/material.dart';
import 'package:lalia/application.dart';
import 'package:lalia/model/bmobBean/user.dart';
import 'package:lalia/utils/bmob_util.dart';

class UserProvider extends ChangeNotifier {
  User _user;

  User get user => _user ?? User();

  void setUser(User user) {
    _user = user;
    print(user);
    notifyListeners();
  }

  void init() async {
    if (_user != null) return;
    _user = await BmobUtil.queryUser(Application.sp.getString('author'));

    notifyListeners();
  }
//切换账号和初始账号
//  initUser(String objectId) async {
//    Persona persona=await Persona.queryPersona(FlutterStars.SpUtil.getString("userId"));
//    User user = User();
//    user = await queryUser(objectId);
//    user.persona=persona;
//    if(user.objectId!=FlutterStars.SpUtil.getString('alias'))
//      JpushUtil.setAlias(FlutterStars.SpUtil.getString('userId'));
////    notifyListeners();
//    setUser(user);
////    return true;
//  }

}
