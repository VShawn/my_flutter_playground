import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:store/widgets/dir_item.dart';
import 'package:store/widgets/infinite_page_view.dart';
import 'package:store/widgets/zoom_image.dart';

import 'models/dir_info.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = initDatabase();
  runApp(MyApp(database: database));
}

Future<Database> initDatabase() async {
  if (Platform.isWindows) {
    databaseFactory = databaseFactoryFfi;
  }
  final database = openDatabase(
    join(await getDatabasesPath(), 'my_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE my_table(id INTEGER PRIMARY KEY, name TEXT, value INTEGER)',
      );
    },
    version: 1,
  );
  return database;
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
  const MyApp({super.key, required this.database});

  final Future<Database> database;

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
          primaryColor: Colors.green,
          // 4.次要颜色: FloatingActionButton/按钮颜色
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
      home: FutureBuilder<Database>(
        future: database,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MyHomePage(title: 'Flutter Demo Home Page');
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
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
  List<DirItem> _dirItems = [];

  @override
  void initState() {
    super.initState();
    _loadDirItems();
    print('initState: _dirItems.count = ${_dirItems.length}');
  }

  Future<void> _loadDirItems() async {
    final directory = Directory('D:\\t');
    final List<FileSystemEntity> entities = directory.listSync();
    for (final entity in entities) {
      if (entity is Directory) {
        _dirItems.add(DirItem(dirInfo: DirInfo.folder(entity.path)));
      } else if (entity is File && entity.path.endsWith('.zip')) {
        _dirItems.add(DirItem(dirInfo: DirInfo.zip(entity.path, entity.path)));
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.date_range),
            tooltip: "编辑",
            onPressed: () {},
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Wrap(
          children: _dirItems,
        ),
      ),

      // body: Padding(
      //   padding: const EdgeInsets.all(18.0),
      //   child: PageView(
      //     scrollDirection: Axis.vertical, // 滑动方向为垂直方向
      //     children: [
      //       Center(child: Text("1", textScaleFactor: 5)),
      //       Center(child: Text("2", textScaleFactor: 5)),
      //       Center(child: Text("3", textScaleFactor: 5)),
      //       Center(child: Text("4", textScaleFactor: 5)),
      //     ],
      //   ),
      // ),
      // body: InfinitePageView(),
      // body: ZoomableImage(),
    );
  }
}
