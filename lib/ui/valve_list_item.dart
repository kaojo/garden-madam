import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/ui/valve_page_wrapper.dart';

import 'valve_switch.dart';

class ValvesListItem extends StatelessWidget {
  final Pin _pin;

  ValvesListItem(this._pin);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        var butlerBloc = BlocProvider.of<ButlerBloc>(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext newContext) {
          return ValvePageWrapper(pin: _pin, butlerBloc: butlerBloc,);
        }));
      },
      contentPadding: EdgeInsets.only(left: 10, bottom: 20.0),
      leading: Container(
        decoration: BoxDecoration(
          border: Border.all(
              width: 4,
              color: _pin.status == Status.ON ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(45),
        ),
        padding: EdgeInsets.all(5),
        width: 45,
        height: 45,
        alignment: Alignment.center,
        child: Hero(
          tag: _pin.valvePinNumber,
          child: SvgPicture.asset(
              'images/' +
                  (_pin.imageName != null ? _pin.imageName : 'valve_1.svg'),
              semanticsLabel: 'Valve default image'),
        ),
      ),
      title: Text(
        _pin.displayName(),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      trailing: ValveSwitch(_pin),
    );
  }
}
