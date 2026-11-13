import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:linux_do/utils/log.dart';

import '../models/bookmark_item.dart';
import '../const/app_const.dart';

class BookmarkService extends GetxService {
  static const String STORAGE_KEY = 'bookmarks';

  // 使用Map存储每个分类的收藏列表
  final RxMap<String, RxList<BookmarkItem>> bookmarksByCategory =
      <String, RxList<BookmarkItem>>{}.obs;

  // GetStorage实例
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadBookmarks();
  }

  // 加载所有收藏数据
  void _loadBookmarks() {
    try {
      final String? storedData = _storage.read<String>(STORAGE_KEY);

      // 初始化所有分类
      for (final category in AppConst.bookmarkCategories) {
        bookmarksByCategory[category] = <BookmarkItem>[].obs;
      }

      if (storedData != null) {
        final Map<String, dynamic> data = jsonDecode(storedData);

        // 遍历每个分类
        data.forEach((category, items) {
          if (bookmarksByCategory.containsKey(category)) {
            final List itemsList = items as List;
            final bookmarks = itemsList
                .map((item) => BookmarkItem.fromJson(item))
                .toList();
            bookmarksByCategory[category]!.assignAll(bookmarks);
          }
        });
      }
    } catch (e) {
      l.e('加载书签失败: $e');
    }
  }

  // 保存所有收藏数据
  Future<void> _saveBookmarks() async {
    try {
      final Map<String, dynamic> data = {};

      // 将Observable列表转换为普通列表
      bookmarksByCategory.forEach((category, items) {
        data[category] = items.map((item) => item.toJson()).toList();
      });

      await _storage.write(STORAGE_KEY, jsonEncode(data));
    } catch (e) {
      l.e('保存书签失败: $e');
    }
  }

  // 添加收藏
  Future<bool> addBookmark(BookmarkItem item) async {
    try {
      final category = item.category;

      // 确保分类存在
      if (!bookmarksByCategory.containsKey(category)) {
        bookmarksByCategory[category] = <BookmarkItem>[].obs;
      }

      // 检查是否已存在该主题
      final existingIndex = bookmarksByCategory[category]!.indexWhere(
        (bookmark) => bookmark.id == item.id,
      );

      if (existingIndex >= 0) {
        // 替换现有收藏
        bookmarksByCategory[category]![existingIndex] = item;
      } else {
        // 添加新收藏
        bookmarksByCategory[category]!.add(item);
      }

      // 保存更改
      await _saveBookmarks();
      return true;
    } catch (e) {
      l.e('添加书签失败: $e');
      return false;
    }
  }

  // 移除收藏
  Future<bool> removeBookmark(int id, String category) async {
    try {
      if (bookmarksByCategory.containsKey(category)) {
        final lengthBefore = bookmarksByCategory[category]!.length;
        bookmarksByCategory[category]!.removeWhere(
          (bookmark) => bookmark.id == id,
        );

        final removed = bookmarksByCategory[category]!.length < lengthBefore;

        if (removed) {
          await _saveBookmarks();
          return true;
        }
      }
      return false;
    } catch (e) {
      l.e('移除书签失败: $e');
      return false;
    }
  }

  // 检查主题是否已收藏
  bool isBookmarked(int id) {
    for (final category in bookmarksByCategory.keys) {
      if (bookmarksByCategory[category]!.any((bookmark) => bookmark.id == id)) {
        return true;
      }
    }
    return false;
  }

  // 获取主题所在的分类
  String? getBookmarkCategory(int id) {
    for (final category in bookmarksByCategory.keys) {
      if (bookmarksByCategory[category]!.any((bookmark) => bookmark.id == id)) {
        return category;
      }
    }
    return null;
  }

  // 获取特定分类的所有收藏
  List<BookmarkItem> getBookmarksByCategory(String category) {
    return bookmarksByCategory[category]?.toList() ?? [];
  }

  // 获取所有收藏
  List<BookmarkItem> getAllBookmarks() {
    final List<BookmarkItem> allBookmarks = [];
    for (final items in bookmarksByCategory.values) {
      allBookmarks.addAll(items);
    }
    return allBookmarks;
  }
}
