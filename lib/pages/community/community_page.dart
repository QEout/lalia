import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:lalia/application.dart';
import 'package:lalia/model/bmobBean/event.dart';
import 'package:lalia/model/bmobBean/user.dart';
import 'package:lalia/pages/community/event_editor_page.dart';
import 'package:lalia/pages/community/news_list_view.dart';

import 'package:lalia/pages/community/event_page.dart';

import 'package:lalia/pages/community/popular_course_list_view.dart';
import 'package:lalia/provider/user_provider.dart';

import 'package:lalia/utils/bmob_util.dart';
import 'package:lalia/utils/navigation_util.dart';
import 'package:lalia/widgets/gadge.dart';
import 'package:lalia/widgets/state_layout.dart';
import 'package:lalia/widgets/user_edit_dialog.dart';
import 'package:provider/provider.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with AutomaticKeepAliveClientMixin<CommunityPage> {
  List<EventBean> messages = [];
  SwiperController _swiperController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _init();
//    messages =await BmobUtil.getMessages(10);
    super.initState();
  }

// @override
//  void didChangeDependencies() {
//   _swiperController.dispose();
//    super.didChangeDependencies();
//  }
//@override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          getAppBarUI(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _init,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    getCategoryUI(),
                    Container(
                      child: ListTile(
                          title: Text(
                            '动态',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              letterSpacing: 0.27,
                            ),
                          ),
                          trailing: Container(
                              width: 80,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  GestureDetector(
                                    child: Text(
                                      '写一写',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      EventEditorPage()))
                                          .then((result) {
                                        // 页面返回result为null
                                        if (result == null) {
                                          return;
                                        }
                                        setState(() {
                                          messages.insert(0, result);
                                        });
                                      }).catchError((error) {
                                        print("$error");
                                      });
                                    },
                                  ),
                                  Container(
                                      height: 10,
                                      width: 10,
                                      child: VerticalDivider(
                                        width: 5,
                                        thickness: 2,
                                      )),
                                  GestureDetector(
                                    child: Text(
                                      '更多',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EventPage()));
                                    },
                                  ),
                                ],
                              ))),

//                        padding: laliaEdgeInsets.listInset,
                    ),
                    getMessageUI(),
                    Container(
                        child: ListTile(
                      title: Text(
                        '实用工具',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          letterSpacing: 0.27,
                        ),
                      ),
                    )

//                        padding: laliaEdgeInsets.listInset,
                        ),

                    PopularCourseListView(),

//                      SizedBox(
//                        height: 64,
//                      ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getCategoryUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
//        Padding(
//          padding: const EdgeInsets.only(top: 8.0, left: 18, right: 16),
//          child: Text(
//            '信息与留言',
//            textAlign: TextAlign.left,
//            style: TextStyle(
//              fontWeight: FontWeight.w600,
//              fontSize: 20,
//              letterSpacing: 0.27,
//
//            ),
//          ),
//        ),
//        const SizedBox(
//          height: 16,
//        ),
//
//        const SizedBox(
//          height: 16,
//        ),
        NewsListView(),
      ],
    );
  }

//  void moveTo() {
//    Navigator.push<dynamic>(
//      context,
//      MaterialPageRoute<dynamic>(
//        builder: (BuildContext context) => CourseInfoScreen(),
//      ),
//    );
//  }

  Widget getAppBarUI() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '欢迎您，',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
                Consumer<UserProvider>(builder: (_, provider, __) {
                  return GestureDetector(
                    child: Text(
                      provider.user.nickname != '用户'
                          ? provider.user.nickname
                          : '设置一个昵称吧',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 0.27,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (ctx) {
                          return UserEditDialog(user: provider.user);
                        },
                      );
                    },
                  );
                })
              ],
            ),
          ),
          Consumer<UserProvider>(builder: (_, provider, __) {
            return InkWell(
              child: Container(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: ExtendedImage.network(provider.user.avatar),
                  )),
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (ctx) {
                    return UserEditDialog(user: provider.user);
                  },
                );
              },
            );
          })
        ],
      ),
    );
  }

  Widget getMessageUI() {
    if (messages.length == 0) return StateLayout(type: StateType.loading);

    return Container(
        height: 100,
        child: Swiper(
            autoplay: true,
            controller: _swiperController,
            itemCount: messages.length,
            itemBuilder: (BuildContext context, int index) {
              EventBean message = messages[index];
//          print(message.createdAt);
              return GestureDetector(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
//                color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 14.0,
                                  backgroundImage: ExtendedNetworkImageProvider(
                                      message.author.avatar),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Expanded(
                                    child: Text(
                                  message.author.nickname,
                                  style: TextStyle(fontSize: 14.0),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )),
                              ],
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              message.content,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            Spacer(),
                            Row(
                              children: <Widget>[
                                TimeFN(message.time, size: 14),
                                Spacer(),
                                InfoItem(Icons.navigation,
                                    message.likeNum.toString(),
                                    color: Theme.of(context).primaryColor),
                                SizedBox(
                                  width: 10.0,
                                ),
                                InfoItem(Icons.keyboard,
                                    message.commentNum.toString(),
                                    color: Theme.of(context).primaryColor),
                              ],
                            )
                          ],
                        )),
                        message.cover.length == 0
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  NavigationUtil.goLookImgPage(
                                      context, [message.cover], 0);

//            Navigator.push(context, LookImgRoute(data.pics.map((p) => p.originUrl).toList(), 0, picsContexts));
                                },
                                child: Container(
                                  height: 90,
                                  margin: EdgeInsets.only(left: 5, right: 0),
                                  child: showNetImage(message.cover),
                                ),
                              )
                      ],
                    )),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EventPage()));
                },
              );
            }));
  }

  Future<Null> _init() async {
    messages = await BmobUtil.queryEvent(0, load: 6);
//    print(json.decode( Application.sp.getString("user")));

    Provider.of<UserProvider>(context).init();
    setState(() {
      messages = messages;
    });
  }
}
