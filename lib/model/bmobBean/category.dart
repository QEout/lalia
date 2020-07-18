import 'package:data_plugin/bmob/table/bmob_object.dart';

class Category extends BmobObject {
  String title;
  int type;
  int commentNum;
  String content;
  String url;
  double rating;
  String objectId;
  String imagePath;

  Category({
    String title,
    int type,
    commentNum,
    String content,
    String url,
    double rating,
    String objectId,
    String imagePath,
  }) {
    this.commentNum = commentNum;
    this.objectId = objectId;
    this.content = content;
    this.url = url;
    this.rating = rating;
    this.title = title;
    this.imagePath = imagePath;
    this.type = type;
  }

  /// 将Map转化为PasswordBean
  static Category fromJson(Map<String, dynamic> map) {
    return Category(
        title: map['title'],
        content: map["content"],
        url: map["url"],
        commentNum: map['commentNum'] ?? 0,
        type: map["type"],
        imagePath: map["imagePath"],
        objectId: map['objectId'],
        rating: map["rating"]);
  }

  /// 将PasswordBean转化为Map
  static Map<String, dynamic> toJson(Category bean) {
    Map<String, dynamic> map = {
//      "uniqueKey": bean.uniqueKey,
      "title": bean.title,
      "content": bean.content,
      "type": bean.type,
      "url": bean.url,
      "commentNum": bean.commentNum,
      "imagePath": bean.imagePath,
      "rating": bean.rating,
      "objectId": bean.objectId,
    };
    return map;
  }

  @override
  Map getParams() {
    // TODO: implement getParams
    return toJson(this);
  }
}
