import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import '../models/book_info.dart';
import 'package:crypto/crypto.dart';

/// 一个工具函数，用于列出输入目录中的所有后缀名包括在输入参数 extensions 的文件（当可选参数 includingSubDir = true 时，包括子目录）
/// ```
/// void main() {
///   var dirPath = '/path/to/directory';
///   var fileList = listFiles(dirPath, extensions: ['.txt', '.pdf'], includingSubDir: true);
///   fileList.forEach((file) => print(file));
/// }
/// ```
List<String> listFilesSync(String directoryPath, {List<String>? extensions, bool includingSubDir = false}) {
  var fileList = <String>[];
  var dir = Directory(directoryPath);
  if (!dir.existsSync()) {
    print('Directory not found');
    return fileList;
  }

  for (var fileOrDir in dir.listSync(recursive: includingSubDir)) {
    if (fileOrDir is File && (extensions == null || extensions.any((ext) => fileOrDir.path.toLowerCase().endsWith(ext.toLowerCase())))) {
      fileList.add(fileOrDir.path);
    } else {
      // print('Not a file: ${fileOrDir.path}');
    }
  }
  return fileList;
}

Future<List<String>> listFilesAync(String directoryPath, {List<String>? extensions, bool includingSubDir = false}) async {
  var fileList = <String>[];
  var dir = Directory(directoryPath);
  if (!dir.existsSync()) {
    print('Directory not found');
    return fileList;
  }

  await for (var fileOrDir in dir.list(recursive: includingSubDir)) {
    if (fileOrDir is File && (extensions == null || extensions.any((ext) => fileOrDir.path.toLowerCase().endsWith(ext.toLowerCase())))) {
      fileList.add(fileOrDir.path);
    } else {
      // print('Not a file: ${fileOrDir.path}');
    }
  }
  return fileList;
}

// 一个函数，输入文件夹路径，列出其中的子文件夹

// 输入文件夹路径和支持的文件后缀，返回一个包含所有文件的列表
Future<List<BookInfo>> listBooks(String path, {List<String>? bookExts}) async {
  bookExts ??= [".zip", ".epub", ".cbz", ".mobi"];
  var dir = Directory(path);
  if (!dir.existsSync()) {
    return [];
  }
  var files = dir.listSync();
  var books = <BookInfo>[];
  for (var file in files) {
    if (file is File) {
      var ext = p.extension(file.path).toLowerCase();
      if (bookExts.contains(ext)) {
        var name = p.basenameWithoutExtension(file.path);
        // 文件的 hash
        books.add(BookInfo(name: name, zipPath: file.path, hash: 'hash', size: 0));
      }
    }
  }
  return books;
}

Future<Uint8List> getFileBytes(String path) async {
  var file = File(path);
  if (!file.existsSync()) {
    return Uint8List(0);
  }
  return file.readAsBytes();
}

Uint8List getFileBytesSync(String path) {
  var file = File(path);
  if (!file.existsSync()) {
    return Uint8List(0);
  }
  return file.readAsBytesSync();
}

class FileHelper {
  /// 计算文件的 md5
  static String getFileHash(String filePath) {
    var file = File(filePath);
    if (!file.existsSync()) {
      return '';
    }
    return md5.convert(file.readAsBytesSync()).toString();
  }

  /// 计算文件的 md5
  static Future<String> getFileHashAsync(String filePath) async {
    var file = File(filePath);
    if (!file.existsSync()) {
      return '';
    }
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  }

  /// 计算文件前 1k 数据的 md5
  static Future<String> getFirstKbMd5Async(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return '';
    }
    final length = await file.length();
    final bytes = await file.openRead(0, length < 1024 ? length : 1024).toList().then((chunks) {
      final bytes = <int>[];
      for (final chunk in chunks) {
        bytes.addAll(chunk);
      }
      return bytes;
    });
    return md5.convert(bytes).toString();
  }
}
