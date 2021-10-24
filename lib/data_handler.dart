// @dart=2.11
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';
import'game_difficulty.dart';

class DataHandler {
  /**********************************************************************
  * Read highest score from file.
  **********************************************************************/
  // Method1
  Future<int> readHighestScore() async {
    SharedPreferences storage = await SharedPreferences.getInstance(); // Error! Null check operator used on a null value
    if(!storage.containsKey('highestScore')) {
      print("three"); //debug!!
      return 0;
    }
    return storage.getInt('highestScore');
  }

  // Method2 (Also work)
//   Future<int> readHighestScore() async {
//     String root = (await getApplicationDocumentsDirectory()).path;
//
//     File file = File(root + "highestScore.txt");
//     if (!file.existsSync()) {
//       await writeHighestScore(0);
//     }
//     int highestScore = int.parse(await file.readAsString());
//     return highestScore;
//   }

  /**********************************************************************
  * Write highest score to file.
  **********************************************************************/
  // Method1
  void writeHighestScore(int highestScore) {
    SharedPreferences.getInstance().then((storage) => storage.setInt('highestScore', highestScore));
  }

  // Method2 (Also work)
//   void writeHighestScore(int highestScore) async {
//     File file = File((await getApplicationDocumentsDirectory()).path + "highestScore.txt");
//     file.writeAsString(highestScore.toString());
//   }

  /**********************************************************************
  * Read bgm mute from file
  **********************************************************************/
  Future<bool> readMute() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    if(!storage.containsKey('mute')) {
      return false;
    }
    return storage.getBool('mute');
  }

  /**********************************************************************
  * Write bgm mute state to file.
  **********************************************************************/
  void writeMute(bool mute) {
     SharedPreferences.getInstance().then((storage) => storage.setBool('mute', mute));
  }

  /**********************************************************************
  * Read bgm volume from file
  **********************************************************************/
  Future<double> readVolume() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    if(!storage.containsKey('volume')) {
      return 0.5;
    }
    return storage.getDouble('volume');
  }

  /**********************************************************************
  * Write bgm volume to file.
  **********************************************************************/
  void writeVolume(double volume) {
     SharedPreferences.getInstance().then((storage) => storage.setDouble('volume', volume));
  }

  /**********************************************************************
  * Read effect mute from file
  **********************************************************************/
  Future<bool> readEffectMute() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    if(!storage.containsKey('effectMute')) {
      return false;
    }
    return storage.getBool('effectMute');
  }

  /**********************************************************************
  * Write effect mute state to file.
  **********************************************************************/
  void writeEffectMute(bool effectMute) {
     SharedPreferences.getInstance().then((storage) => storage.setBool('effectMute', effectMute));
  }

  /**********************************************************************
  * Read effect volume from file.
  **********************************************************************/
  Future<double> readEffectVolume() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    if(!storage.containsKey('effectVolume')) {
      return 0.5;
    }
    return storage.getDouble('effectVolume');
  }

  /**********************************************************************
  * Write effect volume to file.
  **********************************************************************/
  void writeEffectVolume(double effectVolume) {
     SharedPreferences.getInstance().then((storage) => storage.setDouble('effectVolume', effectVolume));
  }

  /**********************************************************************
  * Read game difficulty from file.
  **********************************************************************/
  Future<GameDifficulty> readGameDifficulty() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    int gameDifficultyIndex = await storage.getInt('gameDifficulty');
    if(!storage.containsKey('gameDifficulty')) {
      return GameDifficulty.normal;
    }
    return GameDifficulty.values[gameDifficultyIndex];
  }

  /**********************************************************************
  * Write game difficulty to file.
  **********************************************************************/
  void writeGameDifficulty(GameDifficulty gameDifficulty) {
    int gameDifficultyIndex = GameDifficulty.values.indexOf(gameDifficulty);
    SharedPreferences.getInstance().then((storage) => storage.setInt('gameDifficulty', gameDifficultyIndex));
  }
}
