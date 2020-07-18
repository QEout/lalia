import 'package:json_annotation/json_annotation.dart';

import 'package:data_plugin/bmob/table/bmob_object.dart';
import 'package:lalia/model/bmobBean/user.dart';

@JsonSerializable()
class CommentBean extends BmobObject {
  //博客标题
  String forWhich;

  //博客内容
  String content;

  //博客作者
  User author;
  List<CommentBean> replies = [];
  int likeNum = 0, type = 1, commentNum = 0, loadedReply = 0, weight;
  bool liked = false, loadingReply = true, showPic = false;

  CommentBean();

  static CommentBean fromJson(Map<String, dynamic> map) {
    return CommentBean()
      ..createdAt = map['createdAt'] as String
      ..updatedAt = map['updatedAt'] as String
      ..objectId = map['objectId'] as String
      ..forWhich = map['forWhich'] as String
      ..author = map['author'] == null
          ? null
          : User.fromJson(map['author'] as Map<String, dynamic>)
      ..content = map['content'] as String
      ..likeNum = map['likeNum'] ?? 0
      ..commentNum = map['commentNum'] ?? 0
      ..type = map['type'] as int;
  }

  //此处与类名一致，由指令自动生成代码
  static Map<String, dynamic> toJson(CommentBean instance) {
    var map = {
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'objectId': instance.objectId,
      'likeNum': instance.likeNum,
      'commentNum': instance.commentNum,
      'author': instance.author,
      'forWhich': instance.forWhich,
      'type': instance.type,
      'content': instance.content
    };
    return map;
  }

  @override
  Map getParams() {
    return toJson(this);
  }
}
