import 'dart:math';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lalia/model/bmobBean/user.dart';
import 'package:lalia/utils/screen_util.dart';

import 'package:palette_generator/palette_generator.dart';

import 'gadge.dart';

class UserDetailWidget extends StatefulWidget {
  // 影人 id
  final User user;
  final double radius;
  final int type;

  const UserDetailWidget({
    Key key,
    this.user,
    this.radius,
    this.type = 2,
  }) : super(key: key);

  @override
  _UserDetailWidgetState createState() => _UserDetailWidgetState();
}

ImageProvider avatar1 = new ExactAssetImage('assets/avatars/avatar-1.jpg');
ImageProvider avatar2 = new ExactAssetImage('assets/avatars/avatar-2.jpg');
ImageProvider avatar3 = new ExactAssetImage('assets/avatars/avatar-3.jpg');
ImageProvider avatar4 = new ExactAssetImage('assets/avatars/avatar-4.jpg');
ImageProvider avatar5 = new ExactAssetImage('assets/avatars/avatar-5.jpg');
ImageProvider avatar6 = new ExactAssetImage('assets/avatars/avatar-6.jpg');
List avatarList = [avatar1, avatar2, avatar3, avatar4, avatar5, avatar6];

class _UserDetailWidgetState extends State<UserDetailWidget> {
  ImageProvider avatar = avatarList[Random().nextInt(6)];
  Color bgColor = Colors.grey.shade100;

//  double navAlpha = 0;
//  ScrollController scrollController = ScrollController();
//  Color pageColor = Colors.white;
//  bool isSummaryUnfold = false;

  @override
  void initState() {
    super.initState();
    setDialogBg();
  }

  @override
  Widget build(BuildContext context) {
//    Screen.updateStatusBarStyle(SystemUiOverlayStyle.light);
    return
//      Row(children: <Widget>[
        GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (ctx) {
                  return UserDetailDialog(
                    user: widget.user,
                    bgColor: bgColor,
                  );
                },
              );
            },
            child: _buildUserView()
//        child:widget.type==0? CircleAvatar(
//          backgroundImage: widget.user.avatar == null
//              ? avatar
//              : NetworkImage(widget.user.avatar),
//          backgroundColor: Color(0xfff1f3f5),
//          radius: widget.radius,
//        ):Text(widget.user.nickname==null?'用户':widget.user.nickname,style: widget.textStyle,),
            );
//      Gaps.hGap8,
//      Text(widget.user.nickname == null || widget.user.nickname == ''
//          ? '用户'
//          : widget.user.nickname),
//    ]);
  }

  Widget buildGender() {
    if (widget.user.gender == 0) {
      return IconButton(
        icon: Icon(FontAwesomeIcons.venus, color: Colors.pink),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) {
              return UserDetailDialog(
                user: widget.user,
                bgColor: bgColor,
                avatar: avatar,
              );
            },
          );
        },
      );
    } else if (widget.user.gender == 1) {
      return IconButton(
        icon: Icon(FontAwesomeIcons.mars, color: Colors.blue),
        onPressed: () => null,
      );
    } else
      return IconButton(
        icon: Icon(FontAwesomeIcons.robot, color: Colors.grey),
        onPressed: () => null,
      );
  }

  Future<void> setDialogBg() async {
    PaletteGenerator paletteGenerator = widget.user.avatar == null
        ? await PaletteGenerator.fromImageProvider(
            avatar,
          )
        : await PaletteGenerator.fromImageProvider(
            ExtendedNetworkImageProvider(widget.user.avatar, cache: true),
          );
//    }
    if (paletteGenerator.vibrantColor != null) {
      bgColor = paletteGenerator.vibrantColor.color;
    } else
      bgColor = paletteGenerator.dominantColor.color;
  }

  _buildUserView() {
    switch (widget.type) {
      case 0:
        return CircleAvatar(
          backgroundImage: widget.user.avatar == null
              ? avatar
              : NetworkImage(widget.user.avatar),
          backgroundColor: Color(0xfff1f3f5),
          radius: widget.radius,
        );
        break;
      case 1:
        return Text(
          widget.user.nickname == null ? '我' : widget.user.nickname,
        );
        break;
      case 2:
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Adapt.px(250)),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: widget.user.avatar == null
                    ? avatar
                    : NetworkImage(widget.user.avatar),
                backgroundColor: Color(0xfff1f3f5),
                radius: widget.radius,
              ),
              Gaps.hGap5,
              Expanded(
                child: Text(
                  widget.user.nickname,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        );
        break;
    }
  }
}

class UserDetailDialog extends StatelessWidget {
  UserDetailDialog({Key key, this.user, this.bgColor, this.avatar})
      : super(key: key);
  final Color bgColor;
  final User user;
  final ImageProvider avatar;

  Widget build(BuildContext context) {
    return Dialog(
        //创建透明层
        backgroundColor: Colors.transparent, //透明类型
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),

        //保证控件居中效果
        child: new Container(
          height: laliaScreenUtil.setWidth(480),
          width: laliaScreenUtil.setWidth(800),
          child: Stack(

              //重叠的Stack Widget，实现重贴
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)), //裁切长方形
                  child: BackdropFilter(
                    //背景滤镜器
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    //图片模糊过滤，横向竖向都设置5.0
                    child: Opacity(
                      //透明控件
                      opacity: 0.3,
                      child: Container(
                        // 容器组件
                        width: ScreenUtil.getInstance().width,
                        height: ScreenUtil.getInstance().height,
                        decoration:
                            BoxDecoration(color: bgColor), //盒子装饰器，进行装饰，设置颜色为灰色
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(user.nickname,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                            Padding(
                              child: _buildGender(user.gender),
                              padding: EdgeInsets.only(right: 5),
                            )
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Gaps.hGap15,

                          user.avatar == null
                              ? Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                  ),
                                  child: Center(
                                      child: Text('暂无头像',
                                          style: TextStyle(
                                              color: Colors.grey.shade50))),
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(user.avatar),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                ),
//         CircleAvatar(
//           backgroundImage: avatar1,
//
//         ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              child: Text(
                            '签名：' + user.brief,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      ),
                    ],
                  ),
                )
              ]),
        ));
  }

  Widget _buildGender(int gender) {
    if (gender == 0) {
      return IconButton(
        icon: Icon(FontAwesomeIcons.venus, color: Colors.pink),
        onPressed: () {
          return null;
        },
      );
    } else if (gender == 1) {
      return IconButton(
        icon: Icon(FontAwesomeIcons.mars, color: Colors.blue),
        onPressed: () => null,
      );
    } else
      return IconButton(
        icon: Icon(FontAwesomeIcons.robot, color: Colors.grey),
        onPressed: () => null,
      );
  }
}
