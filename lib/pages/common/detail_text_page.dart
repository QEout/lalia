import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lalia/model/password_bean.dart';
import 'package:lalia/provider/theme_provider.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/encrypt_util.dart';
import 'package:lalia/utils/screen_util.dart';
import 'package:lalia/widgets/common/none_border_circular_textfield.dart';
import 'package:lalia/widgets/gadge.dart';
import 'package:provider/provider.dart';

class RobotWidget extends StatefulWidget {
  const RobotWidget({
    Key key,
  }) : super(key: key);

  @override
  _RobotWidgetState createState() => _RobotWidgetState();
}

class _RobotWidgetState extends State<RobotWidget> {
  String _toggle = "reposo";
  TextEditingController _nameController;
  TextEditingController _usernameController;
  TextEditingController _passwordController;
  bool _passwordVisible = false;
  Color _mainColor;

  @override
  void dispose() {
    _nameController?.dispose();
    _usernameController?.dispose();
    _passwordController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _nameController = TextEditingController();
    _usernameController = TextEditingController();

    _passwordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainColor = Provider
          .of<ThemeProvider>(context)
          .currTheme
          .primaryColor;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
    Padding(
    padding: EdgeInsets.only(top: laliaScreenUtil.setHeight(100)),
    ),
    Container(
    height: 100,
    child: GestureDetector(
    onTap: () {
    setState(() {
    _toggle = "buscando";
    });
    },
    onLongPress: () {
    setState(() {
    _toggle = "Cargando";
    });
    },
    onLongPressUp: () {
    setState(() {
    _toggle = "reposo";
    });
    },
    child: FlareActor(
    "assets/flrs/robot.flr",
    animation: _toggle,
    fit: BoxFit.contain,
    callback: (animation) {
    setState(() {
    _toggle = "reposo";
    });
    },
    ))),

    Padding(
    padding: laliaEdgeInsets.smallTBPadding,
    ),

//        Divider(height: 5,),
    Container(
    margin: EdgeInsets.only(left: 16, right: 16),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(17),

    ///圆角
    border: Border.all(color: Colors.grey, width: 1)
