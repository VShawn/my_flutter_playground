import 'dart:io';

/// 一个工具函数，用于列出输入目录中的所有后缀名包括在输入参数 extensions 的文件（当可选参数 includingSubDir = true 时，包括子目录）
/// ```
/// void main() {
///   var dirPath = '/path/to/directory';
///   var fileList = listFiles(dirPath, extensions: ['.txt', '.pdf'], includingSubDir: true);
///   fileList.forEach((file) => print(file));
/// }
/// ```
List<String> listFilesSync(String directoryPath,
    {List<String>? extensions, bool includingSubDir = false}) {
  var fileList = <String>[];
  var dir = Directory(directoryPath);
  if (!dir.existsSync()) {
    print('Directory not found');
    return fileList;
  }

  // print('Directory found');
  // final List<FileSystemEntity> list = dir.listSync();
  // for (var fileOrDir in list) {
  //   if (fileOrDir is File &&
  //       (extensions == null ||
  //           extensions.any((ext) =>
  //               fileOrDir.path.toLowerCase().endsWith(ext.toLowerCase())))) {
  //     fileList.add(fileOrDir.path);
  //   } else if (fileOrDir is Directory && includingSubDir) {
  //     fileList.addAll(listFilesSync(fileOrDir.path,
  //         extensions: extensions, includingSubDir: includingSubDir));
  //   } else {
  //     // print('Not a file: ${fileOrDir.path}');
  //   }
  // }

  for (var fileOrDir in dir.listSync(recursive: includingSubDir)) {
    if (fileOrDir is File &&
        (extensions == null ||
            extensions.any((ext) =>
                fileOrDir.path.toLowerCase().endsWith(ext.toLowerCase())))) {
      fileList.add(fileOrDir.path);
    } else {
      // print('Not a file: ${fileOrDir.path}');
    }
  }
  return fileList;
}

Future<List<String>> listFilesAync(String directoryPath,
    {List<String>? extensions, bool includingSubDir = false}) async {
  var fileList = <String>[];
  var dir = Directory(directoryPath);
  if (!dir.existsSync()) {
    print('Directory not found');
    return fileList;
  }

  await for (var fileOrDir in dir.list(recursive: includingSubDir)) {
    if (fileOrDir is File &&
        (extensions == null ||
            extensions.any((ext) =>
                fileOrDir.path.toLowerCase().endsWith(ext.toLowerCase())))) {
      fileList.add(fileOrDir.path);
    } else {
      // print('Not a file: ${fileOrDir.path}');
    }
  }
  return fileList;
}
