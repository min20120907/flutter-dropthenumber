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
  double dropSpeed = 10; // debug
  /* Variables */
  // Store the screen size, the value will be set in resize() function.
  Size screenSize;
  // Calculated canvas size in the middle of screen.
  Size canvasSize;
  // Left offset of the canvas left.
  double canvasXOffset;
  // If the start game screen is showed, it only show once when the game start.
  bool startGameScreenFinished =
      true; //////////////////////////// Temporary set the value to true for debugging
  // If the game is game over, waiting for restart.
  bool gameOver;
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
  int highestScore = 99; // Temporary set the value for debug
  // The start time point of the game.
  DateTime startTime;
  // The time elapsed of the game running from the start time.
  Duration elapsedTime;
  // The time elapsed of the game pause.
  Duration pauseElapsedTime;

  double mergingSpeed = 5;
  DateTime cooldownTimeHor; // wip
  DateTime cooldownTimeVert; // wip

  /* Utils */
  // A generator of random values, import from 'dart:math'.
  Random random = Random();
  // Draw handler for helping to draw everything on screen.
  DrawHandler drawHandler = DrawHandler();
  // Convert the absolute x to relative x.
  double toRelativeX(double x) => (x-canvasXOffset) * 100 / canvasSize.width;
  // Convert the absolute y to relative y.
  double toRelativeY(double y) => y * 100 / canvasSize.height;
  // Check if the number is within given lower boundary and upper boundary.
  bool inRange(double number, double lowerBoundary, double upperBoundary) =>
      number >= lowerBoundary && number <= upperBoundary;

  // coordinates of clicked position
  // double xAxis = (75 + 70 * currentTrack).toDouble(), yAxis = 237;
  // double maxYAxis = 597;

  // merging speed
  // double mergingSpeed = 5;

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

    // Called twice to be sure didn't used the next block value of last round.
    setupCurrentBlock();
    setupCurrentBlock();
  }

  /**********************************************************************
  * Random the currentTrack, currentBlock and nextBlock.
  **********************************************************************/
  void setupCurrentBlock() {
    // The max power quantity of 2.
    int MAX_POWER = 12;
    // The offset of power quantity of 2.
    int POWER_OFFSET = 1;
    if (nextBlockValue == null) {
      nextBlockValue = pow(2, random.nextInt(MAX_POWER) + POWER_OFFSET).toInt();
    }
    currentTrack = random.nextInt(5);
    currentBlock =
        Block(nextBlockValue, (15 + 14 * currentTrack).toDouble(), 30);
    nextBlockValue = pow(2, random.nextInt(MAX_POWER) + POWER_OFFSET).toInt();
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
      drawHandler.drawFiveCross();
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
  ******************************************************d****************/
  @override
  void update(double previousLoopTimeConsumed) {
    // Print lag percentage for debugging
    // int lagPercentage = ((previousLoopTimeConsumed*60-1) * 100).toInt();
    // print("Lag: " + (lagPercentage).toString() + "%");

    if (!pause && isGameRunning()) {
      // Update time
      elapsedTime = DateTime.now().difference(startTime) - pauseElapsedTime;

      // Drop block
      if (!dropCurrentBlock()) {
        // Hit solid block, current block cannot be drop any more!
        if (blocks[currentTrack].length < 6) {
          //HERE
          appendCurrentBlockToTrack();
          setupCurrentBlock();
          merge(currentTrack, blocks[currentTrack].length - 1);
        } else {
          // print(blocks[currentTrack].length);
          print("Game over!"); //debug
          this.gameOver = true;
        }
      }
    }
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
      }
      // Track clicked.
      else if (inRange(x, 15, 85) && inRange(y, 30, 87)) {
        currentTrack = (x - 15) ~/ 14;
        print("Track " + currentTrack.toString() + " clicked!"); // debug
        appendCurrentBlockToTrack();
        setupCurrentBlock();
      }
      // Horizontal super power clicked.
      else if (inRange(x, 65, 75) && inRange(y, 92.5, 97.5)) {
        print("Horizontal super power clicked!"); // debug
      }
      // Vertical super power clicked.
      else if (inRange(x, 80, 90) && inRange(y, 92.5, 97.5)) {
        print("Vertical super power clicked!"); // debug
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
      if (inRange(x, 25, 45) && inRange(y, 70, 75)) {
        print("Restart button clicked!"); // debug
        blocks = [[], [], [], [], []];
        resetGame();
      } else if (inRange(x, 55, 65) && inRange(y, 70, 75)) {
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
    // do the merge process
    try {
      merge(currentTrack, blocks[currentTrack].length - 1);
    } catch (RangeError) {
      print("Range Error occurs!!!!!");
    }
  }

  // Merge method
  void merge(int x, int y) {
    print("X: " + x.toString() + "Y: " + y.toString());
    if (x < 0 && x > 5) return;
    if (y < 0 && blocks[x].length - 1 < y) return;

    // Check left and right and down(T shape)
    if (x > 0 && x < 4 && y > 0) {
      int leftLineY = blocks[x - 1].length - 1;
      int rightLineY = blocks[x + 1].length - 1;
      if (leftLineY >= y && rightLineY >= y) {
        if (blocks[x][y].v == blocks[x - 1][y].v &&
            blocks[x][y].v == blocks[x + 1][y].v &&
            blocks[x][y].v == blocks[x][y - 1].v) {
          int old = blocks[x][y].v;
          double ii = blocks[x][y].y;
          double jj = blocks[x - 1][y].x;
          double kk = blocks[x + 1][y].x;

          blocks[x][y - 1].v *= 8;
          score += blocks[x][y - 1].v;
          dropAboveBlocks(x - 1, y);
          dropAboveBlocks(x + 1, y);

          // while (jj < blocks[x][y - 1].x && kk > blocks[x][y - 1].x) {
          //   drawHandler.drawBackground();
          //   drawHandler.drawBorders();
          //   drawHandler.drawTitle(nextBlockValue);
          //   drawHandler.drawNextBlockHintText();
          //   drawHandler.drawNextBlock(nextBlockValue);
          //   drawHandler.drawTime(elapsedTime);
          //   if (!mute) {
          //     drawHandler.drawMusicButton();
          //   } else {
          //     drawHandler.drawMuteButton();
          //   }
          //   drawHandler.drawFiveCross();
          //   drawHandler.drawAllBlocks(blocks);

          //   drawHandler.drawScore(score);
          //   drawHandler.drawVerticalSuperPowerButton();
          //   drawHandler.drawHorizontalSuperPowerButton();
          //   if (!pause) {
          //     drawHandler.drawPauseButton();
          //   } else {
          //     drawHandler.drawPlayButton();
          //   }

          //   ii += mergingSpeed;
          //   jj += mergingSpeed;
          // }
          // while (ii < blocks[x][y - 1].y) {
          //   drawHandler.drawBackground();
          //   drawHandler.drawBorders();
          //   drawHandler.drawTitle(nextBlockValue);
          //   drawHandler.drawNextBlockHintText();
          //   drawHandler.drawNextBlock(nextBlockValue);
          //   drawHandler.drawTime(elapsedTime);
          //   if (!mute) {
          //     drawHandler.drawMusicButton();
          //   } else {
          //     drawHandler.drawMuteButton();
          //   }
          //   drawHandler.drawFiveCross();
          //   drawHandler.drawAllBlocks(blocks);

          //   drawHandler.drawScore(score);
          //   drawHandler.drawVerticalSuperPowerButton();
          //   drawHandler.drawHorizontalSuperPowerButton();
          //   if (!pause) {
          //     drawHandler.drawPauseButton();
          //   } else {
          //     drawHandler.drawPlayButton();
          //   }

          //   drawHandler.drawBlock(Block(old, blocks[x][y - 1].x, ii));
          //   ii += mergingSpeed;
          // }
          merge(x, y);
          merge(x, y - 1);
          merge(x - 1, y);
          merge(x + 1, y);
          // something about to check above
          merge(x, blocks[x].length - 1);
          merge(x - 1, blocks[x - 1].length - 1);
          merge(x + 1, blocks[x + 1].length - 1);
          return;
        }
      }
    }
    // Check right and down(Gamma shape)
    if (x < 4 && y > 0) {
      int rightLineY = blocks[x + 1].length - 1;
      if (rightLineY >= y) {
        if (blocks[x][y].v == blocks[x + 1][y].v &&
            blocks[x][y].v == blocks[x][y - 1].v) {
          int old = blocks[x][y].v;
          double ii = blocks[x][y].y;
          double jj = blocks[x + 1][y].x;
          blocks[x][y - 1].v *= 4;
          score += blocks[x][y - 1].v;
          dropAboveBlocks(x + 1, y);
          // while (jj > blocks[x][y].x) {
          //   drawHandler.drawBackground();
          //   drawHandler.drawBorders();
          //   drawHandler.drawTitle(nextBlockValue);
          //   drawHandler.drawNextBlockHintText();
          //   drawHandler.drawNextBlock(nextBlockValue);
          //   drawHandler.drawTime(elapsedTime);
          //   if (!mute) {
          //     drawHandler.drawMusicButton();
          //   } else {
          //     drawHandler.drawMuteButton();
          //   }
          //   drawHandler.drawFiveCross();
          //   drawHandler.drawAllBlocks(blocks);

          //   drawHandler.drawScore(score);
          //   drawHandler.drawVerticalSuperPowerButton();
          //   drawHandler.drawHorizontalSuperPowerButton();
          //   if (!pause) {
          //     drawHandler.drawPauseButton();
          //   } else {
          //     drawHandler.drawPlayButton();
          //   }
          //   drawHandler.drawBlock(Block(old, jj, blocks[x][y].y));
          //   jj -= mergingSpeed;
          // }
          dropAboveBlocks(x, y);
          // while (ii < blocks[x][y - 1].y) {
          //   drawHandler.drawBackground();
          //   drawHandler.drawBorders();
          //   drawHandler.drawTitle(nextBlockValue);
          //   drawHandler.drawNextBlockHintText();
          //   drawHandler.drawNextBlock(nextBlockValue);
          //   drawHandler.drawTime(elapsedTime);
          //   if (!mute) {
          //     drawHandler.drawMusicButton();
          //   } else {
          //     drawHandler.drawMuteButton();
          //   }
          //   drawHandler.drawFiveCross();
          //   drawHandler.drawAllBlocks(blocks);

          //   drawHandler.drawScore(score);
          //   drawHandler.drawVerticalSuperPowerButton();
          //   drawHandler.drawHorizontalSuperPowerButton();
          //   if (!pause) {
          //     drawHandler.drawPauseButton();
          //   } else {
          //     drawHandler.drawPlayButton();
          //   }
          //   drawHandler.drawBlock(Block(old, blocks[x][y - 1].x, ii));
          //   ii += mergingSpeed;
          // }
          merge(x, y);
          merge(x, y - 1);
          merge(x - 1, y);

          // check above
          merge(x, blocks[x].length - 1);
          merge(x - 1, blocks[x].length - 1);
          return;
        }
      }
    }
    // Check left and down(7 Shape)
    if (x > 0 && y > 0) {
      int leftLineY = blocks[x - 1].length - 1;
      if (leftLineY > 0) {
        if (blocks[x][y].v == blocks[x - 1][y].v &&
            blocks[x][y].v == blocks[x][y - 1].v) {
          int old = blocks[x][y].v;
          double ii = blocks[x][y].y;
          double jj = blocks[x - 1][y].x;
          score += blocks[x][y - 1].v;
          blocks[x][y - 1].v *= 4;
          dropAboveBlocks(x - 1, y);
          // while (jj < blocks[x][y].x) {
          //   drawHandler.drawBackground();
          //   drawHandler.drawBorders();
          //   drawHandler.drawTitle(nextBlockValue);
          //   drawHandler.drawNextBlockHintText();
          //   drawHandler.drawNextBlock(nextBlockValue);
          //   drawHandler.drawTime(elapsedTime);
          //   if (!mute) {
          //     drawHandler.drawMusicButton();
          //   } else {
          //     drawHandler.drawMuteButton();
          //   }
          //   drawHandler.drawFiveCross();
          //   drawHandler.drawAllBlocks(blocks);

          //   drawHandler.drawScore(score);
          //   drawHandler.drawVerticalSuperPowerButton();
          //   drawHandler.drawHorizontalSuperPowerButton();
          //   if (!pause) {
          //     drawHandler.drawPauseButton();
          //   } else {
          //     drawHandler.drawPlayButton();
          //   }
          //   drawHandler.drawBlock(Block(old, jj, blocks[x][y].y));
          //   jj += mergingSpeed;
          // }
          // while (ii < blocks[x][y - 1].y) {
          //   drawHandler.drawBackground();
          //   drawHandler.drawBorders();
          //   drawHandler.drawTitle(nextBlockValue);
          //   drawHandler.drawNextBlockHintText();
          //   drawHandler.drawNextBlock(nextBlockValue);
          //   drawHandler.drawTime(elapsedTime);
          //   if (!mute) {
          //     drawHandler.drawMusicButton();
          //   } else {
          //     drawHandler.drawMuteButton();
          //   }
          //   drawHandler.drawFiveCross();
          //   drawHandler.drawAllBlocks(blocks);

          //   drawHandler.drawScore(score);
          //   drawHandler.drawVerticalSuperPowerButton();
          //   drawHandler.drawHorizontalSuperPowerButton();
          //   if (!pause) {
          //     drawHandler.drawPauseButton();
          //   } else {
          //     drawHandler.drawPlayButton();
          //   }
          //   drawHandler.drawBlock(Block(old, jj, blocks[x][y].y));
          //   ii += mergingSpeed;
          // }
          merge(x, y);
          merge(x, y - 1);
          merge(x - 1, y);
          merge(x, blocks[x].length - 1);
          merge(x - 1, blocks[x - 1].length - 1);
          return;
        }
      }
    }
    // Check left and right(horizontal shape)
    if (x > 0 && x < 4) {
      int leftLineY = blocks[x - 1].length - 1;
      int rightLineY = blocks[x + 1].length - 1;
      if (leftLineY >= y && rightLineY >= y) {
        if (blocks[x][y].v == blocks[x - 1][y].v &&
            blocks[x][y].v == blocks[x + 1][y].v) {
          int old = blocks[x][y].v;
          double ii = blocks[x + 1][y].x;
          double jj = blocks[x - 1][y].x;
          blocks[x][y].v *= 4;
          dropAboveBlocks(x - 1, y);
          dropAboveBlocks(x + 1, y);
          // while (ii > blocks[x][y].x && jj < blocks[x][y].x) {
          //   drawHandler.drawBackground();
          //   drawHandler.drawBorders();
          //   drawHandler.drawTitle(nextBlockValue);
          //   drawHandler.drawNextBlockHintText();
          //   drawHandler.drawNextBlock(nextBlockValue);
          //   drawHandler.drawTime(elapsedTime);
          //   if (!mute) {
          //     drawHandler.drawMusicButton();
          //   } else {
          //     drawHandler.drawMuteButton();
          //   }
          //   drawHandler.drawFiveCross();
          //   drawHandler.drawAllBlocks(blocks);

          //   drawHandler.drawScore(score);
          //   drawHandler.drawVerticalSuperPowerButton();
          //   drawHandler.drawHorizontalSuperPowerButton();
          //   if (!pause) {
          //     drawHandler.drawPauseButton();
          //   } else {
          //     drawHandler.drawPlayButton();
          //   }
          //   drawHandler.drawBlock(Block(old, ii, blocks[x][y].y));
          //   drawHandler.drawBlock(Block(old, jj, blocks[x][y].y));
          //   ii += mergingSpeed;
          //   jj += mergingSpeed;
          // }
          merge(x, y);
          merge(x - 1, y);
          merge(x + 1, y);
          // check above
          merge(x, blocks[x].length - 1);
          merge(x - 1, blocks[x - 1].length - 1);
          merge(x + 1, blocks[x + 1].length - 1);
          return;
        }
      }
    }
    // Check right
    if (x < 4) {
      int rightLineY = blocks[x + 1].length - 1;
      if (rightLineY >= y) {
        if (blocks[x][y].v == blocks[x + 1][y].v) {
          int old = blocks[x][y].v;
          double jj = blocks[x + 1][y].x;
          blocks[x][y].v *= 2;
          score += blocks[x][y].v;
          dropAboveBlocks(x + 1, y);
          // while (jj > blocks[x][y].x) {
          //   drawHandler.drawBackground();
          //   drawHandler.drawBorders();
          //   drawHandler.drawTitle(nextBlockValue);
          //   drawHandler.drawNextBlockHintText();
          //   drawHandler.drawNextBlock(nextBlockValue);
          //   drawHandler.drawTime(elapsedTime);
          //   if (!mute) {
          //     drawHandler.drawMusicButton();
          //   } else {
          //     drawHandler.drawMuteButton();
          //   }
          //   drawHandler.drawFiveCross();
          //   drawHandler.drawAllBlocks(blocks);

          //   drawHandler.drawScore(score);
          //   drawHandler.drawVerticalSuperPowerButton();
          //   drawHandler.drawHorizontalSuperPowerButton();
          //   if (!pause) {
          //     drawHandler.drawPauseButton();
          //   } else {
          //     drawHandler.drawPlayButton();
          //   }
          //   drawHandler.drawBlock(Block(old, jj, blocks[x][y].y));
          //   jj -= mergingSpeed;
          // }
          merge(x, y);
          merge(x + 1, y - 1);
          merge(x + 1, blocks[x + 1].length - 1);
          return;
        }
      }
    }
    // Check down
    if (y > 0) {
      if (blocks[x][y].v == blocks[x][y - 1].v) {
        double jj = blocks[x][y].y;
        int old = blocks[x][y].v;
        blocks[x][y - 1].v *= 2;
        score += blocks[x][y - 1].v;
        dropAboveBlocks(x, y);
        // while (jj < blocks[x][y - 1].y) {
        //   drawHandler.drawBackground();
        //   drawHandler.drawBorders();
        //   drawHandler.drawTitle(nextBlockValue);
        //   drawHandler.drawNextBlockHintText();
        //   drawHandler.drawNextBlock(nextBlockValue);
        //   drawHandler.drawTime(elapsedTime);
        //   if (!mute) {
        //     drawHandler.drawMusicButton();
        //   } else {
        //     drawHandler.drawMuteButton();
        //   }
        //   drawHandler.drawFiveCross();
        //   drawHandler.drawAllBlocks(blocks);

        //   drawHandler.drawScore(score);
        //   drawHandler.drawVerticalSuperPowerButton();
        //   drawHandler.drawHorizontalSuperPowerButton();
        //   if (!pause) {
        //     drawHandler.drawPauseButton();
        //   } else {
        //     drawHandler.drawPlayButton();
        //   }
        //   drawHandler.drawBlock(Block(old, blocks[x][y - 1].x, jj));
        //   jj += mergingSpeed;
        // }
        merge(x, y);
        merge(x, y - 1);
        merge(x, blocks[x].length - 1);
        return;
      }
    }
  }
  //void blockAppend(Canvas canvas) {
  //  double maxYAxis = (597 - 70 * blocks[currentTrack].length).toDouble();
  //  if (maxYAxis > 237) {
  //    Block block1 = Block(current, xAxis, maxYAxis);
  //    blocks[currentTrack].add(block1);
  //    merge(canvas, currentTrack, blocks[currentTrack].length - 1);
  //    getNewNextBlock();
  //    return;
  //  } else if (current ==
  //      blocks[currentTrack][blocks[currentTrack].length - 1].v) {
  //    Block block1 = Block(current, xAxis, maxYAxis);
  //    blocks[currentTrack].add(block1);
  //    merge(canvas, currentTrack, blocks[currentTrack].length - 1);
  //    getNewNextBlock();
  //    return;
  //  }
  //}

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
