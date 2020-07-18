import 'dart:async';

import 'package:common_utils/common_utils.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lalia/application.dart';

TimeFN(String time, {double size = 14, bool toString = false}) {
  if (toString == true)
    return '${TimelineUtil.format(DateTime.parse(time).millisecondsSinceEpoch, locTimeMillis: DateTime.now().millisecondsSinceEpoch, locale: 'zh_normal', dayFormat: DayFormat.Full)}';
  return Text(
    '${TimelineUtil.format(DateTime.parse(time).millisecondsSinceEpoch, locTimeMillis: DateTime.now().millisecondsSinceEpoch, locale: 'zh_normal', dayFormat: DayFormat.Full)}',
    style: TextStyle(inherit: true, color: Colors.grey, fontSize: size),
  );
}

Widget InfoItem(IconData icon, String info, {color: Colors.grey}) {
  return Row(
    children: <Widget>[
      Icon(
        icon,
        size: 15.0,
        color: color,
      ),
      SizedBox(
        width: 3.0,
      ),
      Text(
        info,
        style: TextStyle(fontSize: 14.0, color: color),
      )
    ],
  );
}

Widget showNetImage(String url,
    {double width, double height, BoxFit fit, double radius: 10}) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ExtendedImage.network(
        url,
        width: width,
        height: height,
        fit: fit,
      ));
}

Widget HEmptyView(double width) {
  return SizedBox(
    width: ScreenUtil().setWidth(width),
  );
}

Widget VEmptyView(double height) {
  return SizedBox(
    height: ScreenUtil().setWidth(height),
  );
}

Future<bool> onLikeTap(var data, bool isLiked) async {
  ///send your request here
  ///
  final Completer<bool> completer = new Completer<bool>();
  Timer(const Duration(milliseconds: 300), () {
    data.liked = !data.liked;
    data.likeNum = data.liked ? data.likeNum + 1 : data.likeNum - 1;
    data.liked
        ? Application.sp.setBool(data.objectId, true)
        : Application.sp.remove(data.objectId);
    data.update();
    // if your request is failed,return null,
    completer.complete(data.liked);
  });

  return completer.future;
}

class Gaps {
  /// 水平间隔
  static const Widget hGap5 = SizedBox(width: 5);
  static const Widget hGap10 = SizedBox(width: 10);
  static const Widget hGap15 = SizedBox(width: 15);
  static const Widget hGap16 = SizedBox(width: 16);

  /// 垂直间隔
  static const Widget vGap5 = SizedBox(height: 5);
  static const Widget vGap10 = SizedBox(height: 10);
  static const Widget vGap15 = SizedBox(height: 15);
  static const Widget vGap50 = SizedBox(height: 50);

  static const Widget vGap4 = SizedBox(height: 4.0);
  static const Widget vGap8 = SizedBox(height: 8.0);
  static const Widget vGap12 = SizedBox(height: 12.0);
  static const Widget vGap16 = SizedBox(height: 16);

  static const Widget hGap4 = SizedBox(width: 4.0);
  static const Widget hGap8 = SizedBox(width: 8.0);
  static const Widget hGap12 = SizedBox(width: 12.0);

  static Widget line = Container(height: 0.6, color: Colors.blueGrey);
  static const Widget empty = SizedBox();
}
