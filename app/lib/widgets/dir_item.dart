import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:store/pages/viewer.dart';

import '../models/dir_info.dart';

class DirItem extends StatefulWidget {
  const DirItem({
    Key? key,
    required this.dirInfo,
  }) : super(key: key);
  final DirInfo dirInfo;

  @override
  State<DirItem> createState() => _DirItemState();
}

class _DirItemState extends State<DirItem> {
  Uint8List? corverBytes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDirItems();
  }

  Future<void> _loadDirItems() async {
    corverBytes = await widget.dirInfo.getCoverBytes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO 点击事件
        print('点击了文件夹' + widget.dirInfo.name);
        //导航到新路由
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Viewer(dirInfo: widget.dirInfo, password: widget.dirInfo.psw);
        }));

        // showDialog(
        //     context: context,
        //     builder: (context) {
        //       return AlertDialog(
        //         title: Text('提示'),
        //         content: Text('点击了图片' + _imagePath),
        //         actions: <Widget>[
        //           TextButton(
        //             onPressed: () {
        //               Navigator.of(context).pop();
        //             },
        //             child: Text('确定'),
        //           ),
        //         ],
        //       );
        //     });
      },
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.memory(
                widget.dirInfo.getCoverBytesSync(),
                fit: BoxFit.fitHeight,
              ),
              // Image.file(
              //   File(_dirInfo.coverPath),
              //   fit: BoxFit.fitHeight,
              // ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      widget.dirInfo.name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Microsoft YaHei'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
