// @dart=2.11
import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropthenumber/dropthenumber.dart';

void main() {
  Util flameUtil = Util();
  flameUtil.fullScreen();
  flameUtil.setOrientation(DeviceOrientation.portraitUp);
  DropTheNumber game = DropTheNumber();

  runApp(game.widget);
  Flame.audio.playLongAudio("edm.mp3", volume: 0.5);
}
