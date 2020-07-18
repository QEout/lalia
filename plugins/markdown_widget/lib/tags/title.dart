import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

import 'markdown_tags.dart';

class MTitle {
  MTitle._internal();

  static MTitle _instance;

  factory MTitle() {
    _instance ??= MTitle._internal();
    return _instance;
  }

  ///h1~h6
  Widget getTitleWidget(m.Element node, String tag) {
    Widget titleWidget;
    switch (tag) {
      case h1:
        titleWidget = textWithDivider(node, _titleStyle(28), h1);
        break;
      case h2:
        titleWidget = textWithDivider(node, _titleStyle(25), h2);
        break;
      case h3:
        titleWidget = textWithDivider(node, _titleStyle(22), h3);
        break;
      case h4:
        titleWidget = textWithDivider(node, _titleStyle(19), h4);
        break;
      case h5:
        titleWidget = textWithDivider(node, _titleStyle(17), h5);
        break;
      case h6:
        titleWidget = textWithDivider(node, _titleStyle(12), h6);
        break;
    }
    return titleWidget;
  }

  TextStyle _titleStyle(double fontSize) => TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: defaultTitleColor,
      );

  Widget buildDivider() => Container(height: 1, color: defaultDividerColor);

  Widget textWithDivider(m.Element node, TextStyle style, String tag) {
    final config = StyleConfig().titleConfig;
    bool showDivider = config?.showDivider ?? true;
    TextStyle configStyle;
    switch (tag) {
      case h1:
        configStyle = config?.h1;
        break;
      case h2:
        configStyle = config?.h2;
        break;
      case h3:
        configStyle = config?.h3;
        break;
      case h4:
        configStyle = config?.h4;
        break;
      case h5:
        configStyle = config?.h5;
        break;
      case h6:
        configStyle = config?.h6;
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        P().getPWidget(node.children, node,
            textStyle: (configStyle ?? style).merge(config?.commonStyle)),
        SizedBox(height: config?.space ?? 4.0),
        showDivider ? (config?.divider ?? buildDivider()) : Container()
      ],
    );
  }
}

class TitleConfig {
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle h6;
  final TextStyle commonStyle;
  final bool showDivider;
  final Widget divider;
  final double space;

  TitleConfig(
      {this.h1,
      this.h2,
      this.h3,
      this.h4,
      this.h5,
      this.h6,
      this.commonStyle,
      this.showDivider,
      this.divider,
      this.space});
}
