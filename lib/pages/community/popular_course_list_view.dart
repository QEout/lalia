import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:lalia/pages/community/design_course_app_theme.dart';
import 'package:lalia/model/bmobBean/category.dart';

import 'package:lalia/utils/bmob_util.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';
import 'package:url_launcher/url_launcher.dart';

class PopularCourseListView extends StatefulWidget {
  const PopularCourseListView({Key key}) : super(key: key);

  @override
  _PopularCourseListViewState createState() => _PopularCourseListViewState();
}

class _PopularCourseListViewState extends State<PopularCourseListView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List<Category> categoryList = [];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _onLoad();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  void _onLoad() async {
    categoryList = await BmobUtil.queryCategory(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            return GridView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
              physics: NeverScrollableScrollPhysics(),
//              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: List<Widget>.generate(
                categoryList.length,
                (int index) {
                  final int count = categoryList.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController,
                      curve: Interval((1 / count) * index, 1.0,
                          curve: Curves.fastOutSlowIn),
                    ),
                  );
                  animationController.forward();

                  return Container(
                      height: 30,
                      child: CategoryView(
                        category: categoryList[index],
                        animation: animation,
                        animationController: animationController,
                      ));
                },
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1.8,
              ),
            );
          }
        },
      ),
    );
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
                  0.0, 50 * (1.0 - animation.value), 0.0),
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () async {
                  await launch(category.url);
                },
                child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          // border: new Border.all(
                          //     color: DesignCourseAppTheme.notWhite),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              category.title,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.27,
                                color: DesignCourseAppTheme.darkerText,
                              ),
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  category.content,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w200,
                                    fontSize: 12,
                                    letterSpacing: 0.27,
                                    color: DesignCourseAppTheme.grey,
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '${category.rating}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w200,
                                          fontSize: 18,
                                          letterSpacing: 0.27,
                                          color: DesignCourseAppTheme.grey,
                                        ),
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      NeuomorphicContainer(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        style: NeuomorphicStyle.Convex,
                        intensity: 0.2,
                        height: 40,
                        offset: Offset(3, 3),
                        blur: 4,
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16.0)),
                            child: ExtendedImage.network(
                              category.imagePath,
                              fit: BoxFit.fill,
                            )),
                      ),
                    ]),
              )),
        );
      },
    );
  }
}
