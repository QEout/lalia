import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';
import 'markdown_tags.dart';
import 'p.dart';

class Ul {
  Ul._internal();

  static Ul _instance;

  factory Ul() {
    _instance ??= Ul._internal();
    return _instance;
  }

  Widget getUlWidget(m.Element rootNode, int deep) {
    final children = rootNode?.children;
    if (children == null) return Container();
    return Column(
      children: List.generate(
        children.length,
        (index) {
          final node = children[index];
          if (node is m.Element) {
            if (node.tag == li) return _getLiWidget(node, deep, index);
            if (node.tag == ul) return getUlWidget(node, deep + 1);
          }
          return Container();
        },
      ),
    );
  }

  Widget _getLiWidget(m.Element rootNode, int deep, int index) {
    final children = rootNode?.children;
    final List<m.Node> otherTagNodes = [];
    final isSolid = deep % 2 == 0;
    Widget ulWidget;
//    Widget
    for (var node in children) {
      if (node is m.Element && node.tag == ul) {
        ulWidget = getUlWidget(node, deep + 1);
      }
      if (node is m.Element && node.tag == input) {
      } else
        otherTagNodes.add(node);
    }
    final config = StyleConfig().ulConfig;
    final Widget dotWidget =
        StyleConfig()?.ulConfig?.dotWidget?.call(deep, index);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: deep * (config?.leftSpacing ?? 10.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment:
                config?.crossAxisAlignment ?? CrossAxisAlignment.start,
            children: <Widget>[
              dotWidget ?? _getUlDot(isSolid),
              Expanded(
                child: P().getPWidget(
                  otherTagNodes,
                  rootNode,
                  textStyle: config?.textStyle ?? defaultPStyle,
                  crossAxisAlignment: WrapCrossAlignment.start,
                ),
              ),
            ],
          ),
        ),
        ulWidget ?? Container(),
      ],
    );
  }

  Widget _getUlDot(bool isSolid) {
    final config = StyleConfig().ulConfig;
    final dotSize = config?.dotSize ?? 6;
    final marginTop =
        (config?.textStyle?.fontSize ?? defaultPStyle?.fontSize ?? 14) / 2;

    return Container(
      width: dotSize,
      height: dotSize,
      margin: config?.dotMargin ??
          EdgeInsets.only(left: 5, right: 5, top: marginTop),
      decoration: BoxDecoration(
        border: isSolid ? null : Border.all(color: defaultUlDotColor),
        shape: BoxShape.circle,
        color: isSolid ? defaultUlDotColor : null,
      ),
    );
  }
}

class UlConfig {
  final TextStyle textStyle;
  final DotWidget dotWidget;
  final double leftSpacing;
  final double dotSize;
  final EdgeInsetsGeometry dotMargin;
  final CrossAxisAlignment crossAxisAlignment;

  UlConfig({
    this.textStyle,
    this.dotWidget,
    this.leftSpacing,
    this.crossAxisAlignment,
    this.dotSize,
    this.dotMargin,
  });
}

typedef Widget DotWidget(int deep, int index);
