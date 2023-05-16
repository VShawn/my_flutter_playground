import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:sqflite/sqflite.dart';

import '../constants.dart';

class BookInfo {
  String name;
  String zipPath;
  String hash;
  String? currentImagePath;
  int currentImageIndex = 0;
  int totalImageCount = 0;
  String? author;
  double? rating;
  String? description;
  Uint8List? coverBytes;
  int size = 0; // in bytes, 最大值为 2^63 - 1

  BookInfo({
    required this.name,
    required this.zipPath,
    required this.hash,
    required this.size,
  });

  BookInfo.fromZipPath(String zipPath, {String psw = ""})
      : name = p.basenameWithoutExtension(zipPath),
        zipPath = zipPath,
        hash = File(zipPath)
            .statSync()
            .modified
            .millisecondsSinceEpoch
            .toRadixString(16) {
    size = File(zipPath).lengthSync();
    final inputStream = InputFileStream(zipPath);
    final archive = ZipDecoder().decodeBuffer(inputStream, password: psw);
    for (var file in archive.files) {
      // is jpg file
      final filename = file.name.toLowerCase();
      if (file.isFile &&
          Constants.supportedImage.any((ext) => filename.endsWith(ext))) {
        coverBytes = file.content as Uint8List;
        break;
      }
    }
    inputStream.close();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'zipPath': zipPath,
      'hash': hash,
      'currentImagePath': currentImagePath,
      'currentImageIndex': currentImageIndex,
      'totalImageCount': totalImageCount,
      'author': author,
      'rating': rating,
      'description': description,
      'coverBytes': coverBytes,
      'size': size,
    };
  }

  Future<void> saveToDatabase(Database db) async {
    await db.insert(
      'books',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
