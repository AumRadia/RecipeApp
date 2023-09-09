import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkProvider extends ChangeNotifier {
  List<String> _bookmarkedUrls = [];
  List<String> _bookmarkedTitles = [];
  SharedPreferences? _prefs;

  List<String> get bookmarkedUrls => _bookmarkedUrls;
  List<String> get bookmarkedTitles => _bookmarkedTitles;

  BookmarkProvider() {
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadBookmarkedUrls();
  }

  Future<void> _loadBookmarkedUrls() async {
    _bookmarkedUrls = _prefs?.getKeys().toList() ?? [];
    _bookmarkedTitles = _bookmarkedUrls
        .map((url) => _prefs?.getString(url) ?? 'Untitled')
        .toList();
    notifyListeners();
  }

  Future<void> addBookmark(String url, String title) async {
    await _prefs?.setString(url, title);
    _loadBookmarkedUrls();
  }

  Future<void> removeBookmark(String url) async {
    await _prefs?.remove(url);
    _loadBookmarkedUrls();
  }

  bool isBookmarked(String url) {
    return _bookmarkedUrls.contains(url);
  }
}
