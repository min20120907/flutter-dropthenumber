// @dart=2.11

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sprintf/sprintf.dart';


Random random = new Random();
int randomNumber = random.nextInt(13);

class DropTheNumber extends Game {
  bool pause = false;
  double score = 0;
  Size screenSize;
  bool lastLoopPaused=false;
  DateTime startTime=DateTime.now();
  Duration stopTimeText;
  DateTime startTimeOfPause;
  Duration duration;
  DateTime cooldown_time_hor;
  DateTime cooldown_time_vert;
  Duration pauseDuration;
  ui.Image img;
  double log2(double x) => log(x) / log(2);
  int a = pow(2, randomNumber);
  // colorlist
  var colorList = [
    Color.fromRGBO(255, 0, 0, 0),
    Color.fromRGBO(0, 255, 0, 0),
    Color.fromRGBO(204, 153, 255, 0),
    Color.fromRGBO(209, 237, 0, 0),
    Color.fromRGBO(209, 237, 240, 0),
    Color.fromRGBO(209, 40, 240, 0),
    Color.fromRGBO(254, 239, 222, 0),
    Color.fromRGBO(0, 239, 222, 0),
    Color.fromRGBO(255, 255, 80, 0),
    Color.fromRGBO(51, 102, 255, 0),
    Color.fromRGBO(255, 204, 164, 0),
    Color.fromRGBO(153, 255, 153, 0),
    Color.fromRGBO(194, 194, 214, 0)
  ];
  @override
  void render(Canvas canvas) {
    // draw background
    drawImage(Paint(), canvas, "/img/bg3.jpg", 0, 0, screenSize.width,
        screenSize.height);

    Rect Rect1 = Rect.fromLTWH(screenSize.width / 10, screenSize.height / 20,
        screenSize.width * 4 / 5, screenSize.height * 650 / 750);

    Paint rect1Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawRect(Rect1, rect1Paint);

    Rect Rect2 = Rect.fromLTWH(
        screenSize.width * 75 / 500,
        screenSize.height * 45 / 202,
        screenSize.width * 35 / 50,
        screenSize.height * 50 / 75);

    Paint rect2Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawRect(Rect2, rect2Paint);

    Rect Rect3 = Rect.fromLTWH(
        screenSize.width * 180 / 450,
        screenSize.height * 81 / 630,
        screenSize.width * 45 / 500,
        screenSize.height * 37 / 750);

    Paint rect3Paint = Paint()
      ..color = Colors.pink[200]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(Rect3, rect3Paint);

    Rect Rect5 = Rect.fromLTWH(
        screenSize.width * 55 / 590,
        screenSize.height * 685 / 730,
        screenSize.width * 40 / 500,
        screenSize.height * 32 / 750);

    Paint rect5Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(Rect5, rect5Paint);

    Rect Rect4 = Rect.fromLTWH(
        screenSize.width * 350 / 490,
        screenSize.height * 685 / 730,
        screenSize.width * 40 / 500,
        screenSize.height * 32 / 750);

    Paint rect4Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(Rect4, rect4Paint);

    Rect Rect6 = Rect.fromLTWH(
        screenSize.width * 405 / 490,
        screenSize.height * 685 / 730,
        screenSize.width * 40 / 500,
        screenSize.height * 32 / 750);

    Paint rect6Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(Rect6, rect6Paint);

    //draw three horizontal lines
    drawLine(Colors.white, canvas, 50, 90, 450, 90, 5);
    drawLine(Colors.white, canvas, 50, 140, 450, 140, 5);
    drawLine(Colors.white, canvas, 75, 235, 425, 235, 5);
  
    // draw five vertical lines
    for (double i = 0; i < 5; i++)
      drawLine(Colors.white, canvas, 75 + i * 70, 165, 75 + i * 70, 665, 5);

    //draw text
    drawText(canvas, 'Drop', Colors.red, 30, 215, 48);
    drawText(canvas, 'Next Block ►', Colors.pink, 18, 60, 103);
    drawText(canvas, 'Score:' + score.toString(), Colors.white, 27, 100, 703);
    for (double i = 0; i < 5; i++)
      drawText(canvas, '†', Colors.red, 50, 90 + i * 70, 170);
   drawTime(canvas);
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
  //Format the time from second to minute and second
String getTimeformat(Duration totalSecond){
    return sprintf("%02d:%02d", [totalSecond.inSeconds/60, totalSecond.inSeconds%60]);
}

void drawTime(Canvas canvas){
    if (lastLoopPaused != pause){
        if (pause){
            startTimeOfPause = DateTime.now();
        }
        else{
            pauseDuration = DateTime.now().difference(startTimeOfPause);
            
            // Stop horizontal super skill cooldown when puase
            if (cooldown_time_hor != null){
                cooldown_time_hor.add(pauseDuration);
            }
            // Stop vertical super skill cooldown when puase
            if (cooldown_time_vert != null){
                cooldown_time_vert.add(pauseDuration);
            }
            // Change start time of the game which use to count the timer 'arial.ttf'
            startTime.add(pauseDuration);
          }
    lastLoopPaused = pause;
    }
    if (pause){
        drawText(canvas,'►',Colors.white,28,61,692);
        duration = stopTimeText;
    }
    else{
        drawText(canvas,'II',Colors.white,28,63,692);
        duration = DateTime.now().difference(startTime);
        stopTimeText = duration;
    }
    drawText(canvas,'TIME:'+getTimeformat(duration),Colors.black,20,275,91); //display clock
}
  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void drawImage(Paint p, Canvas canvas, String imgPath, double x, double y,
      double sx, double sy) {
    loadUiImage("img/bg3.jpg").then((value) => this.img = value);

    canvas.drawImageRect(
        this.img,
        Rect.fromLTWH(screenSize.width * x / 500, screenSize.height * y / 750,
            img.width.toDouble(), img.height.toDouble()),
        Rect.fromLTWH(screenSize.width * x / 500, y, sx, sy),
        p);
  }

  @override
  void update(double t) {}

  @override
  void resize(Size size) {
    screenSize = size;
    super.resize(size);
  }
}
