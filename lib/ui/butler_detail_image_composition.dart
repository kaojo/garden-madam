import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/models/models.dart';

import 'detail_image_composition.dart';

class ButlerDetailImageComposition extends StatelessWidget {
  const ButlerDetailImageComposition({
    Key key,
    @required Butler butler,
  })  : _butler = butler,
        super(key: key);

  final Butler _butler;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: _butler.id,
      child: DetailImageComposition(
        status: _butler.online,
        child: SvgPicture.asset('images/butler.svg',
            semanticsLabel: 'Butler default image'),
        imageScale: 0.75),
    );
  }
}
