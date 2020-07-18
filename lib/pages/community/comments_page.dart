import 'dart:async';


import 'package:data_plugin/bmob/bmob_query.dart';
import 'package:extended_image/extended_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lalia/application.dart';
import 'package:lalia/model/bmobBean/comment.dart';
import 'package:lalia/model/bmobBean/user.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/widgets/comment_input.dart';
import 'package:lalia/widgets/gadge.dart';
import 'package:lalia/widgets/lalia_listview.dart';
import 'package:lalia/widgets/state_layout.dart';
import 'package:lalia/widgets/user_detail_widget.dart';
import 'package:like_button/like_button.dart';

class CommentsPage extends StatefulWidget {
//  final List<Liker> comment;
  final forWhich;
  final String title;

  CommentsPage({Key key,
    this.title = "全部评论",
    @required this.forWhich,
  })
      : super(key: key);

  @override
  _CommentsPageState createState() => new _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage>
    with TickerProviderStateMixin {
  List comments = [];

  CommentBean recommend;
  int _loadedComment = 0,
      _commentNum = 10;
  bool _isLoading = true;
  StateType _stateType = StateType.loading;
  var forWhich;
  var data;

  @override
  void initState() {
    // TODO: implement initState
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: laliaTextUI.titleBarStyle,),
          centerTitle: true,
        ),
        body: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
//        alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              Container(
                child: LaliaListView(
                  onRefresh: _onRefresh,
                  loadMore: _loadMore,
                  hasMore: _hasMore(),
                  stateType: _stateType,

                  padding: EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return _buildComment(context, comments[index]);
                  },
                ),
                margin: EdgeInsets.only(bottom: 60),
              ),
              Positioned(
                  bottom: 0,
                  left: 16,
                  right: 16,
                  child: Container(

                    padding: EdgeInsets.only(bottom: 10, top: 5),
                    child: CommentInput(
                      forWhich: forWhich,
                      recommend: recommend,
                      callback: (val) => _onInput(val),
                    ),
                  ))
            ],
          ),
        ));
  }

  _onInput(val) async {
    var liker = val;
    liker.createdAt = DateTime.now().toString();
    forWhich.commentNum += 1;
    setState(() {
      if (recommend != null) {
//        forWhich.commentNum += 1;
        recommend.replies.insert(0, liker);
      } else {
//        widget.forWhich.commentNum += 1;
        comments.insert(0, liker);
      }
      recommend = null;
    });
  }

//  Widget _buildMoreReplyWidget(comment) {
//    bool hasMore = comment.loadedReply < comment.commentNum;
//    return Padding(
//      padding: const EdgeInsets.symmetric(vertical: 5.0),
//      child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        crossAxisAlignment: CrossAxisAlignment.center,
//        children: <Widget>[
//          Offstage(offstage: !hasMore, child: _buildReplyLine(comment))
//        ],
//      ),
//    );
//  }
//
//  Widget _buildReplyLine(comment) {
//    int leftReply = comment.commentNum - comment.loadedReply;
//    if (comment.loadingReply == true) return Gaps.hGap4;
//    return GestureDetector(
//      child: Text('查看' + leftReply.toString() + '条回复',
//          style: TextStyle(color: const Color(0x8A000000))),
//      onTap: () {
//        _loadReply(comment);
//      },
//    );
//  }

  Widget _buildComment(BuildContext context, CommentBean comment) {
    // var reply = comment.reply;
    String content = comment.content.split("*@#")[0] == null
        ? null
        : comment.content.split("*@#")[0];
    String url = comment.content.split("*@#")[0] == comment.content
        ? null
        : comment.content.split("*@#")[1];
    return Column(children: <Widget>[
      _buildTopView(comment),
      content == null
          ? Gaps.hGap5
          : Container(
          padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          alignment: Alignment.centerLeft,
//    ${comment.content}
          child: RichText(
              text: TextSpan(
                  text: content,
                  style: TextStyle(color: Theme
                      .of(context)
                      .textTheme
                      .body1
                      .color),
                  children: <TextSpan>[
                    url != null
                        ? TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
//                              comment.delete();
//                              widget.forWhich.commentNum-=1;
//                              widget.forWhich.update();
//                              Fluttertoast.showToast(msg:'删除成功');
                          setState(() {
                            comment.showPic = true;
                          });
                        },
                      text: '查看图片',
                      style: new TextStyle(
                          color: Colors.blueGrey),
                    )
                        : TextSpan(text: '',),
                    TextSpan(
                      text: '      ',
                    ),
                    comment.author.objectId ==
                        Application.sp.getString('author')
                        ? TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          comment.delete();
                          widget.forWhich.commentNum -= 1;
                          widget.forWhich.update();
                          Fluttertoast.showToast(msg: '删除成功');
                          setState(() {
                            comments.remove(comment);
                          });
                        },
                      text: '删除',
                      style: new TextStyle(
                          color: Theme
                              .of(context)
                              .accentColor),
                    )
                        : TextSpan(text: '',),

                    TextSpan(
                      text: '      ',
                    ),
                    TextSpan(
                        text: TimeFN(comment.createdAt, toString: true),
                        style: TextStyle(color: Colors.grey)
                    ),
                  ]))),
      comment.showPic ? Container(
        padding: EdgeInsets.only(bottom: 5), child: ExtendedImage.network(url),
      ) : Gaps.hGap4,
      comment.replies.length > 0
          ? Container(
        margin: EdgeInsets.only(top: 5, bottom: 5, left: 10),
        padding: EdgeInsets.only(left: 5),
        decoration: new BoxDecoration(
            color: Colors.grey.shade200,
//                      borderRadius: BorderRadius.circular(17),
            border: Border(
                left: BorderSide(
                  width: 5,

                  color: Theme
                      .of(context)
                      .accentColor,
                ))),
        child: ListView.builder(
            itemCount: comment.replies.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return _buildReply(context, comment.replies[index], comment);
            }),
      )
          : Gaps.hGap4,
      comment.commentNum > 3 ?
      _buildMoreReplies(comment) : Gaps.hGap4,
