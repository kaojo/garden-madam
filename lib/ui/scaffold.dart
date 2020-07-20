import 'package:flutter/material.dart';

import 'drawer.dart';

class MyScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  const MyScaffold({this.body, this.title = "Garden Madam"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: NavigationDrawer(),
    );
  }
}
