// @dart=2.11
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';

class DataHandler {
  /**********************************************************************
  * Read highest score from file.
  **********************************************************************/
  // Method1
  Future<int> readHighestScore() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.getInt('highestScore');
  }

  // Method2 (Also working :))
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

  // Method2 (Also working :))
//   void writeHighestScore(int highestScore) async {
//     File file = File((await getApplicationDocumentsDirectory()).path + "highestScore.txt");
//     file.writeAsString(highestScore.toString());
//   }
}
