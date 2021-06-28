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

    Rect Rect1 = Rect.fromLTWH(screenSize.width / 10, screenSize.height / 30,
        screenSize.width * 4 / 5, screenSize.height * 650 / 750);

    Paint rect1Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawRect(Rect1, rect1Paint);

    //pygame.draw.rect(screen, white, (75,150,350,500), 5)
    Rect Rect2 = Rect.fromLTWH(
        screenSize.width * 75 / 500,
        screenSize.height * 15 / 75,
        screenSize.width * 35 / 50,
        screenSize.height * 50 / 75);

    Paint rect2Paint = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawRect(Rect2, rect2Paint);
    //draw three horizontal lines
    drawLine(Colors.white, canvas, 50, 75, 450, 75, 5);
    drawLine(Colors.white, canvas, 50, 125, 450, 125, 5);
    drawLine(Colors.white, canvas, 75, 220, 425, 220, 5);
    // draw five vertical lines
    for (double i = 0; i < 5; i++)
      drawLine(Colors.white, canvas, 75 + i * 70, 150, 75 + i * 70, 650, 5);

    drawText(canvas, 'Hello world!', 10, 10);
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

  void drawText(Canvas canvas, String text, double x, double y) {
    TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.white)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )
      ..layout(minWidth: screenSize.height, maxWidth: screenSize.height)
      ..paint(canvas,
          Offset(screenSize.width * x / 500, screenSize.height * y / 750));
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
    // Image img = Image(image: AssetImage('img/bg3.jpg'));

    loadUiImage("img/bg3.jpg").then((value) {
      this.img = value;
    }).whenComplete(() => print("done"));

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
