import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive_io.dart';
import '../constants.dart';
import '../models/dir_info.dart';
import '../utils/file_helper.dart';
import '../widgets/image_item.dart';

class Viewer extends StatefulWidget {
  String password = '';
  Viewer({
    super.key,
    required DirInfo dirInfo,
    this.password = '',
  }) : _dirInfo = dirInfo {
    if (_dirInfo.isZip) {
      final inputStream = InputFileStream(_dirInfo.path);
      _archive = ZipDecoder().decodeBuffer(inputStream, password: password);
      if (_archive?.files.isNotEmpty == true) {
        _fileList = _archive!.files
            .where((e) => e.isFile && Constants.supportedImage.contains(path.extension(e.name).toLowerCase()))
            .map((e) => ImageItemInZip(e.name, e))
            .toList();
      }
    } else {
      final list = listFilesSync(_dirInfo.path, includingSubDir: true, extensions: Constants.supportedImage);
      _fileList = list.map((e) => ImageItemBase(e)).toList();
    }
    print('Viewer Opened with ${_fileList.length} files in ${_dirInfo.path}');
  }

  // final String _imagePath;
  // final String _title;
  final DirInfo _dirInfo;
  Archive? _archive;
  List<ImageItemBase> _fileList = [];

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget._dirInfo.name),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.date_range),
              tooltip: "编辑",
              onPressed: () {},
            ),
          ],
        ),
        body: Stack(
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: Image.memory(
                widget._fileList[currentIndex].getImageBytesSync(),
                fit: BoxFit.fitHeight,
              ),
            ),
            Align(
              //图片index显示
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black38,
                ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "${currentIndex + 1}/${widget._fileList.length}",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Microsoft YaHei'),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        ));
  }
}
