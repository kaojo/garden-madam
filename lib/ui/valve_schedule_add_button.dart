import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/butler_bloc.dart';
import 'package:garden_madam/models/pin.dart';
import 'package:garden_madam/ui/schedule_page_wrapper.dart';
import 'package:garden_madam/ui/theme.dart';

class AddScheduleButton extends StatelessWidget {
  final Pin pin;

  const AddScheduleButton({Key key, this.pin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: RaisedButton(
        onPressed: () {
          // Open "add schedule dialog"
          _navigateToSchedulePage(context);
        },
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add_circle_outline,
              ),
              Container(
                margin: EdgeInsets.only(left: 5.0),
                child: Text("Add Schedule"),
              ),
            ],
          ),
        ),
        color: APPBAR_COLOR,
      ),
    );
  }

  _navigateToSchedulePage(BuildContext context) {
    var butlerBloc = BlocProvider.of<ButlerBloc>(context);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext newContext) {
      return SchedulePageWrapper(
        pin: pin,
        butlerBloc: butlerBloc,
      );
    }));
  }
}
