import 'package:flutter/material.dart';

import 'drawer.dart';

class MyScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final FloatingActionButton floatingActionButton;

  const MyScaffold(
      {this.body, this.title = "Garden Madam", this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: NavigationDrawer(),
      floatingActionButton: floatingActionButton,
    );
  }
}
