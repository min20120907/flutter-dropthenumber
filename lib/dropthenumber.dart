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
import 'package:dropthenumber/drawhandler.dart';
import 'block.dart';
import 'mergingstatus.dart';

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
  // If the start page is showed, it only show once when the game start.
  bool startPageScreenFinished = false;
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
  static double volume = 0.5;
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
  Duration cooldown_period = Duration(seconds: 120);
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
  // ignore: non_constant_identifier_names
  bool LastLoopPaused = false;
  // Record the time stamp of pause
  DateTime startTimeOfPause = DateTime.now();
  // Record the duration of pause phase
  Duration pauseDuration = Duration.zero;
  Duration cdh, cdv;
  bool blockedHor = false, blockedVert = false;

  /* Merge animation */
  // Merge animation speed (percentage of the map)
  double mergingSpeed = 2;
  // When it is merging, game logic should stop
  MergingStatus mergingStatus = MergingStatus.none;
  // The position of merging center block.
  Point mergingBlock;

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
    //  else if (score >= 500) {
    //   MAXPOWER = 6; // Temporary set to small number for debug
    //   currentTrack = random.nextInt(MAXPOWER);
    //   currentBlock =
    //       Block(nextBlockValue, (15 + 14 * currentTrack).toDouble(), 30);
    //   nextBlockValue = pow(2, random.nextInt(MAXPOWER) + POWEROFFSET).toInt();
    // } else if (score >= 600) {
    //   MAXPOWER = 7; // Temporary set to small number for debug
    //   currentTrack = random.nextInt(MAXPOWER);
    //   currentBlock =
    //       Block(nextBlockValue, (15 + 14 * currentTrack).toDouble(), 30);
    //   nextBlockValue = pow(2, random.nextInt(MAXPOWER) + POWEROFFSET).toInt();
    // } else if (score >= 700) {
    //   MAXPOWER = 8; // Temporary set to small number for debug
    //   currentTrack = random.nextInt(MAXPOWER);
    //   currentBlock =
    //       Block(nextBlockValue, (15 + 14 * currentTrack).toDouble(), 30);
    //   nextBlockValue = pow(2, random.nextInt(MAXPOWER) + POWEROFFSET).toInt();
    // } else {
    //   // MAXPOWER = 5;
    //   currentTrack = random.nextInt(5);
    //   currentBlock =
    //       Block(nextBlockValue, (15 + 14 * currentTrack).toDouble(), 30);
    //   nextBlockValue = pow(2, random.nextInt(MAXPOWER) + POWEROFFSET).toInt();
    // }
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
    drawHandler.tryToInit();
    drawHandler.setCanvas(canvas);
    drawHandler.setSize(screenSize, canvasSize, canvasXOffset);
    // Draw start game screen. (It only show once when the game start)
    if (!startPageScreenFinished) {
      drawHandler.drawStartPageScreen();
      if (!mute) {
        drawHandler.drawStartPageMusicButton();
      } else {
        drawHandler.drawStartPageMuteButton();
      }
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
      if (mergingStatus == MergingStatus.none) {
        if (!dropCurrentBlock()) {
          // Hit solid block, current block cannot be drop any more!
          if (blocks[currentTrack].length < 6) {
            appendCurrentBlockToTrack();
            merge(currentTrack, blocks[currentTrack].length - 1);
            setupCurrentBlock();
          } else {
            // print(blocks[currentTrack].length);
            print("Game over!"); //debug
            this.gameOver = true;
          }
        }
      } else {
        runMergingAnimation();
      }
    }
  }

  /**********************************************************************
  * Super Horizontal Power
  **********************************************************************/
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
  * Super Vertical Power
  **********************************************************************/
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
    if (!startPageScreenFinished) {
      if (inRange(x, 32, 70) && inRange(y, 29, 37)) {
        startPageScreenFinished = true;
      }
      if (inRange(x, 87, 99) && inRange(y, 80, 88)) {
        if (volume < 1.0) volume += 0.1;
        Flame.bgm.audioPlayer.setVolume(volume);
        print(volume);
      }
      if (inRange(x, 87, 99) && inRange(y, 90, 98)) {
        if (volume > 0) volume -= 0.1;
        Flame.bgm.audioPlayer.setVolume(volume);
        print(volume);
      }
      if (inRange(x, 87, 99) && inRange(y, 70, 78)) {
        toggleMute();
      }
      if (inRange(x, 2, 12) && inRange(y, 91.3, 98.3)) {
        print(x);
      }
      // main page quit button
      if (inRange(x, 2, 12) && inRange(y, 91, 98)) {
        exit(0);
      }
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
        if (mergingStatus == MergingStatus.none) {
          currentTrack = (x - 15) ~/ 14;
          print("Track " + currentTrack.toString() + " clicked!"); // debug
          appendCurrentBlockToTrack();
          setupCurrentBlock();
        }
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
    }
    // Game over
    else {
      if (inRange(x, 21, 48) && inRange(y, 68.5, 74.5)) {
        print("Restart button clicked!"); // debug
        blocks = [[], [], [], [], []];
        resetGame();
      } else if (inRange(x, 53.5, 80.5) && inRange(y, 68.5, 74.5)) {
        startPageScreenFinished = false;
        print("Quit button clicked!"); // debug
        exit(0); // debug
      } else if (inRange(x, 2, 11) && inRange(y, 92, 99.5)) {
        resetGame();
        blocks = [[], [], [], [], []];
        startPageScreenFinished = false;
        print("home button clicked!"); // debug
      }
    }
  }

  /**********************************************************************
  * Keep running the unfinish merging animation.
  **********************************************************************/
  void runMergingAnimation() {
    int x = mergingBlock.x;
    int y = mergingBlock.y;
    switch (mergingStatus) {
      case MergingStatus.tShape:
        {
          // Merge step one
          if (blocks[x - 1][y].x + mergingSpeed < blocks[x][y].x) {
            blocks[x - 1][y].x += mergingSpeed;
            blocks[x + 1][y].x -= mergingSpeed;
          } else if (blocks[x - 1][y].x != blocks[x][y].x) {
            blocks[x - 1][y].x = blocks[x][y].x;
            blocks[x + 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw these block any more.
            blocks[x - 1][y].v = 0;
            blocks[x + 1][y].v = 0;
          }
          // Merge step two
          else if (blocks[x][y].y + mergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += mergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].v = 0;
          }
          // Merge done
          else {
            mergingStatus = MergingStatus.none;
            blocks[x][y - 1].v *= 8;
            score += blocks[x][y - 1].v;
            dropAboveBlocks(x - 1, y);
            dropAboveBlocks(x + 1, y);
            dropAboveBlocks(x, y);

            merge(x, y);
            merge(x, y - 1);
            merge(x - 1, y);
            merge(x + 1, y);
          }

          break;
        }

      case MergingStatus.gammaShape:
        {
          // Merge step one
          if (blocks[x + 1][y].x - mergingSpeed > blocks[x][y].x) {
            blocks[x + 1][y].x -= mergingSpeed;
          } else if (blocks[x + 1][y].x != blocks[x][y].x) {
            blocks[x + 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x + 1][y].v = 0;
          }
          // Merge step two
          else if (blocks[x][y].y + mergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += mergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].v = 0;
          }
          // Merge done
          else {
            mergingStatus = MergingStatus.none;
            blocks[x][y - 1].v *= 4;
            score += blocks[x][y - 1].v;
            dropAboveBlocks(x + 1, y);
            dropAboveBlocks(x, y);

            merge(x, y);
            merge(x, y - 1);
            merge(x + 1, y);
          }

          break;
        }

      case MergingStatus.sevenShape:
        {
          // Merge step one
          if (blocks[x - 1][y].x + mergingSpeed < blocks[x][y].x) {
            blocks[x - 1][y].x += mergingSpeed;
          } else if (blocks[x - 1][y].x != blocks[x][y].x) {
            blocks[x - 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x - 1][y].v = 0;
          }
          // Merge step two
          else if (blocks[x][y].y + mergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += mergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].v = 0;
          }
          // Merge done
          else {
            mergingStatus = MergingStatus.none;
            blocks[x][y - 1].v *= 4;
            score += blocks[x][y - 1].v;
            dropAboveBlocks(x - 1, y);
            dropAboveBlocks(x, y);

            merge(x, y);
            merge(x, y - 1);
            merge(x - 1, y);
          }

          break;
        }

      case MergingStatus.horizontalShape:
        {
          if (blocks[x - 1][y].x + mergingSpeed < blocks[x][y].x) {
            blocks[x - 1][y].x += mergingSpeed;
            blocks[x + 1][y].x -= mergingSpeed;
          } else if (blocks[x - 1][y].x != blocks[x][y].x) {
            blocks[x - 1][y].x = blocks[x][y].x;
            blocks[x + 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw these block any more.
            blocks[x - 1][y].v = 0;
            blocks[x + 1][y].v = 0;
          } else {
            mergingStatus = MergingStatus.none;
            blocks[x][y].v *= 4;
            score += blocks[x][y].v;
            dropAboveBlocks(x - 1, y);
            dropAboveBlocks(x + 1, y);

            merge(x, y);
            merge(x - 1, y);
            merge(x + 1, y);
          }
          break;
        }

      case MergingStatus.rightShape:
        {
          if (blocks[x + 1][y].x - mergingSpeed > blocks[x][y].x) {
            blocks[x + 1][y].x -= mergingSpeed;
          } else if (blocks[x + 1][y].x != blocks[x][y].x) {
            blocks[x + 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x + 1][y].v = 0;
          } else {
            mergingStatus = MergingStatus.none;
            blocks[x][y].v *= 2;
            score += blocks[x][y].v;
            dropAboveBlocks(x + 1, y);

            merge(x, y);
            merge(x + 1, y);
          }

          break;
        }

      case MergingStatus.leftShape:
        {
          if (blocks[x - 1][y].x + mergingSpeed < blocks[x][y].x) {
            blocks[x - 1][y].x += mergingSpeed;
          } else if (blocks[x - 1][y].x != blocks[x][y].x) {
            blocks[x - 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x - 1][y].v = 0;
          } else {
            mergingStatus = MergingStatus.none;
            blocks[x][y].v *= 2;
            score += blocks[x][y].v;
            dropAboveBlocks(x - 1, y);

            merge(x, y);
            merge(x - 1, y);
          }

          break;
        }

      case MergingStatus.downShape:
        {
          if (blocks[x][y].y + mergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += mergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].v = 0;
          } else {
            mergingStatus = MergingStatus.none;
            blocks[x][y - 1].v *= 2;
            score += blocks[x][y - 1].v;
            dropAboveBlocks(x, y);

            merge(x, y);
            merge(x, y - 1);
          }
          break;
        }

      default:
        {
          print(
              "Error! Undefine shape merging in runMergingAnimation(), skipped.");
          mergingStatus = MergingStatus.none;
          break;
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

  /**********************************************************************
  * Merge method
  **********************************************************************/
  void merge(int x, int y) {
    if (x < 0 || x > 5) return;
    if (y < 0 || blocks[x].length - 1 < y) return;
    print("merge (" + x.toString() + "," + y.toString() + ")"); // debug

    // Check left and right and down(T shape)
    if (x > 0 && x < 4 && y > 0) {
      int leftLineY = blocks[x - 1].length - 1;
      int rightLineY = blocks[x + 1].length - 1;
      if (leftLineY >= y && rightLineY >= y) {
        if (blocks[x][y].v == blocks[x - 1][y].v &&
            blocks[x][y].v == blocks[x + 1][y].v &&
            blocks[x][y].v == blocks[x][y - 1].v) {
          print("T shape"); // debug

          // Animation merge
          mergingStatus = MergingStatus.tShape;
          mergingBlock = Point(x, y);
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
          print("gamma shape"); // debug

          // Animation merge
          mergingStatus = MergingStatus.gammaShape;
          mergingBlock = Point(x, y);
          return;
        }
      }
    }
    // Check left and down(7 Shape)
    if (x > 0 && y > 0) {
      int leftLineY = blocks[x - 1].length - 1;
      if (leftLineY >= y) {
        if (blocks[x][y].v == blocks[x - 1][y].v &&
            blocks[x][y].v == blocks[x][y - 1].v) {
          print("seven shape"); // debug

          // Animation merge
          mergingStatus = MergingStatus.sevenShape;
          mergingBlock = Point(x, y);
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
          print("horizontal shape"); // debug

          // Animation merge
          mergingStatus = MergingStatus.horizontalShape;
          mergingBlock = Point(x, y);
          return;
        }
      }
    }
    // Check right
    if (x < 4) {
      int rightLineY = blocks[x + 1].length - 1;
      if (rightLineY >= y) {
        if (blocks[x][y].v == blocks[x + 1][y].v) {
          print("right shape"); // debug

          // Animation merge
          mergingStatus = MergingStatus.rightShape;
          mergingBlock = Point(x, y);
          return;
        }
      }
    }

    // Check left
    if (x > 0) {
      int leftLineY = blocks[x - 1].length - 1;
      if (leftLineY >= y) {
        if (blocks[x][y].v == blocks[x - 1][y].v) {
          print("left shape"); // debug

          // Animation merge
          mergingStatus = MergingStatus.leftShape;
          mergingBlock = Point(x, y);
          return;
        }
      }
    }

    // Check down
    if (y > 0) {
      if (blocks[x][y].v == blocks[x][y - 1].v) {
        print("down shape"); // debug

        // Animation merge
        mergingStatus = MergingStatus.downShape;
        mergingBlock = Point(x, y);
        return;
      }
    }
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
    if (startPageScreenFinished && !gameOver) {
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
  * The block which on the given position will be delete.
  * Block size is (14, 9).
  **********************************************************************/
  void dropAboveBlocks(int x, int y) {
    if (x < 0 && x >= blocks.length) {
      print("Error! Try to call dropAboveBlocks() with out of bound x index!");
      return;
    } else if (y < 0 && y >= blocks[x].length) {
      print("Error! Try to call dropAboveBlocks() with out of bound y index!");
      return;
    }
    if (blocks[x].length > 0) {
      print("Removal has been triggered"); // debug
      print(blocks[x].length); // debug
      blocks[x].removeAt(y);
      print(blocks[x].length); // debug
      for (int i = y; i < blocks[x].length; i++) {
        blocks[x][i].y += 9;
      }
      for (int i = y; i < blocks[x].length; i++) {
        merge(x, i);
      }
    }
  }
}
