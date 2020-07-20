import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:garden_madam/blocs/settings_form_bloc.dart';
import 'package:garden_madam/repositories/settings_repository.dart';
import 'package:garden_madam/ui/scaffold.dart';

import 'loading_dialog.dart';

class MqttSettingsForm extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const MqttSettingsForm(this.settingsRepository);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: "Mqtt Settings",
      body: BlocProvider(
        create: (context) => SettingsFormBloc(settingsRepository),
        child: Builder(
          builder: (context) {
            // ignore: close_sinks
            final settingsFormBloc = context.bloc<SettingsFormBloc>();

            return FormBlocListener<SettingsFormBloc, String, String>(
              formBloc: settingsFormBloc,
              onSubmitting: (context, state) {
                LoadingDialog.show(context);
              },
              onSuccess: (context, state) {
                LoadingDialog.hide(context);

                Navigator.of(context).pop("SUCCESS");
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);

                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(state.failureResponse)));
              },
              child: BlocBuilder<SettingsFormBloc, FormBlocState>(
                builder: (context, state) {
                  if (state is FormBlocLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is FormBlocLoadFailed) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.sentiment_dissatisfied, size: 70),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              alignment: Alignment.center,
                              child: Text(
                                state.failureResponse ??
                                    'An error has occurred please try again later',
                                style: TextStyle(fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 20),
                            RaisedButton(
                              onPressed: settingsFormBloc.reload,
                              child: Text('RETRY'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ListView(
                      children: <Widget>[
                        TextFieldBlocBuilder(
                          textFieldBloc: settingsFormBloc.hostname,
                          keyboardType: TextInputType.text,
                          suffixButton: SuffixButton.clearText,
                          decoration: InputDecoration(
                            labelText: 'Mqtt Broker Hostname',
                            prefixIcon: Icon(Icons.computer),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: settingsFormBloc.port,
                          keyboardType: TextInputType.numberWithOptions(),
                          suffixButton: SuffixButton.clearText,
                          decoration: InputDecoration(
                            labelText: 'Port',
                            prefixIcon: Icon(Icons.settings_input_component),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: settingsFormBloc.username,
                          keyboardType: TextInputType.text,
                          suffixButton: SuffixButton.clearText,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: settingsFormBloc.password,
                          suffixButton: SuffixButton.obscureText,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        ListTile(
                          title: RaisedButton(
                            onPressed: settingsFormBloc.submit,
                            child: Text('SAVE'),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
