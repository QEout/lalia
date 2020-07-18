import 'package:data_plugin/bmob/table/bmob_object.dart';
import 'package:flutter/material.dart';
import 'package:lalia/application.dart';
import 'package:lalia/model/bmobBean/comment.dart';
import 'package:lalia/model/bmobBean/user.dart';

/// 保存“卡片”数据
class EventBean extends BmobObject {
  String objectId;
  User author;
  int likeNum;
  bool liked;
  List<Pic> pics;
  List<CommentBean> comments = [];
  bool showComment = false;
  String cover;
  String time;
  String created;
  int commentNum;
  String content;

  EventBean({
    String content,
    User author,
    int likeNum = 0,
    bool liked,
    int commentNum = 0,
    String time,
    String cover,
    List<Pic> pics,
    String objectId,
  }) {
    this.commentNum = commentNum;
    this.objectId = objectId;
    this.author = author;
    this.liked = liked;
    this.likeNum = likeNum;
    this.pics = pics;
    this.cover = cover;
    this.time = time;
    this.content = content;
  }

  /// 将Map转化为CardBean
  static EventBean fromJson(Map<String, dynamic> map) {
    print(map['pics']);
    bool liked = Application.sp.getBool(map["objectId"]) ?? false;
    List res = map['pics'] as List;
    print(res);
    List<Pic> pics = [];

    if (res.length > 0) {
      for (var item in res) {
//        print(item);
//        print(item.runtimeType);
        if (item != null) {
          pics.add(Pic.fromJson(item));
        }
      }
    }
    return EventBean(
        commentNum: map["commentNum"] ?? 0,
        time: map["createdAt"] as String,
        objectId: map["objectId"],
        cover: map["cover"] ?? '',
        pics: pics,
        liked: liked,
        author: map["author"] == null
            ? null
            : User.fromJson(map['author'] as Map<String, dynamic>),
        likeNum: map["likeNum"] ?? 0,
        content: map["content"]);
  }

  /// 将CardBean转化为Map
  static Map<String, dynamic> toJson(EventBean bean) {
    print(bean.pics);
//   List pics=[{"cUrl": "http://q9razy9yo.bkt.clouddn.com/%E5%AF%86%E8%AF%AD%281%29.png", "oUrl": "http://q9razy9yo.bkt.clouddn.com/%E5%AF%86%E8%AF%AD%281%29.png"}];
    List pics = [];
    var res = bean.pics;
    if (res.length > 0) {
      for (var item in res) {
        if (item != null) {
          pics.add({"cUrl": item.cUrl, "oUrl": item.oUrl});
        }
      }
    }
//   print(bean.pics.runtimeType);
    Map<String, dynamic> map = {
//      "uniqueKey": bean.uniqueKey,
      "author": bean.author,
      "pics": pics,
      "cover": bean.cover,
      "commentNum": bean.commentNum,
      "objectId": bean.objectId,
      "likeNum": bean.likeNum,
      "content": bean.content
    };
    return map;
  }

  @override
  Map getParams() {
    // TODO: implement getParams
    return toJson(this);
  }
}

class Pic {
  String cUrl;
  String oUrl;

  Pic({String cUrl, String oUrl}) {
    this.cUrl = cUrl;
    this.oUrl = oUrl;
  }

//  @override
//  Map getParams() {
//    // TODO: implement getParams
//    return toJson(this);
//  }
  static Pic fromJson(Map<String, dynamic> map) {
    return Pic(cUrl: map['cUrl'], oUrl: map['oUrl']);
  }

//  @override
//  Map getParams() {
//    // TODO: implement getParams
//    return toJson(this);
//  }
  static Map<String, dynamic> toJson(Pic pic) {
    var map = {"cUrl": pic.cUrl, "oUrl": pic.oUrl};
    return map;
  }
}
