import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/repositories/butler-repository.dart';
import 'package:garden_madam/models/butler.dart';
import 'package:garden_madam/models/pin.dart';
import 'package:garden_madam/ui/valve_details_page.dart';

class ButlerDetailsPage extends StatelessWidget {
  final Butler _butler;

  ButlerDetailsPage(this._butler);

  @override
  Widget build(BuildContext context) {
    print('building butler detail widget');
    return ListView(
        children: <Widget>[
          Container(
              color: Colors.grey[300],
              margin: EdgeInsets.only(bottom: 10),
              child: Center(
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 10,
                          color: _butler.online ? Colors.green : Colors.red),
                      borderRadius: BorderRadius.circular(200),
                    ),
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: SvgPicture.asset('images/butler.svg',
                        semanticsLabel: 'Butler default image'),
                  ),
                ),
              ),
              ..._getValves(_butler)
        ],
    );
  }

  List<ValvesListItem> _getValves(Butler butler) {
    return butler.pins != null
        ? butler.pins.map((pin) => _getValve(pin)).toList()
        : [];
  }

  ValvesListItem _getValve(Pin pin) {
    return ValvesListItem(pin);
  }
}


class ValvesListItem extends StatelessWidget {
  final Pin _pin;

  ValvesListItem(this._pin);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return ValvePage(_pin);
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
        _pin.name(),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      trailing: Switch(
        value: _pin.status == Status.ON,
        onChanged: togglePin(context, _pin),
      ),
    );
  }

  void handleMqttError(BuildContext context, Pin pin, bool newValue) {
    pin.status = newValue ? Status.OFF : Status.ON;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Connection Error"),
          content: new Text("Could not reach your butler. Try again later."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  togglePin(BuildContext context, Pin pin) => (bool newValue) {
    var butlerController = RepositoryProvider.of<ButlerRepository>(context);
    try {
      if (_pin.status == Status.ON) {
        butlerController.turnOff(_pin);
      } else {
        butlerController.turnOn(_pin);
      }
    } on Exception catch (e) {
      print(e);
      handleMqttError(context, _pin, newValue);
    }

  };
}
