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
import 'dart:io';

class DrawHandler {
  /* Variables */
  // If draw handler is initialized. (Use by tryToInit(), after initialized image and video are loaded.)
  bool initialized = false;
  // The screen size, needed by the drawBackground().
  Size screenSize;
  // The draw area size. (Background image is not in this limit)
  Size canvasSize;
  // The left margin of canvas, prevent the screen stretch. (This is already in absolute coordinates)
  double canvasXOffset;

  /* Utils */
  // The canvas that the draw handler want to draw on.
  Canvas canvas;
  // Convert the relative x to ablolute x.
  double toAbsoluteX(double x) => x * canvasSize.width / 100;
  // Convert the relative y to ablolute y.
  double toAbsoluteY(double y) => y * canvasSize.height / 100;
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
  // Images which will be load later.
  ui.Image backgroundImage;
  ui.Image musicImage;
  ui.Image muteImage;
  ui.Image pauseImage;
  ui.Image playImage;
  ui.Image horizontalSuperPowerImage;
  ui.Image verticalSuperPowerImage;
  ui.Image superHor1;
  // Videos combine by lots of images which will be load later.
  List<ui.Image> verticalSuperPowerVideo;
  List<ui.Image> horizontalSuperPowerVideo;

  /**********************************************************************
    * Constructor
    **********************************************************************/
  DrawHandler() {}

  /**********************************************************************
    * Set the canvas to draw.
    **********************************************************************/
  void setCanvas(Canvas canvas) {
    this.canvas = canvas;
  }

  /**********************************************************************
    * Set the size to draw, that everything will draw in correct relative size.
    * Should called to get the current screen size before every draw method invoke.
    **********************************************************************/
  void setSize(Size screenSize, Size canvasSize, double canvasXOffset) {
    this.screenSize = screenSize;
    this.canvasSize = canvasSize;
    this.canvasXOffset = canvasXOffset;
  }

  /**********************************************************************
    * Initial the draw handler if it is not initialized.
    * DrawHandler should be initial before the first use.
    **********************************************************************/
  void tryToInit() {
    if (!initialized) {
      initImages();
      initVideos();
      initialized = true;
    }
  }

  /**********************************************************************
    * Initial images like music image, backgroundImage, etc.
    **********************************************************************/
  void initImages() {
    loadUiImage("assets/image/background.jpg")
        .then((value) => backgroundImage = value);
    loadUiImage("assets/image/music.png").then((value) => musicImage = value);
    loadUiImage("assets/image/mute.png").then((value) => muteImage = value);
    loadUiImage("assets/image/pause.png").then((value) => pauseImage = value);
    loadUiImage("assets/image/play.png").then((value) => playImage = value);
    loadUiImage("assets/image/horizontalSuperPower.png")
        .then((value) => horizontalSuperPowerImage = value);
    loadUiImage("assets/image/verticalSuperPower.png")
        .then((value) => verticalSuperPowerImage = value);
  }

  /**********************************************************************
    * Initial super power animation video.
    * The video is combine by lots of (.png) files.
    **********************************************************************/
  void initVideos() {
    loadUiImage("assets/video/power1/1.png").then((value) => superHor1 = value);
    // for (int i = 1; i < 15; i++) {
    //   loadUiImage("assets/video/power1/" + i.toString() + ".png")
    //       .then((value) => verticalSuperPowerVideo.add(value));
    // }
    // for (int i = 0; i < 19; i++) {
    //   loadUiImage("assets/video/power2/" + i.toString() + ".png")
    //       .then((value) => horizontalSuperPowerVideo.add(value));
    // }
    // print(horizontalSuperPowerVideo);
  }

  /**********************************************************************
    * Draw the screen before the game start.
    * The screen will only show once when the game start.
    **********************************************************************/
  void drawStartGameScreen() {
    // WIP
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
      // here
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
    * Draw horizontal super power button.
    **********************************************************************/
  void drawHorizontalSuperPowerButton() {
    // Horizontal super power image
    drawImage(horizontalSuperPowerImage, 69.5, 91, 10, 7);
    // Horizontal super power border
    drawRectStroke(70, 92.5, 9, 5, Colors.white, 3);
  }

  /**********************************************************************
    * Draw vertical super power button.
    **********************************************************************/
  void drawVerticalSuperPowerButton() {
    // Vertical super power image
    drawImage(verticalSuperPowerImage, 81.5, 91.25, 10, 7);
    // Vertical super power border
    drawRectStroke(82, 92.5, 9, 5, Colors.white, 3);
  }

  /**********************************************************************
    * Draw the game over screen.
    **********************************************************************/
  void drawGameOverScreen(int score, int highestScore, Duration elapsedTime) {
    drawRect(0, 0, 100, 100, Colors.white);
    drawText("Game Over", 50, 20, Colors.black, 50);
    if (elapsedTime == null) {
      elapsedTime = Duration();
    }
    drawText("TIME: " + getTimeformat(elapsedTime), 49, 35, Colors.black, 30);
    drawText(
        "Highest Score: " + highestScore.toString(), 50, 45, Colors.black, 30);
    drawText("Your Score: " + score.toString(), 45, 55, Colors.black, 30);
    drawRectStroke(20, 68, 27, 5, Colors.black, 5);
    drawText("Restart", 33.5, 68.5, Colors.black, 25);
    drawRectStroke(53, 68, 27, 5, Colors.black, 5);
    drawText("Quit", 66, 68.5, Colors.black, 25);
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
    **********************************************************************/
  void drawBlock(Block block) {
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
    * Play vertical super power animation. (flame animation)
    **********************************************************************/
  void playVerticalSuperPowerAnimation(int track) {
    // int maxTrack = getMaxTrack();
    drawVideo(verticalSuperPowerVideo, 220, 367, 500, 500);
    // blocks.removeAt(maxTrack);
    // blocks.insert(maxTrack - 1, []);
  }

  /**********************************************************************
    * Play horizontal super power animation. (puple magic animation)
    **********************************************************************/
  void playHorizontalSuperPowerAnimation() {
    initVideos();
    // drawVideo(horizontalSuperPowerVideo, 50, 50, 100, 100);
    print('vidoe');
  }

  /**********************************************************************
    * Draw an animation video on the canvas.
    **********************************************************************/
  void drawVideo(
      List<ui.Image> video, double x, double y, double width, double height) {
    // load video
    for (int i = 0; i < video.length; i++) {
      canvas.drawImageRect(
          video[i],
          Rect.fromLTWH(
              0, 0, video[i].width.toDouble(), video[i].height.toDouble()),
          Rect.fromLTWH(toAbsoluteX(x), toAbsoluteY(y), width, height),
          Paint());
      sleep(Duration(milliseconds: 600));
    }
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
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height),
        Paint());
  }
}
