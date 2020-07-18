import 'package:extended_image/extended_image.dart';
/**
 * Author: Damodar Lohani
 * profile: https://github.com/lohanidamodar
 */

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lalia/widgets/swiper_pagination.dart';

class IntroPage extends StatefulWidget {
  static final String path = "lib/src/pages/onboarding/intro4.dart";

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final SwiperController _swiperController = SwiperController();
  final int _pageCount = 3;
  int _currentIndex = 0;
  List<String> titleList = [
    "多样丰富的功能等你发现，成为你最贴心的密码管家 ",
    "不只是一个密码管理工具，欢迎您加入社区",
    "自动填充密码，隐私保护"
  ];
  String title;
  List<String> images = [
    "http://lalia.aiyi.pro/Screenshot_1590557065.png",
    "http://lalia.aiyi.pro/Screenshot_1590557059.png",
    "http://lalia.aiyi.pro/Screenshot_2020-05-27-11-39-38-06_e77114277cb867f.png"
  ];
  final String bgImage = "http://lalia.aiyi.pro/bg.jpg";
  double opacityLevel = 0;

  _changeOpacity(int index) {
    //调用setState（）  根据opacityLevel当前的值重绘ui
    // 当用户点击按钮时opacityLevel的值会（1.0=>0.0=>1.0=>0.0 ...）切换
    // 所以AnimatedOpacity 会根据opacity传入的值(opacityLevel)进行重绘 Widget

    setState(() {
      opacityLevel = opacityLevel == 0 ? 1.0 : 0.0;
      _currentIndex = index;
      title = titleList[index];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _changeOpacity(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Image.network(
              bgImage,
              fit: BoxFit.contain,
            ),
            padding: EdgeInsets.only(bottom: 100),
          ),
          Column(
            children: <Widget>[
              Expanded(
                  child: Swiper(
                index: _currentIndex,
                controller: _swiperController,
                itemCount: _pageCount,
                onIndexChanged: (index) {
                  _changeOpacity(index);
                },
                loop: false,
                itemBuilder: (context, index) {
                  return _buildPage(icon: images[index]);
                },
                pagination: SwiperPagination(
                    builder: CustomPaginationBuilder(
                        activeSize: Size(10.0, 20.0),
                        size: Size(10.0, 15.0),
                        color: Colors.grey.shade600)),
              )),
              SizedBox(height: 10.0),
              AnimatedOpacity(
                  // 使用一个AnimatedOpacity Widget
                  opacity: opacityLevel,
                  duration: new Duration(seconds: 1), //过渡时间：1
                  child: Container(
//                      color: Colors.black12,

                      child: Text(title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                              color: Colors.blue)))),
              _buildButtons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      margin: const EdgeInsets.only(right: 16.0, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
            textColor: Colors.grey.shade700,
            child: Text("跳过"),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('login');
            },
          ),
          IconButton(
            icon: Icon(
              _currentIndex < _pageCount - 1
                  ? FontAwesomeIcons.arrowCircleRight
                  : FontAwesomeIcons.checkCircle,
              size: 35,
            ),
            color: Colors.blue,
            onPressed: () async {
              if (_currentIndex < _pageCount - 1)
                _swiperController.next();
              else {
                Navigator.of(context).pushReplacementNamed('login');
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildPage({String icon}) {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(50.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.grey.shade200,
            image: DecorationImage(
              image: ExtendedNetworkImageProvider(icon),
              fit: BoxFit.fill,

//          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.multiply)
            ),
            boxShadow: [
              BoxShadow(
                  blurRadius: 10.0,
                  spreadRadius: 5.0,
                  offset: Offset(5.0, 5.0),
                  color: Colors.black12)
            ]));
  }
}
