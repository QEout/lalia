import 'package:flutter/material.dart';
import 'package:neuomorphic_container/neuomorphic_container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:lalia/application.dart';
import 'package:lalia/ui/lalia_ui.dart';
import 'package:lalia/utils/screen_util.dart';
import 'package:lalia/pages/develop/debug_page.dart';

class AboutPage extends StatelessWidget {
  static final Text serviceContent = Text

  (

  '''

  
        1. lalia（下称“本产品”）是一款开源的私密数据管理工具，采用Apache 2.0协议，所以你可以在满足Apache 2.0协议的基础上对本产品进行再发布。
        2. 本产品不做任何担保。由于用户行为（Root等）导致用户信息泄露或丢失，本产品免责。
        3. 任何由于黑客攻击、计算机病毒侵入或发作、因政府管制而造成的暂时性关闭等影响网络正常经营的不可抗力而造成的个人资料泄露、丢失、被盗用或被窜改等，本产品均