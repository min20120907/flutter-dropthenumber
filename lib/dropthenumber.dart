// @dart=2.11

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DropTheNumber extends Game {
  Size screenSize;
  ui.Image img;
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

    //draw three horizontal lines
    drawLine(Colors.white, canvas, 50, 90, 450, 90, 5);
    drawLine(Colors.white, canvas, 50, 140, 450, 140, 5);
    drawLine(Colors.white, canvas, 75, 235, 425, 235, 5);
    // draw five vertical lines
    for (double i = 0; i < 5; i++)
      drawLine(Colors.white, canvas, 75 + i * 70, 165, 75 + i * 70, 665, 5);
    //draw text
    drawText(canvas, '2048v2', 100, -250, 70);
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

  void drawText(Canvas canvas, String text, double fontSize, double x, double y) {
    TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.white, fontSize: fontSize)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )
      ..layout(minWidth: screenSize.height, maxWidth: screenSize.height)
      ..paint(canvas,
          // Offset(screenSize.width * x / 500, screenSize.height * y / 750));
          Offset(0,0));
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

  void update(double t) {}

  void resize(Size size) {
    screenSize = size;
    super.resize(size);
  }
}
