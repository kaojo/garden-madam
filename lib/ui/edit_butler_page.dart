
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/blocs/edit_butler_form_bloc.dart';
import 'package:garden_madam/models/butler.dart';
import 'package:garden_madam/repositories/settings_repository.dart';
import 'package:garden_madam/ui/scaffold.dart';

import 'loading_dialog.dart';

class EditButlerPage extends StatelessWidget {
  final ButlerConfig config;
  final Butler butler;

  final SettingsRepository settingsRepository;

  const EditButlerPage(
      {Key key, this.config, @required this.settingsRepository, this.butler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: "Edit Butler",
      body: BlocProvider(
        create: (context) => EditButlerFormBloc(
            settingsRepository: settingsRepository,
            butler: this.butler,
            butlerConfig: this.config),
        child: Builder(
          builder: (context) {
            // ignore: close_sinks
            final editButlerFormBloc = context.bloc<EditButlerFormBloc>();

            return FormBlocListener<EditButlerFormBloc, ButlerConfig, String>(
              formBloc: editButlerFormBloc,
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
              child: BlocBuilder<EditButlerFormBloc, FormBlocState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TextFieldBlocBuilder(
                          textFieldBloc: editButlerFormBloc.butlerId,
                          isEnabled: false,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Id',
                            prefixIcon: Icon(Icons.perm_identity),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: editButlerFormBloc.butlerName,
                          keyboardType: TextInputType.text,
                          suffixButton: SuffixButton.clearText,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        BlocBuilder<ListFieldBloc<ValveFieldBloc>,
                            ListFieldBlocState<ValveFieldBloc>>(
                          cubit: editButlerFormBloc.valves,
                          builder: (context, state) {
                            if (state.fieldBlocs.isNotEmpty) {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.fieldBlocs.length,
                                itemBuilder: (context, i) {
                                  return Card(
                                    child: Column(
                                      children: <Widget>[
                                        TextFieldBlocBuilder(
                                          textFieldBloc:
                                              state.fieldBlocs[i].number,
                                          isEnabled: false,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            labelText: 'Number',
                                            prefixIcon:
                                                Icon(Icons.perm_identity),
                                          ),
                                        ),
                                        TextFieldBlocBuilder(
                                          textFieldBloc:
                                              state.fieldBlocs[i].valveName,
                                          keyboardType: TextInputType.text,
                                          suffixButton: SuffixButton.clearText,
                                          decoration: InputDecoration(
                                            labelText: 'Valve Name',
                                            prefixIcon: Icon(Icons.person),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                            return Container();
                          },
                        ),
                        RaisedButton(
                          onPressed: editButlerFormBloc.submit,
                          child: Text('Save'),
                        ),
                      ],
                    ),
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
