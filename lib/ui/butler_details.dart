import 'package:flutter/material.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/ui/valve_list_item.dart';

import 'butler_detail_image_composition.dart';

class ButlerDetailsPage extends StatelessWidget {
  final Butler _butler;

  ButlerDetailsPage(this._butler);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        new ButlerDetailImageComposition(butler: _butler),
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
