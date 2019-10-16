
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/models/butler.dart';
import 'package:garden_madam/repositories/butler-repository.dart';

import 'butler_details.dart';

class ButlerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var butlerRepository = RepositoryProvider.of<ButlerRepository>(context);
    return StreamBuilder<Butler>(
      stream: butlerRepository.stream, // a Stream<int> or null
      builder: (BuildContext context, AsyncSnapshot<Butler> snapshot) {
        Widget body;
        Butler butler;
        if (snapshot.hasError) {
          body = ListView(children: <Widget>[
            Text('Error: ${snapshot.error}'),
          ]);
        } else {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              butler = snapshot.data;
              body = butler != null
                  ? ButlerDetailsPage(butler)
                  : _getLoadingPage();
              break;
            case ConnectionState.done:
              body = ListView(
                children: <Widget>[
                  Text('No connection to butler.'),
                ],
              );
              break;
            default:
              body = _getLoadingPage();
              break;
          }
        }
        return Scaffold(
          appBar: AppBar(
            title: butler != null && butler.name != null
                ? Text(butler.name)
                : Text('Loading'),
          ),
          body: RefreshIndicator(
            child: body,
            onRefresh: () => butlerRepository.refresh(),
          ),
        );
      },
    );
  }
}

Center _getLoadingPage() {
  return new Center(
    child: new CircularProgressIndicator(),
  );
}