//      _buildMoreReplyWidget(comment),
    ]);
  }

  _buildMoreReplies(CommentBean data) {
    return InkWell(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(
            builder: (context) => CommentsPage(forWhich: data, title: "全部回复")
        ));
      },
      child: Text('查看更多${data.commentNum - 5}条回复', style: TextStyle(color: Theme
          .of(context)
          .accentColor),),
    );
  }

  _buildReply(BuildContext context, CommentBean comment, CommentBean data) {
    comment.liked = Application.sp.getBool(comment.objectId) ?? false;
    return Container(
      child:
      Row(crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            UserDetailWidget(
              user: comment.author,
              type: 0,
              radius: 12,
            ),
            HEmptyView(5),
            Expanded(child: Text('：' + comment.content)),

            GestureDetector(
              child: Text(
                '回复',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(
                    builder: (context) =>
                        CommentsPage(forWhich: data, title: "全部回复",)
                ));
              },
            ),
            Gaps.hGap10,

            LikeButton(
              isLiked: comment.liked,
              likeCount: comment.likeNum,
              likeBuilder: (bool isliked) {
                return Icon(
                  Icons.navigation,
                  color: isliked ? Theme
                      .of(context)
                      .accentColor : Colors.grey,
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

  Widget _buildTopView(comment) {
    comment.liked = Application.sp.getBool(comment.objectId) ?? false;
    return Row(children: <Widget>[
      Expanded(child:
      UserDetailWidget(
        user: comment.author,
        radius: 14,
        // radius: reply ? 12 : 16,
//        type: reply?1:2,
      )),


      GestureDetector(
        child: Text(
          '${comment.commentNum != 0 ? comment.commentNum : ''}回复'
          ,
          style: TextStyle(color: Theme
              .of(context)
              .accentColor),
        ),
        onTap: () {
          // reply == true ? forWhich = comment.forWhich : forWhich = comment;
//          data = TrendReply();
          setState(() {
            recommend = comment;
          });
        },
      ),
      Gaps.hGap10,
      LikeButton(
        isLiked: comment.liked,
        likeCount: comment.likeNum,
        likeBuilder: (bool isliked) {
          return Icon(
            Icons.navigation,
            color: isliked ? Theme
                .of(context)
                .accentColor : Colors.grey,
            size: 20,
          );
        },
        onTap: (bool isLiked) {
          return onLikeTap(comment, isLiked);
        },
      ),
    ]);
  }

  Future _initData() async {
    forWhich = widget.forWhich;
    _commentNum = widget.forWhich.commentNum;
    _isLoading = true;
    await _loadComment();
  }


  _loadComment() async {
//    setState(() {
//      _isLoading = true;
//    });

    BmobQuery<CommentBean> likerQuery = BmobQuery();
    likerQuery.addWhereEqualTo("forWhich", widget.forWhich.objectId);
    likerQuery.setLimit(10);
    likerQuery.setOrder("-likeNum");
    likerQuery.setSkip(_loadedComment);
    likerQuery.setInclude("author");
    await likerQuery.queryObjects().then((List<dynamic> data) async {
      comments..addAll(data.map((i) => CommentBean.fromJson(i)).toList());
      if (comments.length == 0) {
        setState(() {
          _stateType = StateType.empty;
        });
        return;
      }
      for (CommentBean comment in comments) {
        if (comment.commentNum > 0) {
          comment.replies = await _loadReply(comment.objectId);
        }
      }
      setState(() {
        comments = comments;
        _loadedComment += 10;
        _isLoading = false;
      });
    });
  }

  _loadReply(String forWhich) async {
    BmobQuery<CommentBean> likerQuery = BmobQuery();
    likerQuery.addWhereEqualTo("forWhich", forWhich);
    likerQuery.setLimit(3);
    likerQuery.setOrder("-likeNum");
    likerQuery.setInclude("author");
    return await likerQuery.queryObjects().then((List<dynamic> data) async {
      return data.map((i) => CommentBean.fromJson(i)).toList();
    });
  }


  Future _onRefresh() async {
    _loadedComment = 0;
    comments = [];
    await _loadComment();
  }

  bool _hasMore() {
    return _loadedComment < _commentNum;
  }

  Future _loadMore() async {
    if (_isLoading) {
      return;
    }
    if (!_hasMore()) {
      return;
    }
    _isLoading = true;
    await _loadComment();
  }
}
