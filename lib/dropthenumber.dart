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
import 'package:dropthenumber/drawhandler.dart';

class DropTheNumber extends Game with TapDetector {
  /* Setting */
  // Y dropped for every second. (In percentage)
  double dropSpeed = 7; // debug
  /* Variables */
  // Store the screen size, the value will be set in resize() function.
  Size screenSize;
  // Calculated canvas size in the middle of screen.
  Size canvasSize;
  // Left offset of the canvas left.
  double canvasXOffset;
  // If the start game screen is showed, it only show once when the game start.
  bool startGameScreenFinished = false;
  // Check whether the icon is clicked
  bool volumeOn;
  // Check whether the icon is clicked
  bool volumeDown;
  // If the game is game over, waiting for restart.
  bool gameOver;
  // If the horizontal superpower is clicked
  bool superHorBool = false;
  // If the vertical superpower is triggered
  bool superVertBool = false;
  // If the game is paused.
  bool pause;
  // If the game is muted.
  bool mute = false;
  // The track using by the dropping block.
  int currentTrack;
  // Store the information of the dropping block.
  Block currentBlock;
  // The value of next block.
  int nextBlockValue;
  // The list which maximum is 5*7 to store all blocks information.
  List<List<Block>> blocks = [[], [], [], [], []];
  // The current score of the game.
  int score;
  // The highest score on the local game.
  int highestScore = 98237; // Temporary set the value for debug
  // The start time point of the game.
  DateTime startTime = DateTime.now();
  // The time elapsed of the game running from the start time.
  Duration elapsedTime = Duration.zero;
  // The time elapsed of the game pause.
  Duration pauseElapsedTime = Duration.zero;
  // Get the maximum track among the blocks

  //cooldown
  // ignore: non_constant_identifier_names
  Duration cooldown_period = Duration(seconds: 15);
  // The last time which horizontal superpower clicked
  // ignore: non_constant_identifier_names
  DateTime cooldown_time_hor;
  // Horizontal superpower cooldown duration
  // ignore: non_constant_identifier_names
  Duration cool_down_hor = Duration.zero;
  // The last time which vertical superpower clicked
  // ignore: non_constant_identifier_names
  DateTime cooldown_time_vert;
  // Vertical superpower cooldown duration
  // ignore: non_constant_identifier_names
  Duration cool_down_vert = Duration.zero;
  // LastLoopPaused
  // ignore: non_constant_identifier_names
  bool LastLoopPaused = false;
  // Record the time stamp of pause
  DateTime startTimeOfPause = DateTime.now();
  // Record the duration of pause phase
  Duration pauseDuration = Duration.zero;
  Duration cdh, cdv;
  bool blockedHor = false, blockedVert = false;

  // Merge animation

  int old;
  int x, y;
  double ii;
  double jj;
  double kk;
  // T Shape occurance check boolean variable
  bool tShapeOccurance = false;
  // Left and right occurance check boolean variable
  bool leftOccurance = false;
  bool rightOccurance = false;
  // Down occurance check boolean variable
  bool downOccurance = false;
  // horizontal shape occurance check boolean variable
  bool horizontalOccurance = false;
  // Gamma shape occurance check boolean variable
  bool gammaOccurance = false;
  // 7 Shape occurance check boolean variable
  bool sevenOccurance = false;
  // first occurance of horizontal super power
  bool firstHorizontalOccurance = true;
  // first occurance of vertical super power
  bool firstVerticalOccurance = true;
  int getMaxTrack() {
    int maximum = blocks[0].length, index = 0;
    for (int i = 1; i < 5; i++) maximum = max(blocks[i].length, maximum);
    print(maximum.toString());
    for (int j = 0; j < 5; j++) {
      if (blocks[j].length == maximum) {
        index = j;
        break;
      }
    }
    return index;
  }

  double mergingSpeed = 3;

