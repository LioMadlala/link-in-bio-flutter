import 'package:flutter/material.dart';

import 'pages/edit_page.dart';
import 'pages/view_page.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const LinkInUrlApp());
}

class LinkInUrlApp extends StatelessWidget {
  const LinkInUrlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link in bio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        if (uri.path == '/view') {
          final encoded = uri.queryParameters['d'];
          return MaterialPageRoute(builder: (_) => ViewPage(encoded: encoded));
        } else if (uri.path == '/edit') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(builder: (_) => EditPage(initialData: args));
        }
        return MaterialPageRoute(builder: (_) => const EditPage());
      },
    );
  }
}
