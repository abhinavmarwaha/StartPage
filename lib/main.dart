import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:start_page/providers/saved_later_items_provider.dart';
import 'package:start_page/providers/start_apps_provider.dart';
import 'package:start_page/screens/home_screen.dart';
import 'package:start_page/utils/ThemeChanger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => StartAppsProvider.instance,
          ),
          ChangeNotifierProvider(
            create: (_) => SavedLaterItemsProvider.instance,
          ),
          ChangeNotifierProvider(
            create: (_) => ThemeChanger(),
          ),
        ],
        child: Builder(builder: (context) {
          final theme = Provider.of<ThemeChanger>(context);
          return MaterialApp(
            title: 'StartPage',
            theme: theme.getTheme(),
            home: HomeScreen(),
          );
        }));
  }
}