  /* Utils */
  // A generator of random values, import from 'dart:math'.
  Random random = Random();
  // Draw handler for helping to draw everything on screen.
  DrawHandler drawHandler = DrawHandler();
  // Convert the absolute x to relative x.
  double toRelativeX(double x) => (x - canvasXOffset) * 100 / canvasSize.width;
  // Convert the absolute y to relative y.
  double toRelativeY(double y) => y * 100 / canvasSize.height;
  // Check if the number is within given lower boundary and upper boundary.
  bool inRange(double number, double lowerBoundary, double upperBoundary) =>
      number >= lowerBoundary && number <= upperBoundary;
  Canvas cv;
  /**********************************************************************
    * Constructor
    **********************************************************************/
  DropTheNumber() {
    resetGame();
  }

  /**********************************************************************
  * Reset the game to initial state.
  **********************************************************************/
  void resetGame() {
    score = 0;
    gameOver = false; // debug
    pause = false;
    pauseElapsedTime = Duration();
    startTime = DateTime.now();
    cooldown_time_hor = DateTime.now();
    cooldown_time_vert = DateTime.now();

    // Called twice to be sure didn't used the next block value of last round.
    setupCurrentBlock();
    setupCurrentBlock();
  }

  // Super Horizontal power
  void superHor() {
    for (int i = 0; i < 5; i++) {
      try {
        blocks[i].removeAt(0);
      } catch (Exception) {
        print("except hor1");
      }
      for (int j = 0; j < blocks[i].length; j++) {
        try {
          blocks[i][j].y += 9;
        } catch (Exception) {
          print("except hor2");
        }
      }
    }
  }

  /**********************************************************************
  * Random the currentTrack, currentBlock and nextBlock.
  **********************************************************************/
  void setupCurrentBlock() {
    // The max power quantity of 2.
    int MAXPOWER = 5; // Temporary set to small number for debug
    // The offset of power quantity of 2.
    int POWEROFFSET = 1;
    if (nextBlockValue == null) {
      nextBlockValue = pow(2, random.nextInt(MAXPOWER) + POWEROFFSET).toInt();
    }
    currentTrack = random.nextInt(5);
    currentBlock =
        Block(nextBlockValue, (15 + 14 * currentTrack).toDouble(), 30);
    nextBlockValue = pow(2, random.nextInt(MAXPOWER) + POWEROFFSET).toInt();
  }

