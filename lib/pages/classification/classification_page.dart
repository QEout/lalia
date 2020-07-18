import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:lalia/params/runtime_data.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/screen_util.dart';
import 'package:lalia/pages/classification/favorite_page.dart';
import 'package:lalia/pages/setting/category_manager_page.dart';
import 'package:lalia/pages/classification/classification_details_page.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';

class ClassificationPage extends StatelessWidget {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: InkWell(
            splashColor: Colors.transparent,
            child: Text(
              "分类",
              style: laliaTextUI.titleBarStyle,
            ),
            onTap: () {
              _controller.animateTo(0,
                  duration: Duration(milliseconds: 200), curve: Curves.linear);
            },
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: GridView(
          controller: _controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: laliaScreenUtil.setWidth(100),
            crossAxisSpacing: laliaScreenUtil.setWidth(100),
          ),
          padding: laliaEdgeInsets.listInsetN,
          children: getClassWidgets(context),
        ));
  }

  List<Widget> getClassWidgets(BuildContext context) {
    List<Widget> list = List();
    list.add(GestureDetector(
      child: NeuomorphicContainer(
        margin: EdgeInsets.all(2),
        borderRadius: BorderRadius.circular(11),
        intensity: 0.1,
        color: Theme.of(context).scaffoldBackgroundColor,
        offset: Offset(2, 2),
        blur: 4,
        style: NeuomorphicStyle.Flat,
        child: Center(
          child: Text(
            "收藏",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onTap: () => Navigator.push(
          context, CupertinoPageRoute(builder: (context) => FavoritePage())),
    ));
    list.addAll(RuntimeData.folderList.map((folder) => GestureDetector(
          child: NeuomorphicContainer(
            margin: EdgeInsets.all(2),
            borderRadius: BorderRadius.circular(11),
            intensity: 0.1,
            color: Theme.of(context).scaffoldBackgroundColor,
            offset: Offset(2, 2),
            blur: 4,
            style: NeuomorphicStyle.Flat,
            child: Center(
              child: Text(
                folder,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: getRandomColor(seed: folder.hashCode),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ClassificationDetailsPage(folder)));
          },
          onLongPress: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => CategoryManagerPage("文件夹"),
              )),
        )));
    return list;
  }
}
