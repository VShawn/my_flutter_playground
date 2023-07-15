import 'dart:io';

import 'package:store/models/dao/book_info.dart';
import 'package:store/pages/item_view.dart';

class BookListHelper {
  static Future<List<BookInfo>> getBookList(String dirPath) async {
    var books = await BookInfoDatabase.getAllBookInfos(dirPath);
    var dir = Directory(dirPath);
    if (dir.existsSync()) {
      // 遍历文件夹，找出其中的书籍
      var bookss = await BookInfo.getBookFromDirAsync(dirPath);
      for (var book in bookss) {
        // 如果 books 中全部元素的 path 与 book 都不相同，则添加到 books 中
        if (books.any((element) => element.basePath == book.basePath && element.fileName == book.fileName) == false) {
          books.add(book);
        }
      }
    }

    // 更新到数据库
    for (var book in books) {
      if (book.id.isEmpty) {
        BookInfoDatabase.insertBookInfo(book);
      }
    }

    return books;
  }

  /// relativePath 用于读取包中的数据，例如 dirPath 为 zip 包路径时，传入 relativePath = test 可以读取 zip 包中 test 文件夹内的文件
  static Future<List<ItemView>> getItemViewList(String dirPath, {String? relativePath}) async {
    var itemViews = <ItemView>[];
    if (relativePath == null) {
      var bookTask = getBookList(dirPath);
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        final List<FileSystemEntity> files = dir.listSync();
        for (final file in files) {
          if (file is Directory) {
            var itemView = ItemView.dir(
              directory_: file,
            );
            itemViews.add(itemView);
          }
        }
      }
      var books = await bookTask;
      for (final book in books) {
        // print(book.fileFullName);
        itemViews.add(ItemView.bookInfo(bookInfo_: book));
      }
    }
    return itemViews;
  }
}
