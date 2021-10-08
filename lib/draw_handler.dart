// @dart=2.11
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sprintf/sprintf.dart';
import 'package:dropthenumber/dropthenumber.dart';
import 'package:dropthenumber/block.dart';
import 'package:dropthenumber/superpower_status.dart';

class DrawHandler {
  /**********************************************************************
  * Settings
  **********************************************************************/
  // Every block color in different value of block.
  List<Color> blockColors = [
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

  /**********************************************************************
  * Constructor
  **********************************************************************/
  DrawHandler() {}

  // Frame delay gap function
  Future<void> delayGap() {
    return Future.delayed(Duration(milliseconds: 100));
  }

  /**********************************************************************
  * Convert the relative x to ablolute x.
  **********************************************************************/
  double toAbsoluteX(double x) => x * canvasSize.width / 100;

  /**********************************************************************
  * Convert the relative y to ablolute y.
  **********************************************************************/
  double toAbsoluteY(double y) => y * canvasSize.height / 100;

  /**********************************************************************
  * Set the canvas to draw.
  **********************************************************************/
  // The canvas that the draw handler want to draw on.
  Canvas canvas;

  void setCanvas(Canvas canvas) {
    this.canvas = canvas;
  }

  /**********************************************************************
  * Set the size to draw, that everything will draw in correct relative size.
  * Should called to get the current screen size before every draw method invoke.
  **********************************************************************/
  // The screen size, needed by the drawBackground().
  Size screenSize;
  // The draw area size. (Background image is not in this limit)
  Size canvasSize;
  // The left margin of canvas, prevent the screen stretch. (This is already in absolute coordinates)
  double canvasXOffset;

  void setSize(Size screenSize, Size canvasSize, double canvasXOffset) {
    this.screenSize = screenSize;
    this.canvasSize = canvasSize;
    this.canvasXOffset = canvasXOffset;
  }

  /**********************************************************************
  * Initial the draw handler if it is not initialized.
  * DrawHandler should be initial before the first use.
  **********************************************************************/
  /* Settings */
  // Picture count of horizontal superpower Animation
  static const int horizontalSuperpowerAnimationLength = 86; // full is 215
  // Picture count of vertical superpower Animation
  static const int verticalSuperpowerAnimationLength = 15; // full is 67

  /* Variable */
  // If draw handler is initialized. (Use by tryToInit(), after initialized image and video are loaded.)
  bool initialized = false;

  void tryToInit() {
    if (!initialized) {
      initImages();
      initHorizontalSuperpowerAnimation(horizontalSuperpowerAnimationLength);
      initVerticalSuperpowerAnimation(verticalSuperpowerAnimationLength);
      initialized = true;
    }
  }

  /**********************************************************************
  * Initial images like music image, backgroundImage, etc.
  * Remember to add the path to "pubspec.yaml' or the resource may not show up.
  **********************************************************************/
  /* Image which will be load later */
  // Start Page
  ui.Image startPageBackgroundImage;
  ui.Image startPageTitleBorderImage;
  ui.Image startPageButtonBorderImage;
  ui.Image startPageMusicImage;
  ui.Image startPageMuteImage;
  ui.Image startPageVolumeUpImage;
  ui.Image startPageVolumeDownImage;
  // In Game
  ui.Image backgroundImage;
  ui.Image overImage;
  ui.Image exitImage;
  ui.Image musicImage;
  ui.Image muteImage;
  ui.Image startButtonImage;
  ui.Image startButtonBorderImage;
  ui.Image pauseImage;
  ui.Image playImage;
  ui.Image horizontalSuperpowerImage;
  ui.Image verticalSuperpowerImage;
  ui.Image tmpVertImage;
  ui.Image homeImage;

  void initImages() {
    // Start page
    loadUiImage("assets/image/startPage/background.png")
        .then((value) => startPageBackgroundImage = value);
    loadUiImage("assets/image/startPage/titleBorder.png")
        .then((value) => startPageTitleBorderImage = value);
    loadUiImage("assets/image/startPage/buttonBorder.png")
        .then((value) => startPageButtonBorderImage = value);
    loadUiImage("assets/image/startPage/music.png")
        .then((value) => startPageMusicImage = value);
    loadUiImage("assets/image/startPage/mute.png")
        .then((value) => startPageMuteImage = value);
    loadUiImage("assets/image/startPage/volumeUp.png")
        .then((value) => startPageVolumeUpImage = value);
    loadUiImage("assets/image/startPage/volumeDown.png")
        .then((value) => startPageVolumeDownImage = value);
    // Game
    loadUiImage("assets/image/background.jpg")
        .then((value) => backgroundImage = value);
    loadUiImage("assets/image/music.png").then((value) => musicImage = value);
    loadUiImage("assets/image/mute.png").then((value) => muteImage = value);
    loadUiImage("assets/image/pause.png").then((value) => pauseImage = value);
    loadUiImage("assets/image/play.png").then((value) => playImage = value);
    loadUiImage("assets/image/horizontalSuperpower.png")
        .then((value) => horizontalSuperpowerImage = value);
    loadUiImage("assets/image/verticalSuperpower.png")
        .then((value) => verticalSuperpowerImage = value);
    loadUiImage("assets/image/startButton.png")
        .then((value) => startButtonImage = value);
    loadUiImage("assets/image/startButtonBorder.png")
        .then((value) => startButtonBorderImage = value);
    loadUiImage("assets/image/exit.png").then((value) => exitImage = value);
    loadUiImage("assets/image/home.png").then((value) => homeImage = value);
    loadUiImage("assets/image/gameover1.jpg")
        .then((value) => overImage = value);
  }

  /**********************************************************************
  * Initial vertical superpower animation.
  * The animation is combine by lots of (.png) files.
  **********************************************************************/
  List<ui.Image> horizontalSuperpowerAnimation = [];

  void initHorizontalSuperpowerAnimation(
      int horizontalSuperpowerAnimationLength) {
    for (int i = 68; i < horizontalSuperpowerAnimationLength; i++) {
      loadUiImage("assets/video/horizontalSuperpower/" + i.toString() + ".png")
          .then((value) => horizontalSuperpowerAnimation.add(value));
    }
  }

  /**********************************************************************
  * Initial vertical superpower animation.
  * The animation is combine by lots of (.png) files.
  **********************************************************************/
  List<ui.Image> verticalSuperpowerAnimation = [];

  void initVerticalSuperpowerAnimation(int verticalSuperpowerAnimationLength) {
    for (int i = 0; i < verticalSuperpowerAnimationLength; i++) {
      loadUiImage("assets/video/verticalSuperpower/" + i.toString() + ".png")
          .then((value) => verticalSuperpowerAnimation.add(value));
    }
  }

  /**********************************************************************
  * Draw the screen before the game start.
  * The screen will only show once when the game start.
  **********************************************************************/
  void drawStartPageScreen() {
    drawFullScreenImage(startPageBackgroundImage);
    drawText2('2048 V.2', 50, 3, Colors.white, 60);
    drawText2('START', 52, 30.5, Colors.white, 38);
    drawImage(startPageVolumeUpImage, 87, 80, 12, 8);
    drawImage(startPageVolumeDownImage, 87, 90, 12, 8);
    drawImage(startPageButtonBorderImage, 32, 27.5, 40, 22);
    drawImage(startPageTitleBorderImage, 0, -5.5, 100, 28);
    drawImage(exitImage, 2, 91.3, 10, 7);
  }

  /**********************************************************************
  * Draw music button on the start page.
  **********************************************************************/
  void drawStartPageMusicButton() {
    drawImage(startPageMusicImage, 89, 71, 8.5, 6.5);
  }

  /**********************************************************************
  * Draw mute button on the start page.
  **********************************************************************/
  void drawStartPageMuteButton() {
    drawImage(startPageMuteImage, 89, 71, 8.5, 6.5);
  }

  /**********************************************************************
  * Draw the game background.
  **********************************************************************/
  void drawBackground() {
    drawFullScreenImage(backgroundImage);
  }

  /**********************************************************************
  * Draw all the borders.
  **********************************************************************/
  void drawBorders() {
    // Biggest border
    drawRectStroke(10, 5, 80, 85, Colors.white, 10);
    // Middle border
    drawRectStroke(15, 23, 70, 64, Colors.white, 5);

    // Draw three horizontal lines. (top to bottom)
    drawLine(10, 14, 90, 14, Colors.white, 5);
    drawLine(10, 20, 90, 20, Colors.white, 5);
    drawLine(15, 30, 85, 30, Colors.white, 5);

    // Draw four vertical lines. (left to right)
    for (double i = 1; i < 5; i++) {
      double x = 15 + (i * 14);
      drawLine(x, 23, x, 87, Colors.white, 5);
    }
  }

  /**********************************************************************
  * Draw game title text on the canvas. (The big text on the top)
  * The title color are the same as the color of next block rectangle.
  **********************************************************************/
  void drawTitle(int nextBlockValue) {
    drawText(
        'Drop The Number', 50, 6.5, getBlockColorByValue(nextBlockValue), 35);
  }

  /**********************************************************************
  * Draw next block hint on the canvas.
  **********************************************************************/
  void drawNextBlockHintText() {
    drawText('Next Block >', 25, 15.5, Colors.white, 17);
  }

  /**********************************************************************
  * Draw "nextBlock" on the canvas.
  **********************************************************************/
  void drawNextBlock(int nextBlockValue) {
    // Draw nextBlock rectangle
    drawRect(40, 14.5, 8, 5, getBlockColorByValue(nextBlockValue));
    // Draw nextBlock border
    drawRectStroke(40, 14.5, 8, 5, Colors.pink[200], 3);
    // Paint nextBlock text
    drawText(nextBlockValue.toString(), 44, 16, Colors.black, 14);
  }

  /**********************************************************************
  * Draw the game elapsed time on the canvas.
  **********************************************************************/
  void drawTime(Duration elapsedTime) {
    if (elapsedTime == null) {
      return;
    }
    drawText('TIME:' + getTimeformat(elapsedTime), 64, 15.5, Colors.white, 20);
  }

  /**********************************************************************
  * Draw mute button.
  **********************************************************************/
  void drawMuteButton() {
    drawImage(muteImage, 80, 15, 7, 4.5);
  }

  /**********************************************************************
  * Draw music button.
  **********************************************************************/
  void drawMusicButton() {
    drawImage(musicImage, 80, 15, 7, 4.5);
  }

  /**********************************************************************
  * Draw five cross on the canvas. (On the five track)
  **********************************************************************/
  void drawFiveCross(int nextBlockValue) {
    for (double i = 0; i < 5; i++) {
      drawText(
          '†', 22 + i * 14, 22.5, getBlockColorByValue(nextBlockValue), 49);
    }
  }

  /**********************************************************************
  * Draw all the blocks from block array to canvas.
  **********************************************************************/
  void drawAllBlocks(List<List<Block>> blocks) {
    for (List<Block> linesOfBlocksY in blocks) {
      for (Block block in linesOfBlocksY) {
        drawBlock(block);
      }
    }
  }

  /**********************************************************************
  * Draw current dropping block.
  **********************************************************************/
  void drawCurrentBlock(Block currentBlock) {
    drawBlock(currentBlock);
  }

  /**********************************************************************
  * Draw pause image.
  **********************************************************************/
  void drawPauseButton() {
    // Pause button image
    drawImage(pauseImage, 12, 93.5, 4, 3);
    // Pause button border
    drawRectStroke(9, 92.5, 10, 5, Colors.white, 3);
  }

  /**********************************************************************
  * Draw play image.
  **********************************************************************/
  void drawPlayButton() {
    // Play button image
    drawImage(playImage, 11.5, 93.25, 5, 3.5);
    drawImage(startButtonImage, 30.5, 37.25, 40, 26);
    drawImage(startButtonBorderImage, 30.5, 37.25, 40, 26);
    // Play button border
    drawRectStroke(9, 92.5, 10, 5, Colors.white, 3);
  }

  /**********************************************************************
  * Draw the current score.
  **********************************************************************/
  void drawScore(int score) {
    drawText('Score: ', 30, 92.5, Colors.white, 27);
    drawText(score.toString(), 60, 93, Colors.white, 26);
  }

  /**********************************************************************
  * Draw horizontal superpower button.
  **********************************************************************/
  void drawHorizontalSuperpowerButton() {
    // Horizontal superpower image
    drawImage(horizontalSuperpowerImage, 70, 92, 9, 6);
    // Horizontal superpower border
    drawRectStroke(70, 92.5, 9, 5, Colors.white, 3);
  }

  /**********************************************************************
  * Draw vertical superpower button.
  **********************************************************************/
  void drawVerticalSuperpowerButton() {
    // Vertical superpower image
    drawImage(verticalSuperpowerImage, 81.5, 91.25, 10, 7);
    // Vertical superpower border
    drawRectStroke(82, 92.5, 9, 5, Colors.white, 3);
  }

  /**********************************************************************
  * Draw the game over screen.
  **********************************************************************/
  void drawGameOverScreen(int score, int highestScore, Duration elapsedTime) {
    drawFullScreenImage(overImage);
    drawText2("Game Over", 50, 15, Colors.white, 65);
    if (elapsedTime == null) {
      elapsedTime = Duration();
    }
    drawText2("TIME: " + getTimeformat(elapsedTime), 49, 35, Colors.white, 40);
    drawText2(
        "Highest Score: " + highestScore.toString(), 50, 45, Colors.white, 40);
    drawText2("Your Score: " + score.toString(), 45, 55, Colors.white, 40);
    drawImage(startPageButtonBorderImage, 18.5, 66, 33, 19);
    drawText2("Restart", 34.5, 68.5, Colors.white, 33);
    drawImage(startPageButtonBorderImage, 50.5, 66, 33, 19);
    drawText2("Quit", 66, 68.5, Colors.white, 33);
    drawImage(homeImage, 1, 91.5, 12, 8);
  }

  /**********************************************************************
  * Format the time from second to minute and second.
  **********************************************************************/
  String getTimeformat(Duration totalSecond) {
    return sprintf("%02d:%02d",
        [totalSecond.inSeconds ~/ 60, (totalSecond.inSeconds % 60).toInt()]);
  }

  /**********************************************************************
  * Draw the current dropping block on the canvas.
  * Block size is (14, 9).
  **********************************************************************/
  void drawBlock(Block block) {
    // If block value is zero, ignore the block.
    if (block.v == 0) {
      return;
    }
    double width = 14;
    double height = 9;

    // Draw block color
    drawRect(block.x, block.y, width, height, getBlockColorByValue(block.v));

    // Draw border
    drawRectStroke(block.x, block.y, width, height, Colors.black, 4);

    // Draw block text
    drawText(block.v.toString(), block.x + width / 2, block.y + height / 2 - 2,
        Colors.black, 20);
  }

  /**********************************************************************
  * Draw a single frame of horizontal superpower animation. (glow animation)
  **********************************************************************/
  /* Settings */
  // Add extra width to horizontal superpower animation.
  double horizontalSuperpowerExtraWidth = 25;
  // Add extra height to horizontal superpower animation.
  double horizontalSuperpowerExtraHeight = 5;
  // Adjust the x coordinate of horizontal superpower animation.
  double horizontalSuperpowerXOffset = -25;
  // Adjust the y coordinate of horizontal superpower animation.
  double horizontalSuperpowerYOffset = 0;

  void drawHorizontalSuperpowerAnimationImage(int animationFrameIndex) {
    double imageHeight = 30;
//     drawImage(horizontalSuperpowerAnimation[animationFrameIndex], 15.0, 90 - imageHeight, 85, imageHeight);
    drawImage(
        horizontalSuperpowerAnimation[animationFrameIndex],
        15.0 + horizontalSuperpowerXOffset,
        83 - imageHeight + horizontalSuperpowerYOffset,
        100 + horizontalSuperpowerExtraWidth,
        imageHeight + horizontalSuperpowerExtraHeight);
  }
//   void playHorizontalSuperpowerAnimation() async {
//     double x = 50, y = 50, width = 250, height = 250;
//     for (int i = 1; i < 100; i++) {
//       ui.Image tmpHorImg =
//           await loadUiImage("assets/video/horizontalSuperpower/" + i.toString() + ".png");
//       canvas.drawImageRect(
//           tmpHorImg,
//           Rect.fromLTWH(
//               0, 0, tmpHorImg.width.toDouble(), tmpHorImg.height.toDouble()),
//           Rect.fromLTWH(toAbsoluteX(x), toAbsoluteY(y), width, height),
//           Paint());
//
//       /* await delayGap(); */
//       print("load pic " + i.toString());
//       print(tmpHorImg.height);
//       print(tmpHorImg.width);
//     }
//   }

  /**********************************************************************
  * Draw a single frame of vertical superpower animation. (flame animation)
  **********************************************************************/
  /* Settings */
  // Add extra width to vertical superpower animation.
  double verticalSuperpowerExtraWidth = 40;
  // Add extra height to vertical superpower animation.
  double verticalSuperpowerExtraHeight = 0;
  // Adjust the x coordinate of vertical superpower animation.
  double verticalSuperpowerXOffset = -20;
  // Adjust the y coordinate of vertical superpower animation.
  double verticalSuperpowerYOffset = 0;

  void drawVerticalSuperpowerAnimationImage(
      int animationFrameIndex, int track) {
    double imageHeight = 60;
//     drawImage(verticalSuperpowerAnimation[animationFrameIndex], 15.0 + 14 * track, 90 - imageHeight, 14, imageHeight);
    drawImage(
        verticalSuperpowerAnimation[animationFrameIndex],
        4.7 + 14 * track + verticalSuperpowerXOffset,
        90 - imageHeight + verticalSuperpowerYOffset,
        34 + verticalSuperpowerExtraWidth,
        imageHeight + verticalSuperpowerExtraHeight);
  }

//   void playVerticalSuperpowerAnimation(
//       int track, List<List<Block>> blocks) async {
//     double a = 5, b = 2, width = 400, height = 600;
//     for (int i = 1; i < 68; i++) {
//       ui.Image tmpVertImg =
//           await loadUiImage("assets/video/verticalSuperpower/" + i.toString() + ".png");
//
//       canvas.drawImageRect(
//           tmpVertImage,
//           Rect.fromLTWH(0, 0, tmpVertImage.width.toDouble(),
//               tmpVertImage.height.toDouble()),
//           Rect.fromLTWH(toAbsoluteX(a), toAbsoluteY(b), width, height),
//           Paint());
//       /* delayGap(); */
//     }
//     /*
//     drawVideo(verticalSuperpowerVideo, blocks[track][0].x - 5,
//         blocks[track][0].y - 50, 300, 300);
//     */
//   }

  /**********************************************************************
  * Draw the horizontal cooldown hint overlap the button.
  **********************************************************************/
  void drawBlockedHorizontalSuperpower() {
    drawText("X", 74.5, 91, Colors.black, 55);
    drawRectStroke(70, 92.5, 9, 5, Colors.black, 3);
  }

  /**********************************************************************
  * Draw the vertical cooldown hint overlap the button.
  **********************************************************************/
  void drawBlockedVerticalSuperpower() {
    drawText("X", 86.5, 91, Colors.black, 55);
    drawRectStroke(82, 92.5, 9, 5, Colors.black, 3);
  }

  /**********************************************************************
  * Load an image from the given path.
  **********************************************************************/
  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  /**********************************************************************
  * Get block color by given block value.
  **********************************************************************/
  Color getBlockColorByValue(int value) {
    if (value == 0) {
      return Color.fromRGBO(0, 0, 0, 0.0);
    }
    return getBlockColorByIndex((log(value) / log(2)).toInt() - 1);
  }

  /**********************************************************************
  * Get block color by index of blockColors.
  * If it is out of defined color, it will warp to the beginning.
  * For example: color1, color2, color3, color1, color2, etc.
  **********************************************************************/
  Color getBlockColorByIndex(int index) {
    return blockColors[index % blockColors.length];
  }

  /**********************************************************************
  * Draw a rectangle on the canvas.
  **********************************************************************/
  void drawRect(double x, double y, double width, double height, Color color) {
    Rect rect = Rect.fromLTWH(toAbsoluteX(x) + canvasXOffset, toAbsoluteY(y),
        toAbsoluteX(width), toAbsoluteY(height));
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  /**********************************************************************
  * Draw a rectangle but only stroke on the canvas.
  **********************************************************************/
  void drawRectStroke(double x, double y, double width, double height,
      Color color, double strokeWidth) {
    Rect rect = Rect.fromLTWH(toAbsoluteX(x) + canvasXOffset, toAbsoluteY(y),
        toAbsoluteX(width), toAbsoluteY(height));
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRect(rect, paint);
  }

  void drawRectStroke2(double x, double y, double width, double height,
      Color color, double strokeWidth) {
    Rect rect = Rect.fromLTWH(toAbsoluteX(x) + canvasXOffset, toAbsoluteY(y),
        toAbsoluteX(width), toAbsoluteY(height));
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    Container(
      // padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 16.0, color: Colors.lightBlue.shade50),
          bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
        ),
      ),
    );
    canvas.drawRect(rect, paint);
  }

