import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/repositories/butler-repository.dart';
import 'package:garden_madam/models/butler.dart';
import 'package:garden_madam/models/pin.dart';
import 'package:garden_madam/ui/valve_details_page.dart';

class ButlerDetailsPage extends StatelessWidget {
  final Butler _butler;
  final ButlerRepository _butlerController;

  ButlerDetailsPage(this._butler, this._butlerController);

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
              ..._getValves(_butler, _butlerController)
        ],
    );
  }

  List<ValvesListItem> _getValves(Butler butler,
      ButlerRepository butlerController) {
    return butler.pins != null
        ? butler.pins.map((pin) => _getValve(pin, butlerController)).toList()
        : [];
  }

  ValvesListItem _getValve(Pin pin, ButlerRepository butlerController) {
    return ValvesListItem(butlerController, pin);
  }
}
