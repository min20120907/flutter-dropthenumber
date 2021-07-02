// @dart=2.11
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sprintf/sprintf.dart';
import 'block.dart';

// Global Variables
Random random = new Random();
int randomNumber = random.nextInt(13);
int randomNumber2 = random.nextInt(13);
int track = random.nextInt(5);
int current = pow(2, randomNumber).toInt();
int next = pow(2, randomNumber2).toInt();
int randomRange(int min, int max) => min + random.nextInt(max - min);

// Game Main Loop
class DropTheNumber extends Game with TapDetector {
  // Create Variable
  List<List<Block>> blocks = [[]];
  int highest = 99;
  bool pause = false;
  bool mute = false;
  double score = 0;
  Size screenSize;
  bool lastLoopPaused = false;
  bool gameOver = false;
  DateTime startTime = DateTime.now();
  Duration stopTimeText;
  DateTime startTimeOfPause;
  DateTime cooldownTimeHor;
  DateTime cooldownTimeVert;
  Duration pauseDuration;
  Duration displayDuration;

  // coordinates of clicked position
  double xAxis = 0, yAxis = 0;
  ui.Image img1, img2, img3, img4;
  // Videos declaration
  List<ui.Image> vid1, vid2;
  // Lambda Function
  double log2(double x) => log(x) / log(2);
  double getX(double x) => screenSize.width * x / 500;
  double getY(double y) => screenSize.height * y / 750;
  bool inRange(double x, double a, double b) => x >= a && x <= b;

  // colorlist
  List<Color> colorList = [
    Color.fromRGBO(255, 0, 0, 1.0),
    Color.fromRGBO(0, 255, 0, 1.0),
    Color.fromRGBO(204, 153, 255, 1.0),
    Color.fromRGBO(209, 237, 0, 1.0),
    Color.fromRGBO(209, 237, 240, 1.0),
    Color.fromRGBO(209, 40, 240, 1.0),
    Color.fromRGBO(254, 239, 222, 1.0),
    Color.fromRGBO(0, 239, 222, 1.0),
    Color.fromRGBO(255, 255, 80, 1.0),
    Color.fromRGBO(51, 102, 255, 1.0),
    Color.fromRGBO(255, 204, 164, 1.0),
    Color.fromRGBO(153, 255, 153, 1.0),
    Color.fromRGBO(194, 194, 214, 1.0)
  ];

  @override
  void render(Canvas canvas) {
    if (!gameOver) {
      // draw background
      loadUiImage("img/bg3.jpg").then((value) => img1 = value);
      drawImage(Paint(), canvas, img1, 0, 0, 500, 750);
      // draw mute
      if (mute) {
        loadUiImage("img/mute-2.png").then((value) => img2 = value);
        drawImage(new Paint(), canvas, img2, 399, 98, 40, 40);
      } else {
        loadUiImage("img/mute-1.png").then((value) => img2 = value);
        drawImage(new Paint(), canvas, img2, 399, 98, 40, 40);
      }

      // Draw outline
      drawRectStroke(canvas, 500 / 10, 750 / 20, 500 * 4 / 5, 750 * 650 / 750,
          Colors.white, 10);
      drawRectStroke(canvas, 500 * 75 / 500, 750 * 45 / 202, 500 * 35 / 50,
          750 * 50 / 75, Colors.white, 5);
      drawRectStroke(canvas, 500 * 350 / 490, 750 * 685 / 730, 500 * 40 / 500,
          750 * 32 / 750, Colors.white, 3);
      drawRectStroke(canvas, 500 * 55 / 590, 750 * 685 / 730, 500 * 40 / 500,
          750 * 32 / 750, Colors.white, 3);
      drawRectStroke(canvas, 500 * 405 / 490, 750 * 685 / 730, 500 * 40 / 500,
          750 * 32 / 750, Colors.white, 3);

      //draw three horizontal lines
      drawLine(Colors.white, canvas, 50, 90, 450, 90, 5);
      drawLine(Colors.white, canvas, 50, 140, 450, 140, 5);
      drawLine(Colors.white, canvas, 75, 235, 425, 235, 5);

      // draw five vertical lines
      for (double i = 0; i < 5; i++)
        drawLine(Colors.white, canvas, 75 + i * 70, 165, 75 + i * 70, 665, 5);

      //draw text
      drawText(canvas, 'Drop', Colors.red, 30, 215, 48);
      drawText(canvas, 'Next Block ►', Colors.white, 18, 60, 103);
      drawText(canvas, 'Score:' + score.toString(), Colors.white, 27, 100, 703);
      for (double i = 0; i < 5; i++)
        drawText(canvas, '†', Colors.black, 50, 100 + i * 70, 170);

      drawTime(canvas);
      drawBlock(canvas, Block(current, 216, 240));
      drawNextBlock(canvas, Block(next, 200, 96));
      drawAllBlocks(canvas);
    } else {
      drawGameover(canvas);
    }
  }

