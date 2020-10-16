import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/repositories/butler_repository.dart';
import 'package:garden_madam/repositories/settings_repository.dart';
import 'package:garden_madam/ui/error_message.dart';

import '../main.dart';
import 'butler_details.dart';
import 'edit_butler_page.dart';
import 'scaffold.dart';

class ButlerPage extends StatelessWidget {
  final ButlerConfig config;

  const ButlerPage(this.config);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: config.name,
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
      onTap: () async {
        var butler =
            await RepositoryProvider.of<ButlerRepository>(context).getButler();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext newContext) {
              return new EditButlerPage(
                settingsRepository:
                    RepositoryProvider.of<SettingsRepository>(context),
                config: config,
                butler: butler,
              );
            },
          ),
        );
        Navigator.of(context).pop();
      },
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
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        BlocProvider.of<SettingsBloc>(context)
            .add(DeleteButlerEvent(config.id));
      },
      child: ListTile(
        leading: Icon(Icons.delete),
        title: Text(
          "Delete",
          textScaleFactor: 1.5,
        ),
      ),
    );
  }
}
