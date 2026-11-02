import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/notes/presentation/pages/notes_search_page.dart';

void main() {
  runApp(const ProviderScope(child: NotesSearchApp()));
}

class NotesSearchApp extends StatelessWidget {
  const NotesSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes Search AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const NotesSearchPage(),
    );
  }
}
