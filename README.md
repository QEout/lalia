# LALIA

## 介绍

密语（lalia）是一款密码数据管理工具，功能包括密码管理及自动填充、浏览新闻及社区互动、个人信息管理。采用Flutter构建，是国产密码管理工具中唯一一个开源且支持自动填充的密码管理工具。

- 密码与卡片信息管理
- 支持指纹解锁软件
- AES256位加密
- 支持从csv文件中导入或导出为csv文件
- 支持从Chrome中导入密码
- 支持从剪贴板中导入密码
- 标签功能
- 文件夹功能
- 收藏功能
- 备注功能
- 密码生成器
- 多选编辑功能
- Bmob同步功能

# 注意

**若要构建Lalia，请修改**`lib/utils/encrypt_util.dart`**中的**`_key`**（32位字符串）**；

# 软件截图

| ![卡片页](http://lalia.aiyi.pro/2.jpg) | ![登录页](http://lalia.aiyi.pro/1.jpg) | ![新建密码页](http://lalia.aiyi.pro/3.jpg) |
| :----------------------------------------------------------: | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![密码页](http://lalia.aiyi.pro/4.jpg) | ![社区页](http://lalia.aiyi.pro/5.jpg) 

# 下载体验

你可以在酷安搜索“密语”进行下载，扫描下面的二维码或者[点此下载](https://www.aengus.top/assets/app/Allpass_V1.2.0_signed.apk)

![AllpassV1.2.0](https://www.aengus.top/assets/app/allpass_v1.2.0.png)

# 未来规划

- 自动获取网站favicon作为密码头像
- 智能识别网址生成名称

## 文件结构

- dao/ 与数据库交互层
- model/ 密码或卡片实体类
- pages/ 页面
- params/ 软件相关参数
- provider/ 状态管理
- route/ 路由管理
- services/ 服务管理，包括生物识别授权及路由服务
- utils/ 工具
- ui/ 界面相关
- widgets/ 自定义组件

## 命名规范

### Dart文件
1. dart文件采用下划线命名方式；
2. 类采取大驼峰命名法，变量、常量、函数名采用小驼峰命名法；
3. 导包as后的名称使用小写+下划线；
4. 导包顺序为：
    Dart SDK; flutter内的库; 第三方库; 自己的库; 相对路径引用;

### 数据库相关
1. 数据库表名使用下划线命名方式，且表名开头的第一个单词为`allpass`；
2. 表的列名与model相同，采用小写驼峰命名方式；


# Flutter环境
```
[√] Flutter (Channel stable, v1.17.4, on Microsoft Windows [Version 10.0.18363.900], locale zh-CN)

[√] Android toolchain - develop for Android devices (Android SDK version 29.0.2)
[√] Android Studio (version 4.0)
```

# LICENSE
[![License](https://img.shields.io/badge/license-Apache%202-green.svg)](https://www.apache.org/licenses/LICENSE-2.0)
