import 'package:flutter/material.dart';

class ZoomableImage extends StatefulWidget {
  const ZoomableImage({Key? key}) : super(key: key);

  @override
  _ZoomableImageState createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: Stack(
        children: [
          Center(
            child: Transform(
              transform: Matrix4.identity()..scale(_scale),
              child: Image.network(
                'https://p5.ssl.qhimgs1.com/dr/400__/t03eb6e944c561e5b05.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      _scale += 0.1;
                    });
                  },
                  child: Text('放大')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      _scale -= 0.1;
                    });
                  },
                  child: Text('缩小')),
            ],
          )
        ],
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    print('ScaleStartDetails = $details');
    _previousScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    print('_handleScaleUpdate = $details');
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 3.0);
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    print('_handleScaleEnd = $details');
    _previousScale = 1.0;
  }
}
