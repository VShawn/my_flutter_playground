import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
// import 'package:path/path.dart' as p;

// 一个dir类，有名称、路径、封面路径三个属性
class DirInfo {
  String name;
  String path;
  bool isZip = false;
  String? _coverPath;
  Uint8List? coverBytes;

  DirInfo(this.name, this.path, this._coverPath);
  DirInfo.coverBytes(this.name, this.path, this.coverBytes);
  DirInfo.zip(this.name, this.path) {
    isZip = true;
    // TODO add a default cover to return
    var file = File(path);
    if (!file.existsSync()) {
      coverBytes = Uint8List(0);
    } else {
      final inputStream = InputFileStream(path);
      final archive = ZipDecoder().decodeBuffer(inputStream);
      for (var file in archive.files) {
        // is jpg file
        final filename = file.name.toLowerCase();
        if (file.isFile &&
            [".jpg", ".png", ".bmp", ".webp"]
                .any((ext) => filename.endsWith(ext))) {
          coverBytes = file.content as Uint8List;
          break;
        }
      }
      inputStream.close();
    }
  }

  // // 从路径中获取封面路径
  // static String? getCoverPath(String path) {
  //   p.
  //   var dir = Directory(path);
  //   var files = dir.listSync();
  //   for (var file in files) {
  //     if (file is File) {
  //       var ext = p.extension(file.path);
  //       if (ext == '.jpg' || ext == '.png') {
  //         return file.path;
  //       }
  //     }
  //   }
  //   return null;
  // }

  Future<Uint8List> getCoverBytes() async {
    if (coverBytes != null) {
      return coverBytes!;
    }
    var file = File(_coverPath!);
    if (!file.existsSync()) {
      return Uint8List(0);
    }
    return file.readAsBytes();
  }

  Uint8List getCoverBytesSync() {
    if (coverBytes != null) {
      return coverBytes!;
    }
    if (_coverPath == null) return Uint8List(0);
    var file = File(_coverPath!);
    if (!file.existsSync()) {
      return Uint8List(0);
    }
    return file.readAsBytesSync();
  }
}
