import 'dart:math';
import 'dart:io';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'draw_handler.dart';
import 'block.dart';
import 'config.dart';
import 'merging_status.dart';
import 'superpower_status.dart';
import 'data_handler.dart';
import 'game_difficulty.dart';

class DropTheNumber extends Game with TapDetector {
  double volume = 0.5;
  double effectVolume = 0.5;
  GameDifficulty gameDifficulty = GameDifficulty.normal;

  /// Init screen only show once each time the game start
  bool gameInitScreenFinished = false;
  bool gameOver = false;
  bool gamePaused = true;
  bool muted = false;
  bool effectMuted = false;
  int score = 0;
  int highestScore = 0;
  // Store the screen size, the value will be set in resize() function.
  Size screenSize = Size(0.0, 0.0);
  // Calculated canvas size in the middle of screen.
  Size canvasSize_ = Size(0.0, 0.0); // debug! the name is conflict with Game.canvasSize
  // Left offset of the canvas
  double canvasXOffset = 0.0;
  // If the setting screen is open
  bool settingScreenIsOpen = false;
  // The track using by the dropping block.
  int currentTrack = 0;
  // Store the information of the dropping block.
  Block currentBlock = Block(0, 0.0, 0.0);
  // The value of next block.
  int nextBlockValue = 0;
  // The list which maximum is 5*7 to store all blocks information.
  List<List<Block>> blocks = [[], [], [], [], []];
  // The start time point of the game.
  DateTime startTime = DateTime.now();
  // The time elapsed of the game running from the start time.
  Duration elapsedTime = Duration.zero;
  // The time elapsed of the game pause.
  Duration pauseElapsedTime = Duration.zero;
  // Get the maximum track among the blocks

  /// The last time point that horizontal superpower used
  DateTime horizontalSuperpowerLastUsed = DateTime(0);
  /// The last time point that vertical superpower used
  DateTime verticalSuperpowerLastUsed = DateTime(0);
  bool lastLoopPaused = false;
  // Record the time stamp of pause
  DateTime startTimeOfPause = DateTime.now();
  // Record the duration of pause phase
  Duration pauseDuration = Duration.zero;
  Duration cdh = Duration.zero, cdv = Duration.zero;
  bool blockedHor = false, blockedVert = false;

  // Data handler can help to save and read data from file.
  DataHandler dataHandler;
  // A generator of random values, import from 'dart:math'.
  Random random = Random();
  // Draw handler for helping to draw everything on screen.
  DrawHandler drawHandler = DrawHandler();
  // Convert the absolute x to relative x.
  double toRelativeX(double x) => (x - canvasXOffset) * 100 / canvasSize_.width;
  // Convert the absolute y to relative y.
  double toRelativeY(double y) => y * 100 / canvasSize_.height;
  // Check if the number is within given lower boundary and upper boundary.
  bool inRange(double number, double lowerBoundary, double upperBoundary) =>
      number >= lowerBoundary && number <= upperBoundary;
  // Canvas cv;

  // first occurance of vertical superpower
  bool firstHorizontalOccurance = true;
  // first occurance of vertical superpower
  bool firstVerticalOccurance = true;

  /**********************************************************************
  * Constructor
  **********************************************************************/
  DropTheNumber(DataHandler dataHandler)
  :dataHandler = dataHandler,
  highestScore = dataHandler.readHighestScore(),
  gameDifficulty = dataHandler.readGameDifficulty(),
  muted = dataHandler.readMute(),
  volume = dataHandler.readVolume(),
  effectMuted = dataHandler.readEffectMute(),
  effectVolume = dataHandler.readEffectVolume() {

    FlameAudio.bgm.play("edm.mp3", volume: volume);
    if(muted) {
      FlameAudio.bgm.pause();
    }

    resetGame();
  }

