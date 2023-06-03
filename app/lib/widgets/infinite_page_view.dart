import 'package:flutter/material.dart';

class InfinitePageView extends StatefulWidget {
  const InfinitePageView({Key? key}) : super(key: key);

  @override
  _InfinitePageViewState createState() => _InfinitePageViewState();
}

class _InfinitePageViewState extends State<InfinitePageView> {
  final _pageController = PageController();
  static const List<Color> _colors = [Colors.blue, Colors.green, Colors.red];
  int currentPage = 0;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemBuilder: (BuildContext context, int index) {
              // Calculate the real subscript.
              var renderIndex = index;
              print('index = $index');
              currentPage = index;
              renderIndex = renderIndex % _colors.length;
              if (renderIndex < 0) {
                renderIndex += _colors.length;
              }
              if (index % _colors.length == 0) {
                return Image.network(
                  "https://p5.ssl.qhimgs1.com/dr/400__/t03eb6e944c561e5b05.jpg",
                  width: 100.0,
                  scale: 1,
                  fit: BoxFit.fitHeight,
                );
              }
              return Container(
                  color: _colors[index % _colors.length],
                  child: Center(child: Text("text $renderIndex, default Index: $index", style: TextStyle(fontSize: 36.0, color: Colors.white))));
            },
          ),
          Positioned(
            // 放到最下面
            bottom: 0,
            // 半透明背景
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                // 两个按钮左右排布
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        print('currentPage = $currentPage');
                        //pageController.jumpToPage(currentPage + 1);
                        // pageController.nextPage(duration: Duration(milliseconds: 200), curve: Curves.linear);
                        _pageController.animateToPage(currentPage - 1, duration: Duration(milliseconds: 200), curve: Curves.linear);
                      },
                      child: Text('lastpage')),
                  ElevatedButton(
                      onPressed: () {
                        print('currentPage = $currentPage');
                        //pageController.jumpToPage(currentPage + 1);
                        // pageController.nextPage(duration: Duration(milliseconds: 200), curve: Curves.linear);
                        _pageController.animateToPage(currentPage + 1, duration: Duration(milliseconds: 200), curve: Curves.linear);
                      },
                      child: Text('nextPage')),
                ],
              ),
            ),
          ),
        ],
      );
}