  /**********************************************************************
  * Draw the screen on every render call.
  * Override from Game, which is from 'package:flame/game.dart'.
  **********************************************************************/
  @override
  void render(Canvas canvas) {
    // print("render() invoked!"); // debug
    drawHandler.tryToInit();
    drawHandler.setCanvas(canvas);
    drawHandler.setSize(screenSize, canvasSize, canvasXOffset);
    // Draw start game screen. (It only show once when the game start)
    if (!startGameScreenFinished) {
      drawHandler.drawStartGameScreen();
    }
    // Draw game running screen.
    else if (!gameOver) {
      drawHandler.drawBackground();
      drawHandler.drawBorders();
      drawHandler.drawTitle(nextBlockValue);
      drawHandler.drawNextBlockHintText();
      drawHandler.drawNextBlock(nextBlockValue);
      drawHandler.drawTime(elapsedTime);
      if (!mute) {
        drawHandler.drawMusicButton();
      } else {
        drawHandler.drawMuteButton();
      }
      drawHandler.drawFiveCross(nextBlockValue);
      drawHandler.drawAllBlocks(blocks);
      drawHandler.drawCurrentBlock(currentBlock);

      drawHandler.drawScore(score);
      drawHandler.drawVerticalSuperPowerButton();
      drawHandler.drawHorizontalSuperPowerButton();
      if (!pause) {
        drawHandler.drawPauseButton();
      } else {
        drawHandler.drawPlayButton();
      }
      cdh = DateTime.now().difference(cooldown_time_hor);
      cdv = DateTime.now().difference(cooldown_time_vert);
      // Horizontal cross while cooldown
      if (cdh < cooldown_period && cdh != null && !firstHorizontalOccurance) {
        blockedHor = true;
        // draw the cross

      } else if (!pause || firstHorizontalOccurance) {
        blockedHor = false;
        firstHorizontalOccurance = false;
      }

      // Vertical cross while cooldown
      if (cdv < cooldown_period && cdv != null && !firstVerticalOccurance) {
        blockedVert = true;

        // draw the cross
      } else if (!pause || firstVerticalOccurance) {
        blockedVert = false;
        firstVerticalOccurance = false;
      }
      if (blockedVert) {
        drawHandler.drawBlockedVerticalSuperpower();
      }
      if (blockedHor) {
        drawHandler.drawBlockedHorizontalSuperpower();
      }
      if (superHorBool) {
        //drawHandler.playHorizontalSuperPowerAnimation();
        superHorBool = false;
        return;
      }
      if (superVertBool) {
        //drawHandler.playVerticalSuperPowerAnimation(getMaxTrack(), blocks);
        superVertBool = false;
        return;
      }
      // Update time
      if (LastLoopPaused != pause) {
        if (pause) {
          startTimeOfPause = DateTime.now();
        } else {
          pauseDuration = DateTime.now().difference(startTimeOfPause);
          if (cooldown_time_hor != null) {
            cooldown_time_hor.add(pauseDuration);
          }
          if (cooldown_time_vert != null) {
            cooldown_time_vert.add(pauseDuration);
          }
        }
      }
      LastLoopPaused = pause;
      // if the t shape occurance is triggered
      if (tShapeOccurance) {
        try {
          while (jj < blocks[x][y - 1].x && kk > blocks[x][y - 1].x) {
            drawHandler.drawBlock(Block(old, blocks[x][y].y, ii));
            drawHandler.drawBlock(Block(old, blocks[x][y].y, jj));
            ii += mergingSpeed;
            jj += mergingSpeed;
          }
        } catch (RangeError) {
          print("Range Error occurs in the coordinate: " +
              "(" +
              x.toString() +
              "," +
              y.toString() +
              ")");
        }
        dropAboveBlocks(x, y);
        try {
          while (ii < blocks[x][y - 1].y) {
            drawHandler.drawBlock(Block(old, blocks[x][y - 1].x, ii));
            ii += mergingSpeed;
          }
        } catch (RangeError) {
          print("Range Error occurs in the coordinate: " +
              "(" +
              x.toString() +
              "," +
              y.toString() +
              ")");
        }
        try {
          merge(x, y);
        } catch (Exception) {}
        try {
          merge(x, y - 1);
        } catch (Exception) {}
        try {
          merge(x - 1, y);
        } catch (Exception) {}
        try {
          merge(x + 1, y);
        } catch (Exception) {}
        // something about to check above
        try {
          merge(x, blocks[x].length - 1);
        } catch (Exception) {}
        try {
          merge(x - 1, blocks[x + 1].length - 1);
        } catch (Exception) {}
        try {
          merge(x + 1, blocks[x - 1].length - 1);
        } catch (Exception) {}
        tShapeOccurance = false;
        return;
      }
      // if the first phase of seven shape occurance is triggered
      if (sevenOccurance) {
        try {
          while (jj < blocks[x][y].x) {
            dropAboveBlocks(x, y);

            if (!pause) {
              drawHandler.drawPauseButton();
            } else {
              drawHandler.drawPlayButton();
            }
            try {
              drawHandler.drawBlock(Block(old, jj, blocks[x][y].y));
            } catch (Exception) {}
            jj += mergingSpeed;
          }
        } catch (RangeError) {
          print("Range Error occurs in the coordinate: " +
              "(" +
              x.toString() +
              "," +
              y.toString() +
              ")");
        }
        try {
          while (ii < blocks[x][y - 1].y) {
            try {
              drawHandler.drawBlock(Block(old, ii, blocks[x][y].y));
            } catch (Exception) {}
            ii += mergingSpeed;
          }
        } catch (RangeError) {}
        try {
          merge(x, y);
        } catch (Exception) {}
        try {
          merge(x, y - 1);
        } catch (Exception) {}
        try {
          merge(x - 1, y);
        } catch (Exception) {}
        try {
          merge(x, blocks[x].length - 1);
        } catch (Exception) {}
        try {
          merge(x - 1, blocks[x - 1].length - 1);
        } catch (Exception) {}
        sevenOccurance = false;
        return;
      }
      // // if the first phase of gamma shape occurance is triggered
      if (gammaOccurance) {
        try {
          while (jj > blocks[x][y].x) {
            try {
              drawHandler.drawBlock(Block(old, jj, blocks[x][y].y));
            } catch (Exception) {}
            jj -= mergingSpeed;
          }
        } catch (RangeError) {
          print("Range Error occurs in the coordinate: " +
              "(" +
              x.toString() +
              "," +
              y.toString() +
              ")");
        }
        dropAboveBlocks(x, y);
        try {
          while (ii < blocks[x][y - 1].y) {
            drawHandler.drawBlock(Block(old, blocks[x][y - 1].x, ii));
            ii += mergingSpeed;
          }
        } catch (RangeError) {
          print("Range Error occurs in the coordinate: " +
              "(" +
              x.toString() +
              "," +
              y.toString() +
              ")");
        }
        try {
          merge(x, y);
        } catch (Exception) {}
        try {
          merge(x, y - 1);
        } catch (Exception) {}
        try {
          merge(x + 1, y);
        } catch (Exception) {}

        // check above
        try {
          merge(x, blocks[x].length - 1);
        } catch (Exception) {}
        try {
          merge(x + 1, blocks[x + 1].length - 1);
        } catch (Exception) {}

        gammaOccurance = false;
        return;
      }
      // // if down occurance is triggered
      if (downOccurance) {
        try {
          while (jj < blocks[x][y - 1].y) {
            try {
              drawHandler.drawBlock(Block(old, blocks[x][y - 1].x, jj));
            } catch (Exception) {}
            jj += mergingSpeed;
          }
        } catch (RangeError) {
          print("Range Error occurs in the coordinate: " +
              "(" +
              x.toString() +
              "," +
              y.toString() +
              ")");
        }
        try {
          merge(x, y);
        } catch (Exception) {}
        try {
          merge(x, y - 1);
        } catch (Exception) {}
        try {
          merge(x, blocks[x].length - 1);
        } catch (Exception) {}
        downOccurance = false;
        return;
      }
      // if horizontal shape is triggered
      if (horizontalOccurance) {
        try {
          while (ii > blocks[x][y].x && jj < blocks[x][y].x) {
            try {
              drawHandler.drawBlock(Block(old, ii, blocks[x][y].y));
            } catch (Exception) {}
            try {
              drawHandler.drawBlock(Block(old, jj, blocks[x][y].y));
            } catch (Exception) {}
            ii += mergingSpeed;
            jj += mergingSpeed;
          }
        } catch (RangeError) {
          print("Range Error occurs in the coordinate: " +
              "(" +
              x.toString() +
              "," +
              y.toString() +
              ")");
        }
        try {
          merge(x, y);
        } catch (Exception) {}
        try {
          merge(x - 1, y);
        } catch (Exception) {}
        try {
          merge(x + 1, y);
        } catch (Exception) {}
        try {
          merge(x, blocks[x].length - 1);
        } catch (Exception) {}
        try {
          merge(x - 1, blocks[x - 1].length - 1);
        } catch (Exception) {}
        // check above
        try {
          merge(x + 1, blocks[x + 1].length - 1);
        } catch (Exception) {}
        horizontalOccurance = false;
        return;
      }
      // // if the left occurance is triggered
      if (leftOccurance) {
        try {
          while (jj > blocks[x][y].x) {
            try {
              drawHandler.drawBlock(Block(old, jj, blocks[x][y].y));
            } catch (Exception) {}
            jj += mergingSpeed;
          }
        } catch (RangeError) {
          print("Range Error occurs in the coordinate: " +
              "(" +
              x.toString() +
              "," +
              y.toString() +
              ")");
        }
        try {
          merge(x, y);
        } catch (Exception) {}
        try {
          merge(x - 1, y - 1);
        } catch (Exception) {}
        try {
          merge(x - 1, blocks[x - 1].length - 1);
        } catch (Exception) {}
        leftOccurance = false;
        return;
      }
      // // if the right occurance is triggered
      if (rightOccurance) {
        try {
          while (jj > blocks[x][y].x) {
            if (!pause) {
              try {
                drawHandler.drawBlock(Block(old, jj, blocks[x][y].y));
              } catch (Exception) {}
              jj -= mergingSpeed;
            }
          }
        } catch (RangeError) {
          print("Range Error occurs in the coordinate: " +
              "(" +
              x.toString() +
              "," +
              y.toString() +
              ")");
        }
        try {
          merge(x, y);
        } catch (Exception) {}
        try {
          merge(x + 1, y - 1);
        } catch (Exception) {}
        try {
          merge(x + 1, blocks[x + 1].length - 1);
        } catch (Exception) {}
        rightOccurance = false;
        return;
      }

      // if (!pause) {
      //     yAxis += 1;
      //     maxYAxis = (597 - 70 * blocks[currentTrack].length).toDouble();
      //     drawBlock(canvas, Block(current, xAxis, yAxis));
      // }
    }
    // Draw game over screen.
    else {
      drawHandler.drawGameOverScreen(score, highestScore, elapsedTime);
    }
  }

