import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lalia/utils/other_util.dart';

class SelectedImage extends StatelessWidget {
  const SelectedImage(
      {Key key, this.height: 80.0, this.width: 80.0, this.onTap, this.image})
      : super(key: key);

  final double height;
  final double width;
  final GestureTapCallback onTap;
  final File image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.0),
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          // 图片圆角展示
          borderRadius: BorderRadius.circular(16.0),
          image: DecorationImage(
            image: image == null
                ? AssetImage(Utils.getImgPath("store/icon_zj"))
                : FileImage(image),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
