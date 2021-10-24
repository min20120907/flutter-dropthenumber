// @dart=2.11
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sprintf/sprintf.dart';
import 'draw_handler.dart';
import 'block.dart';
import 'merging_status.dart';
import 'superpower_status.dart';
import 'data_handler.dart';
import 'game_difficulty.dart';

class DropTheNumber extends Game with TapDetector {
  /**********************************************************************
  * Settings
  **********************************************************************/
  // Y dropped for every second. (In percentage)
  Map<GameDifficulty, double> dropSpeed = {
    GameDifficulty.noob: 2,
    GameDifficulty.easy: 4,
    GameDifficulty.normal: 8,
    GameDifficulty.hard: 20,
  };

  // Merge animation speed (percentage of the map)
  Map<GameDifficulty, double> mergingSpeed = {
    GameDifficulty.noob: 2,
    GameDifficulty.easy: 2,
    GameDifficulty.normal: 2,
    GameDifficulty.hard: 2,
  };

  // The cooldown of the superpower
  Map<GameDifficulty, Duration> superpowerCooldown = {
    GameDifficulty.noob: Duration(seconds:10),
    GameDifficulty.easy: Duration(seconds:20),
    GameDifficulty.normal: Duration(seconds:30),
    GameDifficulty.hard: Duration(seconds:30),
  };

  // The default volume of the game (can be change by click on the volume adjust button)
  static double volume = 0.5;

  // The current difficulty of the game
  // wip: Temporary set to normal, it need to be set to the difficulty that the game leaved previous time.
  GameDifficulty gameDifficulty = GameDifficulty.normal;

  /**********************************************************************
  * Variables
  **********************************************************************/
  // Y dropped for every second. (In percentage)
  double currentDropSpeed; // debug
  // Merge animation speed (percentage of the map)
  double currentMergingSpeed;
  // The cooldown of the superpower
  Duration currentSuperpowerCooldown;
  // If the start page is showed, it only show once when the game start.
  bool startPageScreenFinished = false;
  // If the game is game over, waiting for restart.
  bool gameOver;
  // Store the screen size, the value will be set in resize() function.
  Size screenSize;
  // Calculated canvas size in the middle of screen.
  Size canvasSize;
  // Left offset of the canvas left.
  double canvasXOffset;
  // Check whether the icon is clicked
  bool volumeOn;
  // Check whether the icon is clicked
  bool volumeDown;
  // If the setting screen is open
  bool settingScreenIsOpen = false;
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
  int highestScore = 0;
  // The start time point of the game.
  DateTime startTime;
  // The time elapsed of the game running from the start time.
  Duration elapsedTime = Duration.zero;
  // The time elapsed of the game pause.
  Duration pauseElapsedTime = Duration.zero;
  // Get the maximum track among the blocks

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


  // Data handler can help to save and read data from file.
  DataHandler dataHandler = DataHandler();
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

  // first occurance of vertical superpower
  bool firstHorizontalOccurance = true;
  // first occurance of vertical superpower
  bool firstVerticalOccurance = true;

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
    gameOver = false;
    pause = false;
    for(List lineOfBlocks in blocks) {
      lineOfBlocks.clear();
    }
    setGameDifficulty(gameDifficulty);
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
    if (score >= 5000) {
      print("score is bigger than 5000");
      MAXPOWER = 6; // Temporary set to small number for debug
    } else if (score >= 10000) {
      print("score is bigger than 10000");
      MAXPOWER = 7; // Temporary set to small number for debug
    } else if (score >= 50000) {
      print("score is bigger than 50000");
      MAXPOWER = 8; // Temporary set to small number for debug
    } else if (score >= 100000) {
      print("score is bigger than 100000");
      MAXPOWER = 9; // Temporary set to small number for debug
    } else {
      MAXPOWER = 5;
    }
    // nextBlockValue = pow(2, random.nextInt(MAXPOWER) + POWEROFFSET).toInt();
    currentTrack = random.nextInt(5);
    print("max power: " + MAXPOWER.toString());
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

