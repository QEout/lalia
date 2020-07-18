import 'package:autofill_service/autofill_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lalia/application.dart';
import 'package:lalia/model/password_bean.dart';
import 'package:lalia/utils/bmob_util.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';
import 'package:provider/provider.dart';

import 'package:lalia/params/config.dart';
import 'package:lalia/params/runtime_data.dart';
import 'package:lalia/provider/password_list.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/encrypt_util.dart';
import 'package:lalia/route/animation_routes.dart';
import 'package:lalia/pages/password/view_password_page.dart';

class PasswordWidgetItem extends StatelessWidget {
  final int index;
  final bool autofill;

  PasswordWidgetItem(this.index, {this.autofill = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<PasswordList>(
      builder: (context, model, child) {
        return
//          Container(
//          margin: laliaEdgeInsets.listInset,
            NeuomorphicContainer(
          margin: laliaEdgeInsets.listInsetN,
          borderRadius: BorderRadius.circular(11),
          intensity: 0.1,
          color: Theme.of(context).scaffoldBackgroundColor,
          offset: Offset(2, 2),
          blur: 4,
          style: NeuomorphicStyle.Flat,
          child: GestureDetector(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: model.passwordList[index].color,
                child: Text(
                  model.passwordList[index].name.substring(0, 1),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              trailing: GestureDetector(
                child: Icon(
                  Icons.cloud_done,
                  color: model.passwordList[index].objectId != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400],
                ),
                onTap: () async {
                  PasswordBean bean = model.passwordList[index];
                  if (bean.objectId != null) {
                    await BmobUtil.delete(bean);
                    bean.objectId = null;
                  } else {
                    bean.author = Application.sp.getString("author");
                    bean.objectId = await BmobUtil.insert(bean);
                    Fluttertoast.showToast(msg: '数据已备份到云端');
                  }
                  model.updatePassword(bean, up: false);
                },
              ),
              title: Text(
                model.passwordList[index].name,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                model.passwordList[index].username,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                if (autofill) {
                  AutofillService().resultWithDataset(
                      label: model.passwordList[index].name,
                      username: model.passwordList[index].username,
                      password: model.passwordList[index].password);
                  print('sss');
                  return;
                }
                Navigator.push(
                        context,
                        ExtendRoute(
                            page: ViewPasswordPage(model.passwordList[index]),
                            tapPosition: RuntimeData.tapVerticalPosition))
                    .then((bean) {
                  if (bean != null) {
                    if (bean.isChanged) {
                      model.updatePassword(bean);
                    } else {
                      model.deletePassword(model.passwordList[index]);
                    }
                  }
                });
              },
              onLongPress: () {
                if (Config.longPressCopy) {
                  Clipboard.setData(ClipboardData(
                      text: EncryptUtil.decrypt(
                          model.passwordList[index].password)));
                  Fluttertoast.showToast(msg: "已复制密码");
                }
              },
            ),
            onPanDown: (details) => RuntimeData.updateTapPosition(details),
          ),
        );
      },
    );
  }
}

class MultiPasswordWidgetItem extends StatefulWidget {
  final int index;

  MultiPasswordWidgetItem(this.index);

  @override
  State<StatefulWidget> createState() {
    return _MultiPasswordWidgetItem(this.index);
  }
}

class _MultiPasswordWidgetItem extends State<StatefulWidget> {
  final int index;

  _MultiPasswordWidgetItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Consumer<PasswordList>(
      builder: (context, model, child) {
        return Container(
          margin: laliaEdgeInsets.listInset,
          child: CheckboxListTile(
            value: RuntimeData.multiPasswordList
                .contains(model.passwordList[index]),
            onChanged: (value) {
              setState(() {
                if (value) {
                  RuntimeData.multiPasswordList.add(model.passwordList[index]);
                } else {
                  RuntimeData.multiPasswordList
                      .remove(model.passwordList[index]);
                }
              });
            },
            secondary: CircleAvatar(
              backgroundColor: model.passwordList[index].color,
              child: Text(
                model.passwordList[index].name.substring(0, 1),
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              model.passwordList[index].name,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              model.passwordList[index].username,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
