import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:store/pages/viewer.dart';
import 'package:store/pages/image_list_page.dart';
import 'package:archive/archive_io.dart';

import 'package:path/path.dart' as p;
import '../constants.dart';
import '../models/dir_info.dart';
import 'ViewImageRight2Left.dart';
import '../widgets/image_item.dart';
import '../utils/file_helper.dart';
import '../models/dao/book_info.dart';

class ItemView extends StatefulWidget {
  ItemView.bookInfo({
    Key? key,
    required BookInfo bookInfo_,
  }) : super(key: key) {
    title = bookInfo_.displayName;
    bookInfo = bookInfo_;
  }

  ItemView.dir({
    Key? key,
    required Directory directory_,
  }) : super(key: key) {
    // log("build dir ${directory_.path}");
    directory = directory_;
    title = p.basename(directory_.path);
  }

  BookInfo? bookInfo;
  Directory? directory;

  String title = "";

  Future<Uint8List> getCoverBytes() async {
    if (bookInfo != null) {
      var bytes = bookInfo!.getCoverBytes();
      if (bytes.isEmpty) {
        // 如果封面图片为空，则开始异步读取封面图片
        final ext = p.extension(bookInfo!.fileName).toLowerCase();
        if (ext == ".zip") {
          final inputStream = InputFileStream(bookInfo!.fileFullName);
          final archive = ZipDecoder().decodeBuffer(inputStream); // TODO password: psw
          for (var file in archive.files) {
            final filename = file.name.toLowerCase();
            if (file.isFile && Constants.supportedImage.any((ext) => filename.endsWith(ext))) {
              bytes = file.content as Uint8List;
              log("读取封面图片${file.name}");
              bookInfo!.coverBytes = base64.encode(bytes);
              BookInfoDatabase.updateBookInfo(bookInfo!);
              break;
            }
          }
          // TODO 其他格式的封面构建
        }
      }
      return bytes;
    } else if (directory != null) {
      // TODO
      var bytes = File("D:\\220.jpg").readAsBytes();
      return bytes;
    }
    return Uint8List(0);
  }

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  Uint8List? corverBytes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItemViews();
  }

  Future<void> _loadItemViews() async {
    var bytes = await widget.getCoverBytes();
    setState(() {
      corverBytes = bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO 点击事件
        print('Tap ItemView: ' + widget.title);
        log('Tap ItemView: ' + widget.title);
        // 弹窗
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('提示'),
              content: Text('是否打开${widget.title}'),
              actions: <Widget>[
                TextButton(
                  child: Text('取消'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('确定'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ).then((value) {
          if (value == true) {}
        });

        //导航到新路由
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   List<ImageItemBase> fileList = [];
        //   if (widget.bookInfo.isZip) {
        //     final inputStream = InputFileStream(widget.bookInfo.path);
        //     var archive = ZipDecoder().decodeBuffer(inputStream, password: widget.bookInfo.psw);
        //     if (archive.files.isNotEmpty == true) {
        //       fileList = archive.files
        //           .where((e) => e.isFile && Constants.supportedImage.contains(p.extension(e.name).toLowerCase()))
        //           .map((e) => ImageItemInZip(e.name, e))
        //           .toList();
        //     }
        //   } else {
        //     final list = listFilesSync(widget.bookInfo.path, includingSubDir: true, extensions: Constants.supportedImage);
        //     fileList = list.map((e) => ImageItemBase(e)).toList();
        //   }
        //   print('Viewer Opened with ${fileList.length} files in ${widget.bookInfo.path}');
        //   return ViewImageRight2Left(
        //     imageItemBases: fileList,
        //     index: 0,
        //     title: widget.bookInfo.displayName,
        //   );
        //   return ImageListPage(
        //     imageItemBases: fileList,
        //     index: 0,
        //     title: widget.bookInfo.displayName,
        //   );
        // }));
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
                corverBytes ?? Uint8List(0),
                errorBuilder: (context, error, stackTrace) {
                  if (corverBytes == null) {
                    return Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Icon(
                      Icons.error,
                      size: 50,
                      color: Color.fromARGB(64, 244, 67, 54),
                    ),
                  );
                },
              ),
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
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Microsoft YaHei'),
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
