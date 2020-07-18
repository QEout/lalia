import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lalia/provider/theme_provider.dart';
import 'package:lalia/ui/lalia_ui.dart';
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
  Widget build

  (

  BuildContext