  /**********************************************************************
  * Reset the game to initial state.
  **********************************************************************/
  void resetGame() {
    score = 0;
    gameOver = false;
    gamePaused = false;
    for (List lineOfBlocks in blocks) {
      lineOfBlocks.clear();
    }
    setGameDifficulty(gameDifficulty);
    pauseElapsedTime = Duration();
    startTime = DateTime.now();
    horizontalSuperpowerLastUsed = DateTime(0);
    verticalSuperpowerLastUsed = DateTime(0);

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
    drawHandler.setSize(screenSize, canvasSize_, canvasXOffset);

    // Draw start game screen.
    if (!gameInitScreenFinished) {
      drawHandler.drawStartPageScreen();
      if (!muted) {
        drawHandler.drawStartPageMusicButton();
      } else {
        drawHandler.drawStartPageMuteButton();
      }
    }
    // Draw game setting screen.
    else if (settingScreenIsOpen) {
      drawHandler.drawSettingScreen();
      drawHandler.drawGameDifficultyText(gameDifficulty);
      if (!muted) {
        drawHandler.drawSettingPageMusicButton();
      } else {
        drawHandler.drawSettingPageMuteButton();
      }
      if (!effectMuted) {
        drawHandler.drawSettingPageEffectMusicButton();
      } else {
        drawHandler.drawSettingPageEffectMuteButton();
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
      if (!gamePaused) {
        drawHandler.drawPauseButton();
      } else {
        drawHandler.drawPlayButton();
      }
      cdh = DateTime.now().difference(horizontalSuperpowerLastUsed);
      cdv = DateTime.now().difference(verticalSuperpowerLastUsed);
      // Horizontal cross while cooldown
      Duration superpowerCooldownTime = getSuperpowerCooldownTime(gameDifficulty);
      if (cdh < superpowerCooldownTime && !firstHorizontalOccurance) {
        blockedHor = true;
        // draw the cross

      } else if (!gamePaused || firstHorizontalOccurance) {
        blockedHor = false;
        firstHorizontalOccurance = false;
      }

      // Vertical cross while cooldown
      if (cdv < superpowerCooldownTime && !firstVerticalOccurance) {
        blockedVert = true;

        // draw the cross
      } else if (!gamePaused || firstVerticalOccurance) {
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

      // Update time
      if (lastLoopPaused != gamePaused) {
        if (gamePaused) {
          startTimeOfPause = DateTime.now();
        } else {
          pauseDuration = DateTime.now().difference(startTimeOfPause);
          horizontalSuperpowerLastUsed.add(pauseDuration);
          verticalSuperpowerLastUsed.add(pauseDuration);
        }
      }
      lastLoopPaused = gamePaused;
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

    if (!gamePaused && isGameRunning()) {
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
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    Size screenSize = Size(size.x, size.y);
    this.screenSize = screenSize;
    if (screenSize.width > screenSize.height * 2 / 3) {
      // canvasXOffset = (screenSize.width-screenSize.height*2/3)/2;
      canvasSize_ = Size(screenSize.height * 2 / 3, screenSize.height);
      canvasXOffset = (screenSize.width - canvasSize_.width) / 2;
    } else {
      canvasSize_ = screenSize;
      canvasXOffset = 0;
    }
  }

  /**********************************************************************
  * Print tap position (x,y) in screen ratio.
  * Range is (0.0, 0.0) to (100.0, 100.0).
  * Override from Game, which is from 'package:flame/game.dart'.
  **********************************************************************/
  @override
  void onTapDown(TapDownInfo event) {
    double x = toRelativeX(event.eventPosition.global.x);
    double y = toRelativeY(event.eventPosition.global.y);
    print("Tap down on (${x}, ${y})");
    // xAxis = event.globalPosition.dx;
    // yAxis = event.globalPosition.dy;

    // Game start
    if (!gameInitScreenFinished) {
      if (inRange(x, 32, 70) && inRange(y, 29, 37)) {
        gameInitScreenFinished = true;
        // Start game timer.
        startTime = DateTime.now();

        // Get history highest score from file.
//         dataHandler.readHighestScore().then((value) =>
//             highestScore = value > highestScore ? value : highestScore);
      }
      if (inRange(x, 87, 99) && inRange(y, 80, 88)) {
        increaseVolume();
        FlameAudio.bgm.audioPlayer.setVolume(volume);
        print(volume);
      }
      if (inRange(x, 87, 99) && inRange(y, 90, 98)) {
        decreaseVolume();
        FlameAudio.bgm.audioPlayer.setVolume(volume);
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
    else if (settingScreenIsOpen) {
      // Back button clicked
      if (inRange(x, 89, 98) && inRange(y, 3.5, 8.5)) {
        print("back button clicked"); // debug
        closeSettingScreen();
      }
      // Home button clicked
      else if (inRange(x, 4, 13) && inRange(y, 3.5, 8.5)) {
        gameInitScreenFinished = false;
        settingScreenIsOpen = false;
        resetGame();
        print("home button clicked!"); // debug
      }
      // Music Volume down button clicked
      else if (inRange(x, 69, 77) && inRange(y, 82, 88)) {
        decreaseVolume();
        FlameAudio.bgm.audioPlayer.setVolume(volume);
        print("bgm volume = ${volume}");
      }
      // Music Volume up button clicked
      else if (inRange(x, 83, 91) && inRange(y, 82, 88)) {
        increaseVolume();
        FlameAudio.bgm.audioPlayer.setVolume(volume);
        print("bgm volume = ${volume}");
      }
      // Music Mute button clicked
      else if (inRange(x, 54, 62) && inRange(y, 82, 87)) {
        toggleMute();
      }

      // Effect Volume down button clicked
      else if (inRange(x, 69, 77) && inRange(y, 90, 95)) {
        decreaseEffectVolume();
        print("effect volume = ${effectVolume}");
      }
      // Effect Volume up button clicked
      else if (inRange(x, 83, 92) && inRange(y, 90, 95)) {
        increaseEffectVolume();
        print("effect volume = ${effectVolume}");
      }
      // Effect Mute button clicked
      else if (inRange(x, 54, 62) && inRange(y, 90, 95)) {
        toggleEffectMute();
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
      Duration superpowerCooldownTime = getSuperpowerCooldownTime(gameDifficulty);

      // Setting button clicked.
      if (inRange(x, 80, 87) && inRange(y, 15, 19.5)) {
        print("setting button clicked");
        openSettingScreen();
      }
      // Pause button clicked.
      else if (inRange(x, 9, 19) && inRange(y, 92.5, 97.5)) {
        togglePause();
      } else if (gamePaused && inRange(x, 37, 63) && inRange(y, 42, 58)) {
        togglePause();
      }
      // If it is paused, ignore the click.
      else if (gamePaused) {
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
        if (firstHorizontalOccurance) {
          horizontalSuperpowerLastUsed = DateTime.now();
          triggerHorizontalSuperpower();
          print("Horizontal superpower clicked!"); // debug
          superpowerStatus = SuperpowerStatus.horizontalSuperpower;
          firstHorizontalOccurance;
        }

        Duration HorizontalSuperpowerWaitingTime = DateTime.now().difference(horizontalSuperpowerLastUsed);
        if (HorizontalSuperpowerWaitingTime > superpowerCooldownTime) {
          HorizontalSuperpowerWaitingTime = Duration.zero;
          horizontalSuperpowerLastUsed = DateTime.now();
          triggerHorizontalSuperpower();
          print("Horizontal superpower clicked!"); // debug
          superpowerStatus = SuperpowerStatus.horizontalSuperpower;
        }
      }
      // Vertical superpower clicked.
      else if (inRange(x, 80, 90) && inRange(y, 92.5, 97.5)) {
        if (firstVerticalOccurance) {
          verticalSuperpowerLastUsed = DateTime.now();
          print("Vertical superpower clicked!"); // debug
          firstVerticalOccurance = false;
          superpowerStatus = SuperpowerStatus.verticalSuperpower;
          triggerVerticalSuperpower();
        }

        Duration verticalSuperpowerWaitingTime = DateTime.now().difference(verticalSuperpowerLastUsed);
        if (verticalSuperpowerWaitingTime > superpowerCooldownTime) {
          verticalSuperpowerWaitingTime = Duration.zero;
          verticalSuperpowerLastUsed = DateTime.now();
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
        gameInitScreenFinished = false;
        print("Quit button clicked!"); // debug
        exit(0); // debug
      } else if (inRange(x, 2, 11) && inRange(y, 92, 99.5)) {
        resetGame();
        blocks = [[], [], [], [], []];
        gameInitScreenFinished = false;
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
  int verticalSuperpowerTrack = 0;
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
  Point<int> mergingBlock = Point(0, 0);

  void runMergingAnimation() {
    double mergingSpeed = getMergingSpeed(gameDifficulty);

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
            blocks[x - 1][y].value = 0;
            blocks[x + 1][y].value = 0;
            playBubbleAudio();
            playBubbleAudio();
          }
          // Merge step two
          else if (blocks[x][y].y + mergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += mergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].value = 0;
            playBubbleAudio();
          }
          // Merge done
          else {
            mergingStatus = MergingStatus.none;
            blocks[x][y - 1].value *= 8;
            addScore(blocks[x][y - 1].value);
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
            blocks[x + 1][y].value = 0;
            playBubbleAudio();
          }
          // Merge step two
          else if (blocks[x][y].y + mergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += mergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].value = 0;
            playBubbleAudio();
          }
          // Merge done
          else {
            mergingStatus = MergingStatus.none;
            blocks[x][y - 1].value *= 4;
            addScore(blocks[x][y - 1].value);
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
            blocks[x - 1][y].value = 0;
            playBubbleAudio();
          }
          // Merge step two
          else if (blocks[x][y].y + mergingSpeed < blocks[x][y - 1].y) {
            blocks[x][y].y += mergingSpeed;
          } else if (blocks[x][y].y != blocks[x][y - 1].y) {
            blocks[x][y].y = blocks[x][y - 1].y;
            // Set the value to zero, the drawHandler will not draw this block any more.
            blocks[x][y].value = 0;
            playBubbleAudio();
          }
          // Merge done
          else {
            mergingStatus = MergingStatus.none;
            blocks[x][y - 1].value *= 4;
            addScore(blocks[x][y - 1].value);
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
            blocks[x - 1][y].value = 0;
            blocks[x + 1][y].value = 0;
            playBubbleAudio();
            playBubbleAudio();
            // Merge done
          } else {
            mergingStatus = MergingStatus.none;
            blocks[x][y].value *= 4;
            addScore(blocks[x][y].value);
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
            blocks[x + 1][y].value = 0;
            playBubbleAudio();
            // Merge done
          } else {
            mergingStatus = MergingStatus.none;
            blocks[x][y].value *= 2;
            addScore(blocks[x][y].value);
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
            blocks[x - 1][y].value = 0;
            playBubbleAudio();
            //Merge done
          } else {
            mergingStatus = MergingStatus.none;
            blocks[x][y].value *= 2;
            addScore(blocks[x][y].value);
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
            blocks[x][y].value = 0;
            playBubbleAudio();
            // Merge done
          } else {
            mergingStatus = MergingStatus.none;
            blocks[x][y - 1].value *= 2;
            addScore(blocks[x][y - 1].value);
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
    double dropSpeed = getDropSpeed(gameDifficulty);
    // Height of every blocks
    double blockHeight = 9;
    // The highest y in the current track
    double currentTrackHighestSolidY =
        87 - blockHeight * blocks[currentTrack].length;
    // The bottom y of current block in the next round.
    double currentBlockBottomY =
        currentBlock.y + blockHeight + dropSpeed / 60;

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
        if (blocks[x][y].value == blocks[x - 1][y].value &&
            blocks[x][y].value == blocks[x + 1][y].value &&
            blocks[x][y].value == blocks[x][y - 1].value) {
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
        if (blocks[x][y].value == blocks[x + 1][y].value &&
            blocks[x][y].value == blocks[x][y - 1].value) {
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
        if (blocks[x][y].value == blocks[x - 1][y].value &&
            blocks[x][y].value == blocks[x][y - 1].value) {
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
        if (blocks[x][y].value == blocks[x - 1][y].value &&
            blocks[x][y].value == blocks[x + 1][y].value) {
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
        if (blocks[x][y].value == blocks[x + 1][y].value) {
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
        if (blocks[x][y].value == blocks[x - 1][y].value) {
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
      if (blocks[x][y].value == blocks[x][y - 1].value) {
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
      gamePaused = !gamePaused;
      if (!gamePaused) {
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
    gamePaused = true;
  }

  /**********************************************************************
  * Close the setting screen
  **********************************************************************/
  void closeSettingScreen() {
    settingScreenIsOpen = false;
    gamePaused = false;
  }

  /**********************************************************************
  * Toggle mute bgm.
  * If the bgm is running, it will be paused.
  * Also update the local storge setting file.
  **********************************************************************/
  void toggleMute() {
    muted = !muted;

    if (muted) {
      FlameAudio.bgm.pause();
    } else {
      FlameAudio.bgm.resume();
    }

    dataHandler.writeMute(muted);
  }

  /**********************************************************************
  * Toggle mute effect sound.
  * Also update the local storge setting file.
  **********************************************************************/
  void toggleEffectMute() {
    effectMuted = !effectMuted;

    dataHandler.writeEffectMute(effectMuted);
  }

  /**********************************************************************
  * If the game is started and not game over.
  **********************************************************************/
  bool isGameRunning() {
    if (gameInitScreenFinished && !gameOver) {
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

  void addScore(int score) {
    this.score += (score * getScoreMultiplier(gameDifficulty)).round();
  }

  void increaseVolume() {
    volume += 0.1;
    if(volume > 1.0) {
      volume = 1.0;
    }
    dataHandler.writeVolume(volume);
  }

  void decreaseVolume() {
    volume -= 0.1;
    if(volume < 0) {
      volume = 0.0;
    }
    dataHandler.writeVolume(volume);
  }

  void increaseEffectVolume() {
    effectVolume += 0.1;
    if(effectVolume > 1.0) {
      effectVolume = 1.0;
    }
    playBubbleAudio();
    dataHandler.writeEffectVolume(effectVolume);
  }

  void decreaseEffectVolume() {
    effectVolume -= 0.1;
    if(effectVolume < 0.0) {
      effectVolume = 0.0;
    }
    playBubbleAudio();
    dataHandler.writeEffectVolume(effectVolume);
  }

  void setGameDifficulty(GameDifficulty gameDifficulty) {
    this.gameDifficulty = gameDifficulty;
    dataHandler.writeGameDifficulty(gameDifficulty);
  }

  /// Randomly play one of a bubble audio.
  void playBubbleAudio() {
    if (!effectMuted) {
      FlameAudio.play('bubble' + random.nextInt(4).toString() + '.mp3',
          volume: effectVolume);
    }
  }

  /// Randomly play one of a append audio.
  void playAppendAudio() {
    if (!effectMuted) {
      FlameAudio.play('append' + random.nextInt(4).toString() + '.mp3',
          volume: effectVolume);
    }
  }
}
