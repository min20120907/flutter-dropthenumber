import 'package:shared_preferences/shared_preferences.dart';

import'game_difficulty.dart';

class DataHandler {
  SharedPreferences storage;

  DataHandler(SharedPreferences storage)
  :storage = storage {
  }

  int readHighestScore() {
    return storage.getInt('highestScore') ?? 0;
  }

  void writeHighestScore(int highestScore) {
    storage.setInt('highestScore', highestScore);
  }

  GameDifficulty readGameDifficulty() {
    int? gameDifficultyIndex = storage.getInt('gameDifficulty');
    if(gameDifficultyIndex == null) {
      return GameDifficulty.normal;
    }
    return GameDifficulty.values[gameDifficultyIndex];
  }

  void writeGameDifficulty(GameDifficulty gameDifficulty) {
    int gameDifficultyIndex = GameDifficulty.values.indexOf(gameDifficulty);
    storage.setInt('gameDifficulty', gameDifficultyIndex);
  }

  bool readMute() {
    return storage.getBool('mute') ?? false;
  }

  void writeMute(bool mute) {
     storage.setBool('mute', mute);
  }

  double readVolume() {
    return storage.getDouble('volume') ?? 0.5;
  }

  void writeVolume(double volume) {
     storage.setDouble('volume', volume);
  }

  bool readEffectMute() {
    return storage.getBool('effectMute') ?? false;
  }

  void writeEffectMute(bool effectMute) {
    storage.setBool('effectMute', effectMute);
  }

  double readEffectVolume() {
    return storage.getDouble('effectVolume') ?? 0.5;
  }

  void writeEffectVolume(double effectVolume) {
    storage.setDouble('effectVolume', effectVolume);
  }
}
