import 'dart:io';

import 'package:store/models/dao/book_info.dart';

class BookListHelper {
  static Future<List<BookInfo>> getBookList({List<String>? dirPaths}) async {
    var books = await BookInfoDatabase.getAllBookInfos();
    if (dirPaths != null) {
      // 遍历文件夹，找出其中的书籍
      for (var dirPath in dirPaths) {
        //  目录是否存在
        var dir = Directory(dirPath);
        if (!dir.existsSync()) {
          continue;
        }
        var bookss = BookInfo.getBookFromDir(dirPath);
        for (var book in bookss) {
          // 如果 books 中全部元素的 path 与 book 都不相同，则添加到 books 中
          if (books.any((element) => element.path == book.path) == false) {
            books.add(book);
          }
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
}