  /**********************************************************************
  * Game main loop.
  * Override from Game, which is from 'package:flame/game.dart'.
  **********************************************************************/
  @override
  void update(double previousLoopTimeConsumed) {
    // Print lag percentage for debugging
    // int lagPercentage = ((previousLoopTimeConsumed*60-1) * 100).toInt();
    // print("Lag: " + (lagPercentage).toString() + "%");

    if (!pause && isGameRunning()) {
      elapsedTime = DateTime.now().difference(startTime) - pauseElapsedTime;
      // Drop block
      if (!dropCurrentBlock()) {
        // Hit solid block, current block cannot be drop any more!
        if (blocks[currentTrack].length < 6) {
          //HERE
          appendCurrentBlockToTrack();
          merge(currentTrack, blocks[currentTrack].length - 1);
          setupCurrentBlock();
        } else {
          // print(blocks[currentTrack].length);
          print("Game over!"); //debug
          this.gameOver = true;
        }
      }
    }
  }

  // Super horizontal power
  void superVert() {
    int maxTrack = getMaxTrack();
    print("max track is " + maxTrack.toString());
    try {
      blocks.removeAt(maxTrack);
    } catch (Exception) {}
    blocks.insert(maxTrack, []);
  }

  /**********************************************************************
  * Reserve current screen size.
  * Override from Game, which is from 'package:flame/game.dart'.
  **********************************************************************/
  @override
  void resize(Size screenSize) {
    this.screenSize = screenSize;
    if (screenSize.width > screenSize.height * 2 / 3) {
      // canvasXOffset = (screenSize.width-screenSize.height*2/3)/2;
      canvasSize = Size(screenSize.height * 2 / 3, screenSize.height);
      canvasXOffset = (screenSize.width - canvasSize.width) / 2;
    } else {
      canvasSize = screenSize;
      canvasXOffset = 0;
    }
  }

