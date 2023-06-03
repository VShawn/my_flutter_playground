import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/image_item.dart';

class ViewImageRight2Left extends StatefulWidget {
  final String title;
  final List<ImageItemBase> imageItemBases;
  final int index;

  const ViewImageRight2Left({Key? key, required this.imageItemBases, this.index = 0, required this.title}) : super(key: key);

  @override
  _ViewImageRight2LeftState createState() => _ViewImageRight2LeftState();
}

class _ViewImageRight2LeftState extends State<ViewImageRight2Left> {
  late PageController _pageController;

  final Map<int, Uint8List?> _imageData = {};
  double _scaleFactor = 1.0;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _pageController.addListener(_loadImages);
    currentPage = 0;
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
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageItemBases.length,
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              if (index < 0) index = 0;
              // if (index > widget.imageItemBases.length - 1) index = widget.imageItemBases.length - 1;
              // print('index = $index');
              final color = index % 2 == 0 ? Colors.red : Colors.blue;

              return _buildImage(index);
              if (index % 2 == 0) {
                return Image.network(
                  "https://p5.ssl.qhimgs1.com/dr/400__/t03eb6e944c561e5b05.jpg",
                  width: 100.0,
                  scale: 1,
                  fit: BoxFit.fitHeight,
                );
              }
              return Container(
                  color: Colors.red, child: Center(child: Text("text $index, default Index: $index", style: TextStyle(fontSize: 36.0, color: Colors.white))));
            },
          ),
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black45,
                      offset: Offset(0.0, 0.0), //阴影xy轴偏移量
                      blurRadius: 1.0, //阴影模糊程度
                      spreadRadius: 2.0 //阴影扩散程度
                      )
                ],
                borderRadius: BorderRadius.circular(5.0),
              ),
              width: 200,
              height: 20,
              alignment: Alignment.center,
              child: Text(
                '${currentPage + 1}/${widget.imageItemBases.length}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(int index) {
    if (index < 0 || index >= widget.imageItemBases.length) {
      return SizedBox.shrink();
    }

    if (_imageData[index] != null) {
      print('read form cache $index');
      return Image.memory(
        _imageData[index]!,
        width: MediaQuery.of(context).size.width / _scaleFactor,
        fit: BoxFit.contain,
      );
    }

    final item = widget.imageItemBases[index];
    return FutureBuilder<Uint8List>(
      future: item.getImageBytesAsync(),
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        if (snapshot.hasData) {
          _imageData[index] = snapshot.data;
          return Image.memory(
            snapshot.data!,
            width: MediaQuery.of(context).size.width / _scaleFactor,
            fit: BoxFit.contain,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
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
            print('cached image $i');
          });
        });
      }
    }
  }

  // void _loadImages() {
  //   final int currentPage = _pageController.page?.round() ?? 0;
  //   final int previousPage = currentPage - 1;
  //   final int nextPage = currentPage + 1;
  //   if (previousPage >= 0 && _imageData[previousPage] == null) {
  //     _loadImage(widget.imageItemBases[previousPage].imageUrl).then((value) {
  //       setState(() {
  //         _imageData[previousPage] = value;
  //       });
  //     });
  //   }
  //   if (nextPage < widget.imageItemBases.length && _imageData[nextPage] == null) {
  //     _loadImage(widget.imageItemBases[nextPage].imageUrl).then((value) {
  //       setState(() {
  //         _imageData[nextPage] = value;
  //       });
  //     });
  //   }
  // }
}
