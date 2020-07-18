import 'package:flutter/material.dart';
import 'package:lalia/params/config.dart';
import 'package:lalia/ui/lalia_ui.dart';

class NoneBorderCircularTextField extends StatelessWidget {
  final TextEditingController _controller;
  final String _hintText;
  final Widget _prefixIcon;
  final bool _obscureText;
  final VoidCallback _onEditingComplete;

  NoneBorderCircularTextField(this._controller, this._hintText,
      this._prefixIcon, this._obscureText, this._onEditingComplete);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: laliaEdgeInsets.smallTBPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Config.theme == 'dark' ? Colors.black : Colors.grey[800],
      ),
      child: TextField(
        decoration: InputDecoration(
            prefixIcon: _prefixIcon != null
                ? Container(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    margin: const EdgeInsets.only(right: 8.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            bottomLeft: Radius.circular(30.0),
                            topRight: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0))),
                    child: _prefixIcon)
                : null,
            hintText: _hintText,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(laliaUI.bigBorderRadius),
            ),
            filled: true,
            fillColor: Colors.grey[300],
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0)),
        textAlign: TextAlign.center,
        controller: _controller,
        obscureText: _obscureText,
        onEditingComplete: _onEditingComplete,
      ),
    );
  }
}
