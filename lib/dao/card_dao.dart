import 'package:sqflite/sqflite.dart';

import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/db_provider.dart';
import 'package:lalia/model/card_bean.dart';
import 'package:lalia/utils/string_process.dart';

class CardDao extends BaseDBProvider {
  /// 表名
  final String name = "lalia_card";

  /// 表主键字段
  final String columnId = "uniqueKey";

  @override
  tableName() {
    return name;
  }

  /// 创建表的sql
  @override
  tableSqlString() {
    return tableBaseString(name, columnId) +
        '''
      name TEXT NOT NULL,
      ownerName TEXT,
      cardId TEXT NOT NULL,
      password TEXT,
      telephone TEXT,
      folder TEXT DEFALUT '默认',
      notes TEXT,
      author TEXT,
      objectId TEXT,
      label TEXT,
      fav INTEGER DEFAULT 0)
      ''';
  }

  /// 删除表
  deleteTable() async {
    Database db = await getDataBase();
    db.rawDelete("DROP TABLE $name");
  }

  /// 删除表中所有数据
  deleteContent() async {
    Database db = await getDataBase();
    db.delete(name);
  }

  /// 插入卡片
  Future<int> insert(CardBean bean) async {
    Database db = await getDataBase();
    return await db.insert(name, CardBean.toJson(bean));
  }

  insertList(List<CardBean> beans) async {
    Database db = await getDataBase();
    for (CardBean bean in beans) {
      Map<String, dynamic> map = CardBean.toJson(bean);
      bean.uniqueKey = await db.insert(name, map);
    }
    return beans;
  }

  /// 根据uniqueKey查询记录
  Future<CardBean> getCardBeanById(String id) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(name);
    if (maps.length > 0) {
      CardBean bean = CardBean.fromJson(maps.first);
      bean.color = getRandomColor(seed: bean.uniqueKey);
      return bean;
    }
    return null;
  }

  /// 获取所有的卡片List
  Future<List<CardBean>> getAllCardBeanList() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(name);
    if (maps.length > 0) {
      List<CardBean> res = maps.map((item) {
        CardBean bean = CardBean.fromJson(item);
        bean.color = getRandomColor(seed: bean.uniqueKey);
        return bean;
      }).toList();
      return res;
    }
    return null;
  }

  /// 删除指定uniqueKey的密码
  Future<int> deleteCardBeanById(int key) async {
    Database db = await getDataBase();
    return await db.delete(name, where: '$columnId=?', whereArgs: [key]);
  }

  /// 更新
  Future<int> updatePasswordBean(CardBean bean) async {
    Database db = await getDataBase();
    String labels = list2WaveLineSegStr(bean.label);
    return await db.rawUpdate(
        "UPDATE $name SET name=?, ownerName=?,objectId=?, cardId=?, password=?, telephone=?, folder=?, notes=?, label=?, fav=? WHERE $columnId=${bean
            .uniqueKey}",
        [
          bean.name,
          bean.ownerName,
          bean.objectId,
          bean.cardId,
          bean.password,
          bean.telephone,
          bean.folder,
          bean.notes,
          labels,
          bean.fav
        ]);
  }
}