  // get new random next block
  void getNewNextBlock() {
    track = random.nextInt(4);
    current = next;
    if (score > 100000)
      next = pow(2, randomRange(7, 12)).toInt();
    else if (score > 30000)
      next = pow(2, randomRange(1, 9)).toInt();
    else
      next = pow(2, randomRange(1, 5)).toInt();
    xAxis = (75 + 70 * track).toDouble();
  }

  // Define Function
  // Drawline
  void drawLine(Color c, Canvas canvas, double p1x, double p1y, double p2x,
      double p2y, double width) {
    final p1 =
        Offset(screenSize.width * p1x / 500, screenSize.height * p1y / 750);
    final p2 =
        Offset(screenSize.width * p2x / 500, screenSize.height * p2y / 750);
    final paint = Paint()
      ..color = c
      ..strokeWidth = screenSize.height * width / 750;
    canvas.drawLine(p1, p2, paint);
  }

  // draw gameover screen
  void drawGameover(Canvas canvas) {
    // Draw Gameover Screen
    drawRect(canvas, 0, 0, 500, 750, Colors.white);
    drawText(canvas, "Game Over", Colors.black, 40, 145, 150);
    drawText(canvas, "TIME:", Colors.black, 30, 165, 220);
    drawText(
        canvas, getTimeformat(displayDuration), Colors.black, 30, 252, 220);
    drawText(canvas, "Highest Score:", Colors.black, 30, 100, 270);
    drawText(canvas, highest.toString(), Colors.black, 30, 304, 271);
    drawText(canvas, "Your Score:", Colors.black, 30, 120, 320);
    drawText(canvas, score.toString(), Colors.black, 30, 280, 322);
    drawRectStroke(canvas, 160, 380, 185, 40, Colors.black, 5);
    drawText(canvas, "Restart", Colors.black, 25, 215, 384);
    drawRectStroke(canvas, 160, 430, 185, 40, Colors.black, 5);
    drawText(canvas, "Quit", Colors.black, 25, 225, 435);
  }

