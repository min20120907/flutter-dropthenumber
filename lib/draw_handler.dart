import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprintf/sprintf.dart';

import 'block.dart';
import 'game_difficulty.dart';

class DrawHandler {
  /// Block colors in different value
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

  DrawHandler() {}

  // Frame delay gap function
  Future<void> delayGap() {
    return Future.delayed(Duration(milliseconds: 100));
  }

  /// Convert the relative x to ablolute x.
  double toAbsoluteX(double x) => x * canvasSize.x / 100;

  /// Convert the relative y to ablolute y.
  double toAbsoluteY(double y) => y * canvasSize.y / 100;

  /**********************************************************************
  * Set the canvas to draw.
  **********************************************************************/
  // The canvas that the draw handler want to draw on.
  late Canvas canvas;

  void setCanvas(Canvas canvas) {
    this.canvas = canvas;
  }

  /**********************************************************************
  * Set the size to draw, that everything will draw in correct relative size.
  * Should called to get the current screen size before every draw method invoke.
  **********************************************************************/
  // The screen size, needed by the drawBackground().
  late Vector2 screenSize;
  // The draw area size. (Background image is not in this limit)
  late Vector2 canvasSize;
  // The left margin of canvas, prevent the screen stretch. (This is already in absolute coordinates)
  late double canvasXOffset;

