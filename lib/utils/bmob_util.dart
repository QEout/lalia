import 'dart:io';

import 'package:data_plugin/bmob/bmob_file_manager.dart';
import 'package:data_plugin/bmob/bmob_query.dart';
import 'package:data_plugin/bmob/response/bmob_error.dart';
import 'package:data_plugin/bmob/response/bmob_handled.dart';
import 'package:data_plugin/bmob/response/bmob_registered.dart';
import 'package:data_plugin/bmob/response/bmob_saved.dart';
import 'package:data_plugin/bmob/response/bmob_updated.dart';
import 'package:data_plugin/bmob/table/bmob_object.dart';
import 'package:data_plugin/bmob/table/bmob_user.dart';
import 'package:data_plugin/bmob/type/bmob_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lalia/application.dart';
import 'package:lalia/model/bmobBean/comment.dart';
import 'package:lalia/model/bmobBean/event.dart';
import 'package:lalia/model/bmobBean/user.dart';

import 'package:lalia/model/card_bean.dart';
import 'package:lalia/model/password_bean.dart';
import 'package:lalia/model/bmobBean/category.dart';
import 'package:lalia/provider/user_provider.dart';
import 'package:provider/provider.dart';

class BmobUtil {
  static register(String _username, String _password) {
    BmobUser userRegister = BmobUser();
    userRegister.username = _username;
    userRegister.password = _password;
    return userRegister.register().then((BmobRegistered data) {
      return true;
    }).catchError((e) {
      print(BmobError.convert(e).error);
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  static queryUser(String objectId) async {
    User user = User();
    BmobQuery<_User> query = BmobQuery();
    return await query.queryObject(objectId).then((data) async {
      user = User.fromJson(data);
//    user.persona=await Persona.queryPersona(user.objectId);
      return user;
    }).catchError((e) {
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  ///用户名和密码登录
  static login(String _username, String _password, BuildContext context) {
    BmobUser userRegister = BmobUser();
    userRegister.username = _username;
    userRegister.password = _password;
    return userRegister.login().then((BmobUser bmobUser) {
//      User user=User();
      print(bmobUser.toJson());
//      Provider.of<UserProvider>(context).setUser(user);
      Application.sp.setString("author", bmobUser.objectId);
      return true;
    }).catchError((e) {
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  static insert(BmobObject bean) {
    return bean.save().then((BmobSaved bmobSaved) {
      return bmobSaved.objectId;
    }).catchError((e) {
      print(BmobError.convert(e).error);
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  static update(BmobObject bean) {
    bean.update().then((BmobUpdated bmobUpdated) {
//      return Fluttertoast.showToast(msg: '云端已修改');
    }).catchError((e) {
      print(BmobError.convert(e).error);
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  static delete(BmobObject bean) {
    bean.delete().then((BmobHandled bmobHandled) {
      Fluttertoast.showToast(msg: '云端数据已删除');
//      currentObjectId = null;
//      showSuccess(context, "删除一条数据成功：${bmobHandled.msg}");
    }).catchError((e) {
      print(BmobError.convert(e).error);
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  static queryPass() {
    BmobQuery<PasswordBean> query = BmobQuery();
    query.addWhereEqualTo("author", Application.sp.getString("author"));
    return query.queryObjects().then((data) {
      List<PasswordBean> resList =
          data.map((i) => PasswordBean.fromJson(i)).toList();
      return resList;
    }).catchError((e) {
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  static queryCard() {
    BmobQuery<CardBean> query = BmobQuery();
    query.addWhereEqualTo("author", Application.sp.getString("author"));
    return query.queryObjects().then((data) {
      List<CardBean> resList = data.map((i) => CardBean.fromJson(i)).toList();
      return resList;
    }).catchError((e) {
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  static queryComment(String forWhich, {int limit = 5}) {
    BmobQuery<CommentBean> query = BmobQuery();
    query.addWhereEqualTo("forWhich", forWhich);
    query.setLimit(5);
    query.setInclude("author");
    query.setOrder('-likeNum');
    return query.queryObjects().then((data) {
      List<CommentBean> resList =
          data.map((i) => CommentBean.fromJson(i)).toList();
      return resList;
    }).catchError((e) {
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  static queryCategory(int type, {load = 10}) {
    BmobQuery<Category> query = BmobQuery();
    query.addWhereEqualTo('type', type);
    query.setLimit(load);
    return query.queryObjects().then((data) {
      List<Category> resList = data.map((i) => Category.fromJson(i)).toList();
      print('sjjjjjjjjjjjjjjjjjjjjjjjjj');
      return resList;
    }).catchError((e) {
      print(BmobError.convert(e).error);
    });
  }

  static queryEvent(int skip, {load = 10}) {
    BmobQuery<EventBean> query = BmobQuery();
    query.setInclude('author');
    query.setLimit(load);
    query.setSkip(skip);
    query.setOrder("-createdAt");
    return query.queryObjects().then((data) {
      List<EventBean> resList = data.map((i) => EventBean.fromJson(i)).toList();
      return resList;
    }).catchError((e) {
      print(BmobError.convert(e).error);
    });
  }

  static queryEventNum() {
    BmobQuery<EventBean> query = BmobQuery();
    return query.queryCount().then((int count) {
      return count;
    }).catchError((e) {
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  static uploadPic(File _imageFile,
      {compress = true, width = 120, height = 120}) async {
    if (compress == true)
      _imageFile = await FlutterNativeImage.compressImage(_imageFile.path,
          targetWidth: width, targetHeight: width);
    return await BmobFileManager.upload(_imageFile).then((BmobFile bmobFile) {
      return bmobFile.url;
    }).catchError((e) {});
  }
}

class _User {}
