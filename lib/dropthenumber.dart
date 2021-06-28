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
<<<<<<< HEAD
    // draw box
    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;
    Rect boxRect =
        Rect.fromLTWH(screenCenterX - 75, screenCenterY - 75, 150, 150);
    Paint boxPaint = Paint();
    boxPaint.color = Color(0xffffffff);
    canvas.drawRect(boxRect, boxPaint);
=======
    // pygame.draw.rect(screen, white, (50,25,400,650), 5)
    Rect Rect1 = Rect.fromLTWH(screenSize.width / 10, screenSize.height / 30,
        screenSize.width * 4 / 5, screenSize.height * 650 / 750);
    Paint rect1Paint = Paint();
    rect1Paint.color = Color(0xffffffff);
    canvas.drawRect(Rect1, rect1Paint);
    // pygame.draw.lines(screen, white, True,[(50,75), (450,75)],5)

    // pygame.draw.lines(screen, white, True,[(50,125),(450,125)],5)
    // pygame.draw.lines(screen, white, True,[(75,220),(425,220)],5)
>>>>>>> 8cf70f367398f9e6a8c7db777accf710d46e336f
  }

  void update(double t) {}

  void resize(Size size) {
    screenSize = size;
    super.resize(size);
  }
}
