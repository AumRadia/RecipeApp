import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/first.dart'; // Assuming 'first.dart' contains your HomePage

import 'bookmark_provider.dart'; // Import your BookmarkProvider

void main() {
  runApp(
    // Wrapping the app with ChangeNotifierProvider to provide BookmarkProvider
    ChangeNotifierProvider(
      create: (context) => BookmarkProvider(),
      child: const Recipe(),
    ),
  );
}

class Recipe extends StatelessWidget {
  const Recipe({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: First(), // The initial page of your app
    );
  }
}
