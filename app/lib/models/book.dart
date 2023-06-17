import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BookInfo {
  String id;
  String displayName;
  String path;
  String hash;
  String coverBytes;
  double readProgress;
  int readIndex;
  int readTime;
  String readFilePath;

  BookInfo({
    required this.id,
    this.displayName = '',
    required this.path,
    required this.hash,
    this.coverBytes = '',
    this.readProgress = 0,
    this.readIndex = 0,
    this.readTime = 0,
    this.readFilePath = '',
  });

  factory BookInfo.fromJson(String jsonString) {
    final Map<String, dynamic> map = json.decode(jsonString);
    return BookInfo(
      id: map['id'],
      displayName: map['displayName'] ?? '',
      path: map['path'],
      hash: map['hash'],
      coverBytes: map['coverBytes'] ?? '',
      readProgress: map['readProgress'] ?? 0,
      readIndex: map['readIndex'] ?? 0,
      readTime: map['readTime'] ?? 0,
      readFilePath: map['readFilePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'path': path,
      'hash': hash,
      'coverBytes': coverBytes,
      'readProgress': readProgress,
      'readIndex': readIndex,
      'readTime': readTime,
      'readFilePath': readFilePath,
    };
  }

  String toJsonString() {
    final Map<String, dynamic> map = toJson();
    return json.encode(map);
  }

  // 返回 readTime 的时间格式
  String getReadTime() {
    final date = DateTime.fromMillisecondsSinceEpoch(readTime);
    return '${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}:${date.second}';
  }
}

class BookInfoDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'book_info.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE book_info(
          id TEXT PRIMARY KEY,
          displayName TEXT,
          path TEXT UNIQUE,
          hash TEXT,
          coverBytes TEXT,
          readProgress REAL,
          readIndex INTEGER,
          readTime INTEGER,
          readFilePath TEXT
        )
        ''');
      },
    );
  }

  static Future<List<BookInfo>> getAllBookInfos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('book_info');
    return List.generate(maps.length, (i) {
      return BookInfo(
        id: maps[i]['id'],
        displayName: maps[i]['displayName'] ?? '',
        path: maps[i]['path'],
        hash: maps[i]['hash'],
        coverBytes: maps[i]['coverBytes'] ?? '',
        readProgress: maps[i]['readProgress'] ?? 0,
        readIndex: maps[i]['readIndex'] ?? 0,
        readTime: maps[i]['readTime'] ?? 0,
        readFilePath: maps[i]['readFilePath'] ?? '',
      );
    });
  }

  static Future<void> insertBookInfo(BookInfo bookInfo) async {
    final db = await database;
    await db.insert(
      'book_info',
      bookInfo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteBookInfo(String id) async {
    final db = await database;
    await db.delete(
      'book_info',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateBookInfo(BookInfo bookInfo) async {
    final db = await database;
    await db.update(
      'book_info',
      bookInfo.toJson(),
      where: 'id = ?',
      whereArgs: [bookInfo.id],
    );
  }
}
