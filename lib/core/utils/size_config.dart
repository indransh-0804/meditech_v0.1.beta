import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;

  static const double designWidth = 375;
  static const double designHeight = 810;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }

  static double w(double inputWidth) =>
      (inputWidth / designWidth) * screenWidth;

  static double h(double inputHeight) =>
      (inputHeight / designHeight) * screenHeight;
}
