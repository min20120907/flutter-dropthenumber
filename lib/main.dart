import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dropthenumber.dart';
import 'data_handler.dart';

void main() async {
  Flame.device.fullScreen();
  Flame.device.setOrientation(DeviceOrientation.portraitUp);
  Flame.device.setPortraitUpOnly();

  // SharedPreferences "Null check operator used on a null value" problem
  // Solution found: https://stackoverflow.com/a/62493934
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences storage = await SharedPreferences.getInstance();
  DropTheNumber dropTheNumber = DropTheNumber(DataHandler(storage));
  runApp(GameWidget(game: dropTheNumber));
}
