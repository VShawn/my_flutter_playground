import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:store/utils/file_helper.dart';
import 'package:uuid/uuid.dart';

class BookInfo {
  String id;
  String displayName;
  String basePath;
  String fileName;
  String hash;
  String coverBytes;

  /// 阅读进度：0-100的百分比
  double readProgress;

  /// 阅读进度进度索引（int，阅读txt时表示第几个字，阅读zip或cbz或epub时表示浏览到第几个文件，阅读pdf时表示浏览到第几页）
  int readIndex;

  /// 阅读进度时间戳
  int readTime;

  /// 进度对应的文件路径
  String readFilePath;

  String get fileFullName => join(basePath, fileName);

  BookInfo({
    required this.id,
    this.displayName = '',
    required this.basePath,
    required this.fileName,
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
      basePath: map['basePath'],
      fileName: map['fileName'],
      hash: map['hash'],
      coverBytes: map['coverBytes'] ?? '',
      readProgress: map['readProgress'] ?? 0,
      readIndex: map['readIndex'] ?? 0,
      readTime: map['readTime'] ?? 0,
      readFilePath: map['readFilePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'id': id,
      'displayName': displayName,
      'basePath': basePath,
      'fileName': fileName,
      'hash': hash,
      'coverBytes': coverBytes,
      'readProgress': readProgress,
      'readIndex': readIndex,
      'readTime': readTime,
      'readFilePath': readFilePath,
    };
    return map;
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  /// 返回文件夹中的所有书籍，不包括子文件夹，任何错误发生时返回空列表
  static Future<List<BookInfo>> getBookFromDirAsync(String dirPath) async {
    final List<BookInfo> bookList = [];
    final dir = Directory(dirPath);
    final List<FileSystemEntity> files = dir.listSync();
    if (!dir.existsSync()) return bookList;
    for (final file in files) {
      if (file is File) {
        final ext = extension(file.path).toLowerCase();
        // 判断后缀名是否是 .zip 或 .rar
        if (ext != '.zip' && ext != '.rar') continue;
        final hash = await FileHelper.getFirstKbMd5Async(file.path);
        final bookInfo = BookInfo(
          id: '',
          basePath: dirname(file.path),
          fileName: basename(file.path),
          displayName: basenameWithoutExtension(file.path),
          hash: hash,
        );
        bookList.add(bookInfo);
      }
      // else if (file is Directory) {
      //   final basePath = file.basePath;
      //   final hash = await FileHelper.getFirstKbMd5Async(basePath);
      //   final bookInfo = BookInfo(
      //     id: '',
      //     basePath: basePath,
      //     displayName: basename(basePath),
      //     hash: hash,
      //   );
      //   bookList.add(bookInfo);
      // }
    }
    return bookList;
  }

  Uint8List getCoverBytes() {
    if (coverBytes.isEmpty) {
      return Uint8List(0);
    }
    // base64 to bytes
    return base64.decode(coverBytes);
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
    final basePath = join(databasePath, 'book_info.db');
    return openDatabase(
      basePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE book_info(
          id TEXT PRIMARY KEY,
          displayName TEXT,
          basePath TEXT,
          fileName TEXT,
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

  static Future<List<BookInfo>> getAllBookInfos(String basePath) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'book_info',
      where: 'basePath = ?',
      whereArgs: [basePath],
    );
    return List.generate(maps.length, (i) {
      return BookInfo(
        id: maps[i]['id'],
        displayName: maps[i]['displayName'] ?? '',
        basePath: maps[i]['basePath'],
        fileName: maps[i]['fileName'],
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
    bookInfo.id = const Uuid().v4();
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
