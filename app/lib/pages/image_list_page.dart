import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:store/models/dir_info.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import '../constants.dart';
import '../widgets/image_item.dart';
import '../utils/file_helper.dart';
import '../widgets/dir_item.dart';

class ImageListPage extends StatefulWidget {
  final String title;
  final List<ImageItemBase> imageItemBases;
  final int index;

  ImageListPage({Key? key, required this.imageItemBases, this.index = 0, required this.title}) : super(key: key);

  @override
  State<ImageListPage> createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  final PageController _pageController = PageController();
  final Map<int, Uint8List?> _imageData = {};

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_loadImages);
  }

  @override
  void dispose() {
    _pageController.removeListener(_loadImages);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemExtent: 600,
        controller: _pageController,
        itemCount: widget.imageItemBases.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.imageItemBases[index];
          final color = index % 2 == 0 ? Colors.red : Colors.blue;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<Uint8List>(
              future: item.getImageBytesAsync(),
              builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.fitHeight,
                  );
                } else {
                  return SizedBox(
                    height: 256, // set the height to 48
                    width: 256, // set the width to 48
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _loadImages() {
    final int currentPage = _pageController.page?.round() ?? 0;
    final int previousPage = currentPage - 1;
    final int nextPage = currentPage + 1;
    const int preloadDistance = 2; // adjust this value as needed
    for (int i = 0; i < widget.imageItemBases.length; i++) {
      if (i < previousPage - preloadDistance || i > nextPage + preloadDistance) {
        _imageData.remove(i);
      }
    }
    final int firstVisibleIndex = currentPage - preloadDistance;
    final int lastVisibleIndex = currentPage + preloadDistance;
    for (int i = firstVisibleIndex; i <= lastVisibleIndex; i++) {
      if (i >= 0 && i < widget.imageItemBases.length && _imageData[i] == null) {
        widget.imageItemBases[i].getImageBytesAsync().then((value) {
          setState(() {
            _imageData[i] = value;
          });
        });
      }
    }
  }
}
