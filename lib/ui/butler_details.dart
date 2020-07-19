import 'package:flutter/material.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/ui/valve_list_item.dart';

import 'butler_detail_image_composition.dart';

class ButlerDetailsPage extends StatelessWidget {
  final Butler _butler;
  String errorMessage;

  ButlerDetailsPage(this._butler, {this.errorMessage});

  @override
  Widget build(BuildContext context) {
    var list = List<Widget>();
    if (this.errorMessage != null) {
      final snackBar = Text(errorMessage);
      list.add(snackBar);
      //Scaffold.of(context).showSnackBar(snackBar);
    }

    list.add(new ButlerDetailImageComposition(butler: _butler));
    list.addAll(_getValves(_butler));

    return ListView(
      children: list,
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
