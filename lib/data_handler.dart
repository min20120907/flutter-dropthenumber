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
    int gameDifficultyIndex = storage.getInt('gameDifficulty') ?? GameDifficulty.normal.index;
    return GameDifficulty.values[gameDifficultyIndex];
  }

  void writeGameDifficulty(GameDifficulty gameDifficulty) {
    int gameDifficultyIndex = GameDifficulty.values.indexOf(gameDifficulty);
    storage.setInt('gameDifficulty', gameDifficultyIndex);
  }

  bool readBgmMuted() {
    return storage.getBool('bgmMuted') ?? false;
  }

  void writeBgmMuted(bool bgmMuted) {
     storage.setBool('bgmMuted', bgmMuted);
  }

  double readBgmVolume() {
    return storage.getDouble('bgmVolume') ?? 0.5;
  }

  void writeBgmVolume(double volume) {
     storage.setDouble('bgmVolume', volume);
  }

  bool readEffectMuted() {
    return storage.getBool('effectMuted') ?? false;
  }

  void writeEffectMute(bool effectMute) {
    storage.setBool('effectMuted', effectMute);
  }

  double readEffectVolume() {
    return storage.getDouble('effectVolume') ?? 0.5;
  }

  void writeEffectVolume(double effectVolume) {
    storage.setDouble('effectVolume', effectVolume);
  }
}
