import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/blocs/butler_bloc.dart';
import 'package:garden_madam/blocs/butler_state.dart';
import 'package:garden_madam/repositories/butler_repository.dart';

import 'butler_detail_image_composition.dart';
import 'butler_page_wrapper.dart';
import 'error_message.dart';

class ButlerCard extends StatelessWidget {
  const ButlerCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ButlerBloc, ButlerState>(
      builder: (BuildContext context, ButlerState state) {
        if (state is ButlerError) {
          return Column(
            children: <Widget>[
              ErrorMessage(state.errorMessage),
            ],
          );
        } else if (state is ButlerLoaded) {
          return Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            height: 300,
            child: Card(
              elevation: 1,
              child: InkWell(
                onTap: () =>
                    _navigateToButlerPage(context, state.butler.butlerConfig),
                child: Column(
                  children: <Widget>[
                    ButlerDetailImageComposition(butler: state.butler),
                    Text(
                      state.butler.name,
                      textScaleFactor: 2,
                    )
                  ],
                ),
              ),
            ),
          );
        } else if (state is ButlerLoading) {
          return _loadingAnimation();
        } else {
          return Column(
            children: <Widget>[
              ErrorMessage("Unknown state."),
            ],
          );
        }
      },
    );
  }

  void _navigateToButlerPage(BuildContext context, ButlerConfig config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext newContext) {
          return new ButlerPageWrapper(
            config: config,
            butlerBloc: BlocProvider.of<ButlerBloc>(context),
            butlerRepository: RepositoryProvider.of<ButlerRepository>(context),
          );
        },
      ),
    );
  }

  Widget _loadingAnimation() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }
}
