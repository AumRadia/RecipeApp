import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/bookmark_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmarked Recipes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, _) {
          return ListView.builder(
            itemCount: bookmarkProvider.bookmarkedUrls.length,
            itemBuilder: (context, index) {
              String url = bookmarkProvider.bookmarkedUrls[index];
              String title = bookmarkProvider.bookmarkedTitles[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    url,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    _launchURL(url);
                  },
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      bookmarkProvider.removeBookmark(url);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) {
      throw "URL is empty or null";
    }

    final Uri uri = Uri.parse(url);
    if (!await launch(
      uri.toString(),
      forceSafariVC: false,
      universalLinksOnly: true,
    )) {
      throw "Can't launch URL";
    }
  }
}
