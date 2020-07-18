import 'dart:math';

import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import 'p.dart';
import 'markdown_tags.dart';
import '../config/style_config.dart';

class MTable {
  MTable._internal();

  static MTable _instance;

  factory MTable() {
    _instance ??= MTable._internal();
    return _instance;
  }

  Widget getTableWidget(m.Element node) {
    if (node.children == null) return Container();
    final config = StyleConfig().tableConfig;

    TableRow header;
    List<TableRow> body = [];
    for (var childNode in node.children) {
      if (childNode is m.Element) {
        if (childNode.tag == thead)
          header = _buildHeader(childNode, config);
        else if (childNode.tag == tbody)
          body.addAll(_buildBody(childNode, config));
      }
    }
    if (header != null) body.insert(0, header);
    final table = Table(
      columnWidths: config?.columnWidths,
      defaultColumnWidth: config?.defaultColumnWidth ?? const FlexColumnWidth(),
      textBaseline: config?.textBaseline,
      textDirection: config?.textDirection,
      border: config?.border ?? TableBorder.all(color: defaultTableBorderColor),
      defaultVerticalAlignment:
          config?.defaultVerticalAlignment ?? TableCellVerticalAlignment.middle,
      children: body,
    );
    return config?.wrapBuilder?.call(table) ?? table;
  }

  TableRow _buildHeader(
    m.Element node,
    TableConfig config,
  ) {
    List<m.Element> thList = [];
    _buildTh(node, thList);
    return TableRow(
        decoration: config?.headerRowDecoration,
        children: List.generate(
          thList.length,
          (index) => Container(
            margin: config?.headerMargin ?? const EdgeInsets.all(10),
            alignment: config?.headerAlignment ?? Alignment.center,
            child: P().getPWidget(thList[index].children, thList[index],
                textStyle: config?.headerStyle),
          ),
        ));
  }

  void _buildTh(m.Node node, List<m.Element> thList) {
    if (node != null && node is m.Element) {
      if (node.tag == th) thList.add(node);
      List.generate(node?.children?.length ?? 0,
          (index) => _buildTh(node.children[index], thList));
    }
  }

  List<TableRow> _buildBody(
    m.Element node,
    TableConfig config,
  ) {
    if (node.children == null) return [];
    List<TableRow> results = [];
    int maxRowSize = 0;
    for (var trNode in node.children) {
      if (trNode is m.Element && trNode.tag == tr) {
        List<m.Element> tdList = [];
        _buildTd(trNode, tdList);
        List<Widget> children = [];
        tdList.forEach((element) {
          final child = Container(
            margin: config?.bodyMargin ?? const EdgeInsets.all(10.0),
            alignment: config?.bodyAlignment ?? Alignment.center,
            child: P().getPWidget(element.children, element,
                textStyle: config?.bodyStyle),
          );
          children.add(child);
        });
        maxRowSize = max(maxRowSize, tdList.length);
        if (tdList.length < maxRowSize) {
          for (int i = 0; i < maxRowSize - tdList.length; i++)
            children.add(Container());
        }
        final tableRow = TableRow(
          decoration: config?.bodyRowDecoration,
          children: children,
        );
        results.add(tableRow);
      }
    }
    return results;
  }

  void _buildTd(m.Node node, List<m.Element> tdList) {
    if (node != null && node is m.Element) {
      if (node.tag == td) tdList.add(node);
      List.generate(node.children?.length ?? 0,
          (index) => _buildTd(node.children[index], tdList));
    }
  }
}

class TableConfig {
  final Map<int, TableColumnWidth> columnWidths;
  final TableColumnWidth defaultColumnWidth;
  final TextDirection textDirection;
  final TableBorder border;
  final TableCellVerticalAlignment defaultVerticalAlignment;
  final TextBaseline textBaseline;
  final Decoration headerRowDecoration;
  final Decoration bodyRowDecoration;
  final TextStyle headerStyle;
  final TextStyle bodyStyle;
  final EdgeInsetsGeometry headerMargin;
  final EdgeInsetsGeometry bodyMargin;
  final Alignment headerAlignment;
  final Alignment bodyAlignment;
  final TableWrapper wrapBuilder;

  TableConfig({
    this.columnWidths,
    this.defaultColumnWidth,
    this.textDirection,
    this.border,
    this.defaultVerticalAlignment,
    this.textBaseline,
    this.headerRowDecoration,
    this.bodyRowDecoration,
    this.headerStyle,
    this.bodyStyle,
    this.headerMargin,
    this.bodyMargin,
    this.headerAlignment,
    this.bodyAlignment,
    this.wrapBuilder,
  });
}

typedef Widget TableWrapper(Table table);
