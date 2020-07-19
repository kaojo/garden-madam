import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';

import '../main.dart';
import 'butler_details.dart';
import 'scaffold.dart';

class ButlerPage extends StatelessWidget {
  final String butlerName;

  ButlerPage(this.butlerName);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: butlerName,
      body: RefreshIndicator(
        onRefresh: () async => _loadButler(context),
        child: BlocBuilder<ButlerBloc, ButlerState>(
          builder: (BuildContext context, ButlerState state) {
            if (state is ButlerError) {
              if (state.butler != null) {
                return ButlerDetailsPage(
                  state.butler,
                  errorMessage: state.errorMessage,
                );
              }
            } else if (state is ButlerLoaded) {
              return ButlerDetailsPage(state.butler);
            } else if (state is ButlerLoading) {
              return loadingAnimation();
            }
            return ListView(
              children: <Widget>[
                Text('An unknown error occurred.'),
              ],
            );
          },
        ),
      ),
    );
  }

  void _loadButler(BuildContext context) =>
      BlocProvider.of<ButlerBloc>(context).add(LoadButler());
}
