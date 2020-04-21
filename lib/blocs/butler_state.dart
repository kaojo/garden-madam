import 'package:flutter/material.dart';
import 'package:garden_madam/models/butler.dart';

abstract class ButlerState {
  const ButlerState();
}

class ButlerEmpty extends ButlerState {}

class ButlerLoading extends ButlerState {}

class ButlerError extends ButlerState {}

class ButlerLoaded extends ButlerState {
  final Butler butler;

  const ButlerLoaded({@required this.butler}) : assert(butler != null);

}
