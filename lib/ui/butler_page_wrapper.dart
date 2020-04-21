import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/ui/butler_page.dart';

class ButlerPageWrapper extends StatelessWidget {
  final ButlerBloc butlerBloc;
  final String butlerName;

  const ButlerPageWrapper({Key key, this.butlerBloc, this.butlerName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: butlerBloc,
      child: ButlerPage(butlerName),
    );
  }

}
