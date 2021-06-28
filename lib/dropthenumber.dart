// @dart=2.11
import 'dart:ui';
import 'package:flame/game.dart';

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
    Paint rect1Paint = Paint();
    rect1Paint.color = Color(0xffffffff);
    canvas.drawRect(Rect1, rect1Paint);
  }

  void update(double t) {}

  void resize(Size size) {
    screenSize = size;
    super.resize(size);
  }
}
