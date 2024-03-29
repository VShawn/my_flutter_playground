import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:store/models/book.dart';
import 'package:store/pages/item_view.dart';
import 'package:store/services/book_list_helper.dart';
import 'package:store/widgets/infinite_page_view.dart';
import 'package:store/widgets/zoom_image.dart';

import 'models/dir_info.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  if (Platform.isWindows) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          brightness: Brightness.light,
          // 2.primarySwatch: primaryColor/accentColor的结合体
          primarySwatch: Colors.blue,
          // 3.主要颜色: 导航/底部TabBar
          primaryColor: Colors.green, // 4.次要颜色: FloatingActionButton/按钮颜色
          secondaryHeaderColor: Colors.red,
          // 5.卡片主题
          cardTheme: CardTheme(color: Colors.white, elevation: 10, shape: Border.all(width: 0, color: Colors.red), margin: EdgeInsets.all(10)),
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.yellow),
          // 6.按钮主题
          buttonTheme: ButtonThemeData(minWidth: 0, height: 25),
          // 7.文本主题
          fontFamily: 'Microsoft YaHei UI',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 14.0),
          ),
          splashColor: Colors.transparent,
          // 点击的水波纹设置为无色
          highlightColor: Colors.transparent),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      scrollBehavior: AppScrollBehavior(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ItemView> _itemViews = [];

  @override
  void initState() {
    super.initState();
    SetPath('D:\\t');
  }

  void SetPath(String path) async {
    var itemViews = await BookListHelper.getItemViewList(path);
    setState(() {
      _itemViews = itemViews;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.date_range),
            tooltip: "编辑",
            onPressed: () {
              print('Tap on edit');
              SetPath('D:\\t');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Wrap(
          children: _itemViews,
        ),
      ),
    );
  }
}
