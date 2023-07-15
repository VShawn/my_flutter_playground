import 'dart:typed_data';
import 'dart:io';

import 'package:store/pages/item_view.dart';
import 'package:archive/archive_io.dart';

class ImageItemBase {
  ImageItemBase(this.key);
  String key;
  Future<Uint8List> getImageBytesAsync() async {
    var file = File(key);
    if (file.existsSync()) {
      return file.readAsBytes();
    }
    return Uint8List(0);
  }

  Uint8List getImageBytesSync() {
    var file = File(key);
    if (file.existsSync()) {
      return file.readAsBytesSync();
    }
    return Uint8List(0);
  }
}

class ImageItemInZip extends ImageItemBase {
  ArchiveFile file;

  ImageItemInZip(super.key, this.file) {}

  @override
  Future<Uint8List> getImageBytesAsync() async {
    return file.content as Uint8List;
  }

  @override
  Uint8List getImageBytesSync() {
    return file.content as Uint8List;
  }
}
