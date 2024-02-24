import "package:dropthenumber/game_difficulty.dart";

// Y dropped for every second. (In percentage)
double getDropSpeed(GameDifficulty gameDifficulty) {
  switch (gameDifficulty) {
    case GameDifficulty.noob: return 2.0;
    case GameDifficulty.easy: return 4.0;
    case GameDifficulty.normal: return 8.0;
    case GameDifficulty.hard: return 20.0;
  }
}

// Block merging animation speed (percentage of the map)
double getMergingSpeed(GameDifficulty gameDifficulty) {
  return 2.0;
}


Duration getSuperpowerCooldownTime(GameDifficulty gameDifficulty) {
  switch (gameDifficulty) {
    case GameDifficulty.noob: return Duration(seconds: 10);
    case GameDifficulty.easy: return Duration(seconds: 20);
    case GameDifficulty.normal: return Duration(seconds: 30);
    case GameDifficulty.hard: return Duration(seconds: 30);
  }
}

// The score multiplier of the game
double getScoreMultiplier(GameDifficulty gameDifficulty) {
  switch (gameDifficulty) {
    case GameDifficulty.noob: return 0.25;
    case GameDifficulty.easy: return 0.5;
    case GameDifficulty.normal: return 1;
    case GameDifficulty.hard: return 1.5;
  }
}