  /**********************************************************************
  * Print tap position (x,y) in screen ratio.
  * Range is (0.0, 0.0) to (100.0, 100.0).
  * Override from Game, which is from 'package:flame/game.dart'.
  **********************************************************************/
  @override
  void onTapDown(TapDownDetails event) {
    double x = toRelativeX(event.globalPosition.dx);
    double y = toRelativeY(event.globalPosition.dy);
    print("Tap down on (${x}, ${y})");
    // xAxis = event.globalPosition.dx;
    // yAxis = event.globalPosition.dy;

    // Game start
    if (!startGameScreenFinished) {
      if (inRange(x, 32, 70) && inRange(y, 29, 37)) {
        startGameScreenFinished = true;
      }
      //   if (inRange(x, 20, 30) && inRange(y, 30, 40)) {
      //     Flame.bgm.audioPlayer.setVolume(0.6);
      //   }
      //   if (inRange(x, 20, 30) && inRange(y, 30, 40)) {}
    }
    // Game running
    else if (!gameOver) {
      // Mute button clicked.
      if (inRange(x, 80, 87) && inRange(y, 15, 19.5)) {
        toggleMute();
      }
      // Pause button clicked.
      else if (inRange(x, 9, 19) && inRange(y, 92.5, 97.5)) {
        togglePause();
      } else if (pause && inRange(x, 37, 63) && inRange(y, 42, 58)) {
        togglePause();
      }
      // Track clicked.
      else if (!pause && inRange(x, 15, 85) && inRange(y, 30, 87)) {
        currentTrack = (x - 15) ~/ 14;
        print("Track " + currentTrack.toString() + " clicked!"); // debug
        appendCurrentBlockToTrack();
        setupCurrentBlock();
      }
      // Horizontal super power clicked.
      else if (!pause && inRange(x, 65, 75) && inRange(y, 92.5, 97.5)) {
        if (cooldown_time_hor == null || firstHorizontalOccurance) {
          cooldown_time_hor = DateTime.now();
          superHor();
          print("Horizontal super power clicked!"); // debug
          superHorBool = true;
          firstHorizontalOccurance;
        }

        cool_down_hor = DateTime.now().difference(cooldown_time_hor);
        if (cool_down_hor > cooldown_period) {
          cool_down_hor = Duration.zero;
          cooldown_time_hor = DateTime.now();
          superHor();
          print("Horizontal super power clicked!"); // debug
          superHorBool = true;
        }
      }
      // Vertical super power clicked.
      else if (!pause && inRange(x, 80, 90) && inRange(y, 92.5, 97.5)) {
        if (cooldown_time_vert == null || firstVerticalOccurance) {
          cooldown_time_vert = DateTime.now();
          print("Vertical super power clicked!"); // debug
          superVertBool = true;
          firstVerticalOccurance = false;
          superVert();
        }

        cool_down_vert = DateTime.now().difference(cooldown_time_vert);
        if (cool_down_vert > cooldown_period) {
          cool_down_vert = Duration.zero;
          cooldown_time_vert = DateTime.now();
          print("Vertical super power clicked!"); // debug
          superVertBool = true;
          superVert();
        }
      }
      //
      // if (inRange(x, 15, 29) && inRange(y, 221, 653)) {
      //     currentTrack = ((x - 76) ~/ 70).toInt();
      //     print(currentTrack);
      //     // xAxis = (76 + 70 * currentTrack).toDouble();
      //     // maxYAxis = (582 - 70 * blocks[currentTrack].length).toDouble();
      // }
    }
    // Game over
    else {
      if (inRange(x, 20, 47) && inRange(y, 68, 73)) {
        print("Restart button clicked!"); // debug
        blocks = [[], [], [], [], []];
        resetGame();
      } else if (inRange(x, 53, 79) && inRange(y, 68, 73)) {
        print("Quit button clicked!"); // debug
      }
    }
  }

