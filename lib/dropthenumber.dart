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

class DropTheNumber extends Game with TapDetector {
  List<List<Block>> blocks = [[]];
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
  ui.Image img1, img2, img3, img4;
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
      drawImage(
          Paint(), canvas, img1, 0, 0, screenSize.width, screenSize.height);
      // draw mute
      if (mute) {
        loadUiImage("img/mute-2.png").then((value) => img2 = value);
        drawImage(new Paint(), canvas, img2, 399, 98, getX(40), getX(40));
      } else {
        loadUiImage("img/mute-1.png").then((value) => img2 = value);
        drawImage(new Paint(), canvas, img2, 399, 98, getX(40), getX(40));
      }
      // draw superpower horizontal
      loadUiImage("img/fire-4.png").then((value) => img3 = value);
<<<<<<< HEAD
      drawImage(Paint(), canvas, img3, 403, 685, getX(59), getY(60));
=======
      drawImage(Paint(), canvas, img3, 402, 685, getX(59), getX(60));
>>>>>>> 06c39c7fe17eb333aa255edb03efa9f995574203
      // draw superpower vertical
      loadUiImage("img/vertical-2.png").then((value) => img4 = value);
      drawImage(Paint(), canvas, img4, 350, 686, getX(50), getX(50));
      Rect rect1 = Rect.fromLTWH(screenSize.width / 10, screenSize.height / 20,
          screenSize.width * 4 / 5, screenSize.height * 650 / 750);

