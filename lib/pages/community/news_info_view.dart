import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lalia/model/bmobBean/category.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'comments_page.dart';

class NewsInfoView extends StatefulWidget {
  const NewsInfoView({Key key, this.data}) : super(key: key);
  final Category data;

  @override
  _NewsInfoViewState createState() => _NewsInfoViewState();
}

class _NewsInfoViewState extends State<NewsInfoView>
    with TickerProviderStateMixin {
  Category data;
  double size = 15;
  final TocController controller = TocController();

  @override
  void initState() {
    data = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: laliaTextUI.titleBarStyle,
          ),
        ),
        drawer: Drawer(
            child: Container(
                padding: EdgeInsets.only(top: 30), child: buildTocList())),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: MarkdownWidget(
              data: data.content,
              controller: controller,
              styleConfig: StyleConfig(
                markdownTheme: Theme.of(context).canvasColor == Colors.black
                    ? MarkdownTheme.darkTheme
                    : MarkdownTheme.lightTheme,
                pConfig: PConfig(
                  textStyle: TextStyle(
                      color: Theme.of(context).textTheme.body1.color,
                      fontSize: size),
                  linkGesture: (linkChild, url) {
                    return GestureDetector(
                      child: linkChild,
                      onTap: () => _launchURL(url),
                    );
                  },
                ),
              )),
        ),
        floatingActionButton: FabCircularMenu(
            ringColor: Theme.of(context).accentColor.withOpacity(0.8),
            fabColor: Theme.of(context).accentColor.withOpacity(0.8),
            ringWidth: 60,
            fabSize: 40,
            fabOpenIcon: Icon(Icons.menu, color: Colors.white),
            fabCloseIcon: Icon(Icons.clear, color: Colors.white),
            ringDiameter: 300,
            children: <Widget>[
//    Button(icon: Icon(Icons.comment),
//        color: Colors.white, onPressed: () {
//      Navigator.push(context, MaterialPageRoute(
//          builder: (context) =>CommentsPage (forWhich: data)
//      ));
//    }),
              GestureDetector(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.keyboard,
                      size: 25.0,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      data.commentNum.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommentsPage(forWhich: data)));
                },
              ),
              IconButton(
                  icon: Icon(Icons.zoom_in),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      size++;
                    });
                  }),
              IconButton(
                  icon: Icon(Icons.zoom_out),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      size--;
                    });
                  })
            ]));
  }

  Widget buildTocList() => TocListWidget(
        controller: controller,
      );

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