  /**********************************************************************
  * Try to drop the current block, return true if the drop is successed.
  * If current block is going to touch a solid block, it failed to drop and return false.
  **********************************************************************/
  bool dropCurrentBlock() {
    // Height of every blocks
    double blockHeight = 9;
    // The highest y in the current track
    double currentTrackHighestSolidY =
        87 - blockHeight * blocks[currentTrack].length;
    // The bottom y of current block in the next round.
    double currentBlockBottomY = currentBlock.y + blockHeight + dropSpeed / 60;

    if (currentBlockBottomY < currentTrackHighestSolidY) {
      currentBlock.y += dropSpeed / 60;
      return true;
    } else {
      currentBlock.y = currentTrackHighestSolidY - blockHeight;
      return false;
    }
  }

  /**********************************************************************
  * Add current block to solid blocks of current track.
  **********************************************************************/
  void appendCurrentBlockToTrack() {
    // Height of every blocks
    double blockHeight = 9;
    // Make sure the x axis of current block is in the right position.
    currentBlock.x = 15.0 + 14 * currentTrack;
    // Move the block to the highest position of current track.
    currentBlock.y = 87 - blockHeight * (blocks[currentTrack].length + 1);
    // Add current block to blocks array.
    blocks[currentTrack].add(currentBlock);
    if (blocks[currentTrack].length > 6) this.gameOver = true;
    // do the merge process
    merge(currentTrack, blocks[currentTrack].length - 1);
  }

