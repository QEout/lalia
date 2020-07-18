import 'dart:io';
import 'dart:io' as prefix0;
import 'dart:typed_data';
import 'dart:ui';

import 'package:data_plugin/bmob/bmob_file_manager.dart';
import 'package:data_plugin/bmob/response/bmob_error.dart';
import 'package:data_plugin/bmob/response/bmob_saved.dart';
import 'package:data_plugin/bmob/type/bmob_file.dart';
import 'package:flutter/material.dart';

import 'package:flutter_native_image/flutter_native_image.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lalia/application.dart';
import 'package:lalia/model/bmobBean/event.dart';
import 'package:lalia/model/bmobBean/user.dart';
import 'package:lalia/provider/user_provider.dart';

import 'dart:async';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class EventEditorPage extends StatefulWidget {
  @override
  _EventEditorPageState createState() => new _EventEditorPageState();
}

class _EventEditorPageState extends State<EventEditorPage> {
  List<Asset> images = List<Asset>();
  EventBean event = EventBean();
  List<Pic> imgList = [];
  Directory tempDir;

  String _statusText = '发布';
  bool isDirty = false, canPress = true;
  FocusNode titleFocus = FocusNode();
  FocusNode contentFocus = FocusNode();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
//    titleController.text = currentNote.title;
//    contentController.text = currentNote.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        ListView(
          children: <Widget>[
            Container(
              height: 30,
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      Container(
                          height: MediaQuery.of(context).size.height - 500,
//                          width: Screen.width,
                          child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: TextField(
                                focusNode: contentFocus,
                                controller: contentController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                onChanged: (value) {
                                  markContentAsDirty(value);
                                },
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                                decoration: InputDecoration.collapsed(
                                  hintText: '编辑内容（不少于10个字）',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  border: InputBorder.none,
                                ),
                              ))),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                '添加图片+',
                                style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            onTap: loadAssets,
                          ),
                          Container(
                            height: 400,
                            child: buildGridView(),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ],
        ),
        ClipRect(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 80,
                color: Theme.of(context).canvasColor.withOpacity(0.3),
                child: SafeArea(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: handleBack,
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () {
                          handleDelete();
                        },
                      ),
                      AnimatedContainer(
                        margin: EdgeInsets.only(left: 10),
                        duration: Duration(milliseconds: 200),
                        width: isDirty ? 100 : 0,
                        height: 42,
                        curve: Curves.decelerate,
                        child: RaisedButton.icon(
                          color: Theme.of(context).accentColor,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  bottomLeft: Radius.circular(100))),
                          icon: Icon(Icons.done),
                          label: Text(
                            _statusText,
                            style: TextStyle(letterSpacing: 1),
                          ),
                          onPressed: () {
//                                if (canPress == false) return null;
                            return handleSave();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ),
      ],
    ));
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisSpacing: 5.0,
      mainAxisSpacing: 5.0,
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 120,
          height: 120,
        );
      }),
    );
  }

  void handleSave() async {
//    ProgressDialog(hintText: "正在发布...");
    setState(() {
      canPress = false;
    });
    var i = 0;
//    FToast.show('正在发布');
    for (Asset image in images) {
      i++;
      await saveImage(image);
      setState(() {
        _statusText = (i * 100 / images.length).floor().toString();
      });
    }
    User bmobUser = Provider.of<UserProvider>(context).user;
    event.content = contentController.text;
    event.author = bmobUser;
    event.pics = imgList;
    if (imgList.length > 0)
      event.cover = imgList[0].cUrl;
    else
      event.cover = '';
// trend.weight = amount;

    await event.save().then((BmobSaved bmobSaved) {
      event.time = DateTime.now().toString();
      Fluttertoast.showToast(msg: '发布成功');
      Navigator.pop(context, event);
    }).catchError((e) {
      Fluttertoast.showToast(msg: BmobError.convert(e).error);
    });
  }

  Future saveImage(Asset asset) async {
    Pic pic = Pic();
    ByteData byteData = await asset.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();

    File file = File('${tempDir.path}/${asset.name}');
    print(file.path);
    file.writeAsBytesSync(imageData);
    print(file.path);
    if (asset.identifier == 'gif' || asset.originalWidth < 200) {
      await BmobFileManager.upload(file).then((BmobFile bmobFile) {
        pic.oUrl = bmobFile.url;
        pic.cUrl = bmobFile.url;
      });
    } else {
      await BmobFileManager.upload(file).then((BmobFile bmobFile) {
        pic.oUrl = bmobFile.url;
      });
      byteData = await asset.getThumbByteData(
          200, 200 * asset.originalHeight ~/ asset.originalWidth);
      imageData = byteData.buffer.asUint8List();
      file.writeAsBytesSync(imageData);
      await BmobFileManager.upload(file).then((BmobFile bmobFile) {
        pic.cUrl = bmobFile.url;
      });
    }
    imgList.add(pic);
    return;
  }

  void markContentAsDirty(String content) {
    if (content.length > 10) {
      setState(() {
        isDirty = true;
      });
    } else {
      setState(() {
        isDirty = false;
      });
    }
  }

  void handleDelete() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('删除草稿'),
            content: Text('编辑的内容将会清空并退出'),
            actions: <Widget>[
              FlatButton(
                child: Text('删除',
                    style: TextStyle(
                        color: Colors.red.shade300,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('取消',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future<void> loadAssets() async {
    if (tempDir == null) tempDir = await getTemporaryDirectory();
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 9,
          enableCamera: true,
          selectedAssets: images,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
//            actionBarColor: "#FF0D47A1",
            actionBarTitle: "选择图片",
            allViewTitle: "全部图片",
//            selectCircleStrokeColor: "#FF0D47A1",
          ));
    } catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
//  _error = error;
    });
  }

  void handleBack() {
    Navigator.pop(context);
  }
}
