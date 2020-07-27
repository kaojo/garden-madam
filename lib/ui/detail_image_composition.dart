import 'package:flutter/material.dart';

class DetailImageComposition extends StatelessWidget {
  final Widget child;
  final bool status;
  final Color onColor;
  final Color offColor;
  final double imageScale;

  const DetailImageComposition(
      {@required this.child,
      @required this.status,
      onColor,
      offColor,
      double imageScale})
      : this.onColor = onColor != null ? onColor : Colors.green,
        this.offColor = offColor != null ? offColor : Colors.red,
        this.imageScale = imageScale != null ? imageScale : 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      margin: EdgeInsets.only(bottom: 10),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 10, color: status ? onColor : offColor),
            borderRadius: BorderRadius.circular(200 * imageScale),
          ),
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          padding: const EdgeInsets.all(20.0),
          width: 200 * imageScale,
          height: 200 * imageScale,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