  // Drawtext
  void drawText(Canvas canvas, String text, Color colo, double fontSize,
      double x, double y) {
    TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: colo, fontSize: screenSize.height * fontSize / 750)),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )
      ..layout(minWidth: screenSize.width, maxWidth: screenSize.width)
      ..paint(canvas, Offset(getX(x), getY(y)));
  }

  // Drawrect
  void drawRect(Canvas canvas, double x, double y, double width, double height,
      Color color) {
    Rect rect = Rect.fromLTWH(getX(x), getY(y), getX(width), getY(height));
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  // def blockAppend():
  // void blockAppend() {
  //   double max_y_axis = (582 - 70 * blocks[track].length).toDouble();
  //   if (max_y_axis > 223) {
  //     List<Block> block = [current, x, max_y_axis];
  //   }
  // }

  // Drawstroke
  void drawRectStroke(Canvas canvas, double x, double y, double width,
      double height, Color color, double strokeWidth) {
    Rect rect = Rect.fromLTWH(getX(x), getY(y), getX(width), getY(height));
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRect(rect, paint);
  }

  //Format the time from second to minute and second
  String getTimeformat(Duration totalSecond) {
    return sprintf("%02d:%02d",
        [totalSecond.inSeconds ~/ 60, (totalSecond.inSeconds % 60).toInt()]);
  }

  // Drawtime
  void drawTime(Canvas canvas) {
    if (lastLoopPaused != pause) {
      if (pause) {
        startTimeOfPause = DateTime.now();
      } else {
        pauseDuration = DateTime.now().difference(startTimeOfPause);

        // Stop horizontal super skill cooldown when puase
        if (cooldownTimeHor != null) {
          cooldownTimeHor = cooldownTimeHor.add(pauseDuration);
        }
        // Stop vertical super skill cooldown when puase
        if (cooldownTimeVert != null) {
          cooldownTimeVert = cooldownTimeVert.add(pauseDuration);
        }
        // Change start time of the game which use to count the timer 'arial.ttf'
        startTime = startTime.add(pauseDuration);
      }
    }
    lastLoopPaused = pause;
    if (pause) {
      drawText(canvas, '►', Colors.white, 28, 54, 699);
      displayDuration = stopTimeText;
    } else {
      drawText(canvas, 'II', Colors.white, 28, 56, 704);
      displayDuration = DateTime.now().difference(startTime);
      stopTimeText = displayDuration;
    }

    drawText(canvas, 'TIME:' + getTimeformat(displayDuration), Colors.white, 21,
        255, 103); //display clock
  }

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void drawAllBlocks(Canvas canvas) {
    for (List<Block> linesOfBlocksY in blocks) {
      for (Block block in linesOfBlocksY) {
        if (!gameOver) {
          drawBlock(canvas, block);
        }
      }
    }
    // draw superpower horizontal
    loadUiImage("img/fire-4.png").then((value) => img3 = value);
    drawImage(Paint(), canvas, img3, 403, 695, 59, 60);
    // draw superpower vertical
    loadUiImage("img/vertical-2.png").then((value) => img4 = value);
    drawImage(Paint(), canvas, img4, 350, 696, 50, 50);
  }

  // Drawimage
  void drawImage(Paint p, Canvas canvas, ui.Image img, double x, double y,
      double width, double height) {
    canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromLTWH(getX(x), getY(y), getX(width), getY(height)),
        p);
  }

  // draw video
  void drawVideo(Paint p, Canvas canvas, List<ui.Image> vid, double x, double y,
      double sx, double sy) {
    // load video
    for (int i = 0; i < vid.length; i++) {
      canvas.drawImageRect(
          vid[i],
          Rect.fromLTWH(
              0, 0, vid[i].width.toDouble(), vid[i].height.toDouble()),
          Rect.fromLTWH(getX(x), getY(y), sx, sy),
          p);
    }
  }

  void tryToPause() {
    if (!gameOver) {
      pause = !pause;
    }
  }

  void drawNextBlock(Canvas canvas, Block b) {
    double width = 500 * 45 / 500;
    double height = 750 * 37 / 750;
    if (log2(b.v.toDouble()) - 1 < 12) {
      // Paint within 8192
      drawRect(canvas, b.x, b.y, width, height,
          colorList[log2(b.v.toDouble()).toInt() - 1]);
    } else {
      // Paint with over 8192
      drawRect(canvas, b.x, b.y, width, height, colorList[12]);
    }
    // Paint nextBlock border
    drawRectStroke(canvas, b.x, b.y, width, height, Colors.pink[200], 3);
    // Paint nextBlock text
    double textX = b.x + 21 - b.v.toString().length * 5;
    if (b.v < 8192) {
      drawText(canvas, b.v.toString(), Colors.black, getX(22), textX, b.y + 12);
    } else {
      drawText(canvas, b.v.toString(), Colors.black, getX(22), textX, b.y + 12);
    }
  }

  void drawBlock(Canvas canvas, Block b) {
    double width = 68;
    double height = 68;

    if (log2(b.v.toDouble()) - 1 < 12) {
      // Paint within 8192
      drawRect(canvas, b.x, b.y, width, height,
          colorList[log2(b.v.toDouble()).toInt() - 1]);
    } else {
      // paint with over 8192
      drawRect(canvas, b.x, b.y, width, height, colorList[12]);
    }
    // Paint border
    drawRectStroke(canvas, b.x, b.y, width, height, Colors.black, 4);

    // Paint block text
    double textX = b.x + 24 - b.v.toString().length * 5;
    drawText(canvas, b.v.toString(), Colors.black, getX(27), textX, b.y + 15);
  }

  int getMaxTrack() {
    List<int> elems = [];
    for (int i = 0; i < 5; i++) {
      elems.add(blocks[i].length);
    }
    return elems.indexOf(elems.reduce(max));
  }

  // super power of column clearance
  void superVert(Canvas canvas) {
    int maxTrack = getMaxTrack();
    for (int i = 1; i < 16; i++) {
      loadUiImage("vid/power1/power1_000" + sprintf("%02d", i) + ".png")
          .then((value) => vid1.add(value));
      drawVideo(Paint(), canvas, vid1, getX(blocks[maxTrack][0].x - 220),
          getY(blocks[maxTrack][0].y - 367), getX(500), getX(500));
    }
    blocks.remove(blocks[maxTrack]);
    blocks.insert(maxTrack - 1, []);
  }

  // super power of horizontal lines
  void superHor(Canvas canvas) {
    for (int i = 1; i < 20; i++) {
      loadUiImage("vid/power2/power2_000" + sprintf("%02d", i) + ".png")
          .then((value) => vid1.add(value));
      drawVideo(
          Paint(), canvas, vid1, getX(-350), getY(50), getX(500), getX(500));
    }
    for (int i = 0; i < 5; i++) {
      blocks[i].remove(blocks[i][0]);
      for (int j = 0; j < blocks[i].length; j++) {
        blocks[i][j].y += getY(70);
      }
    }
  }

  void dropAboveBlocks(int x, int y) {
    if (blocks[x].length > 0) {
      for (int i = 0; i < blocks[x].length; i++) {
        blocks[x][i].v = blocks[x][i + 1].v;
      }
      blocks[x]
          .removeWhere((element) => element == blocks[x][blocks[x].length - 1]);
    }
  }

  @override
  void onTapDown(TapDownDetails event) {
    print("Player tap down on ${event.globalPosition}");
    xAxis = event.globalPosition.dx;
    yAxis = event.globalPosition.dy;
    double x = event.globalPosition.dx;
    double y = event.globalPosition.dy;
    // pause event
    if (inRange(x, getX(50), getX(95)) && inRange(y, getY(685), getY(730))) {
      pause = !pause;
      if (pause) {
        Flame.bgm.pause();
      } else {
        Flame.bgm.resume();
      }
    }
    if (inRange(x, getX(402), getX(437)) && inRange(y, getY(83), getY(118))) {
      mute = !mute;
      if (mute) {
        Flame.bgm.pause();
      } else {
        Flame.bgm.resume();
      }
    }
  }

  @override
  void update(double t) {}

  @override
  void resize(Size size) {
    screenSize = size;
    super.resize(size);
  }
}
