import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:store/pages/viewer.dart';

import '../models/dir_info.dart';

class DirItem extends StatelessWidget {
  const DirItem({
    super.key,
    required DirInfo dirInfo,
  }) : _dirInfo = dirInfo;

  // final String _imagePath;
  // final String _title;
  final DirInfo _dirInfo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO 点击事件
        print('点击了文件夹' + _dirInfo.name);
        //导航到新路由
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Viewer(dirInfo: _dirInfo);
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
                _dirInfo.getCoverBytesSync(),
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
                      _dirInfo.name,
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
