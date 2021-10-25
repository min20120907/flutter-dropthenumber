// @dart=2.11
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';
import'game_difficulty.dart';

class DataHandler {
  /**********************************************************************
  * Variable
  **********************************************************************/
  SharedPreferences storage;

  /**********************************************************************
  * Constructor
  **********************************************************************/
  DataHandler(SharedPreferences storage) {
    this.storage = storage;
  }

  /**********************************************************************
  * Read highest score from file.
  **********************************************************************/
  // Method1
  int readHighestScore() {
    if(!storage.containsKey('highestScore')) {
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
    storage.setInt('highestScore', highestScore);
  }

  // Method2 (Also work)
//   void writeHighestScore(int highestScore) async {
//     File file = File((await getApplicationDocumentsDirectory()).path + "highestScore.txt");
//     file.writeAsString(highestScore.toString());
//   }

  /**********************************************************************
  * Read game difficulty from file.
  **********************************************************************/
  GameDifficulty readGameDifficulty() {
    int gameDifficultyIndex = storage.getInt('gameDifficulty');
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
    storage.setInt('gameDifficulty', gameDifficultyIndex);
  }

  /**********************************************************************
  * Read bgm mute from file
  **********************************************************************/
  bool readMute() {
    if(!storage.containsKey('mute')) {
      return false;
    }
    return storage.getBool('mute');
  }

  /**********************************************************************
  * Write bgm mute state to file.
  **********************************************************************/
  void writeMute(bool mute) {
     storage.setBool('mute', mute);
  }

  /**********************************************************************
  * Read bgm volume from file
  **********************************************************************/
  double readVolume() {
    if(!storage.containsKey('volume')) {
      return 0.5;
    }
    return storage.getDouble('volume');
  }

  /**********************************************************************
  * Write bgm volume to file.
  **********************************************************************/
  void writeVolume(double volume) {
     storage.setDouble('volume', volume);
  }

  /**********************************************************************
  * Read effect mute from file
  **********************************************************************/
  bool readEffectMute() {
    if(!storage.containsKey('effectMute')) {
      return false;
    }
    return storage.getBool('effectMute');
  }

  /**********************************************************************
  * Write effect mute state to file.
  **********************************************************************/
  void writeEffectMute(bool effectMute) {
    storage.setBool('effectMute', effectMute);
  }

  /**********************************************************************
  * Read effect volume from file.
  **********************************************************************/
  double readEffectVolume() {
    if(!storage.containsKey('effectVolume')) {
      return 0.5;
    }
    return storage.getDouble('effectVolume');
  }

  /**********************************************************************
  * Write effect volume to file.
  **********************************************************************/
  void writeEffectVolume(double effectVolume) {
    storage.setDouble('effectVolume', effectVolume);
  }
}
