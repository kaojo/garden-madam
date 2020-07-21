import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final errorMessage;

  const ErrorMessage(
    this.errorMessage, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
