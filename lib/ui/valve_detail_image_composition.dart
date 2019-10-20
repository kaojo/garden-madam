
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/ui/detail_image_composition.dart';

class ValveDetailImageComposition extends StatelessWidget {
  const ValveDetailImageComposition({
    Key key,
    @required Pin pin,
  }) : _pin = pin, super(key: key);

  final Pin _pin;

  @override
  Widget build(BuildContext context) {
    return DetailImageComposition(
      status: _pin.status == Status.ON,
      onColor: Colors.blue,
      offColor: Colors.grey,
      child: Hero(
        tag: _pin.valvePinNumber,
        child: SvgPicture.asset(
          'images/' +
              (_pin.imageName != null ? _pin.imageName : 'valve_1.svg'),
          semanticsLabel: 'Valve default image',
        ),
      ),
    );
  }
}
