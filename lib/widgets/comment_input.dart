import 'dart:io';

import 'package:data_plugin/bmob/bmob_file_manager.dart';
import 'package:data_plugin/bmob/response/bmob_saved.dart';
import 'package:data_plugin/bmob/type/bmob_file.dart';

import 'package:data_plugin/bmob/response/bmob_error.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lalia/application.dart';
import 'package:lalia/model/bmobBean/comment.dart';
import 'package:lalia/model/bmobBean/user.dart';
import 'package:lalia/provider/user_provider.dart';
import 'package:lalia/widgets/selected_image.dart';
import 'package:provider/provider.dart';

import 'package:share/share.dart';

//https://github.com/alibaba/flutter-go/blob/master/lib/views/fourth_page/page_reveal.dart
class CommentInput extends StatefulWidget {
  final forWhich;
  final double width;
  final double height;
  final Map share;
  final Function callback;

  final recommend;

  const CommentInput(
      {Key key,
      this.recommend,
      @required this.forWhich,
      @required this.callback,
      this.width: double.infinity,
      this.share: const {'title': '万能社团', 'color': Colors.orange},
      this.height})
      : super(key: key);

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  TextEditingController _commentController = TextEditingController();
  FocusNode _commentFocus = FocusNode();
  File _imageFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    String app_main =  Provider.of<ThemeProvider>(context).themeColor;
    if (widget.recommend != null) recommendFocus();
//    double
    return Container(
      constraints: BoxConstraints(maxHeight: 300),
      height: _commentFocus.hasFocus ? null : widget.height,
      width: widget.width,
//      decoration: BoxDecoration(
////        color: Colors.grey[300].withOpacity(.5),
//
//        borderRadius: BorderRadius.circular(30),
//      ),
      child: TextFormField(
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            contentPadding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
            hintText: widget.recommend != null
                ? '回复' + widget.recommend.author.nickname
                : '',
            labelText: '评论一下吧',
            labelStyle: TextStyle(color: Colors.grey[800].withOpacity(.8)),
//            focusedBorder: OutlineInputBorder(
//                borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                borderSide: const BorderSide(color: Colors.grey, width: 1.0)),
//              enabledBorder: OutlineInputBorder(
//                  borderRadius:BorderRadius.all(Radius.circular(16.0),
//                  borderSide: const BorderSide(
//                      color: Colors.grey, width: 1.0)),
            prefixIcon: IconButton(
                color: Theme.of(context).accentColor,
                icon: Icon(
                  FontAwesomeIcons.shareSquare,
                  size: 20,
                  color: widget.share['color'],
                ),
                onPressed: () {
                  Share.share(widget.share['title']);
                }),
            suffixIcon: Container(
              width: 100,
              child: Row(
                children: <Widget>[
                  _imageFile == null
                      ? IconButton(
                          color: Colors.green,
                          icon: Icon(
                            Icons.add,
                            size: 20,
                          ),
                          onPressed: () {
                            _getImage();
                          })
                      : Container(
                          padding: EdgeInsets.all(5),
                          child: Stack(
                            children: <Widget>[
                              SelectedImage(
                                image: _imageFile,
                                onTap: _getImage,
                                height: 40,
                                width: 40,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _imageFile = null;
                                    });
                                  },
                                ),
                              )
                            ],
                          )),
                  IconButton(
                      color: Theme.of(context).accentColor,
                      icon: Icon(
                        Icons.send,
                        size: 20,
                      ),
                      onPressed: () => _sendComment()),
                ],
              ),
            )),
//        scrollPadding: EdgeInsets.all(5),
        maxLines: null,
        controller: _commentController,
        focusNode: _commentFocus,
        style: TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  recommendFocus() {
    if (widget.recommend != null) {
      FocusScope.of(context).requestFocus(_commentFocus);
    }
  }

  _sendComment() async {
    String content = _commentController.text;
    if (_imageFile != null) {
      File compressedFile = _imageFile;
//      FlutterStars.SpUtil.putString('userAvatar',_imageFile.path);
      if (_imageFile.path.substring(_imageFile.path.lastIndexOf(".")) != 'gif')
        compressedFile =
            await FlutterNativeImage.compressImage(_imageFile.path);
      await BmobFileManager.upload(compressedFile).then((BmobFile bmobFile) {
        content += "*@#" + bmobFile.url;
      }).catchError((e) {
        Fluttertoast.showToast(msg: BmobError.convert(e).error);
      });
    }
    if (content.length == 0) {
      Fluttertoast.showToast(msg: '请输入内容');
      return;
    }
//    User bmobUser = User();
//    bmobUser.objectId = FlutterStars.SpUtil.getString('userId');
    var liker = CommentBean();
//    liker.forWhich = widget.recommend.objectId ?? widget.forWhich.objectId;

//    trend.objectId = widget.data.objectId;
//
//    TrendLiker liker = TrendLiker();
    liker.author = Provider.of<UserProvider>(context).user;
    liker.author.objectId = Application.sp.getString("author");
//    widget.recommend != null
//        ?
//        : content;
    if (widget.recommend != null) {
      liker.forWhich = widget.recommend.objectId;
      widget.recommend.commentNum += 1;
      widget.recommend.update();
    } else {
      liker.forWhich = widget.forWhich.objectId;
      widget.forWhich.commentNum += 1;
      widget.forWhich.update();
    }
    liker.content = content;
    liker.save().then((BmobSaved bmobSaved) {
      String message = "评论成功";

      Fluttertoast.showToast(msg: message);
      if (!mounted) {
        return;
      }
      _commentFocus.unfocus();
      widget.callback(liker);
      _commentController.text = '';
      _imageFile = null;
    }).catchError((e) {
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  void _getImage() async {
    try {
      _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: "没有权限，无法打开相册！");
    }
  }
}
