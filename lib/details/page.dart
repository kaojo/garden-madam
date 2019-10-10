import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/butler-feed.dart';
import 'package:garden_madam/details/valve.dart';

import '../model.dart';

class ButlerDetailsPage extends StatelessWidget {
  final Butler _butler;
  final ButlerController _butlerController;

  ButlerDetailsPage(this._butler, this._butlerController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_butler.name),
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          Center(
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
          Divider(
            thickness: 3,
          ),
          ..._getValves(_butler, _butlerController)
        ],
      ),
    );
  }

  List<ValvesListItem> _getValves(
      Butler butler, ButlerController butlerController) {
    return butler.pins != null
        ? butler.pins.map((pin) => _getValve(pin, butlerController)).toList()
        : [];
  }

  ValvesListItem _getValve(Pin pin, ButlerController butlerController) {
    return ValvesListItem(butlerController, pin);
  }
}
