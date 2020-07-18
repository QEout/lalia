import 'package:extended_image/extended_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'package:flutter/material.dart';
import 'package:lalia/pages/community/design_course_app_theme.dart';
import 'package:lalia/model/bmobBean/category.dart';
import 'package:lalia/pages/community/news_info_view.dart';
import 'package:lalia/utils/bmob_util.dart';
import 'package:lalia/widgets/gadge.dart';
import 'package:lalia/widgets/state_layout.dart';

class NewsListView extends StatefulWidget {
  const NewsListView({Key key}) : super(key: key);

  @override
  _NewsListViewState createState() => _NewsListViewState();
}

class _NewsListViewState extends State<NewsListView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List<Category> categoryList = [];
  SwiperController _swiperController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _onLoad();
    super.initState();
  }

//  @override
//  void didChangeDependencies() {
//    _swiperController.dispose();
//    super.didChangeDependencies();
//  }

  @override
  void dispose() {
    _swiperController.dispose();
    animationController.dispose();
    super.dispose();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Container(
        height: 134,
        width: double.infinity,
        child: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              if (categoryList.length == 0)
                return StateLayout(
                  type: StateType.loading,
                );
              return Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 0, right: 16),
                  child: Swiper(
                      controller: _swiperController,
                      pagination: SwiperPagination(),
                      autoplay: false,
                      itemCount: categoryList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        final int count =
                            categoryList.length > 10 ? 10 : categoryList.length;
                        final Animation<double> animation =
                            Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                    parent: animationController,
                                    curve: Interval((1 / count) * index, 1.0,
                                        curve: Curves.fastOutSlowIn)));
                        animationController.forward();

                        return CategoryView(
                          category: categoryList[index],
                          animation: animation,
                          animationController: animationController,
                        );
                      }));
            }
          },
        ),
      ),
    );
  }

  void _onLoad() async {
    categoryList = await BmobUtil.queryCategory(1);
  }
}

class CategoryView extends StatelessWidget {
  const CategoryView({
    Key key,
    this.category,
    this.animationController,
    this.animation,
  }) : super(key: key);

  final Category category;
  final AnimationController animationController;
  final Animation<dynamic> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation.value), 0.0, 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) =>
                        NewsInfoView(data: category),
                  ),
                );
              },
              child: SizedBox(
                width: 280,
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 48,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0)),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, left: 60, right: 5),
                                            child: Text(
                                              category.title,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                letterSpacing: 0.27,
                                                color: DesignCourseAppTheme
                                                    .darkerText,
                                              ),
                                            ),
                                          ),
                                          VEmptyView(5),
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 60, bottom: 5, right: 5),
                                            child: Text(
                                              category.content,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w200,
                                                fontSize: 12,
                                                letterSpacing: 0.27,
                                                color:
                                                    DesignCourseAppTheme.grey,
                                              ),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 24, bottom: 24, left: 16),
                        child: Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16.0)),
                              child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: ExtendedImage.network(
                                      category.imagePath,
                                      fit: BoxFit.fill)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
