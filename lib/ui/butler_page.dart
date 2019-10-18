import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';

import 'butler_details.dart';

class ButlerPage extends StatelessWidget {
  final String butlerName;

  ButlerPage(this.butlerName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(butlerName),
      ),
      body: RefreshIndicator(
        child: BlocBuilder<ButlerBloc, ButlerState>(
          builder: (BuildContext context, ButlerState state) {
            if (state is ButlerError) {
              return ListView(
                children: <Widget>[
                  Text('Error'),
                ],);
            } else if (state is ButlerLoaded) {
              return ButlerDetailsPage(state.butler);
            } else if (state is ButlerLoading) {
              return _getLoadingPage();
            } else {
              return ListView(
                children: <Widget>[
                  Text('No Data'),
                ],);
            }
          },
        ),
        onRefresh: () async => BlocProvider.of<ButlerBloc>(context).dispatch(FetchButler()),
      ),
    );
  }
}

Center _getLoadingPage() {
  return new Center(
    child: new CircularProgressIndicator(),
  );
}