  /**********************************************************************
  * Draw a line on the canvas by the given start point (x1, y1) and end point (x2, y2).
  **********************************************************************/
  void drawLine(double x1, double y1, double x2, double y2, Color color,
      double strokeWidth) {
    Offset p1 = Offset(toAbsoluteX(x1) + canvasXOffset, toAbsoluteY(y1));
    Offset p2 = Offset(toAbsoluteX(x2) + canvasXOffset, toAbsoluteY(y2));
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    canvas.drawLine(p1, p2, paint);
  }

  /**********************************************************************
  * Draw a text on the canvas.
  * The x and y are coordinate the text center.
  **********************************************************************/
  void drawText(String text, double x, double y, Color color, double fontSize) {
    TextPainter(
      text: TextSpan(
          text: text, style: TextStyle(color: color, fontSize: fontSize)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )
      ..layout(minWidth: canvasSize.width, maxWidth: canvasSize.width)
      ..paint(
          canvas,
          Offset(toAbsoluteX(x) - (canvasSize.width / 2) + canvasXOffset,
              toAbsoluteY(y)));
  }

  void drawText2(
      String text, double x, double y, Color color, double fontSize) {
    TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontFamily: 'DancingScript',
            shadows: [
              Shadow(
                color: Colors.deepPurple,
                blurRadius: 12.0,
                offset: Offset(-5.0, 5.0),
              ),
              Shadow(
                color: Colors.white,
                blurRadius: 12.0,
                offset: Offset(10.0, 5.0),
              ),
            ],
          )),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )
      ..layout(minWidth: canvasSize.width, maxWidth: canvasSize.width)
      ..paint(
          canvas,
          Offset(toAbsoluteX(x) - (canvasSize.width / 2) + canvasXOffset,
              toAbsoluteY(y)));
  }

  /**********************************************************************
  * Draw an image on the canvas.
  **********************************************************************/
  void drawImage(
      ui.Image image, double x, double y, double width, double height) {
    if (image == null) {
      return;
    }
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(toAbsoluteX(x) + canvasXOffset, toAbsoluteY(y),
            toAbsoluteX(width), toAbsoluteY(height)),
        Paint());
  }

  /**********************************************************************
  * Draw an full screen image on the canvas.
  **********************************************************************/
  void drawFullScreenImage(ui.Image image) {
    if (image == null) {
      return;
    }
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(-0.5, -0.5, screenSize.width + 1, screenSize.height + 1), // draw a little bit more to make sure the picture cover whole screen.
        Paint());
  }
}