      Paint rect1Paint = Paint()
        ..color = Color(0xffffffff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10;
      canvas.drawRect(rect1, rect1Paint);

      Rect rect2 = Rect.fromLTWH(
          screenSize.width * 75 / 500,
          screenSize.height * 45 / 202,
          screenSize.width * 35 / 50,
          screenSize.height * 50 / 75);

      Paint rect2Paint = Paint()
        ..color = Color(0xffffffff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawRect(rect2, rect2Paint);

      Rect rect3 = Rect.fromLTWH(
          screenSize.width * 180 / 450,
          screenSize.height * 81 / 630,
          screenSize.width * 45 / 500,
          screenSize.height * 37 / 750);

      Paint rect3Paint = Paint()
        ..color = Colors.pink[200]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(rect3, rect3Paint);

      Rect rect5 = Rect.fromLTWH(
          screenSize.width * 55 / 590,
          screenSize.height * 685 / 730,
          screenSize.width * 40 / 500,
          screenSize.height * 32 / 750);

      Paint rect5Paint = Paint()
        ..color = Color(0xffffffff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(rect5, rect5Paint);

      Rect rect4 = Rect.fromLTWH(
          screenSize.width * 350 / 490,
          screenSize.height * 685 / 730,
          screenSize.width * 40 / 500,
          screenSize.height * 32 / 750);

      Paint rect4Paint = Paint()
        ..color = Color(0xffffffff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(rect4, rect4Paint);

      Rect rect6 = Rect.fromLTWH(
          screenSize.width * 405 / 490,
          screenSize.height * 685 / 730,
          screenSize.width * 40 / 500,
          screenSize.height * 32 / 750);

      Paint rect6Paint = Paint()
        ..color = Color(0xffffffff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(rect6, rect6Paint);

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
        drawText(canvas, '†', Colors.black, 50, 90 + i * 70, 170);
      drawTime(canvas);
    } else {
      int highest =
          99; //////////////////////////////////////////////////////////////////debug
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
    // draw superpower horizontal
    loadUiImage("img/fire-4.png").then((value) => img3 = value);
    drawImage(Paint(), canvas, img3, 402, 685, getX(54), getX(60));
    // draw superpower vertical
    loadUiImage("img/vertical-2.png").then((value) => img4 = value);
    drawImage(Paint(), canvas, img4, 350, 686, getX(50), getX(50));
    Rect rect1 = Rect.fromLTWH(screenSize.width / 10, screenSize.height / 20,
        screenSize.width * 4 / 5, screenSize.height * 650 / 750);

    Paint rect1Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawRect(rect1, rect1Paint);

    Rect rect2 = Rect.fromLTWH(
        screenSize.width * 75 / 500,
        screenSize.height * 45 / 202,
        screenSize.width * 35 / 50,
        screenSize.height * 50 / 75);

    Paint rect2Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawRect(rect2, rect2Paint);

    Rect rect3 = Rect.fromLTWH(
        screenSize.width * 180 / 450,
        screenSize.height * 81 / 630,
        screenSize.width * 45 / 500,
        screenSize.height * 37 / 750);

    Paint rect3Paint = Paint()
      ..color = Colors.pink[200]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect3, rect3Paint);

    Rect rect5 = Rect.fromLTWH(
        screenSize.width * 55 / 590,
        screenSize.height * 685 / 730,
        screenSize.width * 40 / 500,
        screenSize.height * 32 / 750);

    Paint rect5Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect5, rect5Paint);

    Rect rect4 = Rect.fromLTWH(
        screenSize.width * 350 / 490,
        screenSize.height * 685 / 730,
        screenSize.width * 40 / 500,
        screenSize.height * 32 / 750);

    Paint rect4Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect4, rect4Paint);

    Rect rect6 = Rect.fromLTWH(
        screenSize.width * 405 / 490,
        screenSize.height * 685 / 730,
        screenSize.width * 40 / 500,
        screenSize.height * 32 / 750);

    Paint rect6Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect6, rect6Paint);

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
      drawText(canvas, '†', Colors.black, 50, 90 + i * 70, 170);
    drawTime(canvas);
    drawBlock(canvas, Block(8, getX(200), getY(200)));
  }

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
      // ..layout(minWidth: screenSize.width, maxWidth: screenSize.width)
      ..layout(minWidth: screenSize.width, maxWidth: screenSize.width)
      ..paint(canvas,
          Offset(screenSize.width * x / 500, screenSize.height * y / 750));
  }

  void drawRect(Canvas canvas, double x, double y, double width, double height,
      Color color) {
    Rect rect = Rect.fromLTWH(getX(x), getY(y), getX(width), getX(height));

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  void drawRectStroke(Canvas canvas, double x, double y, double width,
      double height, Color color, double strokeWidth) {
    Rect rect = Rect.fromLTWH(getX(x), getY(y), getX(width), getX(height));

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

  void drawImage(Paint p, Canvas canvas, ui.Image img, double x, double y,
      double sx, double sy) {
    canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromLTWH(getX(x), getY(y), sx, sy),
        p);
  }

  void tryToPause() {
    if (!gameOver) {
      pause = !pause;
    }
  }

  void drawBlock(Canvas canvas, Block b) {
    Rect rect = Rect.fromLTWH(getX(b.x), getY(b.y), getX(68), getX(68));

    // paint with over 2048
    Paint rectPaint2 = Paint()
      ..color = this.colorList[12]
      ..style = PaintingStyle.fill;
    // border paint
    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    if (log2(b.v.toDouble()) - 1 < 12) {
      // Paint within 2048
      Paint rectPaint1 = Paint()
        ..color = this.colorList[log2(b.v.toDouble()).toInt() - 1]
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, rectPaint1);
      // print(colorList[log2(b.v.toDouble()).toInt()]);
    } else {
      canvas.drawRect(rect, rectPaint2);
      // print("greater 13");
    }
    canvas.drawRect(rect, borderPaint);
    double textX = b.x + 24 - b.v.toString().length * 5;
    if (b.v < 8192) {
      drawText(canvas, b.v.toString(), Colors.black, getX(27), textX, b.y + 15);
    } else {
      drawText(canvas, b.v.toString(), Colors.black, getX(27), textX, b.y + 15);
    }
  }

  @override
  void onTapDown(TapDownDetails event) {
    print("Player tap down on ${event.globalPosition}");
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
