import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/butler-feed.dart';
import 'package:garden_madam/models/pin.dart';


class ValvesListItem extends StatelessWidget {
  ButlerController _butlerController;
  Pin _pin;

  ValvesListItem(this._butlerController, this._pin);

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
        try {
          if (_pin.status == Status.ON) {
            _butlerController.turn_off(_pin);
          } else {
            _butlerController.turn_on(_pin);
          }
        } on Exception catch (e) {
          print(e);
          handleMqttError(context, _pin, newValue);
        }
      };
}

Icon _getScheduleIcon(Pin pin) {
  if (pin.schedule == null) {
    return Icon(Icons.add_alarm, color: Colors.grey);
  }

  if (!pin.schedule.enabled) {
    return Icon(Icons.access_alarm, color: Colors.grey);
  }

  return Icon(Icons.access_alarm, color: Colors.lightBlueAccent);
}

class ValvePage extends StatelessWidget {
  Pin _pin;

  ValvePage(this._pin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pin.name()),
      ),
      body: ListView(
        children: <Widget>[
          Hero(
            tag: _pin.valvePinNumber,
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(10.0),
              color: Colors.grey[300],
              child: SvgPicture.asset(
                'images/' +
                    (_pin.imageName != null ? _pin.imageName : 'valve_1.svg'),
                semanticsLabel: 'Valve default image',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