  // Merge method
  void merge(int x, int y) async {
    this.x = x;
    this.y = y;
    print("merge (" + x.toString() + "," + y.toString() + ")"); // debug
    if (x < 0 || x > 5) return;
    if (y < 0 || blocks[x].length - 1 < y) return;

    // Check left and right and down(T shape)
    print("Try T shape"); // debug
    if ((x > 0 && x < 4 && y > 0)) {
      int leftLineY = blocks[x - 1].length - 1;
      int rightLineY = blocks[x + 1].length - 1;
      if (leftLineY >= y && rightLineY >= y) {
        if (blocks[x][y].v == blocks[x - 1][y].v &&
            blocks[x][y].v == blocks[x + 1][y].v &&
            blocks[x][y].v == blocks[x][y - 1].v) {
          print("T shape"); // debug
          old = blocks[x][y].v;
          ii = blocks[x][y].y;
          jj = blocks[x - 1][y].x;
          kk = blocks[x + 1][y].x;

          blocks[x][y - 1].v *= 8;
          score += blocks[x][y - 1].v;
          dropAboveBlocks(x - 1, y);
          dropAboveBlocks(x + 1, y);

          tShapeOccurance = true;
          return;
        }
      }
    }
    // Check right and down(Gamma shape)
    print("Try gamma shape"); // debug
    if ((x < 4 && y > 0)) {
      int rightLineY = blocks[x + 1].length - 1;
      if (rightLineY >= y) {
        if (blocks[x][y].v == blocks[x + 1][y].v &&
            blocks[x][y].v == blocks[x][y - 1].v) {
          print("gamma shape"); // debug
          old = blocks[x][y].v;
          ii = blocks[x][y].y;
          jj = blocks[x + 1][y].x;
          blocks[x][y - 1].v *= 4;
          score += blocks[x][y - 1].v;
          dropAboveBlocks(x + 1, y);
          gammaOccurance = true;
          return;
        }
      }
    }
    // Check left and down(7 Shape)
    print("Try 7 shape"); // debug
    if ((x > 0 && y > 0)) {
      int leftLineY = blocks[x - 1].length - 1;
//       if (leftLineY > 0) { // Error occurs here!!!!!
      if (leftLineY >= y) {
        if (blocks[x][y].v == blocks[x - 1][y].v &&
            blocks[x][y].v == blocks[x][y - 1].v) {
          print("7 shape"); // debug
          old = blocks[x][y].v;
          ii = blocks[x][y].y;
          jj = blocks[x - 1][y].x;
          score += blocks[x][y - 1].v;
          blocks[x][y - 1].v *= 4;
          dropAboveBlocks(x - 1, y);
          sevenOccurance = true;
          return;
        }
      }
    }
    // Check left and right(horizontal shape)
    print("Try horizontal shape"); // debug
    if ((x > 0 && x < 4)) {
      int leftLineY = blocks[x - 1].length - 1;
      int rightLineY = blocks[x + 1].length - 1;
      if (leftLineY >= y && rightLineY >= y) {
        if (blocks[x][y].v == blocks[x - 1][y].v &&
            blocks[x][y].v == blocks[x + 1][y].v) {
          print("horizontal shape"); // debug
          old = blocks[x][y].v;
          ii = blocks[x + 1][y].x;
          jj = blocks[x - 1][y].x;
          blocks[x][y].v *= 4;
          dropAboveBlocks(x - 1, y);
          dropAboveBlocks(x + 1, y);
          horizontalOccurance = true;
          return;
        }
      }
    }
    // Check right
    print("Try check right"); // debug
    if (x < 4) {
      int rightLineY = blocks[x + 1].length - 1;
      if (rightLineY >= y) {
        if (blocks[x][y].v == blocks[x + 1][y].v) {
          print("check right"); // debug
          this.old = blocks[x][y].v;
          this.jj = blocks[x + 1][y].x;
          blocks[x][y].v *= 2;
          score += blocks[x][y].v;
          dropAboveBlocks(x + 1, y);

          rightOccurance = true;
          return;
        }
      }
    }

    // Check left
    print("Try check left"); // debug
    if (x > 0) {
      int leftLineY = blocks[x - 1].length - 1;
      if (leftLineY >= y) {
        if (blocks[x][y].v == blocks[x - 1][y].v) {
          print("check left"); // debug
          old = blocks[x][y].v;
          jj = blocks[x - 1][y].x;
          blocks[x][y].v *= 2;
          score += blocks[x][y].v;
          dropAboveBlocks(x - 1, y);
          leftOccurance = true;
          return;
        }
      }
    }

    // Check down
    print("Try check down"); // debug
    if (y > 0) {
      if (blocks[x][y - 1] != null) {
        if (blocks[x][y].v == blocks[x][y - 1].v) {
          print("Check down"); // debug
          this.jj = blocks[x][y].y;
          this.old = blocks[x][y].v;
          blocks[x][y - 1].v *= 2;
          score += blocks[x][y - 1].v;
          dropAboveBlocks(x, y);
          if (!downOccurance) {
            downOccurance = true;
            return;
          }
        }
      }
    }
    return;
  }

