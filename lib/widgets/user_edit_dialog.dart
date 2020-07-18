import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lalia/model/bmobBean/user.dart';
import 'package:lalia/provider/user_provider.dart';
import 'package:lalia/utils/bmob_util.dart';
import 'package:lalia/utils/screen_util.dart';
import 'package:lalia/widgets/selected_image.dart';
import 'package:provider/provider.dart';
import 'gadge.dart';

class UserEditDialog extends StatefulWidget {
  UserEditDialog({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _UserEditDialogState createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  TextEditingController _nicknameController = new TextEditingController();
  TextEditingController _briefController = new TextEditingController();
  User user = User();

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  Widget build(BuildContext context) {
    return Dialog(
        //创建透明层
        backgroundColor: Colors.transparent, //透明类型
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),

        //保证控件居中效果
        child: new Container(
          height: laliaScreenUtil.setWidth(900),
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
                        decoration: BoxDecoration(
                            color: Colors.white), //盒子装饰器，进行装饰，设置颜色为灰色
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
                              child: Text('编辑信息',
//                                  overflow: TextOverflow.ellipsis,
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
                      Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: TextField(
                            controller: _nicknameController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                hintText: user.nickname == '用户'
                                    ? '设置一个昵称吧'
                                    : user.nickname,
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.all_inclusive),
                                contentPadding: EdgeInsets.all(10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
//            borderSide: BorderSide(color: Colors.red, width: 3.0, style: BorderStyle.solid)//没什么卵效果
                                )),
                          )),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Gaps.hGap15,
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              _imageFile == null
                                  ? GestureDetector(
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(user.avatar),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                        ),
                                      ),
                                      onTap: _getImage,
                                    )
                                  : SelectedImage(
                                      height: 70,
                                      width: 70,
                                      image: _imageFile,
                                      onTap: _getImage),
                              SizedBox(
                                height: 22,
                              ),
                              Consumer<UserProvider>(
                                  builder: (_, provider, __) {
                                return InkWell(
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.8),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                      ),
                                      child: Text(
                                        '确定',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                    onTap: () async {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      if (_nicknameController.text.length ==
                                              0 &&
                                          _briefController.text.length == 0) {
                                        Fluttertoast.showToast(msg: '信息未改变');
                                        return;
                                      }
                                      user.nickname = _nicknameController.text;
                                      user.brief = _briefController.text;

                                      if (_imageFile != null)
                                        user.avatar = await BmobUtil.uploadPic(
                                            _imageFile);
                                      provider.setUser(user);
                                      user.update();
                                      Fluttertoast.showToast(msg: '信息已更新');
                                      Navigator.pop(context);
                                    });
                              })
                            ],
                          ),
//         CircleAvatar(
//           backgroundImage: avatar1,
//
//         ),
                          SizedBox(
                            width: 15,
                          ),

                          Expanded(
                            child: Padding(
                              child: TextField(
                                controller: _briefController,
                                maxLines: 9,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                    hintText: user.brief == '暂无签名'
                                        ? '设置一个签名吧'
                                        : user.brief,
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.all(10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
//            borderSide: BorderSide(color: Colors.red, width: 3.0, style: BorderStyle.solid)//没什么卵效果
                                    )),
                              ),
//                              child: Text('签名：' + user.brief,
//                                style: TextStyle(color: Colors.white,),
//                                maxLines: 5,
//                                overflow: TextOverflow.ellipsis,
//                              )
                              padding: EdgeInsets.only(right: 15),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ]),
        ));
  }

  Widget _buildGender(int gender) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.venus,
              color: user.gender == 0 ? Colors.pinkAccent : Colors.grey),
          onPressed: () {
            setState(() {
              user.gender = 0;
            });
          },
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.mars,
              color: user.gender == 1 ? Colors.blueAccent : Colors.grey),
          onPressed: () {
            setState(() {
              user.gender = 1;
            });
          },
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.robot,
              color: user.gender == 2 ? Colors.greenAccent : Colors.grey),
          onPressed: () {
            setState(() {
              user.gender = 2;
            });
          },
        )
      ],
    );
  }

  File _imageFile;

  void _getImage() async {
    try {
      _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
//    if(_imageFile!)
      setState(() {
        _imageFile = _imageFile;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "没有权限，无法打开相册！");
    }
  }
}
