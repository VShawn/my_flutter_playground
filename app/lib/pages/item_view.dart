import 'dart:typed_data';
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

class ItemView extends StatefulWidget {
  const ItemView({
    Key? key,
    required this.dirInfo,
  }) : super(key: key);
  final DirInfo dirInfo;

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
    corverBytes = await widget.dirInfo.getCoverBytes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO 点击事件
        print('点击了ItemView: ' + widget.dirInfo.name);
        //导航到新路由
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          List<ImageItemBase> fileList = [];
          if (widget.dirInfo.isZip) {
            final inputStream = InputFileStream(widget.dirInfo.path);
            var archive = ZipDecoder().decodeBuffer(inputStream, password: widget.dirInfo.psw);
            if (archive.files.isNotEmpty == true) {
              fileList = archive.files
                  .where((e) => e.isFile && Constants.supportedImage.contains(p.extension(e.name).toLowerCase()))
                  .map((e) => ImageItemInZip(e.name, e))
                  .toList();
            }
          } else {
            final list = listFilesSync(widget.dirInfo.path, includingSubDir: true, extensions: Constants.supportedImage);
            fileList = list.map((e) => ImageItemBase(e)).toList();
          }
          print('Viewer Opened with ${fileList.length} files in ${widget.dirInfo.path}');

          return ViewImageRight2Left(
            imageItemBases: fileList,
            index: 0,
            title: widget.dirInfo.name,
          );
          return ImageListPage(
            imageItemBases: fileList,
            index: 0,
            title: widget.dirInfo.name,
          );
        }));
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
                errorBuilder: (context, error, stackTrace) {
                  print(error);
                  return Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
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
                      widget.dirInfo.name,
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

  Future<ImageProvider?> _getImage() async {
    try {
      var data = widget.dirInfo.getCoverBytesSync();
      if (data.isEmpty) return null;
      final image = MemoryImage(data);
      await precacheImage(image, context);
      return image;
    } catch (e) {
      return null;
    }
  }
}
