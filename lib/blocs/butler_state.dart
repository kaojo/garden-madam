import 'package:flutter/material.dart';
import 'package:garden_madam/models/butler.dart';

abstract class ButlerState {
  const ButlerState();
}

class ButlerEmpty extends ButlerState {}

class ButlerLoading extends ButlerState {}

class ButlerError extends ButlerState {
  final Butler butler;
  final String errorMessage;

  const ButlerError(this.errorMessage, {this.butler});
}

class ButlerLoaded extends ButlerState {
  final Butler butler;

  const ButlerLoaded({@required this.butler}) : assert(butler != null);

}
