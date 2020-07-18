import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lalia/application.dart';
import 'package:lalia/model/bmobBean/comment.dart';
import 'package:lalia/model/bmobBean/event.dart';
import 'package:lalia/pages/community/comments_page.dart';
import 'package:lalia/utils/bmob_util.dart';
import 'package:lalia/utils/navigation_util.dart';
import 'package:lalia/widgets/comment_input.dart';
import 'package:lalia/widgets/gadge.dart';
import 'package:lalia/widgets/lalia_listview.dart';
import 'package:lalia/widgets/state_layout.dart';
import 'package:lalia/widgets/user_detail_widget.dart';
import 'package:like_button/like_button.dart';
import 'package:markdown_widget/markdown_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'Widgets/event_special_text_span_builder.dart';
import 'package:lalia/ui/lalia_ui.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<EventBean> _eventData = [], _resData = []; // 动态数据
  int _loadedNum = 0;
  int _totalNum = 0; // 当前请求回来的动态数据，如果为空的话则代表没有数据了
//  int lastTime = -1;
  Database db;

  @override
  void initState() {
    _onRefresh();
    super.initState();
  }

  // 构建动态通用的模板（头像、粉丝等）
  Widget _buildCommonTemplate(EventBean data) {
//    String content=data.content;

    Widget title = Row(
      children: <Widget>[
        Expanded(
          child: UserDetailWidget(
            user: data.author,
            radius: 14,
          ),
        ),
        data.author.objectId == Application.sp.getString('author')
            ? GestureDetector(
                child: Text('删除',
                    style: TextStyle(color: Theme.of(context).accentColor)),
                onTap: () {
                  data.delete();

                  Fluttertoast.showToast(msg: '删除成功');
                  setState(() {
                    _eventData.remove(data);
                  });
                },
              )
            : SizedBox(
                height: 1,
              ),
      ],
    );

    Widget picsWidget; // 图片widget
    int crossCount;
    List<BuildContext> picsContexts = [];

    if (data.pics.isEmpty) {
      picsWidget = Container();
    } else if (data.pics.length == 1) {
      picsWidget = Builder(builder: (context) {
        picsContexts.add(context);
        return GestureDetector(
          onTap: () {
            print('ss');
            NavigationUtil.goLookImgPage(
                context, data.pics.map((p) => p.oUrl).toList(), 0);

//            Navigator.push(context, LookImgRoute(data.pics.map((p) => p.originUrl).toList(), 0, picsContexts));
          },
          child: Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setWidth(15)),
            child: showNetImage(data.pics[0].cUrl, height: 200),
          ),
        );
      });
    } else {
      if (data.pics.length >= 2 && data.pics.length < 5) crossCount = 2;
      if (data.pics.length > 4) crossCount = 3;

      picsWidget = Padding(
        padding: EdgeInsets.only(top: ScreenUtil().setWidth(15)),
        child: GridView.custom(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              mainAxisSpacing: ScreenUtil().setWidth(10),
              crossAxisSpacing: ScreenUtil().setWidth(10)),
          childrenDelegate: SliverChildBuilderDelegate((context, index) {
            var w = Builder(
              builder: (context) {
                picsContexts.add(context);
                return GestureDetector(
                  onTap: () {
                    NavigationUtil.goLookImgPage(
                        context, data.pics.map((p) => p.oUrl).toList(), index);
//                  Navigator.push(context, LookImgRoute(data.pics.map((p) => p.originUrl).toList(), index, picsContexts));
                  },
                  child: Hero(
                    tag: '${data.pics[index].oUrl}$index',
                    child: showNetImage(
                      data.pics[index].cUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
            return w;
          }, childCount: data.pics.length),
        ),
      );
    }

    return Container(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title,
        VEmptyView(10),
        ExtendedText(
          data.content ?? "",
          specialTextSpanBuilder: EventSpecialTextSpanBuilder(),
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        picsWidget,
        VEmptyView(20),
        _buildCommonBottomBar(data),
        VEmptyView(10),
        data.showComment
            ? CommentInput(
                forWhich: data,
                callback: (val) => _onInput(data, val),
              )
            : Gaps.hGap4,
        _buildCommentList(context, data),
        data.showComment && data.commentNum > 5
            ? _buildMoreCommentView(data)
            : Gaps.hGap4,
        Divider(
          height: 5,
        ),
        VEmptyView(10),
      ],
    ));
  }

  _buildCommentList(BuildContext context, EventBean data) {
    if (!data.showComment) {
      return HEmptyView(1);
    } else if (data.comments.length == 0) {
      return Padding(
        child: StateLayout(
          type: StateType.empty,
        ),
        padding: EdgeInsets.only(top: 5),
      );
    } else {
      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: data.comments.length,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        itemBuilder: (_, index) {
          return _buildComment(context, data.comments[index], data);
        },
      );
    }
  }

  _buildMoreCommentView(EventBean data) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CommentsPage(forWhich: data)));
      },
      child: Text(
        '查看更多${data.commentNum - 5}条评论',
        style: TextStyle(color: Theme.of(context).accentColor),
      ),
    );
  }

  _buildComment(BuildContext context, CommentBean comment, EventBean data) {
    comment.liked = Application.sp.getBool(comment.objectId) ?? false;
    String content = comment.content.split("*@#")[0];
    String text = comment.content;
    if (comment.content != content) text = content + '[图片]';
    return Container(
      child: Row(crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            UserDetailWidget(
              user: comment.author,
              type: 0,
              radius: 12,
            ),
            HEmptyView(5),
            Expanded(child: Text(text)),
            GestureDetector(
              child: Text(
                '回复',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommentsPage(forWhich: data)));
              },
            ),
            HEmptyView(8),
            LikeButton(
              isLiked: comment.liked,
              likeCount: comment.likeNum,
              likeBuilder: (bool isliked) {
                return Icon(
                  Icons.navigation,
                  color: isliked ? Theme.of(context).accentColor : Colors.grey,
                  size: 20,
                );
              },
              onTap: (bool isLiked) {
                return onLikeTap(comment, isLiked);
              },
            ),
          ]),
      padding: EdgeInsets.symmetric(vertical: 5),
    );
  }

  // 构建通用底部bar
  Widget _buildCommonBottomBar(EventBean data) {
    data.liked = Application.sp.getBool(data.objectId) ?? false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TimeFN(data.time),
        Spacer(),
        LikeButton(
          isLiked: data.liked,
          likeCount: data.likeNum,
          likeBuilder: (bool isliked) {
            return Icon(
              Icons.navigation,
              color: isliked ? Theme.of(context).accentColor : Colors.grey,
              size: 20,
            );
          },
          onTap: (bool isLiked) {
            return onLikeTap(data, isLiked);
          },
        ),
        HEmptyView(60),
        GestureDetector(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                data.showComment ? Icons.keyboard_arrow_down : Icons.keyboard,
                size: 25.0,
                color: Colors.blueGrey,
              ),
              SizedBox(width: 5),
              Text(
                data.commentNum.toString(),
                style: TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
          onTap: () async {
            if (data.commentNum == 0) {
              Fluttertoast.showToast(msg: '快来评论一下吧');
              setState(() {
                data.showComment = !data.showComment;
                data.comments = [];
              });
              return;
            }
            setState(() {
              data.showComment = !data.showComment;
            });
            if (data.showComment && data.comments.length == 0)
              data.comments = await BmobUtil.queryComment(data.objectId);
            setState(() {
              data.comments = data.comments;
            });
          },
        ),
//        Expanded(
//          flex: 2,
//          child: Row(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              Image.asset(
//                'images/icon_event_commend.png',
//                width: ScreenUtil().setWidth(35),
//              ),
//              HEmptyView(5),
//              Text(
//                data.info.likedCount.toString(),
//                style: common13GrayTextStyle,
//              ),
//            ],
//          ),
//        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
//    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '动态',
          style: laliaTextUI.titleBarStyle,
        ),
        centerTitle: true,
      ),

      body: LaliaListView(
//      shrinkWrap: true,
        itemCount: _eventData.length,
        onRefresh: _onRefresh,
        shrinkWrap: true,
        stateType: StateType.loading,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        loadMore: _loadMore,
        hasMore: _loadedNum < _totalNum,
        itemBuilder: (_, index) {
          return _buildCommonTemplate(_eventData[index]);
//      return Text('dsd');
        },
      ),

//        Text('dsd')
    );
  }

  Future _onRefresh() async {
    _loadedNum = 0;
    _resData = await BmobUtil.queryEvent(_loadedNum);
    _totalNum = await BmobUtil.queryEventNum();
    setState(() {
      _eventData = _resData;
//      if (_eventData.length == 0) {
//        setState(() {
//          _stateType = StateType.message;
//        });
//      }
      _loadedNum = 10;
    });
  }

  Future _loadMore() async {
    _resData = await BmobUtil.queryEvent(_loadedNum);
    _eventData.addAll(_resData);
    setState(() {
      _eventData = _eventData;
      _loadedNum += 10;
    });
  }

  _onInput(EventBean data, val) async {
    var liker = val;
    liker.createdAt = DateTime.now().toString();
    setState(() {
      data.comments.insert(0, liker);
    });
  }
}
