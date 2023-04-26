import 'dart:io';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import '../models/dir_info.dart';
import '../utils/file_helper.dart';

class Viewer extends StatefulWidget {
  Viewer({
    super.key,
    required DirInfo dirInfo,
  }) : _dirInfo = dirInfo {
    _fileList = listFilesSync(_dirInfo.path,
        includingSubDir: true, extensions: [".jpg", ".png", ".bmp"]);
    print('Viewer Opened with ${_fileList.length} files in ${_dirInfo.path}');
  }

  // final String _imagePath;
  // final String _title;
  final DirInfo _dirInfo;
  List<String> _fileList = [];

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
            ExtendedImageGesturePageView.builder(
              controller: ExtendedPageController(
                initialPage: 0,
                pageSpacing: 0,
              ),
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              scrollDirection: Axis.horizontal,
              itemCount: widget._fileList.length,
              preloadPagesCount: 2,
              itemBuilder: (BuildContext context, int index) {
                var item = widget._fileList[index];
                Widget image = ExtendedImage.file(
                  File(item),
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.gesture,
                  initGestureConfigHandler: (state) {
                    return GestureConfig(
                      minScale: 0.3,
                      animationMinScale: 0.3,
                      maxScale: 3.0,
                      animationMaxScale: 3.5,
                      speed: 1.0,
                      inertialSpeed: 100.0,
                      initialScale: 1.1,
                      inPageView: true,
                      initialAlignment: InitialAlignment.center,
                      cacheGesture: false,
                    );
                  },
                );
                if (index == currentIndex) {
                  return Hero(
                    tag: item + index.toString(),
                    child: image,
                  );
                } else {
                  return image;
                }
              },
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
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Microsoft YaHei'),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
