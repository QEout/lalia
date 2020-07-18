import 'package:flutter/material.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';

class SearchButtonWidget extends StatelessWidget {
  final String searchType;
  final void Function() press;

  SearchButtonWidget(this.press, this.searchType);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: laliaEdgeInsets.forSearchButtonInset,
        child: NeuomorphicContainer(
          padding: EdgeInsets.all(10),
//      borderRadius: BorderRadius.circular(5),
          intensity: 0.1,
          color: Theme.of(context).scaffoldBackgroundColor,
          offset: Offset(9, 9),
          blur: 3,
          style: NeuomorphicStyle.Pressed,
          child: InkWell(
            onTap: press,
            child: Row(
              children: <Widget>[
                Icon(Icons.search),
                Text("搜索$searchType"),
              ],
            ),
          ),
        ));
  }
}
