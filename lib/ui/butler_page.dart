import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/ui/error_message.dart';

import '../main.dart';
import 'butler_details.dart';
import 'scaffold.dart';

class ButlerPage extends StatelessWidget {
  final String id;
  final String butlerName;

  const ButlerPage(this.id, this.butlerName);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: butlerName,
      pageDrawerItems: <Widget>[
        _editButler(context),
        _deleteButler(context),
      ],
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
                ErrorMessage('An unknown error occurred.'),
              ],
            );
          },
        ),
      ),
    );
  }

  void _loadButler(BuildContext context) =>
      BlocProvider.of<ButlerBloc>(context).add(LoadButler());

  Widget _editButler(BuildContext context) {
    return InkWell(
      onTap: () => null,
      child: ListTile(
        leading: Icon(Icons.edit),
        title: Text(
          "Edit",
          textScaleFactor: 1.5,
        ),
      ),
    );
  }

  Widget _deleteButler(BuildContext context) {
    return InkWell(
      onTap: () {
        BlocProvider.of<SettingsBloc>(context).add(DeleteButlerEvent(this.id));
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
      child: ListTile(
        leading: Icon(Icons.edit),
        title: Text(
          "Delete",
          textScaleFactor: 1.5,
        ),
      ),
    );
  }
}
