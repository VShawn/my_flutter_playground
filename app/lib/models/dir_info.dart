import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import '../constants.dart';

class DirInfo {
  String name;
  String path;
  String psw = "";
  bool isZip = false;
  Uint8List? coverBytes;

  DirInfo(this.name, this.path, this.coverBytes);
  DirInfo.zip(this.name, this.path, {this.psw = ""}) {
    isZip = true;
    var file = File(path);
    if (!file.existsSync()) {
      coverBytes = Uint8List(0);
    } else {
      final inputStream = InputFileStream(path);
      final archive = ZipDecoder().decodeBuffer(inputStream, password: psw);
      for (var file in archive.files) {
        final filename = file.name.toLowerCase();
        if (file.isFile &&
            Constants.supportedImage.any((ext) => filename.endsWith(ext))) {
          coverBytes = file.content as Uint8List;
          break;
        }
      }
      inputStream.close();
    }
  }

  DirInfo.folder(this.path) : name = p.basename(path) {
    var dir = Directory(path);
    name = dir.path.split(Platform.pathSeparator).last;
    var files = dir.listSync();
    for (var file in files) {
      if (file is File) {
        final filename = file.path.toLowerCase();
        if (Constants.supportedImage.any((ext) => filename.endsWith(ext))) {
          coverBytes = file.readAsBytesSync();
          break;
        }
      }
    }
  }

  Future<Uint8List> getCoverBytes() async {
    if (coverBytes != null) {
      return coverBytes!;
    }
    return Uint8List(0);
    return File("D:\\t\\2.jpg").readAsBytes();
  }

  Uint8List getCoverBytesSync() {
    if (coverBytes != null) {
      return coverBytes!;
    }
    return Uint8List(0);
    // 默认显示 `D:/t/2.jpg`
    return File("D:\\t\\2.jpg").readAsBytesSync();
  }
}
