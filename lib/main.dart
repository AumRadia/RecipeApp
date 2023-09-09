import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'first.dart';
import 'bookmark_provider.dart';

void main(List<String> args) {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BookmarkProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: First(),
    );
  }
}
