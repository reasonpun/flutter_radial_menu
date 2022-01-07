import 'package:flutter/material.dart';
import 'package:flutter_radial_menu/radial/src/radial_menu_item.dart';

import 'radial/src/radial_menu.dart';

enum MenuOptions {
  unread,
  share,
  archive,
  delete,
  backup,
  copy,
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter radial menu'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<RadialMenuState> _menuKey = GlobalKey<RadialMenuState>();

  final List<RadialMenuItem<MenuOptions>> items = <RadialMenuItem<MenuOptions>>[
    const RadialMenuItem<MenuOptions>(
      value: MenuOptions.unread,
      child: Icon(
        Icons.markunread,
      ),
      iconColor: Colors.white,
      backgroundColor: Colors.blue,
      tooltip: 'unread',
    ),
    const RadialMenuItem<MenuOptions>(
      tooltip: "share",
      value: MenuOptions.share,
      child: Icon(
        Icons.share,
      ),
      iconColor: Colors.white,
      backgroundColor: Colors.green,
    ),
    const RadialMenuItem<MenuOptions>(
      tooltip: "archive",
      value: MenuOptions.archive,
      child: Icon(
        Icons.archive,
      ),
      iconColor: Colors.white,
      backgroundColor: Colors.yellow,
    ),
    const RadialMenuItem<MenuOptions>(
      tooltip: "delete",
      value: MenuOptions.delete,
      child: Icon(
        Icons.delete,
      ),
      iconColor: Colors.white,
      backgroundColor: Colors.red,
    ),
    const RadialMenuItem<MenuOptions>(
      tooltip: "backup",
      value: MenuOptions.backup,
      child: Icon(
        Icons.backup,
      ),
      iconColor: Colors.white,
      backgroundColor: Colors.black,
    ),
    const RadialMenuItem<MenuOptions>(
      tooltip: "copy",
      value: MenuOptions.copy,
      child: Icon(
        Icons.content_copy,
      ),
      iconColor: Colors.white,
      backgroundColor: Colors.indigo,
    ),
  ];

  void _onItemSelected(MenuOptions value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'This shows button Menu',
            ),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 50.0,
              child: RadialMenu(
                key: _menuKey,
                items: items,
                radius: 100.0,
                onSelected: _onItemSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