  /**********************************************************************
  * Try to toggle pause of the game is running.
  **********************************************************************/
  void togglePause() {
    if (isGameRunning()) {
      pause = !pause;
      if (!pause) {
        pauseElapsedTime =
            DateTime.now().difference(startTime.add(elapsedTime));
      }
    }
  }

  /**********************************************************************
  * Try to toggle the mute the the game is running music.
  **********************************************************************/
  void toggleMute() {
    mute = !mute;

    if (mute) {
      Flame.bgm.pause();
    } else {
      Flame.bgm.resume();
    }
  }

  /**********************************************************************
  * If the game is started and not game over.
  **********************************************************************/
  bool isGameRunning() {
    if (startGameScreenFinished && !gameOver) {
      return true;
    } else {
      return false;
    }
  }

  /**********************************************************************
  * Get the track has the most blocks.
  * If there are more than one track have the most block, get a random of them.
  **********************************************************************/
  int getHighestTrack() {
    // The blocks quantity of the most block track
    int mostBlockQuantity = 0;
    // Count the most block quantity in the track which has the most blocks.
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].length > mostBlockQuantity) {
        mostBlockQuantity = blocks[i].length;
      }
    }
    // Record those tracks have the most block in a list.
    List<int> mostBlockTrackIndex = [];
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].length == mostBlockQuantity) {
        mostBlockTrackIndex.add(i);
      }
    }
    // If there are more than one track have the most block, get a random of them.
    if (mostBlockTrackIndex.length == 1) {
      return mostBlockTrackIndex[0];
    } else {
      return mostBlockTrackIndex[random.nextInt(mostBlockTrackIndex.length)];
    }
  }

  /**********************************************************************
  * Drop the blocks above of the specfic block.
  **********************************************************************/
  void dropAboveBlocks(int x, int y) {
    if (x < 0 && x >= blocks.length) {
      print("Error: Try to call dropAboveBlocks() with out of bound x index!");
      return;
    } else if (y < 0 && y >= blocks[x].length) {
      print("Error: Try to call dropAboveBlocks() with out of bound y index!");
      return;
    }
    if (blocks[x].length > 0) {
      print("Removal has been triggered");
      for (int i = y; i < blocks[x].length - 1; i++) {
        blocks[x][i].v = blocks[x][i + 1].v;
      }
      blocks[x].removeLast();
    }
  }
}
