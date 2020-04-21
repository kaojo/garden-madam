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
        onRefresh: () async => _loadButler(context),
        child: BlocBuilder<ButlerBloc, ButlerState>(
          builder: (BuildContext context, ButlerState state) {
            if (state is ButlerError) {
              return ListView(
                children: <Widget>[
                  Text('Error'),
                ],
              );
            } else if (state is ButlerLoaded) {
              return ButlerDetailsPage(state.butler);
            } else if (state is ButlerLoading) {
              return _loadingAnimation();
            } else {
              return ListView(
                children: <Widget>[
                  Text('No Data'),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _loadButler(BuildContext context) =>
      BlocProvider.of<ButlerBloc>(context).dispatch(LoadButler());
}

Widget _loadingAnimation() {
  return new Center(
    child: new CircularProgressIndicator(),
  );
}
