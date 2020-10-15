import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/repositories/butler_repository.dart';
import 'package:garden_madam/ui/butler_page.dart';

class ButlerPageWrapper extends StatelessWidget {
  final ButlerBloc butlerBloc;
  final ButlerRepository butlerRepository;
  final ButlerConfig config;

  const ButlerPageWrapper(
      {Key key, this.butlerBloc, this.config, this.butlerRepository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: butlerRepository,
      child: BlocProvider.value(
        value: butlerBloc,
        child: ButlerPage(config),
      ),
    );
  }
}