    // Draw start game screen.
    if (!startPageScreenFinished) {
      drawHandler.drawStartPageScreen();
      if (!mute) {
        drawHandler.drawStartPageMusicButton();
      } else {
        drawHandler.drawStartPageMuteButton();
      }
    }
    // Draw game setting screen.
    else if(settingScreenIsOpen) {
      drawHandler.drawSettingScreen();
      drawHandler.drawGameDifficultyText(gameDifficulty);
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
      drawHandler.drawSettingButton();
      // if (!mute) {
      //   drawHandler.drawMusicButton();
      // } else {
      //   drawHandler.drawMuteButton();
      // }
      drawHandler.drawFiveCross(nextBlockValue);
      drawHandler.drawAllBlocks(blocks);
      drawHandler.drawCurrentBlock(currentBlock);

      drawHandler.drawScore(score);
      drawHandler.drawVerticalSuperpowerButton();
      drawHandler.drawHorizontalSuperpowerButton();
      if (!pause) {
        drawHandler.drawPauseButton();
      } else {
        drawHandler.drawPlayButton();
      }
      cdh = DateTime.now().difference(cooldown_time_hor);
      cdv = DateTime.now().difference(cooldown_time_vert);
      // Horizontal cross while cooldown
      if (cdh < currentSuperpowerCooldown && cdh != null && !firstHorizontalOccurance) {
        blockedHor = true;
        // draw the cross

      } else if (!pause || firstHorizontalOccurance) {
        blockedHor = false;
        firstHorizontalOccurance = false;
      }

      // Vertical cross while cooldown
      if (cdv < currentSuperpowerCooldown && cdv != null && !firstVerticalOccurance) {
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

      // draw superpower animation
      if (superpowerStatus == SuperpowerStatus.horizontalSuperpower) {
        drawHandler.drawHorizontalSuperpowerAnimationImage(
            superpowerAnimationFrameIndex);
      } else if (superpowerStatus == SuperpowerStatus.verticalSuperpower) {
        drawHandler.drawVerticalSuperpowerAnimationImage(
            superpowerAnimationFrameIndex, verticalSuperpowerTrack);
      }

//       if (superHorBool) {
//         superHorBool = false;
//         return;
//       }
//       if (superVertBool) {
//         superVertBool = false;
//         return;
//       }
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
      // Update game time.
      elapsedTime = DateTime.now().difference(startTime) - pauseElapsedTime;

      // Check if it is using superpower.
      if (superpowerStatus != SuperpowerStatus.none) {
        runSuperpower();
        return;
      }

      // Check if it is merging.
      if (mergingStatus != MergingStatus.none) {
        runMergingAnimation();
        return;
      }

      // Drop block
      if (!dropCurrentBlock()) {
        // Hit solid block, current block cannot be drop any more!
        appendCurrentBlockToTrack();
        if (!gameOver) {
          merge(currentTrack, blocks[currentTrack].length - 1);
          setupCurrentBlock();
        }
      }
    }
  }

  /**********************************************************************
  * Super Horizontal Power
  **********************************************************************/
  void triggerHorizontalSuperpower() {
    superpowerStatus = SuperpowerStatus.horizontalSuperpower;
  }

  /**********************************************************************
  * Super Vertical Power
  **********************************************************************/
  void triggerVerticalSuperpower() {
    int highestTrack = getHighestTrack();
    // Used in runSuperpower().
    verticalSuperpowerTrack = highestTrack;
    print("highest track is " + highestTrack.toString());
    superpowerStatus = SuperpowerStatus.verticalSuperpower;
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
        // Start game timer.
        startTime = DateTime.now();

        // Get history highest score from file.
        dataHandler.readHighestScore().then((value) =>
            highestScore = value > highestScore ? value : highestScore);
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
      // main page quit button
      if (inRange(x, 2, 12) && inRange(y, 91, 98)) {
        exit(0);
      }
    }

