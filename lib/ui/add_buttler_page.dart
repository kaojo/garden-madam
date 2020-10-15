import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:garden_madam/blocs/add_butler_form_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/repositories/settings_repository.dart';
import 'package:garden_madam/ui/scaffold.dart';

import 'loading_dialog.dart';

class AddButlerPage extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const AddButlerPage({Key key, this.settingsRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: "Add Butler",
      body: BlocProvider(
        create: (context) =>
            AddButlerFormBloc(settingsRepository: settingsRepository),
        child: Builder(
          builder: (context) {
            final addButlerFormBloc = context.bloc<AddButlerFormBloc>();

            return FormBlocListener<AddButlerFormBloc, ButlerConfig, String>(
              formBloc: addButlerFormBloc,
              onSubmitting: (context, state) {
                LoadingDialog.show(context);
              },
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                Navigator.of(context).pop(state.successResponse);
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(state.failureResponse)));
              },
              child: BlocBuilder<AddButlerFormBloc, FormBlocState>(
                builder: (context, state) {
                  return ListView(
                    children: <Widget>[
                      TextFieldBlocBuilder(
                        textFieldBloc: addButlerFormBloc.id,
                        keyboardType: TextInputType.text,
                        suffixButton: SuffixButton.clearText,
                        decoration: InputDecoration(
                          labelText: 'Id',
                          prefixIcon: Icon(Icons.perm_identity),
                        ),
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: addButlerFormBloc.name,
                        keyboardType: TextInputType.text,
                        suffixButton: SuffixButton.clearText,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      ListTile(
                        title: RaisedButton(
                          onPressed: addButlerFormBloc.submit,
                          child: Text('Add'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
