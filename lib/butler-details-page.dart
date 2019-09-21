import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'model.dart';

class ButlerDetailsPage extends StatelessWidget {
  final Butler butler;

  ButlerDetailsPage(this.butler);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(butler.name),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 10,
                      color: butler.online ? Colors.green : Colors.red),
                  borderRadius: BorderRadius.circular(200),
                ),
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                width: 200,
                height: 200,
                alignment: Alignment.center,
                child: SvgPicture.asset('images/butler.svg',
                    semanticsLabel: 'Butler default image'),
              ),
              Divider(
                thickness: 3,
              ),
              Expanded(child: ListView(children: _getValves(butler))),
              Divider(
                thickness: 3,
              ),
            ],
          ),
        ),
      );
  }

  List<Container> _getValves(Butler butler) {
    print(butler.pins.length);
    return butler.pins != null ? butler.pins.map(_getValve).toList() : [];
  }

  Container _getValve(Pin pin) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    width: 5,
                    color: pin.status == Status.ON ? Colors.blue : Colors.grey),
                borderRadius: BorderRadius.circular(50),
              ),
              margin: const EdgeInsets.fromLTRB(4, 4, 50, 4),
              padding: EdgeInsets.all(5),
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: SvgPicture.asset('images/' + (pin.imageName != null ? pin.imageName : 'valve_1.svg'),
                  semanticsLabel: 'Butler default image'),
            ),
            Expanded(
                child: Text(
                  pin.name != null ? pin.name : 'Noname',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
            Expanded(child: _getScheduleIcon(pin))
          ],
        ));
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

}