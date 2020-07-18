import 'package:flutter/material.dart';
import 'package:lalia/application.dart';
import 'package:lalia/params/config.dart';
import 'package:lalia/ui/theme_resource.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData currTheme;

  init() {
    currTheme = getTheme(Config.theme);
  }

  void changeTheme(String themeName) {
    if (themeName == Config.theme) return;
    currTheme = getTheme(themeName);
    Config.theme = themeName;
    Application.sp.setString("theme", themeName);
    notifyListeners();
  }

  ThemeData getTheme(String themeName) {
    switch (themeName) {
      case "gold":
        return laliaTheme.goldTheme();
      case "blue":
        return laliaTheme.blueTheme();

      case "red":
        return laliaTheme.redTheme();
      case "teal":
        return laliaTheme.tealTheme();
      case "deepPurple":
        return laliaTheme.deepPurpleTheme();
      case "orange":
        return laliaTheme.orangeTheme();
      case "pink":
        return laliaTheme.pinkTheme();
      case "blueGrey":
        return laliaTheme.blueGreyTheme();
      case "dark":
        return laliaTheme.darkTheme();
      default:
        return laliaTheme.blueTheme();
    }
  }
}
