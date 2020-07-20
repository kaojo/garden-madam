import 'package:flutter/material.dart';

class DetailImageComposition extends StatelessWidget {
  final Widget child;
  final bool status;
  final Color onColor;
  final Color offColor;

  const DetailImageComposition(
      {@required this.child, @required this.status, onColor, offColor})
      : this.onColor = onColor != null ? onColor : Colors.green,
        this.offColor = offColor != null ? offColor : Colors.red;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      margin: EdgeInsets.only(bottom: 10),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 10, color: status ? onColor : offColor),
            borderRadius: BorderRadius.circular(200),
          ),
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          padding: const EdgeInsets.all(20.0),
          width: 200,
          height: 200,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