  void setSize(Vector2 screenSize, Vector2 canvasSize, double canvasXOffset) {
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

  /// Initialize image and video
  void init() {
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
  // Home Page
  late ui.Image homePageBackgroundImage;
  late ui.Image homePageTitleBorderImage;
  late ui.Image homePageButtonBorderImage;
  late ui.Image homePageMusicImage;
  late ui.Image homePageMuteImage;
  late ui.Image homePageVolumeUpImage;
  late ui.Image homePageVolumeDownImage;
  // In Game
  late ui.Image backgroundImage;
  late ui.Image overImage;
  late ui.Image settingImage;
  late ui.Image settingBackgroundImage;
  late ui.Image exitImage;
  late ui.Image musicImage;
  late ui.Image muteImage;
  late ui.Image startButtonImage;
  late ui.Image startButtonBorderImage;
  late ui.Image pauseImage;
  late ui.Image playImage;
  late ui.Image horizontalSuperpowerImage;
  late ui.Image verticalSuperpowerImage;
  late ui.Image tmpVertImage;
  late ui.Image homeImage;
  late ui.Image xImage;
  late ui.Image arrowImage;

  void initImages() {
    // Home page
    loadUiImage("assets/image/homePage/background.png")
        .then((value) => homePageBackgroundImage = value);
    loadUiImage("assets/image/homePage/titleBorder.png")
        .then((value) => homePageTitleBorderImage = value);
    loadUiImage("assets/image/homePage/buttonBorder.png")
        .then((value) => homePageButtonBorderImage = value);
    loadUiImage("assets/image/homePage/music.png")
        .then((value) => homePageMusicImage = value);
    loadUiImage("assets/image/homePage/mute.png")
        .then((value) => homePageMuteImage = value);
    loadUiImage("assets/image/homePage/volumeUp.png")
        .then((value) => homePageVolumeUpImage = value);
    loadUiImage("assets/image/homePage/volumeDown.png")
        .then((value) => homePageVolumeDownImage = value);
    // Game
    loadUiImage("assets/image/background.jpg")
        .then((value) => backgroundImage = value);
    loadUiImage("assets/image/music.png").then((value) => musicImage = value);
    loadUiImage("assets/image/mute.png").then((value) => muteImage = value);
    loadUiImage("assets/image/setting.png")
        .then((value) => settingImage = value);
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
    loadUiImage("assets/image/setBG.jpg")
        .then((value) => settingBackgroundImage = value);
    loadUiImage("assets/image/x.png").then((value) => xImage = value);
    loadUiImage("assets/image/arrow.png").then((value) => arrowImage = value);
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

  void drawHomeScreen() {
    drawFullScreenImage(homePageBackgroundImage);
    drawText2('2048 V.2', 50, 7, Colors.white, 60);
    drawText2('START', 52, 31.5, Colors.white, 38);
    drawImage(homePageVolumeUpImage, 87, 80, 12, 8);
    drawImage(homePageVolumeDownImage, 87, 90, 12, 8);
    drawImage(homePageButtonBorderImage, 32, 27.5, 40, 22);
    drawImage(homePageTitleBorderImage, 0, -2.5, 100, 28);
    drawImage(exitImage, 2, 91.3, 10, 7);
  }

  /// Draw music button on the home page.
  void drawHomePageMusicButton() {
    drawImage(homePageMusicImage, 89, 71, 8.5, 6.5);
  }

  /// Draw mute button on the home page.
  void drawHomePageMuteButton() {
    drawImage(homePageMuteImage, 89, 71, 8.5, 6.5);
  }

  /// Draw music button on the setting page.
  void drawSettingPageMusicButton() {
    drawImage(homePageMusicImage, 54, 81.8, 10.5, 6.5);
  }

  /// Draw mute button on the home page.
  void drawSettingPageMuteButton() {
    drawImage(homePageMuteImage, 54, 81.8, 10.5, 6.5);
  }

  /// Draw effect music button on the setting page.
  void drawSettingPageEffectMusicButton() {
    drawImage(homePageMusicImage, 54, 89.8, 10.5, 6.5);
  }

  /// Draw mute button on the home page.
  void drawSettingPageEffectMuteButton() {
    drawImage(homePageMuteImage, 54, 89.8, 10.5, 6.5);
  }

  /// Draw the game background.
  void drawBackground() {
    drawFullScreenImage(backgroundImage);
  }

  /// Draw all the borders.
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

  /// Draw game title text on the canvas. (The big text on the top)
  /// The title color are the same as the color of next block rectangle.
  void drawTitle(int nextBlockValue) {
    drawText(
        'Drop The Number', 50, 6.5, getBlockColorByValue(nextBlockValue), 35);
  }

  /// Draw next block hint on the canvas.
  void drawNextBlockHintText() {
    drawText('Next Block >', 25, 15.5, Colors.white, 17);
  }

  /// Draw "nextBlock" on the canvas.
  void drawNextBlock(int nextBlockValue) {
    // Draw nextBlock rectangle
    drawRect(40, 14.5, 8, 5, getBlockColorByValue(nextBlockValue));
    // Draw nextBlock border
    drawRectStroke(40, 14.5, 8, 5, Colors.pink.shade200, 3);
    // Paint nextBlock text
    drawText(nextBlockValue.toString(), 44, 16, Colors.black, 14);
  }

  /// Draw the game elapsed time on the canvas.
  void drawTime(Duration elapsedTime) {
    drawText('TIME:' + getTimeformat(elapsedTime), 64, 15.5, Colors.white, 20);
  }

  /// Draw setting button.
  void drawSettingButton() {
    drawImage(settingImage, 80, 14.7, 7, 4.5);
  }

  /// Draw five cross on the canvas. (Above the five tracks)
  void drawFiveCross(int nextBlockValue) {
    for (double i = 0; i < 5; i++) {
      drawText(
          '†', 22 + i * 14, 22.5, getBlockColorByValue(nextBlockValue), 49);
    }
  }

  /// Draw all the blocks from block array to canvas.
  void drawAllBlocks(List<List<Block>> blocks) {
    for (List<Block> linesOfBlocksY in blocks) {
      for (Block block in linesOfBlocksY) {
        drawBlock(block);
      }
    }
  }

  /// Draw current dropping block.
  void drawCurrentBlock(Block currentBlock) {
    drawBlock(currentBlock);
  }

  /// Draw pause image.
  void drawPauseButton() {
    // Pause button image
    drawImage(pauseImage, 12, 93.5, 4, 3);
    // Pause button border
    drawRectStroke(9, 92.5, 10, 5, Colors.white, 3);
  }

  /// Draw play image.
  void drawPlayButton() {
    // Play button image
    drawImage(playImage, 11.5, 93.25, 5, 3.5);
    drawImage(startButtonImage, 30.5, 37.25, 40, 24);
    drawImage(startButtonBorderImage, 30.5, 37.25, 40, 24);
    // Play button border
    drawRectStroke(9, 92.5, 10, 5, Colors.white, 3);
  }

  /// Draw the current score.
  void drawScore(int score) {
    drawText('Score: ', 30, 92.5, Colors.white, 27);
    drawText(score.toString(), 56, 93, Colors.white, 26);
  }

  /// Draw horizontal superpower button.
  void drawHorizontalSuperpowerButton() {
    // Horizontal superpower image
    drawImage(horizontalSuperpowerImage, 70, 92, 9, 6);
    // Horizontal superpower border
    drawRectStroke(70, 92.5, 9, 5, Colors.white, 3);
  }

  /// Draw vertical superpower button.
  void drawVerticalSuperpowerButton() {
    // Vertical superpower image
    drawImage(verticalSuperpowerImage, 81.5, 91.25, 10, 7);
    // Vertical superpower border
    drawRectStroke(82, 92.5, 9, 5, Colors.white, 3);
  }

  /// Draw the game over screen.
  void drawGameOverScreen(int score, int highestScore, Duration elapsedTime) {
    drawFullScreenImage(overImage);
    drawText2("Game Over", 50, 15, Colors.white, 65);
    drawText2("TIME: " + getTimeformat(elapsedTime), 49, 35, Colors.white, 40);
    drawText2(
        "Highest Score: " + highestScore.toString(), 50, 45, Colors.white, 40);
    drawText2("Your Score: " + score.toString(), 45, 55, Colors.white, 40);
    drawImage(homePageButtonBorderImage, 18.5, 66, 33, 19);
    drawText2("Restart", 34.5, 69.5, Colors.white, 33);
    drawImage(homePageButtonBorderImage, 50.5, 66, 33, 19);
    drawText2("Quit", 66, 69.5, Colors.white, 33);
    drawImage(homeImage, 1, 91.5, 12, 8);
  }

  /// Draw setting screen.
  void drawSettingScreen() {
    drawFullScreenImage(settingBackgroundImage);
    // back button
    drawImage(xImage, 87, 5.5, 9, 5);

    // home button
    drawImage(homeImage, 3, 4, 12, 8);

    // Sound Text
    drawText2("Game Music:", 31, 82, Colors.black, 40);
    drawText2("Effect Sound:", 31, 90, Colors.black, 40);

    // volume adjust button
    drawImage(homePageVolumeDownImage, 67, 81, 14, 8);
    drawImage(homePageVolumeUpImage, 81, 81, 14, 8);

    drawImage(homePageVolumeDownImage, 67, 89, 14, 8);
    drawImage(homePageVolumeUpImage, 81, 89, 14, 8);
  }

  void drawGameDifficultyText(GameDifficulty gameDifficulty) {
    // Difficulty text
    drawText2("Difficulty", 50, 10, Colors.black, 80);
    switch (gameDifficulty) {
      case GameDifficulty.noob:
        {
          drawImage(arrowImage, 28, 32, 5, 5);
          drawText2("Noob", 50, 30, Colors.blue, 70);
          drawText2("Easy", 50, 42.5, Colors.green, 50);
          drawText2("Normal", 50, 55, Colors.yellow, 50);
          drawText2("Hard", 50, 67.5, Colors.red, 50);

          break;
        }
      case GameDifficulty.easy:
        {
          drawImage(arrowImage, 28, 45, 5, 5);
          drawText2("Noob", 50, 30, Colors.blue, 50);
          drawText2("Easy", 50, 42.5, Colors.green, 70);
          drawText2("Normal", 50, 55, Colors.yellow, 50);
          drawText2("Hard", 50, 67.5, Colors.red, 50);

          break;
        }
      case GameDifficulty.normal:
        {
          drawImage(arrowImage, 21, 57, 5, 5);
          drawText2("Noob", 50, 30, Colors.blue, 50);
          drawText2("Easy", 50, 42.5, Colors.green, 50);
          drawText2("Normal", 50, 55, Colors.yellow, 70);
          drawText2("Hard", 50, 67.5, Colors.red, 50);

          break;
        }
      case GameDifficulty.hard:
        {
          drawImage(arrowImage, 28, 69.5, 5, 5);
          drawText2("Noob", 50, 30, Colors.blue, 50);
          drawText2("Easy", 50, 42.5, Colors.green, 50);
          drawText2("Normal", 50, 55, Colors.yellow, 50);
          drawText2("Hard", 50, 67.5, Colors.red, 70);

          break;
        }
    }
  }

  /// Format the time from second to minute and second.
  String getTimeformat(Duration totalSecond) {
    return sprintf("%02d:%02d",
        [totalSecond.inSeconds ~/ 60, (totalSecond.inSeconds % 60).toInt()]);
  }

  /// Draw the current dropping block on the canvas.
  /// Block size is (14, 9).
  void drawBlock(Block block) {
    // If block value is zero, ignore the block.
    if (block.value == 0) {
      return;
    }
    double width = 14;
    double height = 9;

    // Draw block color
    drawRect(block.x, block.y, width, height, getBlockColorByValue(block.value));

    // Draw border
    drawRectStroke(block.x, block.y, width, height, Colors.black, 4);

    // Draw block text
    drawText(block.value.toString(), block.x + width / 2, block.y + height / 2 - 2,
        Colors.black, 20);
  }

  /**********************************************************************
  * Draw a single frame of horizontal superpower animation. (glow animation)
  **********************************************************************/
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
    drawImage(
        horizontalSuperpowerAnimation[animationFrameIndex],
        15.0 + horizontalSuperpowerXOffset,
        83 - imageHeight + horizontalSuperpowerYOffset,
        100 + horizontalSuperpowerExtraWidth,
        imageHeight + horizontalSuperpowerExtraHeight);
  }

  /**********************************************************************
  * Draw a single frame of vertical superpower animation. (flame animation)
  **********************************************************************/
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
    drawImage(
        verticalSuperpowerAnimation[animationFrameIndex],
        4.7 + 14 * track + verticalSuperpowerXOffset,
        90 - imageHeight + verticalSuperpowerYOffset,
        34 + verticalSuperpowerExtraWidth,
        imageHeight + verticalSuperpowerExtraHeight);
  }

  /// Draw the horizontal cooldown hint overlap the button.
  void drawBlockedHorizontalSuperpower() {
    drawImage(xImage, 70, 92.5, 9, 5);
    drawRectStroke(70, 92.5, 9, 5, Colors.black, 3);
  }

  /// Draw the vertical cooldown hint overlap the button.
  void drawBlockedVerticalSuperpower() {
    drawImage(xImage, 82, 92.5, 9, 5);
    drawRectStroke(82, 92.5, 9, 5, Colors.black, 3);
  }

  /// Load an image from the given path.
  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  /// Get block color by given block value.
  Color getBlockColorByValue(int value) {
    if (value == 0) {
      return Color.fromRGBO(0, 0, 0, 0.0);
    }
    return getBlockColorByIndex(log(value) ~/ log(2) - 1);
  }

  /// Get block color by index of blockColors.
  /// If it is out of defined color, it will warp to the beginning.
  /// For example: color1, color2, color3, color1, color2, etc.
  Color getBlockColorByIndex(int index) {
    return blockColors[index % blockColors.length];
  }

  /// Draw a rectangle on the canvas.
  void drawRect(double x, double y, double width, double height, Color color) {
    Rect rect = Rect.fromLTWH(toAbsoluteX(x) + canvasXOffset, toAbsoluteY(y),
        toAbsoluteX(width), toAbsoluteY(height));
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  /// Draw a rectangle but only stroke on the canvas.
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

  /// Draw a line on the canvas by the given start point (x1, y1) and end point (x2, y2).
  void drawLine(double x1, double y1, double x2, double y2, Color color,
      double strokeWidth) {
    Offset p1 = Offset(toAbsoluteX(x1) + canvasXOffset, toAbsoluteY(y1));
    Offset p2 = Offset(toAbsoluteX(x2) + canvasXOffset, toAbsoluteY(y2));
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    canvas.drawLine(p1, p2, paint);
  }

  /// Draw a text on the canvas.
  /// The x and y are coordinate the text center.
  void drawText(String text, double x, double y, Color color, double fontSize) {
    // Adjust the font size, make sure the size is not going to huge
    fontSize /= canvasSize.x > canvasSize.y
        ? (canvasSize.y / canvasSize.x)
        : (canvasSize.x / canvasSize.y);
    fontSize /= 2.5;

    TextPainter(
      text: TextSpan(
          text: text, style: TextStyle(color: color, fontSize: fontSize)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )
      ..layout(minWidth: canvasSize.x, maxWidth: canvasSize.x)
      ..paint(
          canvas,
          Offset(toAbsoluteX(x) - (canvasSize.x / 2) + canvasXOffset,
              toAbsoluteY(y)));
  }

  void drawText2(
      String text, double x, double y, Color color, double fontSize) {
    // Adjust the font size, make sure the size is not going to huge
    fontSize /= canvasSize.x > canvasSize.y
        ? (canvasSize.y / canvasSize.x)
        : (canvasSize.x / canvasSize.y);
    fontSize /= 2.5;

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
      ..layout(minWidth: canvasSize.x, maxWidth: canvasSize.x)
      ..paint(
          canvas,
          Offset(toAbsoluteX(x) - (canvasSize.x / 2) + canvasXOffset,
              toAbsoluteY(y)));
  }

  /// Draw an image on the canvas.
  void drawImage(
      ui.Image image, double x, double y, double width, double height) {
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(toAbsoluteX(x) + canvasXOffset, toAbsoluteY(y),
            toAbsoluteX(width), toAbsoluteY(height)),
        Paint());
  }

  /// Draw an full screen image on the canvas.
  void drawFullScreenImage(ui.Image image) {
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(-0.5, -0.5, screenSize.x, screenSize.y),
        Paint());
  }
}
