// @dart=2.11
import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dropthenumber.dart';
import 'data_handler.dart';

void main() async {
  Util flameUtil = Util();
  flameUtil.fullScreen();
  flameUtil.setOrientation(DeviceOrientation.portraitUp);
  flameUtil.setPortraitUpOnly();

  DataHandler dataHandler = DataHandler();

  DropTheNumber dropTheNumber = DropTheNumber();
  runApp(dropTheNumber.widget);
  Flame.bgm.play("edm.mp3", volume: 0);
}
