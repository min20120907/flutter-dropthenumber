// @dart=2.11
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class DropTheNumber extends Game {
  Size screenSize = Size(500, 750);

  void render(Canvas canvas) {
    // draw background
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff000000);
    canvas.drawRect(bgRect, bgPaint);
    // pygame.draw.rect(screen, white, (50,25,400,650), 5)
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
    // pygame.draw.lines(screen, white, True,[(50,75), (450,75)],5)
    DrawLine(Colors.white, canvas, 50, 75, 450, 75, 5);
    // pygame.draw.lines(screen, white, True,[(50,125),(450,125)],5)
    DrawLine(Colors.white, canvas, 50, 125, 450, 125, 5);
    // pygame.draw.lines(screen, white, True,[(75,220),(425,220)],5)
    DrawLine(Colors.white, canvas, 75, 220, 425, 220, 5);
  }

  // ignore: non_constant_identifier_names
  void DrawLine(Color c, Canvas canvas, double p1x, double p1y, double p2x,
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

  void update(double t) {}

  void resize(Size size) {
    screenSize = size;
    super.resize(size);
  }
}