    // game setting screen
    else if(settingScreenIsOpen) {
      // Back button clicked
      if(inRange(x, 89, 98) && inRange(y, 3.5, 8.5)) {
        print("back button clicked"); // debug
        closeSettingScreen();
      }
      // Home button clicked
      else if (inRange(x, 2, 11) && inRange(y, 92, 99.5)) {
        startPageScreenFinished = false;
        settingScreenIsOpen = false;
        resetGame();
        print("home button clicked!"); // debug
      }
      // Volume down button clicked
      else if (inRange(x, 87, 99) && inRange(y, 80, 88)) {
        if (volume < 1.0) volume += 0.1;
        Flame.bgm.audioPlayer.setVolume(volume);
        print(volume);
      }
      // Volume down button clicked
      else if (inRange(x, 87, 99) && inRange(y, 90, 98)) {
        if (volume > 0) volume -= 0.1;
        Flame.bgm.audioPlayer.setVolume(volume);
        print(volume);
      }
      // Mute button clicked
      else if (inRange(x, 87, 99) && inRange(y, 70, 78)) {
        toggleMute();
      }
      // Difficulty noob button click
      else if (inRange(x, 37, 62) && inRange(y, 31, 38)) {
        setGameDifficulty(GameDifficulty.noob);
      }
      // Difficulty easy button click
      else if (inRange(x, 36, 67) && inRange(y, 44, 52)) {
        setGameDifficulty(GameDifficulty.easy);
      }
      // Difficulty normal button click
      else if (inRange(x, 29, 76) && inRange(y, 56, 62)) {
        setGameDifficulty(GameDifficulty.normal);
      }
      // Difficulty hard button click
      else if (inRange(x, 35, 67) && inRange(y, 68, 75)) {
        setGameDifficulty(GameDifficulty.hard);
      }

    }

    // Game running
    else if (!gameOver) {
      // Setting button clicked.
      if (inRange(x, 80, 87) && inRange(y, 15, 19.5)) {
        print("setting button clicked");
        openSettingScreen();
      }
      // Pause button clicked.
      else if (inRange(x, 9, 19) && inRange(y, 92.5, 97.5)) {
        togglePause();
      } else if (pause && inRange(x, 37, 63) && inRange(y, 42, 58)) {
        togglePause();
      }
      // If it is paused, ignore the click.
      else if (pause) {
        return;
      }
      // If it is merging, ignore the click.
      else if (mergingStatus != MergingStatus.none) {
        return;
      }
      // If it is using superpower, ignore the click.
      else if (superpowerStatus != SuperpowerStatus.none) {
        return;
      }
      // Track clicked.
      else if (inRange(x, 15, 85) && inRange(y, 30, 87)) {
        if (mergingStatus == MergingStatus.none) {
          currentTrack = (x - 15) ~/ 14;
          print("Track " + currentTrack.toString() + " clicked!"); // debug
          appendCurrentBlockToTrack();
          setupCurrentBlock();
        }
      }
      // Horizontal superpower clicked.
      else if (inRange(x, 70, 79) && inRange(y, 92.5, 97.5)) {
        if (cooldown_time_hor == null || firstHorizontalOccurance) {
          cooldown_time_hor = DateTime.now();
          triggerHorizontalSuperpower();
          print("Horizontal superpower clicked!"); // debug
          superpowerStatus = SuperpowerStatus.horizontalSuperpower;
          firstHorizontalOccurance;
        }

        cool_down_hor = DateTime.now().difference(cooldown_time_hor);
        if (cool_down_hor > currentSuperpowerCooldown) {
          cool_down_hor = Duration.zero;
          cooldown_time_hor = DateTime.now();
          triggerHorizontalSuperpower();
          print("Horizontal superpower clicked!"); // debug
          superpowerStatus = SuperpowerStatus.horizontalSuperpower;
        }
      }
      // Vertical superpower clicked.
      else if (inRange(x, 80, 90) && inRange(y, 92.5, 97.5)) {
        if (cooldown_time_vert == null || firstVerticalOccurance) {
          cooldown_time_vert = DateTime.now();
          print("Vertical superpower clicked!"); // debug
          firstVerticalOccurance = false;
          superpowerStatus = SuperpowerStatus.verticalSuperpower;
          triggerVerticalSuperpower();
        }

        cool_down_vert = DateTime.now().difference(cooldown_time_vert);
        if (cool_down_vert > currentSuperpowerCooldown) {
          cool_down_vert = Duration.zero;
          cooldown_time_vert = DateTime.now();
          print("Vertical superpower clicked!"); // debug
          superpowerStatus = SuperpowerStatus.verticalSuperpower;
          triggerVerticalSuperpower();
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
  * Keep running the unfinish superpower animation.
  **********************************************************************/
  /* Setting */
  // Picture count of horizontal superpower Animation
  static const int horizontalSuperpowerAnimationLength = 15; // full is 215
  // Picture count of vertical superpower Animation
  static const int verticalSuperpowerAnimationLength = 15; // full is 67
  // Frames of each super power animation image stop for.
  int animationImageFrame = 2;

  /* Variable */
  // When it is using superpower, game logic should stop.
  SuperpowerStatus superpowerStatus = SuperpowerStatus.none;
  // The superpower animation frame index. (The animation is combine by lots of image)
  int superpowerAnimationFrameIndex = 0;
  // The highest track selected by triggerVerticalSuperpower().
  int verticalSuperpowerTrack;
  // Count the current animation image stop for how many frames.
  int animationImageFrameCounter = 0;

  void runSuperpower() {
    switch (superpowerStatus) {
      case SuperpowerStatus.horizontalSuperpower:
        {
          if (superpowerAnimationFrameIndex <=
              horizontalSuperpowerAnimationLength) {
//           drawHandler.drawHorizontalSuperpowerAnimationImage(superpowerAnimationFrameIndex);

            animationImageFrameCounter++;
            if (animationImageFrameCounter >= animationImageFrame) {
              animationImageFrameCounter = 0;
              superpowerAnimationFrameIndex++;
            }
          }
          if (superpowerAnimationFrameIndex >=
              horizontalSuperpowerAnimationLength) {
            superpowerStatus = SuperpowerStatus.none;
            superpowerAnimationFrameIndex = 0;

            for (int i = 0; i < 5; i++) {
              if (blocks[i].length > 0) {
                blocks[i].removeLast();
              }
            }
          }
          break;
        }

      case SuperpowerStatus.verticalSuperpower:
        {
          if (superpowerAnimationFrameIndex <=
              verticalSuperpowerAnimationLength) {
            animationImageFrameCounter++;
            if (animationImageFrameCounter >= animationImageFrame) {
              animationImageFrameCounter = 0;
              superpowerAnimationFrameIndex++;
            }
          }
          if (superpowerAnimationFrameIndex >=
              verticalSuperpowerAnimationLength) {
            superpowerStatus = SuperpowerStatus.none;
            superpowerAnimationFrameIndex = 0;

            blocks[verticalSuperpowerTrack].clear();
          }
          break;
        }

      default:
        {
          print(
              "Error! Unsupport support superpower animation running in runSuperpower(), skipped!");
          superpowerStatus = SuperpowerStatus.none;
          superpowerAnimationFrameIndex = 0;
          break;
        }
    }
  }

  /**********************************************************************
  * Keep running the unfinish merging animation.
  **********************************************************************/
  // When it is merging, game logic should stop.
  MergingStatus mergingStatus = MergingStatus.none;
  // The position of merging center block.
  Point mergingBlock;

  void runMergingAnimation() {
    int x = mergingBlock.x;
    int y = mergingBlock.y;
    switch (mergingStatus) {
      case MergingStatus.tShape:
        {
          // Merge step one
          if (blocks[x - 1][y].x + currentMergingSpeed < blocks[x][y].x) {
            blocks[x - 1][y].x += currentMergingSpeed;
            blocks[x + 1][y].x -= currentMergingSpeed;
          } else if (blocks[x - 1][y].x != blocks[x][y].x) {
            blocks[x - 1][y].x = blocks[x][y].x;
            blocks[x + 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw these block any more.
            blocks[x - 1][y].v = 0;
            blocks[x + 1][y].v = 0;
            playBubbleAudio();
            playBubbleAudio();
          }
          // Merge step two
          else if (blocks[x][y].y + currentMergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += currentMergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].v = 0;
            playBubbleAudio();
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
          if (blocks[x + 1][y].x - currentMergingSpeed > blocks[x][y].x) {
            blocks[x + 1][y].x -= currentMergingSpeed;
          } else if (blocks[x + 1][y].x != blocks[x][y].x) {
            blocks[x + 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x + 1][y].v = 0;
            playBubbleAudio();
          }
          // Merge step two
          else if (blocks[x][y].y + currentMergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += currentMergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].v = 0;
            playBubbleAudio();
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
          if (blocks[x - 1][y].x + currentMergingSpeed < blocks[x][y].x) {
            blocks[x - 1][y].x += currentMergingSpeed;
          } else if (blocks[x - 1][y].x != blocks[x][y].x) {
            blocks[x - 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x - 1][y].v = 0;
            playBubbleAudio();
          }
          // Merge step two
          else if (blocks[x][y].y + currentMergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += currentMergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].v = 0;
            playBubbleAudio();
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
          if (blocks[x - 1][y].x + currentMergingSpeed < blocks[x][y].x) {
            blocks[x - 1][y].x += currentMergingSpeed;
            blocks[x + 1][y].x -= currentMergingSpeed;
          } else if (blocks[x - 1][y].x != blocks[x][y].x) {
            blocks[x - 1][y].x = blocks[x][y].x;
            blocks[x + 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw these block any more.
            blocks[x - 1][y].v = 0;
            blocks[x + 1][y].v = 0;
            playBubbleAudio();
            playBubbleAudio();
            // Merge done
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
          if (blocks[x + 1][y].x - currentMergingSpeed > blocks[x][y].x) {
            blocks[x + 1][y].x -= currentMergingSpeed;
          } else if (blocks[x + 1][y].x != blocks[x][y].x) {
            blocks[x + 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x + 1][y].v = 0;
            playBubbleAudio();
            // Merge done
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
          if (blocks[x - 1][y].x + currentMergingSpeed < blocks[x][y].x) {
            blocks[x - 1][y].x += currentMergingSpeed;
          } else if (blocks[x - 1][y].x != blocks[x][y].x) {
            blocks[x - 1][y].x = blocks[x][y].x;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x - 1][y].v = 0;
            playBubbleAudio();
            //Merge done
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
          if (blocks[x][y].y + currentMergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += currentMergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].v = 0;
            playBubbleAudio();
            // Merge done
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
    double currentBlockBottomY = currentBlock.y + blockHeight + currentDropSpeed / 60;

    if (currentBlockBottomY < currentTrackHighestSolidY) {
      currentBlock.y += currentDropSpeed / 60;
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
    if (blocks[currentTrack].length > 6) {
      gameOver = true;
      if (score >= highestScore) {
        highestScore = score;
        dataHandler.writeHighestScore(highestScore);
      }
      return;
    }
    playAppendAudio();
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
  * Open the setting screen
  **********************************************************************/
  void openSettingScreen() {
    settingScreenIsOpen = true;
    pause = true;
  }

  /**********************************************************************
  * Close the setting screen
  **********************************************************************/
  void closeSettingScreen() {
    settingScreenIsOpen = false;
    pause = false;
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
    // The height of highest track.
    int highestTrackHeight = 0;
    // Count the most block quantity in the track which has the most blocks.
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].length > highestTrackHeight) {
        highestTrackHeight = blocks[i].length;
      }
    }
    // Record those tracks have the most block in a list.
    List<int> mostBlockTrackIndex = [];
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].length == highestTrackHeight) {
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

  /**********************************************************************
  * Set the difficulty of the game
  * It will change some other value like currentDropSpeed or currentSuperpowerCooldown
  **********************************************************************/
  void setGameDifficulty(GameDifficulty gameDifficulty) {
    this.gameDifficulty = gameDifficulty;
    currentDropSpeed = dropSpeed[gameDifficulty];
    currentMergingSpeed = mergingSpeed[gameDifficulty];
    currentSuperpowerCooldown = superpowerCooldown[gameDifficulty];
  }

  /**********************************************************************
  * Randomly play one of a bubble audio.
  **********************************************************************/
  void playBubbleAudio() {
    if (!mute) {
      Flame.audio.play('bubble' + random.nextInt(4).toString() + '.mp3',
          volume: volume);
    }
  }

  /**********************************************************************
  * Randomly play one of a append audio.
  **********************************************************************/
  void playAppendAudio() {
    if (!mute) {
      Flame.audio.play('append' + random.nextInt(4).toString() + '.mp3',
          volume: volume);
    }
  }
}
