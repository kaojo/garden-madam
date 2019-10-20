import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/ui/valve_details_page.dart';

class ValvePageWrapper extends StatelessWidget {
  final Pin pin;
  final ButlerBloc butlerBloc;

  const ValvePageWrapper({Key key, this.pin, this.butlerBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: butlerBloc,
      child: BlocBuilder<ButlerBloc, ButlerState>(
        builder: (BuildContext context, ButlerState state) {
          if (state is ButlerError) {
            return ListView(
              children: <Widget>[
                Text('Error'),
              ],
            );
          } else if (state is ButlerLoaded) {
            return ValvePage(
              pin: pin,
            );
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
    );
  }
}

Widget _loadingAnimation() {
  return new Center(
    child: new CircularProgressIndicator(),
  );
}
